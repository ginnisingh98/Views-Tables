--------------------------------------------------------
--  DDL for Package Body PQH_PSF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PSF_BUS" as
/* $Header: pqpsfbus.pkb 120.10.12010000.4 2009/05/13 12:28:50 sudsahu ship $ */
--
function POSITION_CONTROL_ENABLED(P_ORGANIZATION_ID NUMBER default null,
                                  p_effective_date in date default sysdate,
                                  p_assignment_id number default null) RETURN VARCHAR2 IS
--
l_return varchar2(100);
--
BEGIN
l_return := per_pqh_shr.POSITION_CONTROL_ENABLED(P_ORGANIZATION_ID => p_organization_id,
                                  p_effective_date => p_effective_date,
                                  p_assignment_id => p_assignment_id);
return l_return;
--
END;
--
--
--
function pos_assignments_exist(p_position_id number,
                    p_validation_start_date date, p_validation_end_date date)
                    return boolean is
l_dummy varchar2(10);
l_proc  varchar2(100):= 'PQH_PSF_BUS.POS_ASSIGNMENTS_EXIST';

cursor c1 is
select 'x'
from dual
where exists (
select null
from per_all_assignments_f asg, per_assignment_status_types ast
where asg.position_id = p_position_id
and asg.assignment_type in ('E', 'C','A') -- changes made for the bug 5680305
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN'
and ((asg.effective_start_date between p_validation_start_date
      and p_validation_end_date) or
      (asg.effective_end_date between p_validation_start_date
      and p_validation_end_date) or
      (asg.effective_start_date <= p_validation_start_date
      and effective_end_date >=p_validation_end_date))
);
begin
 hr_utility.set_location('Entering '||l_proc,10);
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
    close c1;
    hr_utility.set_location('Leaveing '||l_proc,11);
    return true;
  end if;
  close c1;
  hr_utility.set_location('Leaveing '||l_proc,12);
  return false;
end pos_assignments_exist;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------<   hr_psf_bus_insert_validate    >---------------------|
--  ---------------------------------------------------------------------------
--
procedure hr_psf_bus_insert_validate(p_rec 			 in hr_psf_shd.g_rec_type
     ,p_effective_date	       in date
     ) is
l_chk_position_job_grade        boolean;
l_transaction_status            varchar2(100);
--
cursor c_position_transaction(p_position_transaction_id number) is
select transaction_status
from pqh_position_transactions
where position_transaction_id = p_position_transaction_id;
--
begin
  null;
/*
  hr_utility.set_location('Check position is submitted for PC Org validation rule:', 630);
  --
  if p_rec.position_transaction_id is not null then
    open c_position_transaction(p_rec.position_transaction_id);
    fetch c_position_transaction into l_transaction_status;
    if (l_transaction_status <> 'SUBMITTED') then
      hr_utility.set_message(8302, 'PQH_NO_SUBMIT_CANT_CRE_POS');
      hr_utility.raise_error;
    end if;
  end if;
*/
  --
  --
end;
--
--  ---------------------------------------------------------------------------
--  |-----------------<   hr_psf_bus_update_validate    >---------------------|
--  ---------------------------------------------------------------------------
--
procedure hr_psf_bus_update_validate(p_rec in hr_psf_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
     ,p_datetrack_mode	       in varchar2
     ) is
--
--
l_chk_seasonal                  boolean;
l_chk_overlap			boolean;
l_permit_extended_pay           boolean;
l_chk_work_pay_term_dates       boolean;
l_chk_position_job_grade        boolean;
l_chk_earliest_hire_date	boolean;
l_chk_prop_date_for_layoff	boolean;
l_transaction_status            varchar2(100);
l_asg_max_count             number;
--
cursor c_position_transaction(p_position_transaction_id number) is
select transaction_status
from pqh_position_transactions
where position_transaction_id = p_position_transaction_id;
--
cursor c_asg_max_count(p_position_id number
    , p_validation_start_date date
    , p_validation_end_date date) is
select  max(pqh_psf_bus.sum_assignment_fte(p_position_id,ed))
from
(select a.effective_start_date ed
from per_all_assignments_f a
where a.position_id = p_position_id
and ((a.effective_start_date between p_validation_start_date and p_validation_end_date)
    and ((a.effective_end_date between p_validation_start_date and p_validation_end_date)
        ))
union
select  a.effective_end_date ed
from per_all_assignments_f a
where a.position_id = p_position_id
and ((a.effective_start_date between p_validation_start_date and p_validation_end_date)
    and ((a.effective_end_date between p_validation_start_date and p_validation_end_date)
        ))
union
select p_validation_start_date  ed
from dual
union
select p_validation_end_date ed
from dual);
--
begin
  --
/*
  if p_rec.position_transaction_id is not null then
    open c_position_transaction(p_rec.position_transaction_id);
    fetch c_position_transaction into l_transaction_status;
    if (l_transaction_status <> 'SUBMITTED') then
      hr_utility.set_message(8302, 'PQH_NO_SUBMIT_CANT_CRE_POS');
      hr_utility.raise_error;
    end if;
  end if;
*/
  --
  --
  --
  hr_utility.set_location('AVAILABILITY_STATUS_ID :'||p_rec.availability_status_id, 620);

  if ((p_datetrack_mode IN ('CORRECTION', 'UPDATE','UPDATE_CHANGE_INSERT',
       'UPDATE_OVERRIDE')) AND
      ('ELIMINATED'=hr_psf_shd.get_availability_status(
        p_rec.availability_status_id,p_rec.business_group_id))) then
    hr_utility.set_location('AVAILABILITY STATUS : ELIMINATED', 621);
    if (pqh_psf_bus.pos_assignments_exist(p_rec.position_id,
                         p_validation_start_date, p_validation_end_date)) then
      hr_utility.set_location('ASSIGNMENTS EXIST FOR ELIMINATED POSITION', 623);
      pqh_utility.set_message(800,'PER_POS_ELIMINATED',p_rec.organization_id);
      pqh_utility.raise_error;
    end if;
  end if;
  --
  --
  --
  hr_utility.set_location('Check FTE validation rule:', 630);
  --
  -- Check FTE Validation Rule
  --
  --
  hr_utility.set_location('p_validation_start_date:'||p_validation_start_date, 630);
  hr_utility.set_location('p_validation_end_date:'||p_validation_end_date, 630);
  --
 if (p_rec.position_type = 'SHARED') then
 --
  open c_asg_max_count(p_rec.position_id, p_validation_start_date, p_validation_end_date);
  fetch c_asg_max_count into l_asg_max_count;
  close c_asg_max_count;
  hr_utility.set_location('l_max_count:'||l_asg_max_count, 630);
  hr_utility.set_location('Position FTE:'||p_rec.fte, 630);
  if (l_asg_max_count > p_rec.fte)  then
    pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_FTE',p_rec.organization_id);
    pqh_utility.raise_error;
  end if;
  hr_utility.set_location('Check FTE validation rule:', 630);
 --
 end if;
  --
  hr_utility.set_location('Check Earliest hire date validation rule:', 640);
  --
  -- Check Earliest hire date validation rule
  --
  --
    l_chk_earliest_hire_date := pqh_psf_bus.chk_earliest_hire_date(
                        p_position_id => p_rec.position_id, p_earliest_hire_date => p_rec.earliest_hire_date );
    if (not l_chk_earliest_hire_date )  then
      pqh_utility.set_message(8302,'PQH_ASG_HIRED_BEFORE_EARLIEST',p_rec.organization_id);
      pqh_utility.raise_error;
    end if;
      hr_utility.set_location('Check Earliest hire date validation rule:', 640);
  --
  -- Check proposed date for layoff validation rule
  --
  --
    l_chk_prop_date_for_layoff := pqh_psf_bus.chk_prop_date_for_layoff(
                        p_position_id => p_rec.position_id, p_proposed_date_for_layoff => p_rec.proposed_date_for_layoff );
    if (not l_chk_prop_date_for_layoff )  then
      --pqh_utility.set_message(8302,'PQH_LAYOFF_DT_GT_ASG_DT',p_rec.organization_id);
      pqh_utility.set_message(8302,'PQH_ASG_DT_GT_LAYOFF_DT',p_rec.organization_id);
      pqh_utility.raise_error;
    end if;
      hr_utility.set_location('Check proposed date for layoff validation rule:', 650);
end;
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_insert_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_insert_validate(p_rec 	per_asg_shd.g_rec_type
      ,p_effective_date	       in date) IS
l_bgt_lt_abv_fte    boolean := false;
l_open_status               varchar2(30);
l_proposed_date_for_layoff  date;
l_rec                       hr_all_positions%rowtype;
l_fte_capacity              number(15,2);
l_sum				number(15,2);
l_bdgt				number(15,2);
l_available_fte number:=0;
l_person_fte      number:=0;
l_default_asg_fte number:=0;
l_chk_pos_budget  boolean;
l_overlap_dates_present boolean := false;
l_future_res_date   date;
l_asg_st_date	    date;
l_realloc           number;
l_bgt_realloc       number;

cursor c_position is
select *
from hr_all_positions
where position_id = p_rec.position_id;
--
cursor c_single_pos_future_asg(p_position_id number, p_effective_date date) is
select min(effective_start_date)
from per_all_assignments_f
where position_id = p_position_id
and effective_start_date > p_effective_date;
--
BEGIN
 hr_utility.set_location('Insert Validate: Before open Position', 100);
 if (p_rec.position_id is not null) then
  open c_position;
  hr_utility.set_location('Insert Validate: After open before fetch Position', 110);
  fetch c_position into l_rec;
  hr_utility.set_location('Insert Validate: After fetch Position', 120);
  if ( c_position%found) then
    close c_position;
    --
    -- Check for Assignment attached to a Seasonal Position is with in seasonal dates
    --
    hr_utility.set_location('Insert Validate: Before Seasonal Validation', 130);
    if l_rec.seasonal_flag = 'Y' then
      if not pqh_psf_bus.chk_seasonal_dates(
          p_position_id => p_rec.position_id,
          p_seasonal_flag => l_rec.seasonal_flag,
          p_assignment_start_date => p_effective_date) then
      pqh_utility.set_message(8302,'PQH_NON_SEASONAL_ASG_DATE',l_rec.organization_id);
      pqh_utility.raise_error;
      end if;
    end if;
    --
    -- Check whether Assignment Grade is same as Position Grade.
    --
    hr_utility.set_location('Insert Validate: Before Assignment Grade', 130);
    if p_rec.grade_id <> l_rec.entry_grade_id then
      pqh_utility.set_message(8302,'PQH_NON_POSITION_GRADE',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    --
    -- Check assignment start date to be greater than earliest hire date of the position
    --
    hr_utility.set_location('Insert Validate: greater than earliest hire date', 130);
    if p_rec.effective_start_date < l_rec.earliest_hire_date then
      pqh_utility.set_message(8302,'PQH_ASG_HIRED_BEFORE_EARLIEST',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    --
    -- Check whether assignment date is before proposed date for Layoff
    --
    hr_utility.set_location('Insert Validate: before proposed date for Layoff', 130);
    if (p_rec.effective_start_date > l_rec.proposed_date_for_layoff ) then
      pqh_utility.set_message(8302,'PQH_ASG_DT_GT_LAYOFF_DT',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    --
    -- Validate whether a SHARED position has FTE greater than the sum of the budgeted FTE's attached to the Position
    --
    hr_utility.set_location('Insert Validate: SHARED position has FTE greater than', 130);
    if (l_rec.position_type = 'SHARED')  then
      --
      l_default_asg_fte := pqh_psf_bus.default_assignment_fte(p_rec.business_group_id);
      --
      pqh_psf_bus.CHK_ABV_FTE_GT_POS_BGT_FTE(
         p_assignment_id       => p_rec.assignment_id,
         p_position_id         => p_rec.position_id,
         p_effective_date      => p_rec.effective_start_date,
         p_default_asg_fte     => l_default_asg_fte,
         p_bgt_lt_abv_fte      => l_bgt_lt_abv_fte
        );
      --
    elsif (l_rec.position_type = 'SINGLE')  then
        l_bgt_lt_abv_fte := false;
        l_default_asg_fte := 1;
    end if;
    --
    if not l_bgt_lt_abv_fte then
      hr_utility.set_location('l_default_asg_fte :'||l_default_asg_fte, 135);
      pqh_psf_bus.chk_future_pos_asg_fte(
           p_assignment_id         => p_rec.assignment_id,
           p_position_id           => p_rec.position_id,
           p_validation_start_date => p_rec.effective_start_date,
           p_validation_end_date   => hr_general.end_of_time,
           p_default_asg_fte       => l_default_asg_fte);
    end if;
    --
    --Check Insert allowed..
    --
   hr_utility.set_location('Insert Validate:Check Insert allowed', 130);
    if l_rec.position_type = 'POOLED'  then
      hr_utility.set_location('Insert Validate:POOLED', 130);
      if pqh_psf_bus.open_status(p_rec.position_id, p_rec.effective_start_date) = 'OPEN' then
        null;
      else
        pqh_utility.set_message(8302,'PQH_POOLED_POS_NOT_OPEN',l_rec.organization_id);
        pqh_utility.raise_error;
      end if;
      hr_utility.set_location('Insert Validate:END POOLED', 130);
    elsif l_rec.position_type = 'SINGLE' or l_rec.position_type = 'SHARED' then
      hr_utility.set_location('Insert Validate:SINGLE-SHARED', 130);
      if pqh_psf_bus.open_status(p_rec.position_id, p_rec.effective_start_date) = 'OPEN' then
        hr_utility.set_location('Insert Validate:OPEN', 130);
        if not l_bgt_lt_abv_fte then
          hr_utility.set_location('p_rec.business_group_id : '||p_rec.business_group_id, 131);
          if l_rec.position_type = 'SINGLE' then
            l_default_asg_fte := 1;
          else
            l_default_asg_fte := pqh_psf_bus.default_assignment_fte(p_rec.business_group_id);
          end if;
          hr_utility.set_location('l_default_asg_fte : '||l_default_asg_fte, 13);
          --
          if chk_reserved_fte(p_rec.assignment_id, p_rec.person_id,
                p_rec.position_id, l_rec.position_type,
                p_rec.effective_start_date, l_default_asg_fte) then
            pqh_psf_bus.reserved_error(p_rec.assignment_id,
                                       p_rec.person_id,
                                       p_rec.position_id,
                                       p_rec.effective_start_date,
                                       l_rec.organization_id,
                                       l_default_asg_fte);
            --hr_utility.set_location('POSITION RESERVED', 114);
            --pqh_utility.set_message(8302,'PQH_POS_RESERVED',l_rec.organization_id);
            --pqh_utility.raise_error;
          else
            l_future_res_date :=  chk_future_reserved_fte(p_rec.assignment_id, p_rec.person_id,
                     p_rec.position_id, l_rec.position_type,
                     p_rec.effective_start_date, hr_general.end_of_time, l_default_asg_fte);
            if l_future_res_date is not null then
              hr_utility.set_message(8302,'PQH_POS_FUTURE_RESERVED');
              hr_utility.set_message_token('FUTURE_RESERVED_DATE', l_future_res_date);
              pqh_utility.set_message_level_cd('W');
              pqh_utility.raise_error;
            end if;
          end if;
        end if;
      end if;
      hr_utility.set_location('Insert Validate:SINGLE-SHARED', 130);
    elsif (l_rec.position_type = 'NONE') then
      null;
    end if;
    --
/*
    hr_utility.set_location('Money Related Rule before chk_pos_budget', 135);
    l_chk_pos_budget := chk_pos_budget(p_rec.position_id, p_rec.effective_start_date);
    hr_utility.set_location('Money Related Rule after chk_pos_budget', 136);
    if not l_chk_pos_budget then
      hr_utility.set_location('Money Related Rule failed', 140);
      pqh_utility.set_message(8302,'PQH_SUM_ASG_AMT_GT_BGT_AMT',l_rec.organization_id);
      pqh_utility.raise_error;
    else
      hr_utility.set_location('Money Related Rule success', 140);
    end if;
*/
  else
    close c_position;
  end if;
 end if;
 --
 hr_utility.set_location('per_asg_insert_validate End',400);
END;
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_update_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_update_validate(p_rec 	per_asg_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode	       in varchar2 ) IS
l_bgt_lt_abv_fte	    boolean := false;
l_open_status               varchar2(30);
l_proposed_date_for_layoff  date;
l_rec                       hr_all_positions%rowtype;
l_asg			    per_all_assignments%rowtype;
l_fte_capacity              number(15,2);
l_sum                           number(15,2);
l_bdgt                          number(15,2);
l_available_fte number:=0;
l_assignment_fte number:=0;
l_overlap_dates_present boolean := false;
l_future_res_date   date;
l_asg_st_date       date;
l_realloc           number;
l_bgt_realloc       number;
l_default_asg_fte   number;

cursor c_position is
select *
from hr_all_positions
where position_id = p_rec.position_id;

cursor c_assignment is
select *
from per_all_assignments
where assignment_id = p_rec.assignment_id;
--
cursor c_single_pos_future_asg(p_position_id number, p_effective_date date) is
select min(effective_start_date)
from per_all_assignments_f
where position_id = p_position_id
and effective_start_date > p_effective_date;
--
BEGIN
  hr_utility.set_location('Entering Procedure PQH_PSF_BUS ', 100);
  hr_utility.set_location('p_validation_start_date '||p_validation_start_date, 101);
  hr_utility.set_location('p_validation_end_date '||p_validation_end_date, 101);
  hr_utility.set_location('p_effective_date '||p_effective_date, 101);
  hr_utility.set_location('p_datetrack_mode '||p_datetrack_mode, 101);

  open c_position;
  fetch c_position into l_rec;

  open c_assignment;
  fetch c_assignment into l_asg;

  if (c_position%found) then
    close c_position;
    --
    -- Check for Assignment attached to a Seasonal Position is with in seasonal dates
    --
    if p_rec.position_id <> nvl(l_asg.position_id, -999) then
    if l_rec.seasonal_flag = 'Y' then
      if not pqh_psf_bus.chk_seasonal_dates(
          p_position_id => p_rec.position_id,
          p_seasonal_flag => l_rec.seasonal_flag,
          p_assignment_start_date => p_validation_start_date) then

        pqh_utility.set_message(8302,'PQH_NON_SEASONAL_ASG_DATE',l_rec.organization_id);
        pqh_utility.raise_error;
      end if;
    end if;
    end if;
    --
    -- Check whether Assignment Grade is same as Position Grade.
    --
    if p_rec.position_id <> nvl(l_asg.position_id, -999) or p_rec.grade_id <> l_asg.grade_id then
    if p_rec.grade_id <> l_rec.entry_grade_id then
      pqh_utility.set_message(8302,'PQH_NON_POSITION_GRADE',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    end if;
    --
    -- Check assignment start date to be greater than earliest hire date of the position
    --
    if p_rec.position_id <> nvl(l_asg.position_id, -999) or p_validation_start_date <> l_asg.effective_start_date then
    if p_validation_start_date < l_rec.earliest_hire_date then
      pqh_utility.set_message(8302,'PQH_ASG_HIRED_BEFORE_EARLIEST',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    --
    -- Check whether assignment date is before proposed date for Layoff
    --
    if (p_validation_start_date > l_rec.proposed_date_for_layoff ) then
      pqh_utility.set_message(8302,'PQH_ASG_DT_GT_LAYOFF_DT',l_rec.organization_id);
      pqh_utility.raise_error;
    end if;
    end if;
    --
    -- Validate whether a SHARED position has FTE greater than the sum of the budgeted FTE's attached to the Position
    --
    --
    -- Validate whether a SHARED position has FTE greater than the sum of the budgeted FTE's attached to the Position
    --
    hr_utility.set_location('Insert Validate: SHARED position has FTE greater than', 130);
    if p_rec.position_id <> nvl(l_asg.position_id, -999) then
      if (l_rec.position_type = 'SHARED')  then
        --
        hr_utility.set_location('before l_overlap_dates_present ', 100);
        l_default_asg_fte := null;
           --pqh_psf_bus.default_assignment_fte(p_rec.business_group_id);
        --
        pqh_psf_bus.CHK_ABV_FTE_GT_POS_BGT_FTE(
           p_assignment_id       => p_rec.assignment_id,
           p_position_id         => p_rec.position_id,
           p_effective_date      => p_validation_start_date,
           p_default_asg_fte     => l_default_asg_fte,
           p_bgt_lt_abv_fte      => l_bgt_lt_abv_fte
          );
        --
      elsif (l_rec.position_type = 'SINGLE')  then
        l_bgt_lt_abv_fte := false;
        l_default_asg_fte := 1;
      end if;
      --
      if not l_bgt_lt_abv_fte then
          hr_utility.set_location('l_default_asg_fte :'||l_default_asg_fte, 135);
          pqh_psf_bus.chk_future_pos_asg_fte(
           p_assignment_id         => p_rec.assignment_id,
           p_position_id           => p_rec.position_id,
           p_validation_start_date => p_validation_start_date,
           p_validation_end_date   => hr_general.end_of_time,
           p_default_asg_fte       => l_default_asg_fte);
      end if;
      --
      hr_utility.set_location('after chk_future_pos_asg_fte ', 100);
      --
      if (l_rec.position_type = 'SHARED')  then
        --
        hr_utility.set_location('before PQH_FTE_NE_SHARED_POS_FTE_CAP ', 100);
        --
        l_assignment_fte := pqh_psf_bus.assignment_fte(p_rec.assignment_id, p_validation_start_date);
        if (l_rec.fte/l_rec.max_persons <> l_assignment_fte) then
          pqh_utility.set_message(8302,'PQH_FTE_NE_SHARED_POS_FTE_CAP',l_rec.organization_id);
          pqh_utility.raise_error;
        end if;
        --
        hr_utility.set_location('after PQH_FTE_NE_SHARED_POS_FTE_CAP ', 100);
        --
      end if;
      --
      --
      --Check Insert allowed..
      --
      if l_rec.position_type = 'POOLED'  then
        if pqh_psf_bus.open_status(l_rec.position_id, l_rec.effective_start_date) = 'OPEN' then
          null;
        else
          pqh_utility.set_message(8302,'PQH_POOLED_POS_NOT_OPEN',l_rec.organization_id);
          pqh_utility.raise_error;
        end if;
      elsif l_rec.position_type = 'SINGLE' or l_rec.position_type = 'SHARED' then
        hr_utility.set_location('SINGLE OR SHARED', 111);
        if pqh_psf_bus.open_status(l_rec.position_id, l_rec.effective_start_date) = 'OPEN' then
          hr_utility.set_location('OPEN', 112);
          if not l_bgt_lt_abv_fte then
            hr_utility.set_location('NOT l_bgt_lt_abv_fte ', 113);
            if chk_reserved_fte(p_rec.assignment_id, p_rec.person_id,
                  p_rec.position_id, l_rec.position_type,
                  p_validation_start_date) then
              pqh_psf_bus.reserved_error(p_rec.assignment_id,
                                       p_rec.person_id,
                                       p_rec.position_id,
                                       p_validation_start_date,
                                       l_rec.organization_id);

              --hr_utility.set_location('POSITION RESERVED', 114);
              --pqh_utility.set_message(8302,'PQH_POS_RESERVED',l_rec.organization_id);
              --pqh_utility.raise_error;
            else
              l_future_res_date :=  chk_future_reserved_fte(p_rec.assignment_id, p_rec.person_id,
                                          p_rec.position_id, l_rec.position_type,
                                          p_validation_start_date, hr_general.end_of_time);
              if l_future_res_date is not null then
                hr_utility.set_message(8302,'PQH_POS_FUTURE_RESERVED');
                hr_utility.set_message_token('FUTURE_RESERVED_DATE', l_future_res_date);
                pqh_utility.set_message_level_cd('W');
                pqh_utility.raise_error;
              end if;
            end if;
          end if;
        end if;
      elsif (l_rec.position_type = 'NONE') then
        null;
      end if;
    end if;
  else
    close c_position;
  end if;
  hr_utility.set_location('Exiting PQH_PSF_BUS', 130);
  --
END;
--
--  ---------------------------------------------------------------------------
--  |-----------------<   per_asg_bus_delete_validate    >--------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_asg_bus_delete_validate(p_rec 	per_asg_shd.g_rec_type
      ,p_effective_date	       in date
      ,p_validation_start_date in date
      ,p_validation_end_date    in date
      ,p_datetrack_mode	       in varchar2 ) IS
l_position_id  number;
l_organization_id   number;
l_fte number;
l_bgt_lt_abv_fte boolean;
l_bdgt  number;
l_sum   number;
l_sum1   number;
l_sum2   number;
l_overlap_period	number;
l_overlap_dates_present	boolean;
l_realloc           number;
l_bgt_realloc       number;
--
cursor c_changed_dates(p_position_id number,
p_validation_start_date date ,p_validation_end_date date) is
select effective_start_date, business_group_id
from per_all_assignments_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select effective_end_date, business_group_id
from per_all_assignments_f
where position_id = p_position_id
and effective_end_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date, abv.business_group_id
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
  and asg.position_id = p_position_id
  and abv.effective_start_date between p_validation_start_date and p_validation_end_date
  and asg.effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_end_date, abv.business_group_id
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
  and asg.position_id = p_position_id
  and abv.effective_end_date between p_validation_start_date and p_validation_end_date
  and asg.effective_end_date between p_validation_start_date and p_validation_end_date
union
select effective_start_date, business_group_id
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date;
--
cursor c_position_id(p_assignment_id number, p_effective_date date) is
select position_id
from per_all_assignments_f
where assignment_id = p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor c_position_fte(p_position_id number, p_date date) is
select overlap_period, fte, organization_id
from hr_all_positions_f
where position_id = p_position_id
  and p_date between effective_start_date and effective_end_date;
--
begin
  hr_utility.set_location('Entering pqh_asg_bus_delete_validate', 10);
  l_position_id := p_rec.position_id;
  hr_utility.set_location('l_position_id : ' || l_position_id,51);
  hr_utility.set_location('p_assignment_id : ' || p_rec.assignment_id,51);
  hr_utility.set_location('p_effective_date : ' || p_effective_date,51);
  hr_utility.set_location('p_validation_start_date : ' || p_validation_start_date,51);
  hr_utility.set_location('p_validation_end_date : ' || p_validation_end_date,51);
  hr_utility.set_location('p_datetrack_mode : ' || p_datetrack_mode,51);
  if l_position_id is null then
    open c_position_id(p_rec.assignment_id, p_effective_date);
    fetch c_position_id into l_position_id;
    close c_position_id;
  end if;
  hr_utility.set_location('l_position_id : ' || l_position_id,51);
  --
  if p_datetrack_mode in ('DELETE_NEXT_CHANGE', 'FUTURE_CHANGE') then
     for r1 in c_changed_dates(l_position_id, p_validation_start_date, p_validation_end_date)
     loop
        hr_utility.set_location('Effective Start Date : ' || r1.effective_start_date,50);
	--
	open c_position_fte(l_position_id, r1.effective_start_date);
	fetch c_position_fte into l_overlap_period,l_fte, l_organization_id;
	close c_position_fte;
        hr_utility.set_location('l_overlap_period : ' || l_overlap_period,51);
        --
        l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => l_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => r1.effective_start_date);
	--
        if not l_overlap_dates_present then
          --
          l_bdgt := budgeted_fte(l_position_id, r1.effective_start_date);
          --
          l_realloc := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => l_position_id
                ,p_start_date         => r1.effective_start_date
                ,p_end_date           => r1.effective_start_date
                ,p_effective_date     => r1.effective_start_date
                ,p_system_budget_unit =>'FTE'
                ,p_business_group_id  => r1.business_group_id
                );
          --
          --
          l_sum1 := pqh_psf_bus.sum_assignment_fte(l_position_id, r1.effective_start_date, p_rec.assignment_id);
          l_sum2 := pqh_psf_bus.assignment_fte(p_rec.assignment_id, r1.effective_start_date);
          l_sum := l_sum1 + l_sum2;
          --
          hr_utility.set_location('l_bdgt '||l_bdgt, 101);
          hr_utility.set_location('l_fte '||l_fte, 101);
          hr_utility.set_location('l_sum1'||l_sum1, 101);
          hr_utility.set_location('l_sum2'||l_sum2, 101);
          hr_utility.set_location('l_sum '||l_sum, 101);

          --
          if l_bdgt is not null or l_realloc is not null then
            l_bgt_realloc := nvl(l_bdgt,0) + nvl(l_realloc,0);
            --
            if l_bgt_realloc < l_sum then
              l_bgt_lt_abv_fte := true;
              pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_BGT_FTE',l_organization_id);
              pqh_utility.raise_error;
            end if;
          else
            --
            if l_fte < l_sum then
              l_bgt_lt_abv_fte := true;
              pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_FTE',l_organization_id);
              pqh_utility.raise_error;
            end if;
          end if;
        end if;
     end loop;
   end if;
   hr_utility.set_location('Exiting pqh_asg_bus_delete_validate', 400);
   --
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_insert_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_insert_validate(
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date) is
l_proc          varchar2(100) := 'per_abv_insert_validate';
l_position_id		 hr_all_positions_f.position_id%type;
l_fte		hr_all_positions_f.fte%type;
l_max_persons	hr_all_positions_f.max_persons%type;
l_position_type hr_all_positions_f.position_type%type;
l_organization_id number;
l_sum_abv            number:=0;
l_pos_budget_fte     number:=0;
l_person_id         number;
l_available_fte     number;
l_overlap_dates_present boolean := false;
l_overlap_period     number;
l_abv_gt_fte        boolean := false;
l_realloc           number;
l_bgt_realloc       number;
l_business_group_id number;
l_assignment_type   per_all_assignments_f.assignment_type%type; -- bug 7008697

cursor c_asg is
select paf.position_id, paf.person_id, paf.business_group_id, paf.assignment_type  -- bug 7008697
from per_all_assignments_f paf
where paf.assignment_id = p_assignment_id
and p_effective_date between paf.effective_start_date and paf.effective_end_date;

cursor c_positions is
select position_id, fte, max_persons, position_type, organization_id, overlap_period
from hr_all_positions_f psf
where position_id =
(select position_id
from per_all_assignments_f paf
where paf.assignment_id = p_assignment_id
and p_effective_date between paf.effective_start_date and paf.effective_end_date)
and p_effective_date between psf.effective_start_date and psf.effective_end_date;

cursor c_sum_abv (p_position_id number) is
select sum(value)
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and abv.unit in ('F', 'FTE')
and asg.assignment_type in ('E','C'); -- bug 7008697

begin
hr_utility.set_location('Entering Procedure '||l_proc, 100);
hr_utility.set_location('p_unit '||p_unit, 101);
hr_utility.set_location('p_assignment_id '||nvl(p_assignment_id,-1), 102);
hr_utility.set_location('p_effective_date '||p_effective_date, 102);
open c_asg;
fetch c_asg into l_position_id, l_person_id, l_business_group_id, l_assignment_type ; -- bug 7008697
close c_asg;
--

hr_utility.set_location('l_position_id '||nvl(l_position_id,-1), 103);
--
IF l_assignment_type IN ('C','E') THEN -- Bug 7008697
 if p_unit in ('FTE') then
  hr_utility.set_location('Unit is FTE:'||l_proc, 110);
  open c_positions;
  fetch c_positions into l_position_id, l_fte, l_max_persons,
  	l_position_type, l_organization_id, l_overlap_period;
  close c_positions;
  --
  hr_utility.set_location('Position : FTE, Head Count, Pos Type:'||
        l_fte||' - '||l_max_persons ||' - '||l_position_type, 120);
  --
  --
  if l_position_type in ('SINGLE', 'SHARED') then
    l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => l_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => p_effective_date);
    if not l_overlap_dates_present then
      --
      --Validate Position Budget values with sum of Assignment Budget Values
      --
      l_sum_abv := pqh_psf_bus.sum_assignment_fte(l_position_id, p_effective_date);
      --
      l_pos_budget_fte := budgeted_fte(l_position_id, p_effective_date);
      --
      l_realloc := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => l_position_id
                ,p_start_date         => p_effective_date
                ,p_end_date           => p_effective_date
                ,p_effective_date     => p_effective_date
                ,p_system_budget_unit =>'FTE'
                ,p_business_group_id  => l_business_group_id
                );
      --
      --
      hr_utility.set_location('FTE: l_sum_abv:'||l_sum_abv, 130);
      hr_utility.set_location('FTE: l_pos_budget_fte:'||l_pos_budget_fte, 140);
      hr_utility.set_location('FTE: l_realloc:'||l_realloc, 143);
      hr_utility.set_location('FTE: l_fte:'||l_fte, 145);
      hr_utility.set_location('FTE: p_value:'||p_value, 150);
      --
      if l_pos_budget_fte is not null or l_realloc is not null then
        l_bgt_realloc := nvl(l_pos_budget_fte,0) + nvl(l_realloc,0);
        --
        if (l_bgt_realloc < nvl(l_sum_abv,0)+ nvl(p_value,0)) then
          l_abv_gt_fte := true;
          ---Position Budget FTE is less than the sum of the assignment budget FTE
          pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_BGT_FTE',l_organization_id);
          pqh_utility.raise_error;
        end if;
      else
        if (l_fte < nvl(l_sum_abv,0)+ nvl(p_value,0)) then
          l_abv_gt_fte := true;
          ---Position FTE is less than the sum of the assignment budget FTE
          pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_FTE',l_organization_id);
          pqh_utility.raise_error;
        end if;
      end if;
      --
      if (not l_abv_gt_fte) and (l_position_type = 'SHARED') then
        --
        -- Check Reserved
        --
        hr_utility.set_location('Insert Validate:SINGLE-SHARED', 130);
        if pqh_psf_bus.open_status(l_position_id, p_effective_date) = 'OPEN' then
           hr_utility.set_location('Insert Validate:OPEN', 130);
           l_available_fte := pqh_psf_bus.available_fte(l_person_id, l_position_id, p_effective_date);
           hr_utility.set_location('l_available_fte : '||l_available_fte, 131);
           if (nvl(p_value,0) > l_available_fte) then
            pqh_psf_bus.reserved_error(p_assignment_id, l_person_id,
                                       l_position_id,
                                       p_effective_date,
                                       l_organization_id);
           end if;
        end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Position : FTE, Head Count, Pos Type:'||
        l_fte||' - '||l_max_persons ||' - '||l_position_type, 120);
  --
  if (l_position_type = 'SHARED') and (l_fte/l_max_persons <> p_value) then
      pqh_utility.set_message(8302,'PQH_FTE_NE_SHARED_POS_FTE_CAP',l_organization_id);
      pqh_utility.raise_error;
  end if;
 end if;
END IF ;  -- IF l_assignment_type IN ('C','E') THEN      -- bug 7008697
hr_utility.set_location('Exiting Procedure '||l_proc, 200);
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   per_abv_update_validate    >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE per_abv_update_validate(
		p_abv_id number,
		p_assignment_id number,
		p_value number,
		p_unit varchar2,
		p_effective_date date,
        p_validation_start_date date,
        p_validation_end_date  date,
        p_datetrack_mode    varchar2) is
l_proc              varchar2(100) := 'per_abv_update_validate';
l_position_id		 hr_all_positions_f.position_id%type;
l_fte		         hr_all_positions_f.fte%type;
l_max_persons	     hr_all_positions_f.max_persons%type;
l_position_type      hr_all_positions_f.position_type%type;
l_organization_id    number;
l_sum_abv            number;
l_pos_budget_fte     number;
l_person_id          number;
l_available_fte      number;
l_assignment_fte     number;
l_temp               number;
l_overlap_dates_present boolean := false;
l_overlap_period    number;
l_abv_gt_fte        boolean:=false;
l_realloc           number;
l_bgt_realloc       number;
l_business_group_id number;
l_assignment_type   per_all_assignments_f.assignment_type%type; -- bug 7008697
--
cursor c_asg(p_assignment_id number, p_effective_date date) is
select position_id, person_id, business_group_id, assignment_type
from per_all_assignments_f paf
where paf.assignment_id = p_assignment_id
and p_effective_date between paf.effective_start_date and paf.effective_end_date;
--
cursor c_positions(p_effective_date date) is
select position_id, fte, max_persons, position_type, organization_id, overlap_period
from hr_all_positions_f psf
where position_id =
(select position_id
from per_all_assignments_f paf
where paf.assignment_id = p_assignment_id
and p_effective_date between paf.effective_start_date and paf.effective_end_date)
and p_effective_date between psf.effective_start_date and psf.effective_end_date;

cursor c_sum_abv (p_position_id number,p_assignment_id number, p_effective_date date) is
select sum(value)
from per_assignment_budget_values_f abv, per_all_assignments_f asg,
per_assignment_status_types ast
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and abv.unit in ('FTE')
and asg.assignment_id <> nvl(p_assignment_id,-999)
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN'				-- Condition added for Bug 8309035
and asg.assignment_type in ('E','C'); -- bug 7008697

begin
hr_utility.set_location('Entering Procedure '||l_proc, 100);
hr_utility.set_location('p_effective_date '||p_effective_date, 100);
hr_utility.set_location('p_validation_start_date '||p_validation_start_date, 100);
hr_utility.set_location('p_validation_end_date '||p_validation_end_date, 100);
hr_utility.set_location('p_datetrack_mode '||p_datetrack_mode, 100);
hr_utility.set_location('p_unit '||p_unit, 100);
if p_unit in ('FTE') then
  open c_asg(p_assignment_id, p_effective_date);
 fetch c_asg into l_position_id, l_person_id, l_business_group_id, l_assignment_type;   -- Bug 7008697
 close c_asg;
  hr_utility.set_location('Unit is FTE:'||l_proc, 110);
  if l_assignment_type in ('C','E') then  -- Bug 7008697
  open c_positions(p_validation_start_date);
  fetch c_positions into l_position_id, l_fte, l_max_persons,
  	l_position_type, l_organization_id, l_overlap_period;
  hr_utility.set_location('Position : FTE, Head Count, Pos Type:'||
        l_fte||' - '||l_max_persons ||' - '||l_position_type, 120);
  if c_positions%found then
    close c_positions;
    hr_utility.set_location('c_positions found', 121);
    --
    if l_position_type in ('SINGLE', 'SHARED') then
      hr_utility.set_location('pos type SINGLE OR SHARED', 122);
      l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => l_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => p_effective_date);
      hr_utility.set_location('After chk_Overlap_dates', 123);
      if not l_overlap_dates_present then
        hr_utility.set_location('Overlap_dates not present', 124);
        --
        --Validate Position Budget values with sum of Assignment Budget Values
        open c_sum_abv(l_position_id,p_assignment_id, p_validation_start_date);
        fetch c_sum_abv into l_sum_abv;
        close c_sum_abv;
        --
        hr_utility.set_location('Before budgeted fte', 124);
        l_pos_budget_fte := budgeted_fte(l_position_id, p_validation_start_date);
        --
        l_realloc := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => l_position_id
                ,p_start_date         => p_validation_start_date
                ,p_end_date           => p_validation_start_date
                ,p_effective_date     => p_validation_start_date
                ,p_system_budget_unit =>'FTE'
                ,p_business_group_id  => l_business_group_id
                );
        --
        --
        --
        hr_utility.set_location('FTE: l_sum_abv:'||l_sum_abv, 130);
        hr_utility.set_location('FTE: l_pos_budget_fte:'||l_pos_budget_fte, 140);
        hr_utility.set_location('FTE: l_realloc:'||l_realloc, 143);
        hr_utility.set_location('FTE: l_fte:'||l_fte, 145);
        hr_utility.set_location('FTE: p_value:'||p_value, 150);
        --
        if l_pos_budget_fte is not null or l_realloc is not null then
          l_bgt_realloc := nvl(l_pos_budget_fte,0) + nvl(l_realloc,0);
          --
          hr_utility.set_location('l_pos_budget_fte is null', 151);
          if (l_bgt_realloc < nvl(l_sum_abv,0)+ nvl(p_value,0)) then
            hr_utility.set_location('PQH_SUM_ABV_FTE_GT_POS_BGT_FTE', 152);
            l_abv_gt_fte := true;
            ---Position Budget FTE is less than the sum of the assignment budget FTE
            pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_BGT_FTE' ,l_organization_id);
            pqh_utility.raise_error;
          end if;
        else
          if (l_fte < nvl(l_sum_abv,0)+ nvl(p_value,0)) then
            hr_utility.set_location('PQH_SUM_ABV_FTE_GT_POS_FTE :'||l_organization_id, 153);
            l_abv_gt_fte := true;
            ---Position FTE is less than the sum of the assignment budget FTE
            pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_FTE',l_organization_id);
            pqh_utility.raise_error;
          end if;
        end if;
        --
        hr_utility.set_location('Before check reserved', 154);
        --
        -- Check Reserved
        --
        if (not l_abv_gt_fte) and (l_position_type = 'SHARED') then
          hr_utility.set_location('Insert Validate:SINGLE-SHARED', 130);
          --if pqh_psf_bus.open_status(l_position_id, p_effective_date) = 'OPEN' then
            hr_utility.set_location('Insert Validate:OPEN', 130);
            l_available_fte := pqh_psf_bus.available_fte(l_person_id, l_position_id, p_effective_date);
            l_assignment_fte := nvl(pqh_psf_bus.assignment_fte(p_assignment_id, p_effective_date),0);
            hr_utility.set_location('l_available_fte : '||l_available_fte, 131);
            hr_utility.set_location('l_assignment_fte : '||l_assignment_fte, 133);
            l_temp :=  l_available_fte + l_assignment_fte ;
            if (nvl(p_value,0) > l_temp ) then
              pqh_psf_bus.reserved_error(p_assignment_id, l_person_id,
                                       l_position_id,
                                       p_effective_date,
                                       l_organization_id);

            end if;
          --end if;
        end if;
      end if;
    end if;
    --
    hr_utility.set_location('Before fte capacity', 155);
    --
    if (l_position_type = 'SHARED') and (l_fte/l_max_persons <> p_value) then
      hr_utility.set_location('PQH_FTE_NE_SHARED_POS_FTE_CAP', 156);
      pqh_utility.set_message(8302,'PQH_FTE_NE_SHARED_POS_FTE_CAP',l_organization_id);
      pqh_utility.raise_error;
    end if;
    --
    hr_utility.set_location('After fte capacity', 157);
    --
  end if;
 end if; -- if l_assignment_type in ('C','E') then  -- bug 7008697
end if;  -- p_unit in ('FTE') then
hr_utility.set_location('Exiting Procedure '||l_proc, 200);
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   funded_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the funded_status of the position.
--
function funded_status
         (p_position_id       in number) return varchar2 is
l_funded_status		varchar2(30);
begin
   l_funded_status := 'Y';
   return(l_funded_status);
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   sum_assignment_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the sum_assignment_fte of the position.
--    If for an assignment budget value does not exist or fte doesn't exist, it's treated as 1
--
function sum_assignment_fte
         (p_position_id       in number, p_effective_date  in date) return number is
l_assignment_fte	number(15,2):=0;
--
CURSOR c_budgeted_fte(p_position_id number) is
select sum(nvl(value,1))
from per_assignment_budget_values_f abv, per_all_assignments_f asn,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and p_effective_date between asn.effective_start_date and asn.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asn.position_id = p_position_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
--
begin
/*
 l_assignment_fte := pqh_utility.get_pos_budget_values(
                        p_position_id,p_effective_date,p_effective_date, 'FTE');
*/
  if p_position_id is not null then
     -- l_assignment_fte := 1;
     open c_budgeted_fte(p_position_id);
     fetch c_budgeted_fte into l_assignment_fte;
     close c_budgeted_fte;
   else
     l_assignment_fte := 0;
   end if;
   return(nvl(l_assignment_fte,0));
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   sum_assignment_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the sum_assignment_fte of the position.
--    If for an assignment budget value does not exist or fte doesn't exist, it's treated as 1
--    Overloaded to check if p_assignment_id is passed, it should be checked in the sql query.
--
function sum_assignment_fte
         (p_position_id       in number, p_effective_date  in date, p_assignment_id  in number) return number is
l_assignment_fte	number(15,2):=0;
--
CURSOR c_budgeted_fte(p_position_id number) is
select sum(nvl(value,1))
from per_assignment_budget_values_f abv, per_all_assignments_f asn,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and asn.assignment_id <> p_assignment_id
and p_effective_date between asn.effective_start_date and asn.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asn.position_id = p_position_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
--
begin
/*
 l_assignment_fte := pqh_utility.get_pos_budget_values(
                        p_position_id,p_effective_date,p_effective_date, 'FTE');
*/
  if p_position_id is not null then
     -- l_assignment_fte := 1;
     open c_budgeted_fte(p_position_id);
     fetch c_budgeted_fte into l_assignment_fte;
     close c_budgeted_fte;
   else
     l_assignment_fte := 0;
   end if;
   return(nvl(l_assignment_fte,0));
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   person_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the assignment_fte of the position.
--
function person_fte
         (p_person_id in number, p_position_id  in number, p_effective_date  in date, p_ex_assignment_id number) return number is
l_person_id         number;
l_assignment_fte	number(15,2):=0;
CURSOR c_budgeted_fte(p_person_id number, p_position_id number) is
select nvl(sum(nvl(value,1)),0)
from per_all_assignments_f asn,FND_SESSIONS SS,
per_assignment_budget_values_f abv, FND_SESSIONS SS2,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and SS.SESSION_ID = USERENV('sessionid')
and asn.EFFECTIVE_START_DATE <= SS.EFFECTIVE_DATE
and asn.EFFECTIVE_END_DATE >= SS.EFFECTIVE_DATE
and SS2.SESSION_ID(+) = USERENV('sessionid')
and abv.EFFECTIVE_START_DATE <= SS2.EFFECTIVE_DATE(+)
and abv.EFFECTIVE_END_DATE >= SS2.EFFECTIVE_DATE(+)
and asn.position_id = p_position_id
and asn.person_id = p_person_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';

CURSOR c_budgeted_fte_ex_asg(p_person_id number, p_position_id number, p_ex_assignment_id number) is
select nvl(sum(nvl(value,1)),0)
from per_all_assignments_f asn,FND_SESSIONS SS,
per_assignment_budget_values_f abv, FND_SESSIONS SS2,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and SS.SESSION_ID = USERENV('sessionid')
and asn.EFFECTIVE_START_DATE <= SS.EFFECTIVE_DATE
and asn.EFFECTIVE_END_DATE >= SS.EFFECTIVE_DATE
and SS2.SESSION_ID(+) = USERENV('sessionid')
and abv.EFFECTIVE_START_DATE <= SS2.EFFECTIVE_DATE(+)
and abv.EFFECTIVE_END_DATE >= SS2.EFFECTIVE_DATE(+)
and asn.position_id = p_position_id
and asn.person_id = p_person_id
and asn.assignment_id <> p_ex_assignment_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
begin
  if p_person_id is not null and p_position_id is not null and p_effective_date is not null then
     if p_ex_assignment_id is null then
       open c_budgeted_fte(p_person_id, p_position_id);
       fetch c_budgeted_fte into l_assignment_fte;
       hr_utility.set_location('l_person_id : '||l_person_id, 630);
       hr_utility.set_location('l_assignment_fte : '||l_assignment_fte, 630);
       close c_budgeted_fte;
     else
       open c_budgeted_fte_ex_asg(p_person_id, p_position_id, p_ex_assignment_id);
       fetch c_budgeted_fte_ex_asg into l_assignment_fte;
       hr_utility.set_location('l_person_id : '||l_person_id, 630);
       hr_utility.set_location('l_assignment_fte : '||l_assignment_fte, 630);
       close c_budgeted_fte_ex_asg;
     end if;
   end if;
   return(l_assignment_fte);
end;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------<   default_assignment_fte    >----------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the sum_assignment_fte of the position.
--
function default_assignment_fte
         (p_organization_id       in number) return number is
l_default_asg_fte	number(15,2):=0;
cursor c1 is
select to_number(org_information2,'99999999.99')
from hr_organization_information
where org_information_context like 'Budget Value Defaults'
and organization_id = p_organization_id
and org_information1='FTE';
begin
  open c1;
  fetch c1 into l_default_asg_fte;
  close c1;
  return l_default_asg_fte;
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   assignment_fte    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the assignment_fte of the position.
--
function assignment_fte
         (p_assignment_id       in number) return number is
l_assignment_fte	number(15,2);

CURSOR c_budgeted_fte(p_assignment_id number) is
select nvl(value,1)
from per_all_assignments_f asn,FND_SESSIONS SS,
per_assignment_budget_values_f abv, FND_SESSIONS SS2
where abv.assignment_id(+) = asn.assignment_id
and SS.SESSION_ID = USERENV('sessionid')
and asn.EFFECTIVE_START_DATE <= SS.EFFECTIVE_DATE
and asn.EFFECTIVE_END_DATE >= SS.EFFECTIVE_DATE
and SS2.SESSION_ID(+) = USERENV('sessionid')
and abv.EFFECTIVE_START_DATE <= SS2.EFFECTIVE_DATE(+)
and abv.EFFECTIVE_END_DATE >= SS2.EFFECTIVE_DATE(+)
and asn.assignment_id = p_assignment_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE';
begin
   if p_assignment_id is not null then
--     l_assignment_fte := 1;
     open c_budgeted_fte(p_assignment_id);
     fetch c_budgeted_fte into l_assignment_fte;
     close c_budgeted_fte;
--   else
--     l_assignment_fte := 0;
   end if;
   return(l_assignment_fte);
end;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------<   future approved actions    >-----------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the future approved actions of the position.
--
function future_approved_actions
         (p_position_id       in number) return varchar2 is
--
l_position_transaction_id number;
--
cursor c1 is
select position_transaction_id
from pqh_position_transactions
where position_id = nvl(p_position_id, -1)
and transaction_status in ('SUBMITTED','APPROVED');
--
begin
  --
  if p_position_id is not null then
    open c1;
    fetch c1 into l_position_transaction_id;
    if c1%found then
      close c1;
      return('Y');
    end if;
  end if;
  --
  return('N');
  --
end;
--
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   open_status    >-------------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the open_status of the position.
--
function open_status
         (p_position_id       in number, p_effective_date in date) return varchar2 is
l_open_status		     varchar2(30);
l_availability_status    varchar2(30);
l_business_group_id      number(15);
l_availability_status_id number(15);
l_position_type          varchar2(30);
l_pos_effective_date     date;
l_reserved_status        varchar2(30);
l_resrv_start_date       date;
l_resrv_end_date         date;
l_overlap_period         number(15,2);
l_overlap_start_date     date;
l_overlap_end_date       date;
l_resrv_person_id        number(15);
l_fte_reserved           number(15,2);
l_vacancy_status         varchar2(30);
l_funded_status          varchar2(30);

cursor c_positions is
select availability_status_id, business_group_id, position_type, date_effective
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
begin
   l_open_status := 'OPEN';
   open c_positions;
   fetch c_positions into
         l_availability_status_id,l_business_group_id, l_position_type, l_pos_effective_date;
   close c_positions;
   l_availability_status :=
       hr_psf_shd.get_availability_status(l_availability_status_id,l_business_group_id);
   hr_utility.set_location('Open Status- l_availability_status:'||l_availability_status,
                     310);
   hr_utility.set_location('Open Status- l_position_type:'||l_position_type,
                     320);
   l_funded_status := funded_status(p_position_id);
   --
   hr_utility.set_location('Open Status- l_funded_status:'||l_funded_status,
                     320);

   if (l_position_type in ( 'SINGLE', 'SHARED' )) then
     l_vacancy_status:= vacancy_status(p_position_id, p_effective_date);
     hr_utility.set_location('Open Status- l_vacancy_status:'||l_vacancy_status,
                     320);
     if (l_pos_effective_date <= p_effective_date)
        and ( l_availability_status = 'ACTIVE' )
        and ( l_funded_status = 'Y')
        and ( l_vacancy_status <> 'FILLED') then
        l_open_status := 'OPEN';
      else
        l_open_status := 'NOT_OPEN';
     end if;
   elsif (l_position_type in ( 'POOLED')) then
     if (l_pos_effective_date <= p_effective_date)
        and ( l_availability_status = 'ACTIVE' )
        and ( l_funded_status = 'Y') then
        l_open_status := 'OPEN';
      else
        l_open_status := 'NOT_OPEN';
     end if;
   end if;
   hr_utility.set_location('Open Status- l_open_status:'||l_open_status,
                     330);
/*
   reserved_status(p_position_id, l_reserved_status, l_resrv_start_date, l_resrv_end_date, l_resrv_person_id, l_fte_reserved);
   if (l_reserved_status in ( 'NEW_HIRE', 'MANAGEMENT_DISCRETION'))
      and (l_fte_reserved > 0 )
      and (p_effective_date between
        nvl(l_resrv_start_date, p_effective_date) and  nvl(l_resrv_end_date, p_effective_date)) then
        l_open_status := 'NOT_OPEN';
   end if;

   overlap_period(p_position_id, l_overlap_period, l_overlap_start_date, l_overlap_end_date);
   if (l_overlap_period > 0)
      and (p_effective_date between
        nvl(l_overlap_start_date, p_effective_date) and  nvl(l_resrv_end_date, l_overlap_end_date)) then
        l_open_status := 'OPEN';
   end if;
*/
   return(l_open_status);
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   overlap_period   >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the overlap_period of the position.
--
procedure overlap_period
         (p_position_id       in number, p_overlap_period out nocopy number,
                p_start_date out nocopy date, p_end_date out nocopy date)  is
l_overlap_period	varchar2(30);
l_overlap_unit_cd	varchar2(30);

cursor c1 is
select overlap_period, overlap_unit_cd
from hr_all_positions
where position_id = p_position_id;

cursor c2 is
select fnd_date.canonical_to_date(poei_information3), fnd_date.canonical_to_date(poei_information4)
from per_position_extra_info
where information_type = 'PER_OVERLAP'
      and position_id = p_position_id;

begin
   open c2;
   fetch c2 into p_start_date, p_end_date;
   close c2;

   open c1;
   fetch c1 into l_overlap_period, l_overlap_unit_cd;
   close c1;

   p_overlap_period := l_overlap_period;
exception when others then
p_overlap_period := null;
p_start_date := null;
p_end_date := null;
raise;

end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  reserved_status   >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the reserved_status of the position.
--    NEW_HIRE, TYPE_OF_LOA, PERSON_RESERVED_FOR, RESERVED_FTE, MANAGEMENT_DESCRETION
procedure reserved_status
         (p_position_id       in number, p_reserved_status out nocopy varchar2,
                p_start_date out nocopy date, p_end_date out nocopy date, p_person_id out nocopy number, p_fte_reserved out nocopy number)  is
l_reserved_status	varchar2(30);
l_fte_reserved      number(15,2);
l_person_id         number(15);

cursor c1 is
select fnd_date.canonical_to_date(poei_information3) poei_information3,
       nvl(fnd_date.canonical_to_date(poei_information4),
           hr_general.end_of_time) poei_information4,
       poei_information5, poei_information6, poei_information7
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_RESERVED';

begin
   open c1;
   fetch c1 into p_start_date, p_end_date, l_person_id, l_fte_reserved, l_reserved_status;
   close c1;

   p_reserved_status := l_reserved_status;
   p_person_id := l_person_id;
   p_fte_reserved := l_fte_reserved;
exception when others then
p_reserved_status := null;
p_start_date      := null;
p_end_date        := null;
p_person_id       := null;
p_fte_reserved    := null;
raise;
end reserved_status;

function chk_reserved(p_position_id number) return boolean is
l_reserved_status   varchar2(50);
l_start_date        date;
l_end_date          date;
l_person_id         number;
l_fte_reserved      number;
begin
  reserved_status
         (p_position_id , l_reserved_status ,
             l_start_date , l_end_date , l_person_id , l_fte_reserved );
  if l_reserved_status is not null then
     return true;
  end if;
     return false;
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   review_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the review_status of the position.
--
function review_status
         (p_position_id       in number) return varchar2 is
l_review_status		varchar2(30);
begin
   l_review_status := 'Y';
   return(l_review_status);
end;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<   vacancy_status    >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the vacancy_status of the position.
--    FILLED, PARTIALLY FILLED, VACANT
function vacancy_status
         (p_position_id       in number, p_effective_date  in  date) return varchar2 is
l_vacancy_status	varchar2(30);
l_position_type     varchar2(30);
l_fte               number(15,2);
l_budgeted_fte      number;
l_assignment_id     number(15);
l_sum_asg_fte       number;
--
CURSOR C1 IS
select position_type, FTE from hr_all_positions_f
where position_id = p_position_id
and p_effective_date
  between effective_start_date and effective_end_date;

CURSOR C_ASSIGNMENTS IS
select assignment_id
from per_all_assignments_f
where position_id = p_position_id
and p_effective_date
  between effective_start_date and effective_end_date
and assignment_type in ('E', 'C');
begin
   l_vacancy_status := 'VACANT';
   open c1;
   fetch c1 into l_position_type, l_fte;
   close c1;

   if (l_position_type = 'SINGLE') then
        open C_ASSIGNMENTS;
        fetch C_ASSIGNMENTS into l_assignment_id;
        if (C_ASSIGNMENTS%FOUND) then
          l_vacancy_status := 'FILLED';
        else
          l_vacancy_status := 'VACANT';
        end if;
        close C_ASSIGNMENTS;
        return(l_vacancy_status);
   elsif  (l_position_type = 'SHARED') then
        hr_utility.set_location('Shared',101);
        open C_ASSIGNMENTS;
        fetch C_ASSIGNMENTS into l_assignment_id;
        if (C_ASSIGNMENTS%NOTFOUND) then
          close C_ASSIGNMENTS;
          l_vacancy_status := 'VACANT';
          return(l_vacancy_status);
        else
          close C_ASSIGNMENTS;
          l_vacancy_status := 'FILLED';
          l_fte := pqh_psf_bus.get_position_fte(p_position_id, p_effective_date);
          l_sum_asg_fte := sum_assignment_fte(p_position_id, p_effective_date);
          hr_utility.set_location('l_fte' || l_fte,102);
          hr_utility.set_location('sum_asg_fte :' || l_sum_asg_fte,102);
          if l_fte is not null then
            if nvl(l_fte,0) > nvl(l_sum_asg_fte,0) then
            /*if nvl(l_fte,0) >
		pqh_bdgt_actual_cmmtmnt_pkg.get_pos_budget_values(
			p_position_id,p_effective_date,p_effective_date, 'FTE') then
	    */
              l_vacancy_status := 'PARTIALLY FILLED';
            else
              l_vacancy_status := 'FILLED';
            end if;
          else
            l_vacancy_status := 'VACANT';
          end if;
        end if;
   elsif (l_position_type = 'POOLED') then
      l_vacancy_status := 'VACANT';
   else
      l_vacancy_status := 'VACANT';
   end if;
--   l_vacancy_status:= 'FILLED';
   return(l_vacancy_status);
end;
--
function permit_extended_pay(p_position_id varchar2) return boolean is
l_position_family   varchar2(100);
l_chk               boolean := false;
cursor c1 is
select poei_information3
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_FAMILY'
and poei_information3 in ('ACADEMIC','FACULTY');
begin
  if p_position_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
      close c1;
      return true;
    else
      close c1;
      return false;
    end if;
  else
    return(false);
  end if;
end;
--
function permit_extended_pay_poi(p_rec in pe_poi_shd.g_rec_type) return boolean is
l_position_family   varchar2(100);
l_chk               boolean := false;
l_position_extra_info_id number := nvl(p_rec.position_extra_info_id,-1);
cursor c1 is
select poei_information3
from per_position_extra_info
where position_id = p_rec.position_id
and position_extra_info_id <> l_position_extra_info_id
and information_type = 'PER_FAMILY'
and poei_information3 in ('ACADEMIC','FACULTY');
begin
  if p_rec.position_id is not null then
    open c1;
    fetch c1 into l_position_family;
    if c1%found then
      close c1;
      return true;
    else
      close c1;
      return false;
    end if;
  else
    return(false);
  end if;
end;
--
--  ---------------------------------------------------------------------------
--  |----------------------<   chk_overlap_dates   >--------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Checks the overlap_dates of the position.
--
function chk_overlap_dates
         (p_position_id  in number, p_overlap_period  number, p_assignment_start_date date) return boolean is
l_dummy		    varchar2(30);
cursor c2 is
select 'x'
from per_position_extra_info
where p_assignment_start_date
      between fnd_date.canonical_to_date(poei_information3)
      and fnd_date.canonical_to_date(poei_information4)
      and position_id = p_position_id
      and information_type = 'PER_OVERLAP';
begin
   if p_overlap_period is not null
	and p_position_id is not null and p_assignment_start_date is not null then
    open c2;
    fetch c2 into l_dummy;
    if c2%found then
      close c2;
      return(true);
    else
      close c2;
      return(false);
    end if;
    close c2;
   end if;
   return(false);
end;
--
function chk_seasonal_dates( p_position_id number, p_seasonal_flag varchar2, p_assignment_start_date date)
return boolean is
l_f_season_start_date varchar2(20);
l_f_season_end_date   varchar2(20);
l_season_start_date varchar2(20);
l_season_end_date   varchar2(20);

cursor c1 is
select poei_information3,
       poei_information4
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_SEASONAL';

begin
  if nvl(p_seasonal_flag,'N')='Y' then
   if p_position_id is not null then
    open c1;
    loop
      fetch c1 into l_f_season_start_date, l_f_season_end_date;
      exit when (c1%notfound );
      --
      l_season_start_date := to_char(p_assignment_start_date,'RRRR')||substr(l_f_season_start_date,5,6);
      l_season_end_date := to_char(p_assignment_start_date,'RRRR')||substr(l_f_season_end_date,5,6);
      if to_date(l_season_end_date,'RRRR/MM/DD') < to_date(l_season_start_date,'RRRR/MM/DD') then
        if to_date(l_season_start_date,'RRRR/MM/DD') > p_assignment_start_date then
          l_season_start_date :=  substr(l_season_start_date,1,4)-1||substr(l_f_season_start_date,5,6);
        else
          l_season_end_date :=  substr(l_season_end_date,1,4)+1||substr(l_f_season_end_date,5,6);
        end if;
      end if;
      --
      if (p_assignment_start_date between to_date(l_season_start_date,'RRRR/MM/DD')
            and to_date(l_season_end_date,'RRRR/MM/DD')) then
        close c1;
        return(true);
      end if;
    end loop;
    close c1;
    end if;
    return(false);
  end if;
  return(true);
end;
--
function chk_seasonal(p_position_id number) return boolean is
l_dummy             varchar2(1);
cursor c_seasonal is
select 'X'
from hr_all_positions
where position_id = p_position_id
and seasonal_flag = 'Y';
begin
  open c_seasonal;
  fetch c_seasonal into l_dummy;
  close c_seasonal;
  if l_dummy is not null then
    return(true);
  end if;
  return(false);
end;
--
function chk_seasonal_poi(p_position_id number) return boolean is
l_dummy             varchar2(1);
l_position_id	number := nvl(p_position_id,-1);
cursor c_seasonal is
select 'X'
from per_position_extra_info
where position_id = l_position_id
and information_type = 'PER_SEASONAL';
begin
  open c_seasonal;
  fetch c_seasonal into l_dummy;
  if c_seasonal%notfound then
    close c_seasonal;
    return(true);
  end if;
  close c_seasonal;
  return(false);
end;
--
function chk_overlap_poi(p_position_id number) return boolean is
l_dummy             varchar2(1);
l_position_id   number := nvl(p_position_id,-1);
cursor c_overlap is
select 'X'
from per_position_extra_info
where position_id = l_position_id
and information_type = 'PER_OVERLAP';
begin
  open c_overlap;
  fetch c_overlap into l_dummy;
  if c_overlap%notfound then
    close c_overlap;
    return(true);
  end if;
  close c_overlap;
  return(false);
end;
--
function pos_assignments_exists(p_position_id number) return boolean is
l_dummy   varchar2(1);
cursor c1 is
select 'x'
from per_all_assignments
where position_id = p_position_id
and assignment_type in ('E', 'C');
begin
  open c1;
  fetch c1 into l_dummy;
  close c1;
  if l_dummy is not null then
     return(true);
  else
     return(false);
  end if;
end;
--
function chk_overlap(p_position_id number) return boolean is
l_dummy     varchar2(1);
cursor c1 is
select 'X'
from hr_all_positions
where position_id = p_position_id
and overlap_period is not null;
begin
  open c1;
  fetch c1 into l_dummy;
  close c1;
  if l_dummy is not null then
     return(true);
  else
     return(false);
  end if;
end;
--
function chk_amendment_info(
amendment_date date,
amendment_recommendation varchar2,
amendment_ref_number varchar2) return boolean is
begin
 if (amendment_date is null
    and amendment_recommendation is null
    and amendment_ref_number is null ) or
    (amendment_date is not null
    and amendment_recommendation is not null
    and amendment_ref_number is not null ) then
    return(true);
 else
    return(false);
 end if;
end;
--
--
--
function no_assignments(p_position_id number) return number is
l_count number(15);
cursor c1 is
select count(1)
from per_all_assignments
where position_id = p_position_id
and assignment_type in ('E', 'C');
begin
  open c1;
  fetch c1 into l_count;
  close c1;
  return l_count;
end;
--
--
--
function no_assignments(p_position_id number, p_effective_date date) return number is
l_count number(15);
--
cursor c1 is
select count(1)
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in  ('E', 'C')
and p_effective_date between effective_start_date and effective_end_date;
--
begin
  open c1;
  fetch c1 into l_count;
  close c1;
  return l_count;
end;
--
function max_persons(p_position_id number) return number is
l_max_persons  number(15,2);
cursor c1 is
select max_persons
from hr_all_positions
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_max_persons;
  close c1;
  return (l_max_persons);
end;
--
function proposed_date_for_layoff(p_position_id number) return date is
l_proposed_date_for_layoff date;
cursor c1 is
select proposed_date_for_layoff
from hr_all_positions_f
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_proposed_date_for_layoff;
  close c1;
  return(l_proposed_date_for_layoff);
end;
--
function fte_capacity(p_position_id number) return number is
l_fte_capacity number(15,2);
cursor c1 is
select fte/max_persons
from hr_all_positions
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_fte_capacity;
  close c1;
  return(l_fte_capacity);
end;
--
function position_type(p_position_id number) return varchar2 is
l_position_type varchar2(32);
cursor c1 is
select position_type
from hr_all_positions
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_position_type;
  close c1;
  return(l_position_type);
end;
--
function grade(p_position_id number) return number is
l_grade_id  number(15);
cursor c1 is
select entry_grade_id
from hr_all_positions
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_grade_id;
  close c1;
  return(l_grade_id);
end ;
--
function work_period_type_cd(p_position_id number) return varchar2 is
l_work_period_type_cd  varchar2(50);
cursor c1 is
select work_period_type_cd
from hr_all_positions
where position_id = p_position_id;
begin
  open c1;
  fetch c1 into l_work_period_type_cd;
  close c1;
  return(l_work_period_type_cd);
end ;
--
function chk_work_pay_term_dates(p_work_period_type_cd    hr_all_positions_f.work_period_type_cd%type
                                ,p_work_term_end_day_cd   hr_all_positions_f.work_term_end_day_cd%type
                                ,p_work_term_end_month_cd hr_all_positions_f.work_term_end_month_cd%type
                                ,p_pay_term_end_day_cd    hr_all_positions_f.pay_term_end_day_cd%type
                                ,p_pay_term_end_month_cd  hr_all_positions_f.pay_term_end_month_cd%type
                                ,p_term_start_day_cd      hr_all_positions_f.term_start_day_cd%type
                                ,p_term_start_month_cd    hr_all_positions_f.term_start_month_cd%type
                                ) return boolean is
begin
 if (p_work_period_type_cd = 'Y') then
    return(true);
 elsif (p_work_term_end_day_cd is null
        and p_work_term_end_month_cd is null
        and p_pay_term_end_day_cd is null
        and p_pay_term_end_month_cd is null
        and p_term_start_day_cd  is null
        and p_term_start_month_cd is null) then
     return(true);
  else
     return(false);
  end if;
end ;
--
function chk_position_job_grade(p_position_grade_id number, p_job_id number) return boolean is
l_dummy              varchar2(15);
l_chk_position_job_grade    boolean := false;
cursor c1 is
select 'x'
from per_valid_grades
where job_id = p_job_id
and grade_id = p_position_grade_id;
begin
  if (p_position_grade_id is not null) then
    open c1;
    hr_utility.set_location('Entering:'||'chk_position_job_grade', 10);
    fetch c1 into l_dummy;
    if c1%notfound then
       close c1;
       return(false);
    else
       close c1;
       return(true);
    end if;
  end if;
  return(true);
end ;
--
function position_min_asg_dt(p_position_id  number)  return date is
l_min_asg_date		date;
cursor c_min_asg_dt(p_position_id number) is
select min(effective_start_date)
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C');
begin
  open c_min_asg_dt(p_position_id );
  fetch c_min_asg_dt into l_min_asg_date;
  close c_min_asg_dt;
  return l_min_asg_date;
end;
--
function position_max_asg_dt(p_position_id  number)  return date is
l_max_asg_date		date;
cursor c_max_asg_dt(p_position_id number) is
select max(effective_start_date)
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C');
begin
  open c_max_asg_dt(p_position_id );
  fetch c_max_asg_dt into l_max_asg_date;
  close c_max_asg_dt;
  return l_max_asg_date;
end;
--
function chk_earliest_hire_date(p_position_id  number, p_earliest_hire_date date)
return boolean is
begin
  if (position_min_asg_dt(p_position_id) < p_earliest_hire_date) then
    return false;
  else
    return true;
  end if;
  return true;
end;
--
function chk_prop_date_for_layoff(p_position_id  number, p_proposed_date_for_layoff date)
return boolean is
begin
  if (position_max_asg_dt(p_position_id) >= p_proposed_date_for_layoff) then
    return false;
  else
    return true;
  end if;
  return true;
end;
--
function GET_SYSTEM_SHARED_TYPE(p_availability_status_id number)
return varchar2 is
cursor c1 is select system_type_cd
             from per_shared_types
             where shared_type_id = p_availability_status_id;
l_system_type varchar2(30);
begin
   open c1;
   fetch c1 into l_system_type;
   if c1%notfound then
      close c1;
      return null ;
   else
      close c1;
   end if;
   return l_system_type;
end;
--
function budgeted_fte (p_position_id in number,
                              p_effective_date in date) return number is

   l_calendar varchar2(200);
   l_budget_id number;
   l_budget_unit1_id number;
   l_budget_unit2_id number;
   l_budget_unit3_id number;
   l_unit1_name varchar2(200);
   l_unit2_name varchar2(200);
   l_unit3_name varchar2(200);
   l_budgeted_fte number;
   l_business_group_id number;
   --
   cursor c_bus_grp_id(p_position_id number) is
   select business_group_id
   from hr_all_positions_f
   where position_id = p_position_id;
   --
   cursor c1(p_unit_id number) is select system_type_cd from
       per_shared_types where shared_type_id = p_unit_id;
   cursor c2(p_budget_id number) is select bdt.budget_detail_id
                from  pqh_budget_details bdt,pqh_budget_versions bvr
                where bvr.budget_id = p_budget_id
                and p_effective_date between bvr.date_from and nvl(bvr.date_to,p_effective_date)
                and bdt.budget_version_id = bvr.budget_version_id
                and bdt.position_id = p_position_id;
   cursor c3(p_budget_detail_id number) is
                select bpr.budget_unit1_value, bpr.budget_unit2_value, bpr.budget_unit3_value
                from pqh_budget_periods bpr, per_time_periods tp_s,
			per_time_periods tp_e
                where bpr.budget_detail_id = p_budget_detail_id
                and tp_s.time_period_id = bpr.start_time_period_id
                and tp_e.time_period_id = bpr.end_time_period_id
                and tp_s.period_set_name = l_calendar
                and tp_e.period_set_name = l_calendar
                and p_effective_date between tp_s.start_date and tp_e.end_date;
begin
   begin
      open c_bus_grp_id(p_position_id);
      fetch c_bus_grp_id into l_business_group_id;
      close c_bus_grp_id;
      --
      hr_utility.set_location('l_business_group_id:' || l_business_group_id, 550
);

      select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
      into l_budget_id, l_budget_unit1_id, l_budget_unit2_id, l_budget_unit3_id, l_calendar
      from pqh_budgets
      where position_control_flag = 'Y'
      and budgeted_entity_cd = 'POSITION'
      and business_group_id = l_business_group_id
      and p_effective_date between budget_start_date and budget_end_date
      and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'FTE'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'FTE'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'FTE'
      );
      --
      hr_utility.set_location('l_budget_id:' || l_budget_id, 600);
      hr_utility.set_location('l_calendar:' || l_calendar, 600);
      hr_utility.set_location('l_budget_unit1_id:' || l_budget_unit1_id, 600);
      hr_utility.set_location('l_budget_unit2_id:' || l_budget_unit2_id, 600);
      hr_utility.set_location('l_budget_unit3_id:' || l_budget_unit3_id, 600);
      --
      open c1(l_budget_unit1_id);
      fetch c1 into l_unit1_name;
      close c1;
      open c1(l_budget_unit2_id);
      fetch c1 into l_unit2_name;
      close c1;
      open c1(l_budget_unit3_id);
      fetch c1 into l_unit3_name;
      close c1;
      hr_utility.set_location('l_unit1_name:' || l_unit1_name, 601);
      hr_utility.set_location('l_unit2_name:' || l_unit2_name, 601);
      hr_utility.set_location('l_unit3_name:' || l_unit3_name, 601);
  exception
    when others then
      hr_utility.set_location('Error: ' || SQLERRM, 602);
      return l_budgeted_fte;
  end;
      hr_utility.set_location('l_budget_id:' || l_budget_id, 602);
   for i in c2(l_budget_id) loop
       -- row corresponding to the position is picked up
       hr_utility.set_location('budget_detail_id:' || i.budget_detail_id, 603);
       --
       for j in c3(i.budget_detail_id) loop
           hr_utility.set_location('budget_unit1_value:' || j.budget_unit1_value, 604);
           if l_unit1_name ='FTE' then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit1_value,0);
           elsif l_unit2_name ='FTE' then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit2_value,0);
           elsif l_unit3_name ='FTE' then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit3_value,0);
           end if;
       end loop;
   end loop;
      hr_utility.set_location('l_budgeted_fte:' || l_budgeted_fte, 605);
   return l_budgeted_fte;
end;
--
-- Function to calculate position budgeted FTE/Headcount
--
function get_position_budgeted_fte( p_position_id 	 in number default null
		          ,p_budget_entity       in varchar2
		          ,p_start_date          in date default sysdate
		          ,p_end_date            in date default sysdate
	   	          ,p_unit_of_measure     in varchar2
	   	          ,p_business_group_id   in number
	   	          ,p_budgeted_fte_date   out nocopy date
		         ) return number is
--
l_budgeted_fte number;
--
cursor c_date is
select stp.start_date
  from pqh_budget_periods bper,
       pqh_budget_details bdet,
       per_time_periods stp,
       per_time_periods etp
 where bper.budget_detail_id = bdet.budget_detail_id
   and p_position_id = bdet.position_id
   and bper.start_time_period_id = stp.time_period_id
   and bper.end_time_period_id = etp.time_period_id
   and etp.end_date >= p_start_date
   and stp.start_date <= p_end_date
union
select effective_start_date start_date
  from per_all_assignments_f
 where p_position_id = position_id
   and assignment_type in ('E', 'C')
   and effective_start_date between p_start_date and p_end_date
union
select abv.effective_start_date start_date
  from per_assignment_budget_values_f abv, per_all_assignments_f asg
 where abv.assignment_id = asg.assignment_id
   and p_position_id = asg.position_id
   and asg.assignment_type in ('E', 'C')
   and abv.unit = 'FTE'
   and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
   and asg.effective_start_date between p_start_date and p_end_date;

Begin
  for l_date in c_date
  loop
    hr_utility.set_location('get_position_budgeted_fte' , 500);
    hr_utility.set_location('p_start_date' || p_start_date, 501);
    hr_utility.set_location('p_end_date' || p_end_date, 502);
    hr_utility.set_location('p_effective_date' || l_date.start_date, 503);

    l_budgeted_fte := budgeted_fte(p_position_id      =>  p_position_id
				  ,p_budget_entity    =>  p_budget_entity
				  ,p_effective_date   =>  l_date.start_date
				  ,p_unit_of_measure  =>  p_unit_of_measure
				  ,p_business_group_id => p_business_group_id);
    if l_budgeted_fte is not null then
      p_budgeted_fte_date := l_date.start_date;
      return (l_budgeted_fte);
    end if;
  end loop;
  hr_utility.set_location('get_position_budgeted_fte '
                       ||'l_budgeted_fte: ' || l_budgeted_fte, 605);
  hr_utility.set_location('get_position_budgeted_fte '
                       ||'p_budgeted_fte_date: ' || p_budgeted_fte_date, 606);
  return (l_budgeted_fte);
exception when others then
p_budgeted_fte_date := null;
raise;
End;
--
--
-- Function to calculate Job budgeted FTE/Headcount
--
function get_job_budgeted_fte(
	           p_job_id              in number default null
	          ,p_budget_entity       in varchar2
	          ,p_start_date          in date default sysdate
	          ,p_end_date            in date default sysdate
	          ,p_unit_of_measure     in varchar2
	          ,p_business_group_id   in number
	          ,p_budgeted_fte_date   out nocopy date
	         ) return number is

cursor c_date is
select stp.start_date
  from pqh_budget_periods bper,
       pqh_budget_details bdet,
       per_time_periods stp,
       per_time_periods etp
 where bper.budget_detail_id = bdet.budget_detail_id
   and p_job_id = bdet.job_id
   and bper.start_time_period_id = stp.time_period_id
   and bper.end_time_period_id = etp.time_period_id
   and etp.end_date >= p_start_date
   and stp.start_date <= p_end_date
union
select effective_start_date start_date
  from per_all_assignments_f
 where p_job_id = job_id
   and assignment_type in ('E', 'C')
   and effective_start_date between p_start_date and p_end_date
union
select abv.effective_start_date start_date
  from per_assignment_budget_values_f abv, per_all_assignments_f asg
 where abv.assignment_id = asg.assignment_id
   and p_job_id = asg.job_id
   and asg.assignment_type in ('E', 'C')
   and abv.unit = 'FTE'
   and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
   and asg.effective_start_date between p_start_date and p_end_date;

l_budgeted_fte number;
Begin
  for l_date in c_date
  loop
    hr_utility.set_location('get_job_budgeted_fte ', 500);
    hr_utility.set_location('p_start_date' || p_start_date, 501);
    hr_utility.set_location('p_end_date' || p_end_date, 502);
    hr_utility.set_location('p_effective_date' || l_date.start_date, 503);

    l_budgeted_fte := budgeted_fte(
				   p_job_id           =>  p_job_id
				  ,p_budget_entity    =>  p_budget_entity
				  ,p_effective_date   =>  l_date.start_date
				  ,p_unit_of_measure  =>  p_unit_of_measure
				  ,p_business_group_id => p_business_group_id);
    if l_budgeted_fte is not null then
      p_budgeted_fte_date := l_date.start_date;
      return (l_budgeted_fte);
    end if;
  end loop;
  hr_utility.set_location('get_job_budgeted_fte '||'l_budgeted_fte: ' || l_budgeted_fte, 605);
  hr_utility.set_location('get_job_budgeted_fte '||'p_budgeted_fte_date: ' || p_budgeted_fte_date, 606);
  return (l_budgeted_fte);
exception when others then
p_budgeted_fte_date := null;
raise;
End;
--
--
-- Function to calculate Organization budgeted FTE/Headcount
--
function get_org_budgeted_fte(
	           p_organization_id     in number default null
	          ,p_budget_entity       in varchar2
	          ,p_start_date          in date default sysdate
	          ,p_end_date            in date default sysdate
	          ,p_unit_of_measure     in varchar2
	          ,p_business_group_id   in number
	          ,p_budgeted_fte_date   out nocopy date
	         ) return number is

cursor c_date is

select stp.start_date
  from pqh_budget_periods bper,
       pqh_budget_details bdet,
       per_time_periods stp,
       per_time_periods etp
 where bper.budget_detail_id = bdet.budget_detail_id
   and p_organization_id = bdet.organization_id
   and bper.start_time_period_id = stp.time_period_id
   and bper.end_time_period_id = etp.time_period_id
   and etp.end_date >= p_start_date
   and stp.start_date <= p_end_date
union
select effective_start_date start_date
  from per_all_assignments_f
 where p_organization_id = organization_id
   and assignment_type in ('E', 'C')
   and effective_start_date between p_start_date and p_end_date
union
select abv.effective_start_date start_date
  from per_assignment_budget_values_f abv, per_all_assignments_f asg
 where abv.assignment_id = asg.assignment_id
   and p_organization_id = asg.organization_id
   and asg.assignment_type in ('E', 'C')
   and abv.unit = 'FTE'
   and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
   and asg.effective_start_date between p_start_date and p_end_date;

l_budgeted_fte number;
Begin
  for l_date in c_date
  loop
    hr_utility.set_location('get_org_budgeted_fte ', 500);
    hr_utility.set_location('p_start_date' || p_start_date, 501);
    hr_utility.set_location('p_end_date' || p_end_date, 502);
    hr_utility.set_location('p_effective_date' || l_date.start_date, 503);

    l_budgeted_fte := budgeted_fte(
				   p_organization_id  =>  p_organization_id
				  ,p_budget_entity    =>  p_budget_entity
				  ,p_effective_date   =>  l_date.start_date
				  ,p_unit_of_measure  =>  p_unit_of_measure
				  ,p_business_group_id => p_business_group_id);
    if l_budgeted_fte is not null then
      p_budgeted_fte_date := l_date.start_date;
      return (l_budgeted_fte);
    end if;
  end loop;
  hr_utility.set_location('get_org_budgeted_fte '
                ||'l_budgeted_fte: ' || l_budgeted_fte, 605);
  hr_utility.set_location('get_org_budgeted_fte '
                ||'p_budgeted_fte_date: ' || p_budgeted_fte_date, 606);
  return (l_budgeted_fte);
exception when others then
p_budgeted_fte_date := null;
raise;
End;
--
--
-- Function to calculate Grade budgeted FTE/Headcount
--
function get_grade_budgeted_fte(
		           p_grade_id    	       in number default null
		          ,p_budget_entity       in varchar2
		          ,p_start_date          in date default sysdate
		          ,p_end_date            in date default sysdate
 	          ,p_unit_of_measure     in varchar2
 	          ,p_business_group_id   in number
 	          ,p_budgeted_fte_date   out nocopy date
		         ) return number is

cursor c_date is
select stp.start_date
  from pqh_budget_periods bper,
       pqh_budget_details bdet,
       per_time_periods stp,
       per_time_periods etp
 where bper.budget_detail_id = bdet.budget_detail_id
   and p_grade_id = bdet.grade_id
   and bper.start_time_period_id = stp.time_period_id
   and bper.end_time_period_id = etp.time_period_id
   and etp.end_date >= p_start_date
   and stp.start_date <= p_end_date
union
select effective_start_date start_date
  from per_all_assignments_f
 where p_grade_id = grade_id
   and assignment_type in ('E', 'C')
   and effective_start_date between p_start_date and p_end_date
union
select abv.effective_start_date start_date
  from per_assignment_budget_values_f abv, per_all_assignments_f asg
 where abv.assignment_id = asg.assignment_id
   and p_grade_id = asg.grade_id
   and asg.assignment_type in ('E', 'C')
   and abv.unit = 'FTE'
   and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
   and asg.effective_start_date between p_start_date and p_end_date;

l_budgeted_fte number;
Begin
  for l_date in c_date
  loop
    hr_utility.set_location('p_start_date' || p_start_date, 500);
    hr_utility.set_location('p_end_date' || p_end_date, 500);
    hr_utility.set_location('p_effective_date' || l_date.start_date, 500);

    l_budgeted_fte := budgeted_fte(
				   p_grade_id         =>  p_grade_id
				  ,p_budget_entity    =>  p_budget_entity
				  ,p_effective_date   =>  l_date.start_date
				  ,p_unit_of_measure  =>  p_unit_of_measure
				  ,p_business_group_id => p_business_group_id);
    if l_budgeted_fte is not null then
      p_budgeted_fte_date := l_date.start_date;
      return (l_budgeted_fte);
    end if;
  end loop;
  hr_utility.set_location('get_grade_budgeted_fte '
                        ||'l_budgeted_fte: ' || l_budgeted_fte, 605);
  hr_utility.set_location('get_grade_budgeted_fte '
                        ||'p_budgeted_fte_date: ' || p_budgeted_fte_date, 606);
  return (l_budgeted_fte);
exception when others then
p_budgeted_fte_date := null;
raise;
End;
--
--
-- Function to calculate budgeted FTE/Headcount values for different entities
--
function get_budgeted_fte( p_position_id 	 in number default null
		          ,p_job_id         	 in number default null
		          ,p_grade_id    	 in number default null
		          ,p_organization_id     in number default null
		          ,p_budget_entity       in varchar2
		          ,p_start_date          in date default sysdate
		          ,p_end_date            in date default sysdate
	   	          ,p_unit_of_measure     in varchar2
	   	          ,p_business_group_id   in number
	   	          ,p_budgeted_fte_date   out nocopy date
		         ) return number is
l_budgeted_fte number;
Begin
  if (p_position_id is not null) then
    l_budgeted_fte := get_position_budgeted_fte(
                     p_position_id       => p_position_id
                    ,p_budget_entity     => p_budget_entity
                    ,p_start_date        => p_start_date
                    ,p_end_date          => p_end_date
                    ,p_unit_of_measure   => p_unit_of_measure
                    ,p_business_group_id => p_business_group_id
                    ,p_budgeted_fte_date => p_budgeted_fte_date);
  elsif (p_job_id is not null) then
    l_budgeted_fte := get_job_budgeted_fte(
                     p_job_id            => p_job_id
                    ,p_budget_entity     => p_budget_entity
                    ,p_start_date        => p_start_date
                    ,p_end_date          => p_end_date
                    ,p_unit_of_measure   => p_unit_of_measure
                    ,p_business_group_id => p_business_group_id
                    ,p_budgeted_fte_date => p_budgeted_fte_date);
  elsif (p_organization_id is not null) then
    l_budgeted_fte := get_org_budgeted_fte(
                     p_organization_id   => p_organization_id
                    ,p_budget_entity     => p_budget_entity
                    ,p_start_date        => p_start_date
                    ,p_end_date          => p_end_date
                    ,p_unit_of_measure   => p_unit_of_measure
                    ,p_business_group_id => p_business_group_id
                    ,p_budgeted_fte_date => p_budgeted_fte_date);
  elsif (p_grade_id is not null) then
    l_budgeted_fte := get_grade_budgeted_fte(
                     p_grade_id          => p_grade_id
                    ,p_budget_entity     => p_budget_entity
                    ,p_start_date        => p_start_date
                    ,p_end_date          => p_end_date
                    ,p_unit_of_measure   => p_unit_of_measure
                    ,p_business_group_id => p_business_group_id
                    ,p_budgeted_fte_date => p_budgeted_fte_date);

  end if;
  return (l_budgeted_fte);
exception when others then
p_budgeted_fte_date := null;
raise;
End;
--
--
-- Function to calculate budgeted FTE/Headcount values for different entities
--
function budgeted_fte( p_position_id 	     in number default null
		      ,p_job_id      	     in number default null
		      ,p_grade_id    	     in number default null
		      ,p_organization_id     in number default null
		      ,p_budget_entity       in varchar2
		      ,p_effective_date      in date default sysdate
	   	      ,p_unit_of_measure     in varchar2
	   	      ,p_business_group_id   in number
		      ) return number is


   l_calendar  varchar2(200);
   l_budget_id number;
   l_budget_unit1_id number;
   l_budget_unit2_id number;
   l_budget_unit3_id number;
   l_unit1_name varchar2(200);
   l_unit2_name varchar2(200);
   l_unit3_name varchar2(200);
   l_budgeted_fte number;

   cursor c1(p_unit_id number) is
	        select system_type_cd
		  from per_shared_types
		 where shared_type_id = p_unit_id;

   cursor c2(p_budget_id number) is
                select bdet.budget_detail_id
                  from pqh_budget_details bdet,pqh_budget_versions bvr
                 where bvr.budget_id = p_budget_id
                   and hr_general.effective_date between bvr.date_from and nvl(bvr.date_to,hr_general.effective_date)
                   and bdet.budget_version_id = bvr.budget_version_id
		   and nvl(p_organization_id, nvl(bdet.organization_id,  -1)) =
					      nvl(bdet.organization_id,  -1)
		   and nvl(p_job_id,          nvl(bdet.job_id,   -1)) =
					      nvl(bdet.job_id,   -1)
		   and nvl(p_position_id,     nvl(bdet.position_id,      -1)) =
					      nvl(bdet.position_id,      -1)
		   and nvl(p_grade_id,        nvl(bdet.grade_id,         -1)) =
					      nvl(bdet.grade_id,         -1);

   cursor c3(p_budget_detail_id number) is
                select bpr.budget_unit1_value, bpr.budget_unit2_value, bpr.budget_unit3_value
                  from pqh_budget_periods bpr, per_time_periods tp_s,
		       per_time_periods tp_e
                 where bpr.budget_detail_id = p_budget_detail_id
                   and tp_s.time_period_id = bpr.start_time_period_id
                   and tp_e.time_period_id = bpr.end_time_period_id
                   and tp_s.period_set_name = l_calendar
                   and tp_e.period_set_name = l_calendar
                   and p_effective_date between tp_s.start_date and tp_e.end_date;
begin
   begin

      select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
      into l_budget_id, l_budget_unit1_id, l_budget_unit2_id, l_budget_unit3_id, l_calendar
      from pqh_budgets
      where position_control_flag = 'Y'
      and budgeted_entity_cd = p_budget_entity
      and business_group_id = p_business_group_id
      and p_effective_date between budget_start_date and budget_end_date
      and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id)    = p_unit_of_measure
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = p_unit_of_measure
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = p_unit_of_measure
      );
      --
      hr_utility.set_location('p_effective_date' || p_effective_date, 600);
      hr_utility.set_location('l_budget_id:' || l_budget_id, 600);
      hr_utility.set_location('l_calendar:' || l_calendar, 600);
      hr_utility.set_location('l_budget_unit1_id:' || l_budget_unit1_id, 600);
      hr_utility.set_location('l_budget_unit2_id:' || l_budget_unit2_id, 600);
      hr_utility.set_location('l_budget_unit3_id:' || l_budget_unit3_id, 600);
      --
      open c1(l_budget_unit1_id);
      fetch c1 into l_unit1_name;
      close c1;
      open c1(l_budget_unit2_id);
      fetch c1 into l_unit2_name;
      close c1;
      open c1(l_budget_unit3_id);
      fetch c1 into l_unit3_name;
      close c1;
      hr_utility.set_location('l_unit1_name:' || l_unit1_name, 601);
      hr_utility.set_location('l_unit2_name:' || l_unit2_name, 601);
      hr_utility.set_location('l_unit3_name:' || l_unit3_name, 601);
  exception
    when others then
      hr_utility.set_location('Error: ' || SQLERRM, 602);
      return l_budgeted_fte;
  end;
      hr_utility.set_location('l_budget_id:' || l_budget_id, 602);
   for i in c2(l_budget_id) loop
       -- row corresponding to the position is picked up
       hr_utility.set_location('budget_detail_id:' || i.budget_detail_id, 603);
       --
       for j in c3(i.budget_detail_id) loop
           hr_utility.set_location('budget_unit1_value:' || j.budget_unit1_value, 604);
           if l_unit1_name = p_unit_of_measure then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit1_value,0);

           elsif l_unit2_name =  p_unit_of_measure then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit2_value,0);

           elsif l_unit3_name = p_unit_of_measure then
              l_budgeted_fte := nvl(l_budgeted_fte,0) + nvl(j.budget_unit3_value,0);

           end if;
       end loop;
   end loop;
      hr_utility.set_location('l_budgeted_fte:' || l_budgeted_fte, 605);
   return l_budgeted_fte;
end;
--
--
function reserved_fte(p_person_id number, p_position_id number, p_effective_date date) return number is
l_fte number:=0;
l_status varchar2(150);
cursor c1(p_person_id number, p_position_id number, p_effective_date date) is
select to_number(poei_information6,'99999999.99') fte
from per_position_extra_info
where p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
  and position_id = p_position_id
    and information_type= 'PER_RESERVED'
    and poei_information5 = p_person_id;
begin
  if p_person_id is not null and p_position_id is not null and p_effective_date is not null then
    open c1(p_person_id, p_position_id, p_effective_date);
    fetch c1 into l_fte;
    close c1;
  end if;
  return l_fte;
end;
--
function remain_reserved_fte(p_person_id number, p_position_id number, p_effective_date date) return number is
l_reserved_fte number;
l_person_fte number;
l_fte number:=0;
begin
  l_reserved_fte := reserved_fte(p_person_id, p_position_id, p_effective_date);
  l_person_fte := person_fte(p_person_id, p_position_id, p_effective_date,-1);
  if l_reserved_fte - l_person_fte > 0 then
    l_fte := l_reserved_fte - l_person_fte;
  end if;
  return l_fte;
end;
--
function unreserved_fte(p_position_id number, p_effective_date date) return number is
l_pos_fte number:=0;
l_fte number:=0;
l_status varchar2(150);
cursor c1(p_position_id number, p_effective_date date) is
select sum(to_number(poei_information6,'99999999.99')) fte
from per_position_extra_info
where p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
  and  position_id = p_position_id
    and information_type= 'PER_RESERVED';
--
begin
  if p_position_id is not null and p_effective_date is not null then
    --
    l_pos_fte := pqh_psf_bus.get_position_fte(p_position_id, p_effective_date);
    --
    open c1(p_position_id, p_effective_date);
    fetch c1 into l_fte;
    close c1;
  end if;
  hr_utility.set_location('l_pos_fte : '||l_pos_fte, 131);
  hr_utility.set_location('l_fte : '||l_fte, 131);
  if l_pos_fte - nvl(l_fte,0) >=0 then
    return l_pos_fte - nvl(l_fte,0);
  else
    return 0;
  end if;
end;
--
function used_unreserved_fte(p_person_id number, p_position_id number, p_effective_date date) return number is
l_uu_fte number := 0;
l_person_fte number;
l_reserved_fte number;
begin
    l_person_fte := pqh_psf_bus.person_fte(p_person_id, p_position_id, p_effective_date, -1);
    l_reserved_fte := pqh_psf_bus.reserved_fte(p_person_id, p_position_id, p_effective_date);
    hr_utility.set_location('uu: l_person_fte : '||l_person_fte, 131);
    hr_utility.set_location('uu: l_reserved_fte : '||l_reserved_fte, 131);
    if l_reserved_fte>0 and l_person_fte - l_reserved_fte > 0then
      l_uu_fte := l_person_fte - l_reserved_fte;
    end if;
    return l_uu_fte;
end;
--
--
function reserved_overused(p_position_id number, p_effective_date date) return number is
l_reserved_overused number := 0;
l_reserved_person_overused  number := 0;
cursor c1(p_position_id number, p_effective_date date) is
select poei_information5 person_id
from per_position_extra_info
where p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
  and position_id = p_position_id
  and poei_information5 is not null
    and information_type= 'PER_RESERVED';
begin
 if p_position_id is not null and p_effective_date is not null then
  for r1 in c1(p_position_id, p_effective_date)
  loop
    l_reserved_person_overused := used_unreserved_fte(r1.person_id, p_position_id, p_effective_date);
    l_reserved_overused := l_reserved_overused + l_reserved_person_overused;
  end loop;
 end if;
 return l_reserved_overused;
end;
--
-- This function is used for assignment cost defaulting and doesnot consider
-- default values
--
function assignment_fte(p_assignment_id number, p_effective_date date) return number is
l_fte number := 0;
cursor c1(p_assignment_id number, p_effective_date date) is
select nvl(abv.value,0)
from per_assignment_budget_values_f abv, per_all_assignments_f asg,
per_assignment_status_types ast
where asg.assignment_id = p_assignment_id
and abv.assignment_id = asg.assignment_id
and asg.assignment_type in ('E', 'C')
and abv.unit = 'FTE'
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asg.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
--
begin
  open c1(p_assignment_id, p_effective_date);
  fetch c1 into l_fte;
  close c1;
  return l_fte;
end;
--
--
function remain_unreserved_fte(p_position_id number, p_effective_date date) return number is
l_unreserved_fte number;
l_nonreserved_asg_fte number;
l_reserved_overused number;
l_uu_fte number := 0;
l_person_fte number;
l_reserved_fte number;
l_temp number;
begin
    l_unreserved_fte := unreserved_fte(p_position_id, p_effective_date);
    l_nonreserved_asg_fte := nonreserved_asg_fte(p_position_id, p_effective_date);
    l_reserved_overused := reserved_overused(p_position_id, p_effective_date);
    hr_utility.set_location('uu: l_person_fte : '||l_person_fte, 131);
    hr_utility.set_location('uu: l_reserved_fte : '||l_reserved_fte, 131);
    hr_utility.set_location('uu: l_reserved_overused : '||l_reserved_overused, 131);
    l_temp := ((l_unreserved_fte - l_nonreserved_asg_fte) - l_reserved_overused);
    if l_temp > 0then
      l_uu_fte := l_temp;
    end if;
    return l_uu_fte;
end;
--
function available_fte(p_person_id number, p_position_id number, p_effective_date date) return number is
l_remain_reserved_fte number;
l_remain_unreserved_fte number;
l_fte number:=0;
begin
  hr_utility.set_location('p_person_id : '||p_person_id, 131);
  hr_utility.set_location('p_position_id : '||p_position_id, 131);
  hr_utility.set_location('p_effective_date : '||p_effective_date, 131);
  if p_person_id is not null and p_position_id is not null and p_effective_date is not null then
    l_remain_reserved_fte := remain_reserved_fte(p_person_id, p_position_id, p_effective_date);
    l_remain_unreserved_fte := remain_unreserved_fte(p_position_id, p_effective_date);
    l_fte := l_remain_reserved_fte + l_remain_unreserved_fte;
    hr_utility.set_location('l_remain_reserved_fte : '||l_remain_reserved_fte, 131);
    hr_utility.set_location('l_remain_unreserved_fte : '||l_remain_unreserved_fte, 131);
    hr_utility.set_location('l_fte : '||l_fte, 131);
  end if;
  return l_fte;
end;
--
--
function budgeted_money (p_position_id in number,
                         p_effective_date in date) return number is

   l_calendar varchar2(200);
   l_budget_id number;
   l_budget_unit1_id number;
   l_budget_unit2_id number;
   l_budget_unit3_id number;
   l_unit1_name varchar2(200);
   l_unit2_name varchar2(200);
   l_unit3_name varchar2(200);
   l_budgeted_money number;
   l_business_group_id number;
   --
   cursor c_bus_grp_id(p_position_id number) is
   select business_group_id
   from hr_all_positions_f
   where position_id = p_position_id;
   --
   cursor c1(p_unit_id number) is select system_type_cd from
per_shared_types where shared_type_id = p_unit_id;
   cursor c2(p_budget_id number) is
                select bdt.budget_detail_id, bdt.budget_unit1_value, bdt.budget_unit2_value, bdt.budget_unit3_value
                from  pqh_budget_details bdt,pqh_budget_versions bvr
                where bvr.budget_id = p_budget_id
                and p_effective_date between bvr.date_from and nvl(bvr.date_to,p_effective_date)
                and bdt.budget_version_id = bvr.budget_version_id
                and bdt.position_id = p_position_id;
begin
   hr_utility.set_location('inside get_pos_budget',10);
   begin
      open c_bus_grp_id(p_position_id);
      fetch c_bus_grp_id into l_business_group_id;
      close c_bus_grp_id;
      --
      hr_utility.set_location('l_business_group_id:' || l_business_group_id, 20);
      --
      select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
      into l_budget_id, l_budget_unit1_id, l_budget_unit2_id, l_budget_unit3_id, l_calendar
      from pqh_budgets
      where position_control_flag = 'Y'
      and budgeted_entity_cd = 'POSITION'
      and business_group_id = l_business_group_id
      and p_effective_date between budget_start_date and budget_end_date
      and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
      );
      hr_utility.set_location('budget is:'||l_budget_id,30);
      open c1(l_budget_unit1_id);
      fetch c1 into l_unit1_name;
      close c1;
      hr_utility.set_location('unit1 is:'||l_unit1_name,40);
      open c1(l_budget_unit2_id);
      fetch c1 into l_unit2_name;
      close c1;
      hr_utility.set_location('unit2 is:'||l_unit2_name,50);
      open c1(l_budget_unit3_id);
      fetch c1 into l_unit3_name;
      close c1;
      hr_utility.set_location('unit3 is:'||l_unit3_name,60);
  exception
    when others then
      hr_utility.set_location('some error occured',65);
      return l_budgeted_money;
  end;
  for i in c2(l_budget_id) loop
      hr_utility.set_location('budget_detail_id:'||i.budget_detail_id, 80);
       -- row corresponding to the position is picked up
           if l_unit1_name ='MONEY' then
              l_budgeted_money := nvl(l_budgeted_money,0) + nvl(i.budget_unit1_value,0);
           elsif l_unit2_name ='MONEY' then
              l_budgeted_money := nvl(l_budgeted_money,0) + nvl(i.budget_unit2_value,0);
           elsif l_unit3_name ='MONEY' then
              l_budgeted_money := nvl(l_budgeted_money,0) + nvl(i.budget_unit3_value,0);
           end if;
           hr_utility.set_location('l_budgeted_money:'||l_budgeted_money, 90);
   end loop;
   hr_utility.set_location('total budgeted_money is:'||l_budgeted_money, 100);
   return l_budgeted_money;
exception
  when others then
    hr_utility.set_location('some error occured -2 ', 110);
    return l_budgeted_money;
end;
--
function get_pos_actuals_commitment(
                      p_position_id                  in number,
                      p_effective_date              in date,
                      p_ex_assignment_id            in number default -1
                      ) return number is
l_actual_commitment number := 0;
l_start_date    date;
l_end_date      date;
l_last_payroll_dt date;
l_budget_version_id number;
l_budget_id number;
l_budget_unit1_id number;
l_budget_unit2_id number;
l_budget_unit3_id number;
   l_unit1_name varchar2(200);
   l_unit2_name varchar2(200);
   l_unit3_name varchar2(200);
l_calendar      varchar2(200);
   l_business_group_id number;
   --
   cursor c_bus_grp_id(p_position_id number) is
   select business_group_id
   from hr_all_positions_f
   where position_id = p_position_id;
   --
   cursor c1(p_unit_id number) is select system_type_cd from
per_shared_types where shared_type_id = p_unit_id;
--
begin
   hr_utility.set_location('inside chk_pos_budget',10);
   hr_utility.set_location('position_id is '||p_position_id,20);
   hr_utility.set_location('effective_date is '||to_char(p_effective_date,'dd-MM-RRRR'),30);
   begin
      open c_bus_grp_id(p_position_id);
      fetch c_bus_grp_id into l_business_group_id;
      close c_bus_grp_id;
      --
      hr_utility.set_location('l_business_group_id:' || l_business_group_id,40);
      --
      select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
      , budget_start_date, budget_end_date
      into l_budget_id, l_budget_unit1_id, l_budget_unit2_id, l_budget_unit3_id, l_calendar
      ,l_start_date, l_end_date
      from pqh_budgets
      where position_control_flag = 'Y'
      and budgeted_entity_cd = 'POSITION'
      and business_group_id = l_business_group_id
      and p_effective_date between budget_start_date and budget_end_date
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
      );
      hr_utility.set_location('budget exists' || l_budget_id, 50);
      hr_utility.set_location('start_date is '||to_char(l_start_date,'dd-MM-RRRR'),55);
      hr_utility.set_location('end_date is '||to_char(l_end_date,'dd-MM-RRRR'),60);
      --
      select budget_version_id into l_budget_version_id
      from pqh_budget_versions bvr
      where budget_id = l_budget_id
      and p_effective_date between bvr.date_from and nvl(bvr.date_to,p_effective_date);
      hr_utility.set_location('budget version exists' || l_budget_version_id, 70);
      open c1(l_budget_unit1_id);
      fetch c1 into l_unit1_name;
      close c1;
      hr_utility.set_location('unit1 is ' || l_unit1_name, 80);
      open c1(l_budget_unit2_id);
      fetch c1 into l_unit2_name;
      close c1;
      hr_utility.set_location('unit2 is ' || l_unit2_name, 90);
      open c1(l_budget_unit3_id);
      fetch c1 into l_unit3_name;
      close c1;
      hr_utility.set_location('unit3 is ' || l_unit3_name, 100);
  exception
    when others then
      hr_utility.set_location('some error occured', 110);
      return null;
  end;
  --
  if l_unit1_name ='MONEY' then
    l_actual_commitment := l_actual_commitment +
        pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
        (
         p_budget_version_id      =>l_budget_version_id,
         p_position_id            =>p_position_id,
         p_start_date             =>l_start_date,
         p_end_date               =>l_end_date,
         p_unit_of_measure_id     =>l_budget_unit1_id,
         p_value_type             =>'T',
         p_ex_assignment_id       =>p_ex_assignment_id
        );
     hr_utility.set_location('unit1_amt is'||l_actual_commitment, 120);
  elsif l_unit2_name ='MONEY' then
    l_actual_commitment := l_actual_commitment +
        pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
        (
         p_budget_version_id      =>l_budget_version_id,
         p_position_id            =>p_position_id,
         p_start_date             =>l_start_date,
         p_end_date               =>l_end_date,
         p_unit_of_measure_id     =>l_budget_unit2_id,
         p_value_type             =>'T',
         p_ex_assignment_id       =>p_ex_assignment_id
        );
     hr_utility.set_location('unit2_amt is'||l_actual_commitment, 120);
  elsif l_unit3_name ='MONEY' then
    l_actual_commitment := l_actual_commitment +
        pqh_bdgt_actual_cmmtmnt_pkg.get_pos_actual_and_cmmtmnt
        (
         p_budget_version_id      =>l_budget_version_id,
         p_position_id            =>p_position_id,
         p_start_date             =>l_start_date,
         p_end_date               =>l_end_date,
         p_unit_of_measure_id     =>l_budget_unit3_id,
         p_value_type             =>'T',
         p_ex_assignment_id       =>p_ex_assignment_id
        );
     hr_utility.set_location('unit3_amt is'||l_actual_commitment, 120);
  end if;
  return l_actual_commitment;
exception
    when others then
      hr_utility.set_location('some error occured - 2', 120);
      return null;
end;
--
function get_asg_actuals_commitment(
                      p_assignment_id              in number,
                      p_effective_date             in date) return number is
l_actuals number := 0;
l_commitments number:=0;
l_start_date    date;
l_end_date      date;
l_last_payroll_dt date;
l_budget_version_id number;
l_budget_id number;
l_budget_unit1_id number;
l_budget_unit2_id number;
l_budget_unit3_id number;
   l_unit1_name varchar2(200);
   l_unit2_name varchar2(200);
   l_unit3_name varchar2(200);
l_calendar      varchar2(200);
   l_business_group_id number;
   --
   cursor c_bus_grp_id(p_assignment_id number) is
   select business_group_id
   from per_all_assignments_f
   where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date and effective_end_date;
   --
   cursor c1(p_unit_id number) is select system_type_cd from
per_shared_types where shared_type_id = p_unit_id;

begin
   begin
      open c_bus_grp_id(p_assignment_id);
      fetch c_bus_grp_id into l_business_group_id;
      close c_bus_grp_id;
      --
      hr_utility.set_location('l_business_group_id:' || l_business_group_id, 600
);
      --
      select budget_id, budget_unit1_id, budget_unit2_id, budget_unit3_id ,period_set_name
      , budget_start_date, budget_end_date
      into l_budget_id, l_budget_unit1_id, l_budget_unit2_id, l_budget_unit3_id, l_calendar
      ,l_start_date, l_end_date
      from pqh_budgets
      where position_control_flag = 'Y'
      and budgeted_entity_cd = 'POSITION'
      and business_group_id = l_business_group_id
      and p_effective_date between budget_start_date and budget_end_date
     and (
          hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = 'MONEY'
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = 'MONEY'
      );
      --
      select budget_version_id into l_budget_version_id
      from pqh_budget_versions bvr
      where budget_id = l_budget_id
      and p_effective_date between bvr.date_from and nvl(bvr.date_to,p_effective_date);
      open c1(l_budget_unit1_id);
      fetch c1 into l_unit1_name;
      close c1;
      open c1(l_budget_unit2_id);
      fetch c1 into l_unit2_name;
      close c1;
      open c1(l_budget_unit3_id);
      fetch c1 into l_unit3_name;
      close c1;
  exception
    when others then
      return null;
  end;
  --
  if l_unit1_name ='MONEY' then
    l_actuals := l_actuals + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_actuals
                     (p_assignment_id              =>p_assignment_id,
                      p_actuals_start_date         =>l_start_date,
                      p_actuals_end_date           =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit1_id,
                      p_last_payroll_dt            =>l_last_payroll_dt);
    l_commitments := l_commitments + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_commitment(
                      p_assignment_id              =>p_assignment_id,
                      p_budget_version_id          =>l_budget_version_id,
                      p_period_start_date          =>l_start_date,
                      p_period_end_date            =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit1_id);
  elsif l_unit2_name ='MONEY' then
    l_actuals := l_actuals + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_actuals
                     (p_assignment_id              =>p_assignment_id,
                      p_actuals_start_date         =>l_start_date,
                      p_actuals_end_date           =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit2_id,
                      p_last_payroll_dt            =>l_last_payroll_dt);
    l_commitments := l_commitments + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_commitment(
                      p_assignment_id              =>p_assignment_id,
                      p_budget_version_id          =>l_budget_version_id,
                      p_period_start_date          =>l_start_date,
                      p_period_end_date            =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit2_id);
  elsif l_unit3_name ='MONEY' then
    l_actuals := l_actuals + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_actuals
                     (p_assignment_id              =>p_assignment_id,
                      p_actuals_start_date         =>l_start_date,
                      p_actuals_end_date           =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit3_id,
                      p_last_payroll_dt            =>l_last_payroll_dt);
    l_commitments := l_commitments + pqh_bdgt_actual_cmmtmnt_pkg.get_assignment_commitment(
                      p_assignment_id              =>p_assignment_id,
                      p_budget_version_id          =>l_budget_version_id,
                      p_period_start_date          =>l_start_date,
                      p_period_end_date            =>l_end_date,
                      p_unit_of_measure_id         =>l_budget_unit3_id);
  end if;
  return l_actuals + l_commitments;
exception
    when others then
      return null;
end;
--
--
function chk_pos_budget(p_position_id  in number, p_effective_date in date) return boolean is
l_budgeted_money number;
l_pos_actuals_commitment number;
begin
     hr_utility.set_location('inside chk_pos_budget', 30);
l_budgeted_money := budgeted_money(p_position_id,p_effective_date);
l_pos_actuals_commitment := get_pos_actuals_commitment(p_position_id,p_effective_date);
hr_utility.set_location('l_budgeted_money:'||l_budgeted_money, 10);
hr_utility.set_location('l_pos_actuals_commitment:'||l_pos_actuals_commitment, 20);
if l_budgeted_money <> -1 and l_pos_actuals_commitment <> -1 then
  if l_pos_actuals_commitment >l_budgeted_money then
     hr_utility.set_location('actual> budget', 30);
    return false;
  end if;
end if;
return true;
exception
    when others then
      return true;
end;
--
function chk_pos_budget(p_position_id  in number, p_effective_date in date, p_ex_assignment_id number) return boolean is
l_budgeted_money number;
l_pos_actuals_commitment number;
l_pos_actuals_cmmt_ex_asg number;
l_asg_actuals_commitment number;
begin
l_budgeted_money := budgeted_money(p_position_id,p_effective_date);
hr_utility.set_location('l_budgeted_money:'||l_budgeted_money, 100);
if l_budgeted_money  > -1 then
  l_asg_actuals_commitment := get_asg_actuals_commitment(p_ex_assignment_id,p_effective_date);
  hr_utility.set_location('l_asg_actuals_commitment:'||l_asg_actuals_commitment, 100);
  if l_asg_actuals_commitment  > 0 then
    l_pos_actuals_cmmt_ex_asg := get_pos_actuals_commitment(
                                            p_position_id,
                                            p_effective_date,
                                            p_ex_assignment_id);
    l_pos_actuals_commitment := l_pos_actuals_cmmt_ex_asg+l_asg_actuals_commitment;

    hr_utility.set_location('l_pos_actuals_cmmt_ex_asg:'||l_pos_actuals_cmmt_ex_asg, 100);
    hr_utility.set_location('l_pos_actuals_commitment:'||l_pos_actuals_commitment, 100);
    if l_pos_actuals_cmmt_ex_asg <> -1 then
      if ((l_pos_actuals_cmmt_ex_asg < l_budgeted_money)
        and (l_pos_actuals_commitment > l_budgeted_money)) then
        return true;
      end if;
    end if;
  end if;
end if;
return false;
exception
    when others then
      return false;
end;
--
--
--
function pos_reserved_fte(p_position_id number, p_effective_date date,
p_ex_position_extra_info_id number default -1) return number is
l_fte number:=0;
l_status varchar2(150);
l_ex_position_extra_info_id number := nvl(p_ex_position_extra_info_id, -1);
cursor c1(p_position_id number, p_effective_date date, p_ex_position_extra_info_id number) is
select sum(poei_information6) fte
from per_position_extra_info
where p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
  and position_id = p_position_id
    and information_type= 'PER_RESERVED'
    and position_extra_info_id <> l_ex_position_extra_info_id;
begin
  if p_position_id is not null and p_effective_date is not null then
    open c1(p_position_id, p_effective_date, p_ex_position_extra_info_id );
    fetch c1 into l_fte;
    close c1;
  end if;
  return l_fte;
end;
--
function poei_reserved_fte(p_position_extra_info_id number) return number is
l_fte number;
cursor c1(p_position_extra_info_id number) is
select poei_information6
from per_position_extra_info
where position_extra_info_id = p_position_extra_info_id;
begin
if p_position_extra_info_id is not null then
  open c1(p_position_extra_info_id);
  fetch c1 into l_fte;
  close c1;
end if;
--
return l_fte;
end;
--
--
function nonreserved_asg_fte(p_position_id number, p_effective_date date,
p_ex_position_extra_info_id number  default -1, p_ex_person_id number  default -1) return number is
l_unreserved_fte number;
l_reserved_fte number;
l_person_fte number;
l_uu_fte number := 0;
l_ex_person_id number := nvl(p_ex_person_id,-1);
l_ex_position_extra_info_id number := nvl(p_ex_position_extra_info_id,-1);
--
cursor c1(p_position_id number, p_effective_date date,
p_ex_position_extra_info_id number, p_ex_person_id number) is
select sum(nvl(value,0))
from per_all_assignments_f asn,
per_assignment_budget_values_f abv,
per_assignment_status_types ast
where abv.assignment_id = asn.assignment_id
and asn.EFFECTIVE_START_DATE <= p_effective_date
and asn.EFFECTIVE_END_DATE >= p_effective_date
and abv.EFFECTIVE_START_DATE <= p_effective_date
and abv.EFFECTIVE_END_DATE >= p_effective_date
and asn.position_id = p_position_id
and asn.person_id <> l_ex_person_id
and asn.assignment_type in ('E', 'C')
and abv.unit = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN'
and not exists (
    select null
    from per_position_extra_info
    where information_type= 'PER_RESERVED'
    and position_id = p_position_id
    and position_extra_info_id <> l_ex_position_extra_info_id
    and fnd_date.canonical_to_date(poei_information3) <= p_effective_date
    and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
                     >= p_effective_date
    and poei_information5 = asn.person_id);
l_nonreserved_fte number:=0;
begin
  open c1(p_position_id, p_effective_date,
          p_ex_position_extra_info_id, p_ex_person_id);
  fetch c1 into l_nonreserved_fte;
  hr_utility.set_location('l_nonreserved_fte : '||l_nonreserved_fte, 131);
  return nvl(l_nonreserved_fte,0);
end;
--
function position_fte(p_position_id number, p_effective_date date) return number is
l_fte number;
cursor c1(p_position_id number, p_effective_date date) is
select fte
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
begin
  open c1(p_position_id, p_effective_date);
  fetch c1 into l_fte;
  close c1;
  return l_fte;
end;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<   person_asg_fte    >------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieves the assignment_fte of the position.
--
function person_asg_fte
         (p_person_id in number, p_position_id  in number, p_effective_date  in date, p_ex_assignment_id number default -1) return number is
l_person_id         number;
l_assignment_fte	number(15,2):=0;
CURSOR c_budgeted_fte(p_person_id number, p_position_id number) is
select nvl(sum(nvl(value,1)),0)
from per_assignment_budget_values_f abv, per_all_assignments_f asn,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and asn.position_id = p_position_id
and asn.person_id = p_person_id
and asn.assignment_id <> nvl(p_ex_assignment_id, -1)
and p_effective_date between asn.effective_start_date and asn.effective_end_date
and p_effective_date between abv.effective_start_date and abv.effective_end_date
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN';
begin
  if p_person_id is not null and p_position_id is not null and p_effective_date is not null then
     open c_budgeted_fte(p_person_id, p_position_id);
     fetch c_budgeted_fte into l_assignment_fte;
     hr_utility.set_location('l_person_id : '||l_person_id, 630);
     hr_utility.set_location('l_assignment_fte : '||l_assignment_fte, 630);
     close c_budgeted_fte;
   end if;
   return(l_assignment_fte);
end;
--

procedure pqh_poei_validate(p_position_id number,
    p_position_extra_info_id number, p_person_id number,
    p_start_date date, p_end_date date, p_poei_fte number) is
l_person_asg_fte        number;
l_reserved_fte          number;
l_nonreserved_asg_fte   number;
l_poei_fte              number;
l_total_fte             number;
l_position_fte          number;
l_budgeted_fte          number;
l_business_group_id     number;
l_realloc_fte           number;
l_bgt_realloc           number;
--
cursor c1(p_position_id number, p_position_extra_info_id number,
p_start_date date, p_end_date date) is
select abv.effective_start_date effective_date
from per_assignment_budget_values_f abv, per_all_assignments_f asn
where abv.assignment_id = asn.assignment_id
and asn.position_id = p_position_id
and abv.effective_start_date between asn.effective_start_date and asn.effective_end_date
and abv.effective_start_date between
  p_start_date and nvl(p_end_date, hr_general.end_of_time)
and asn.effective_start_date between
  p_start_date and nvl(p_end_date, hr_general.end_of_time)
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
union
select effective_start_date effective_date
from per_all_assignments_f asg
where position_id = p_position_id
and asg.effective_start_date between
p_start_date and nvl(p_end_date, hr_general.end_of_time)
union
select effective_start_date effective_date
from hr_all_positions_f psf
where position_id = p_position_id
and psf.effective_start_date between
p_start_date and nvl(p_end_date, hr_general.end_of_time)
union
select p_start_date effective_date
from dual
union
select nvl(p_end_date, hr_general.end_of_time) effective_date
from dual;
--
cursor c2(p_position_id number) is
select business_group_id
from hr_all_positions_f
where position_id = p_position_id;
--
begin
  --
  open c2(p_position_id);
  fetch c2 into l_business_group_id;
  close c2;
  --
  --
for r1 in c1(p_position_id, p_position_extra_info_id, p_start_date, p_end_date)
loop
  --
  l_reserved_fte := pos_reserved_fte(p_position_id, r1.effective_date, p_position_extra_info_id);
  l_nonreserved_asg_fte := nonreserved_asg_fte(p_position_id, r1.effective_date,
        p_position_extra_info_id, p_person_id);
  l_person_asg_fte := pqh_psf_bus.person_asg_fte(p_person_id, p_position_id, r1.effective_date);
  l_poei_fte := greatest(l_person_asg_fte, p_poei_fte);
  l_position_fte := pqh_psf_bus.position_fte(p_position_id, r1.effective_date);
  --
  l_total_fte := nvl(l_reserved_fte,0) + nvl(l_nonreserved_asg_fte,0) + l_poei_fte;
  l_budgeted_fte := pqh_psf_bus.budgeted_fte(p_position_id, r1.effective_date);
  --
  l_realloc_fte := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => p_position_id
                ,p_start_date         => r1.effective_date
                ,p_end_date           => r1.effective_date
                ,p_effective_date     => r1.effective_date
                ,p_system_budget_unit => 'FTE'
                ,p_business_group_id  => l_business_group_id
                );
  --
  hr_utility.set_location('effective date : '||r1.effective_date, 10);
  hr_utility.set_location('l_total_fte : '|| l_total_fte, 20);
  hr_utility.set_location('l_reserved_fte : '||l_reserved_fte, 30);
  hr_utility.set_location('l_nonreserved_asg_fte : '||l_nonreserved_asg_fte, 40);
  hr_utility.set_location('l_person_asg_fte : '||l_person_asg_fte, 50);
  hr_utility.set_location('l_poei_fte : '||l_poei_fte, 60);
  hr_utility.set_location('l_position_fte : '||l_position_fte, 70);
  hr_utility.set_location('l_budgeted_fte : '||l_budgeted_fte, 80);
  hr_utility.set_location('l_realloc_fte : '||l_realloc_fte, 85);
  --
  if l_budgeted_fte is not null or l_realloc_fte is not null then
    --
    l_bgt_realloc := nvl(l_budgeted_fte,0) + nvl(l_realloc_fte,0);
    --
    if l_total_fte > l_bgt_realloc then
      hr_utility.set_message(8302,'PQH_RES_FTE_GT_AVL_POS_BGT_FTE');
      --hr_utility.set_message_token('PERSON', hr_general.decode_person_name(p_person_id));
      hr_utility.set_message_token('EFFECTIVE_DATE', r1.effective_date);
      hr_utility.raise_error;
    end if;
  else
    if l_total_fte > l_position_fte then
      hr_utility.set_message(8302,'PQH_RES_FTE_GT_AVL_POS_FTE');
      --hr_utility.set_message_token('PERSON', hr_general.decode_person_name(p_person_id));
      hr_utility.set_message_token('EFFECTIVE_DATE', r1.effective_date);
      hr_utility.raise_error;
    end if;
  end if;
end loop;
end;
--
--
function chk_reserved_fte(p_assignment_id number, p_person_id number,
    p_position_id number,  p_position_type varchar2,
    p_effective_date date, p_default_asg_fte number default null)
return boolean is
l_available_fte number;
l_assignment_fte number;
l_dummy  varchar2(10);
l_position_type varchar2(30);
l_overlap_period number;
l_overlap_dates_present boolean;
l_business_group_id  number;
--
cursor c_pos_fte(p_position_id number, p_effective_date date) is
select position_type, overlap_period, business_group_id
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
----
/*** index hint added in the select statement of the inner
     query of the cursor as a fix of bug 5963148 **/
cursor c_pos_reserved(p_position_id number, p_effective_date date) is
select 'x'
from (select /*+ INDEX(PER_POSITION_EXTRA_INFO PER_POSITION_EXTRA_INFO_N3)*/
       fnd_date.canonical_to_date(poei_information3) poei_information3,
       nvl(fnd_date.canonical_to_date(poei_information4),
               hr_general.end_of_time) poei_information4
      from per_position_extra_info
      where information_type = 'PER_RESERVED'
       and position_id = p_position_id)
where p_effective_date between poei_information3 and poei_information4;
--
begin
  open c_pos_fte(p_position_id, p_effective_date);
  fetch c_pos_fte into l_position_type,
        l_overlap_period, l_business_group_id;
  close c_pos_fte;
  --
  hr_utility.set_location('chk_pos_fte_sum_asg_fte l_position_type'||l_position_type , 20);
  --
  --
  if l_position_type in ('SHARED', 'SINGLE') then
    l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => p_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => p_effective_date);
    if not l_overlap_dates_present then

          hr_utility.set_location('Entering chk_reserved_fte', 100);
          --
          open c_pos_reserved(p_position_id, p_effective_date);
          fetch c_pos_reserved into l_dummy;
          if c_pos_reserved%notfound then
            hr_utility.set_location('Exiting chk_reserved_fte FALSE', 100);
            close c_pos_reserved;
            return false;
          else
            close c_pos_reserved;
          end if;
          l_available_fte := pqh_psf_bus.available_fte(p_person_id, p_position_id, p_effective_date);
          if l_position_type = 'SINGLE' then
            hr_utility.set_location('p_position_type is SINGLE ', 110);
            l_assignment_fte := 1;
          elsif p_assignment_id is not null then
            hr_utility.set_location('p_assignment_id is not null ', 111);
            l_assignment_fte := nvl(pqh_psf_bus.assignment_fte(p_assignment_id, p_effective_date),0
);
          else
            hr_utility.set_location('p_assignment_id is null and pos type SHARED', 112);
            l_assignment_fte := p_default_asg_fte;
          end if;
          hr_utility.set_location('l_available_fte : '||l_available_fte, 131);
          hr_utility.set_location('l_assignment_fte : '||l_assignment_fte, 132);
          hr_utility.set_location('p_default_asg_fte : '||p_default_asg_fte, 133);
          if (l_assignment_fte > l_available_fte) then
            hr_utility.set_location('Exiting chk_reserved_fte TRUE', 100);
            return true;
          else
            hr_utility.set_location('Exiting chk_reserved_fte FALSE', 100);
            return false;
          end if;
     end if;
   end if;
   hr_utility.set_location('Exiting chk_reserved_fte FALSE', 420);
   return false;
end;
--
function chk_pos_reserve_exists(p_position_id number,
                p_effective_date date)
return boolean is
l_dummy  varchar2(10);
--
/*** index hint added in the select statement of the inner
     query of the cursor as a fix of bug 6409206 **/
cursor c_pos_reserved(p_position_id number,
            p_effective_date date) is
select 'x'
from (select /*+ INDEX(PER_POSITION_EXTRA_INFO PER_POSITION_EXTRA_INFO_N3)*/
       fnd_date.canonical_to_date(poei_information3) poei_information3,
       nvl(fnd_date.canonical_to_date(poei_information4),
               hr_general.end_of_time) poei_information4
      from per_position_extra_info
      where information_type = 'PER_RESERVED'
       and position_id = p_position_id)
where p_effective_date <= poei_information4;
--
begin
  open c_pos_reserved(p_position_id, p_effective_date);
  fetch c_pos_reserved into l_dummy;
  if c_pos_reserved%found then
    hr_utility.set_location('Exiting chk_pos_reserve_exists TRUE', 100);
    close c_pos_reserved;
    return true;
  end if;
  hr_utility.set_location('Exiting chk_pos_reserve_exists FALSE', 100);
  close c_pos_reserved;
  return false;
end;
--
--
function chk_future_reserved_fte(p_assignment_id number, p_person_id number,
    p_position_id number, p_position_type varchar2,
    p_validation_start_date date, p_validation_end_date date,
    p_default_asg_fte number default null)
return date is
l_available_fte number;
l_assignment_fte number;
cursor c1(p_assignment_id number, p_position_id number, p_validation_start_date date, p_validation_end_date date) is
select effective_start_date
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
and asg.business_group_id = abv.business_group_id
union
select effective_start_date
from (select fnd_date.canonical_to_date(poei_information3) effective_start_date
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_RESERVED')
where effective_start_date >= p_validation_start_date
union
select effective_start_date
from per_all_assignments_f
where assignment_id = p_assignment_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.assignment_id = p_assignment_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
union
select effective_start_date
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date;
--
cursor c2(p_position_id number, p_validation_start_date date, p_validation_end_date date) is
select effective_start_date
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
union
select effective_start_date
from (select fnd_date.canonical_to_date(poei_information3) effective_start_date
from per_position_extra_info
where position_id = p_position_id
and information_type = 'PER_RESERVED')
where effective_start_date >= p_validation_start_date
union
select effective_start_date
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date;
--
begin
 hr_utility.set_location('chk_future_reserved_fte p_position_id : '||p_position_id, 201);
 hr_utility.set_location('chk_future_reserved_fte p_validation_start_date: '
                                                  ||p_validation_start_date, 202);
 hr_utility.set_location('chk_future_reserved_fte p_validation_end_date: '
                                                  ||p_validation_end_date, 202);
 if (p_position_id is not null) then
   if chk_pos_reserve_exists(p_position_id,
                           p_validation_start_date) then
     if (p_assignment_id is not null) then
       for r1 in c1(p_assignment_id, p_position_id, p_validation_start_date, p_validation_end_date)
       loop
         hr_utility.set_location('chk_future_reserved_fte r1.effective_start_date : '
                                                                ||r1.effective_start_date, 203);
         hr_utility.set_location('chk_future_reserved_fte p_assignment_id : '||p_assignment_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_person_id : '||p_person_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_position_id : '||p_position_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_default_asg_fte : '||p_default_asg_fte, 203);
         if chk_reserved_fte(p_assignment_id, p_person_id, p_position_id, p_position_type,
                        r1.effective_start_date, p_default_asg_fte) then
           return r1.effective_start_date;
         end if;
       end loop;
     else
       for r1 in c2(p_position_id, p_validation_start_date, p_validation_end_date)
       loop
         hr_utility.set_location('chk_future_reserved_fte r1.effective_start_date : '||r1.effective_start_date, 203);
         hr_utility.set_location('chk_future_reserved_fte p_assignment_id : '||p_assignment_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_person_id : '||p_person_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_position_id : '||p_position_id, 203);
         hr_utility.set_location('chk_future_reserved_fte p_default_asg_fte : '||p_default_asg_fte, 203);
         if chk_reserved_fte(p_assignment_id, p_person_id, p_position_id, p_position_type,
                        r1.effective_start_date, p_default_asg_fte) then
           return r1.effective_start_date;
         end if;
       end loop;
     end if;
   end if;
 end if;
 return null;
end;
--
--
procedure chk_pos_fte_sum_asg_fte(p_assignment_id number, p_position_id number,
p_effective_date date, p_default_asg_fte number default null,
p_position_type out nocopy varchar2, p_organization_id out nocopy number,
p_budgeted_fte out nocopy number, p_realloc_fte out nocopy number,
p_position_fte out nocopy number, p_total_asg_fte out nocopy number) is
--
l_sum	number;
l_asg number;
l_overlap_period number;
l_overlap_dates_present boolean;
l_business_group_id  number;
--
cursor c_pos_fte(p_position_id number, p_effective_date date) is
select position_type, fte, organization_id, overlap_period, business_group_id
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date between effective_start_date and effective_end_date;
--
begin
  open c_pos_fte(p_position_id, p_effective_date);
  fetch c_pos_fte into p_position_type, p_position_fte,
        p_organization_id, l_overlap_period, l_business_group_id;
  close c_pos_fte;
  --
  hr_utility.set_location('chk_pos_fte_sum_asg_fte p_position_type'||p_position_type , 20);
  --
  if p_position_type = 'SHARED' then
   --
   l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => p_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => p_effective_date);
   if not l_overlap_dates_present then
    hr_utility.set_location('chk_pos_fte_sum_asg_fte SHARED' , 20);
    p_budgeted_fte := budgeted_fte(p_position_id, p_effective_date);
    --
    p_realloc_fte := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => p_position_id
                ,p_start_date         => p_effective_date
                ,p_end_date           => p_effective_date
                ,p_effective_date     => p_effective_date
                ,p_system_budget_unit =>'FTE'
                ,p_business_group_id  => l_business_group_id
                );
    --
    --
    hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_null' , 20);
    if p_assignment_id is null then
      hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_is null' , 20);
      p_total_asg_fte := pqh_psf_bus.sum_assignment_fte(p_position_id, p_effective_date) + p_default_asg_fte;
    else
      hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_is not null' , 20);
      l_sum := pqh_psf_bus.sum_assignment_fte(p_position_id, p_effective_date);
      l_asg := pqh_psf_bus.assignment_fte(p_assignment_id, p_effective_date);
      p_total_asg_fte := l_sum + l_asg;
      --
      hr_utility.set_location('chk_pos_fte_sum_asg_fte l_sum : '||l_sum, 20);
      hr_utility.set_location('chk_pos_fte_sum_asg_fte l_asg : '||l_asg, 20);
      hr_utility.set_location('chk_pos_fte_sum_asg_fte p_total_asg_fte : '||p_total_asg_fte, 20);
    end if;
    --
    hr_utility.set_location('chk_pos_fte_sum_asg_fte  end SHARED' , 20);
   end if;
  elsif p_position_type = 'SINGLE' then
   --
   l_overlap_dates_present := pqh_psf_bus.chk_overlap_dates(
            p_position_id => p_position_id,
            p_overlap_period => l_overlap_period,
            p_assignment_start_date => p_effective_date);
   if not l_overlap_dates_present then
    hr_utility.set_location('chk_pos_fte_sum_asg_fte SINGLE' , 20);
    --
    hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_null' , 20);
    if p_assignment_id is null then
      hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_is null' , 20);
      p_total_asg_fte := pqh_psf_bus.no_assignments(p_position_id, p_effective_date) + 1;
    else
      hr_utility.set_location('chk_pos_fte_sum_asg_fte before asg_is not null' , 20);
      l_sum := pqh_psf_bus.no_assignments(p_position_id, p_effective_date);
      l_asg := 1;
      p_total_asg_fte := l_sum + l_asg;
      --
      hr_utility.set_location('chk_pos_fte_sum_asg_fte l_sum : '||l_sum, 20);
      hr_utility.set_location('chk_pos_fte_sum_asg_fte l_asg : '||l_asg, 20);
      hr_utility.set_location('chk_pos_fte_sum_asg_fte p_total_asg_fte : '||p_total_asg_fte, 20);
    end if;
    --
    hr_utility.set_location('chk_pos_fte_sum_asg_fte  end SINGLE' , 20);
   end if;
  end if;
  hr_utility.set_location('chk_pos_fte_sum_asg_fte  end ' , 20);
  exception when others then
    p_position_type := null;
    p_organization_id := null;
    p_budgeted_fte   := null;
    p_realloc_fte    := null;
    p_position_fte   := null;
    p_total_asg_fte := null;
    raise;
end;
--
procedure chk_future_pos_asg_fte(p_assignment_id number,
                                 p_position_id number,
                                 p_validation_start_date date,
                                 p_validation_end_date date,
                                 p_default_asg_fte number default null) is
--
l_position_type    varchar2(30);
l_organization_id  number;
l_budgeted_fte     number;
l_realloc_fte      number;
l_bgt_and_realloc_fte number;
l_position_fte     number;
l_total_asg_fte    number;
--
cursor c1(p_assignment_id number, p_position_id number, p_validation_start_date date, p_validation_end_date date) is
select effective_start_date
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
and asg.business_group_id = abv.business_group_id
union
select effective_start_date
from per_all_assignments_f
where assignment_id = p_assignment_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.assignment_id = p_assignment_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
union
select effective_start_date
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date;
--
cursor c2(p_position_id number, p_validation_start_date date, p_validation_end_date date) is
select effective_start_date
from per_all_assignments_f
where position_id = p_position_id
and assignment_type in ('E', 'C')
and effective_start_date between p_validation_start_date and p_validation_end_date
union
select abv.effective_start_date effective_start_date
from per_assignment_budget_values_f abv, per_all_assignments_f asg
where abv.assignment_id = asg.assignment_id
and asg.position_id = p_position_id
and asg.assignment_type in ('E', 'C')
and abv.effective_start_date between asg.effective_start_date and asg.effective_end_date
and asg.effective_start_date between p_validation_start_date and p_validation_end_date
and asg.business_group_id = abv.business_group_id
union
select effective_start_date
from hr_all_positions_f
where position_id = p_position_id
and effective_start_date between p_validation_start_date and p_validation_end_date;
--
begin
 hr_utility.set_location('chk_future_pos_asg_fte p_position_id : '||p_position_id, 201);
 hr_utility.set_location('chk_future_pos_asg_fte p_validation_start_date: '||p_validation_start_date, 202);
 hr_utility.set_location('chk_future_pos_asg_fte p_validation_end_date: '||p_validation_end_date, 202);
 if (p_assignment_id is not null and p_position_id is not null) then
 for r1 in c1(p_assignment_id, p_position_id, p_validation_start_date, p_validation_end_date)
 loop
   hr_utility.set_location('chk_future_pos_asg_fte r1.effective_start_date : '||r1.effective_start_date, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_assignment_id : '||p_assignment_id, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_position_id : '||p_position_id, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_default_asg_fte : '||p_default_asg_fte, 203);
   --
   chk_pos_fte_sum_asg_fte(
       p_assignment_id       => p_assignment_id,
       p_position_id         => p_position_id,
       p_effective_date      => r1.effective_start_date,
       p_default_asg_fte     => p_default_asg_fte,
       p_position_type       => l_position_type,
       p_organization_id     => l_organization_id,
       p_budgeted_fte        => l_budgeted_fte,
       p_realloc_fte         => l_realloc_fte,
       p_position_fte        => l_position_fte,
       p_total_asg_fte       => l_total_asg_fte);
   --
   hr_utility.set_location('chk_future_pos_asg_fte l_position_type : '||l_position_type, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_organization_id : '|| l_organization_id, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_budgeted_fte : '|| l_budgeted_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_realloc_fte : '|| l_realloc_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_position_fte : '|| l_position_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_total_asg_fte : '|| l_total_asg_fte, 204);
   --
   if l_position_type = 'SHARED' then
        --
        if l_budgeted_fte is not null or l_realloc_fte is not null then
          --
          l_bgt_and_realloc_fte := nvl(l_budgeted_fte,0) + nvl(l_realloc_fte,0);
          --
          if l_bgt_and_realloc_fte < l_total_asg_fte then
              hr_utility.set_message(8302,'PQH_SHARED_FUT_BFTE_LT_AFTE');
              hr_utility.set_message_token('FUTURE_ASG_DATE', r1.effective_start_date);
              pqh_utility.set_message_level_cd('W');
              pqh_utility.raise_error;
              return;
          end if;
        else
          if l_position_fte < l_total_asg_fte then
              hr_utility.set_message(8302,'PQH_SHARED_FUT_PFTE_LT_AFTE');
              hr_utility.set_message_token('FUTURE_ASG_DATE',r1.effective_start_date );
              pqh_utility.set_message_level_cd('W');
              pqh_utility.raise_error;
              return;
          end if;
        end if;
        --
   elsif l_position_type = 'SINGLE' then
        --
        if l_total_asg_fte > 1 then
            hr_utility.set_message(8302,'PQH_SINGLE_POS_FUTURE_ASG');
            hr_utility.set_message_token('FUTURE_ASG_DATE', r1.effective_start_date);
            pqh_utility.set_message_level_cd('E');
            pqh_utility.raise_error;
            return;
        end if;
        --
   end if;
 end loop;
 elsif (p_assignment_id is null and p_position_id is not null) then
 for r1 in c2(p_position_id, p_validation_start_date, p_validation_end_date)
 loop
   hr_utility.set_location('chk_future_pos_asg_fte r1.effective_start_date : '||r1.effective_start_date, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_assignment_id : '||p_assignment_id, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_position_id : '||p_position_id, 203);
   hr_utility.set_location('chk_future_pos_asg_fte p_default_asg_fte : '||p_default_asg_fte, 203);
   --
   chk_pos_fte_sum_asg_fte(
       p_assignment_id       => p_assignment_id,
       p_position_id         => p_position_id,
       p_effective_date      => r1.effective_start_date,
       p_default_asg_fte     => p_default_asg_fte,
       p_position_type       => l_position_type,
       p_organization_id     => l_organization_id,
       p_budgeted_fte        => l_budgeted_fte,
       p_realloc_fte         => l_realloc_fte,
       p_position_fte        => l_position_fte,
       p_total_asg_fte       => l_total_asg_fte);
   --
   hr_utility.set_location('chk_future_pos_asg_fte l_position_type : '||l_position_type, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_organization_id : '|| l_organization_id, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_budgeted_fte : '|| l_budgeted_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_realloc_fte : '|| l_realloc_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_position_fte : '|| l_position_fte, 204);
   hr_utility.set_location('chk_future_pos_asg_fte l_total_asg_fte : '|| l_total_asg_fte, 204);
   --
   if l_position_type = 'SHARED' then
        --
        if l_budgeted_fte is not null or l_realloc_fte is not null then
          --
          l_bgt_and_realloc_fte := nvl(l_budgeted_fte,0) + nvl(l_realloc_fte,0);
          --
          if l_bgt_and_realloc_fte < l_total_asg_fte then
              hr_utility.set_message(8302,'PQH_SHARED_FUT_BFTE_LT_AFTE');
              hr_utility.set_message_token('FUTURE_ASG_DATE', r1.effective_start_date);
              pqh_utility.set_message_level_cd('W');
              pqh_utility.raise_error;
              return;
          end if;
        else
          if l_position_fte < l_total_asg_fte then
              hr_utility.set_message(8302,'PQH_SHARED_FUT_PFTE_LT_AFTE');
              hr_utility.set_message_token('FUTURE_ASG_DATE',r1.effective_start_date );
              pqh_utility.set_message_level_cd('W');
              pqh_utility.raise_error;
              return;
          end if;
        end if;
        --
   elsif l_position_type = 'SINGLE' then
        --
        if l_total_asg_fte > 1 then
            hr_utility.set_message(8302,'PQH_SINGLE_POS_FUTURE_ASG');
            hr_utility.set_message_token('FUTURE_ASG_DATE', r1.effective_start_date);
            pqh_utility.set_message_level_cd('E');
            pqh_utility.raise_error;
            return;
        end if;
        --
   end if;
 end loop;
 end if;
end;
--
procedure CHK_ABV_FTE_GT_POS_BGT_FTE
(p_assignment_id number,
 p_position_id number,
 p_effective_date date,
 p_default_asg_fte number default null,
 p_bgt_lt_abv_fte out nocopy boolean
) is
l_position_type   varchar2(30);
l_organization_id number;
l_budgeted_fte    number;
l_realloc         number;
l_position_fte    number;
l_sum             number;
l_bgt_realloc     number;
begin
      --
      pqh_psf_bus.chk_pos_fte_sum_asg_fte(
       p_assignment_id       => p_assignment_id,
       p_position_id         => p_position_id,
       p_effective_date      => p_effective_date,
       p_default_asg_fte     => p_default_asg_fte,
       p_position_type       => l_position_type,
       p_organization_id     => l_organization_id,
       p_budgeted_fte        => l_budgeted_fte,
       p_realloc_fte         => l_realloc,
       p_position_fte        => l_position_fte,
       p_total_asg_fte       => l_sum);
       --
       --
       p_bgt_lt_abv_fte := false;
       --
       if l_budgeted_fte is not null or l_realloc is not null then
          --
          l_bgt_realloc := nvl(l_budgeted_fte,0) + nvl(l_realloc,0);
          --
          if l_bgt_realloc < l_sum then
            p_bgt_lt_abv_fte := true;
            pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_BGT_FTE',l_organization_id);
            pqh_utility.raise_error;
          end if;
       else
          if l_position_fte < l_sum then
            p_bgt_lt_abv_fte := true;
            pqh_utility.set_message(8302,'PQH_SUM_ABV_FTE_GT_POS_FTE',l_organization_id);
            pqh_utility.raise_error;
          end if;
       end if;
       --
exception when others then
p_bgt_lt_abv_fte := null;
raise;
end;
--
function get_position_fte(p_position_id number, p_effective_date date) return number is
--
l_budgeted_fte number;
l_realloc_fte number;
l_pos_fte number;
l_fte number;
l_status varchar2(150);
l_business_group_id number;
--
cursor c2(p_position_id number, p_effective_date date) is
select fte, business_group_id
from hr_all_positions_f
where position_id = p_position_id
and p_effective_date
  between effective_start_date and effective_end_date;
begin
  if p_position_id is not null and p_effective_date is not null then
    --
    open c2(p_position_id, p_effective_date);
    fetch c2 into l_pos_fte, l_business_group_id;
    close c2;
    --
    l_budgeted_fte := pqh_psf_bus.budgeted_fte(p_position_id, p_effective_date);
    --
    --
    l_realloc_fte := pqh_reallocation_pkg.get_reallocation(
                 p_position_id        => p_position_id
                ,p_start_date         => p_effective_date
                ,p_end_date           => p_effective_date
                ,p_effective_date     => p_effective_date
                ,p_system_budget_unit =>'FTE'
                ,p_business_group_id  => l_business_group_id
                );
    --
    if l_budgeted_fte is not null or l_realloc_fte is not null then
      l_fte := nvl(l_budgeted_fte,0) + nvl(l_realloc_fte,0);
    else
      hr_utility.set_location('l_pos_fte : '||l_pos_fte, 131);
      l_fte := nvl(l_pos_fte,0);
    end if;
  end if;
  hr_utility.set_location('l_fte : '||l_fte, 131);
  return l_fte;
end;
--
--
procedure reserved_error(p_assignment_id number, p_person_id number,
                         p_position_id number, p_effective_start_date date,
                         p_organization_id number,
                         p_default_asg_fte number default 0) is
--
cursor c1 is
select sum(to_number(poei_information6,'99999999.99'))
from per_position_extra_info
where information_type = 'PER_RESERVED'
and position_id = p_position_id
and p_effective_start_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time)
and poei_information5 is null;
--
--
CURSOR c_sum_asg_fte(p_position_id number) is
select sum(value)
from per_assignment_budget_values_f abv, per_all_assignments_f asn,
per_assignment_status_types ast
where abv.assignment_id(+) = asn.assignment_id
and p_effective_start_date between asn.effective_start_date and asn.effective_end_date
and p_effective_start_date between abv.effective_start_date and abv.effective_end_date
and asn.position_id = p_position_id
and asn.assignment_type in ('E', 'C')
and abv.unit(+) = 'FTE'
and asn.assignment_status_type_id = ast.assignment_status_type_id
and ast.per_system_status <> 'TERM_ASSIGN'
and not exists
( select null
from per_position_extra_info poei
where poei.information_type = 'PER_RESERVED'
and poei.position_id = p_position_id
and p_effective_start_date
  between fnd_date.canonical_to_date(poei.poei_information3)
  and nvl(fnd_date.canonical_to_date(poei.poei_information4),hr_general.end_of_time)
and to_number(poei.poei_information5) = asn.person_id);
--
l_blank_res_pos_fte number := 0;
l_unreserved_fte    number := 0;
l_reserved_overused number := 0;
l_sum_asg_fte number := 0;
l_asg_fte number := 0;
l_total_asg_fte number := 0;
--
begin
  open c1;
  fetch c1 into l_blank_res_pos_fte;
  close c1;
  --
  l_unreserved_fte := unreserved_fte(p_position_id, p_effective_start_date);
  --
  l_reserved_overused := reserved_overused(p_position_id, p_effective_start_date);

  open c_sum_asg_fte(p_position_id);
  fetch c_sum_asg_fte into l_sum_asg_fte;
  close c_sum_asg_fte;
  --
  l_asg_fte := assignment_fte(p_assignment_id, p_effective_start_date);
  --
  l_total_asg_fte := nvl(l_sum_asg_fte,0) + nvl(l_asg_fte,0)
                      + l_reserved_overused + p_default_asg_fte;
  --
  --
  if (l_blank_res_pos_fte < 0) then
    hr_utility.set_location('POSITION RESERVED2', 114);
    pqh_utility.set_message(8302,'PQH_POS_RESERVED',p_organization_id);
    pqh_utility.raise_error;
  elsif ((l_total_asg_fte <= (l_blank_res_pos_fte + l_unreserved_fte))
   or (nvl(l_blank_res_pos_fte,0) >=
                 nvl(l_asg_fte,0) + nvl(p_default_asg_fte,0))) then
    hr_utility.set_location('PQH_ANONYM_POS_RESERVED', 115);
    pqh_utility.set_message(8302,'PQH_ANONYM_POS_RESERVED',p_organization_id);
    pqh_utility.raise_error;
  else
    hr_utility.set_location('PQH_POS_RESERVED', 116);
    pqh_utility.set_message(8302,'PQH_POS_RESERVED',p_organization_id);
    pqh_utility.raise_error;
  end if;
  --
end;
--
function get_pc_topnode (p_business_group_id in number,
                         p_effective_date    in date default null) return number is
   l_top_node number := -1;
   l_effective_date date;
   l_business_group_id number;
   l_pc_version number := -1;

   cursor csr_top_node(p_pc_version in number) is
    select a.organization_id_parent organization_id
    from per_org_structure_elements a
    where a.org_structure_version_id = p_pc_version
    and not exists
    (select null
     from per_org_structure_elements b
     where  b.org_structure_version_id = p_pc_version
         AND b.organization_id_child = a.organization_id_parent);
begin
   l_pc_version := get_pc_str_version(p_business_group_id, p_effective_date);
   open csr_top_node(l_pc_version);
   fetch csr_top_node into l_top_node;
   close csr_top_node;
   return l_top_node;
end get_pc_topnode;
--
function get_pc_str_version (p_business_group_id in number default null,
                             p_effective_date    in date default null) return number is
 l_pc_version number := -1;
 l_effective_date date;
 l_business_group_id number;
 cursor csr_pc_version (p_effective_date in date,
                       p_business_group_id in number) is
 SELECT org_structure_version_id
 FROM per_organization_structures pos,
      per_org_structure_versions ver
 WHERE  pos.organization_structure_id = ver.organization_structure_id
   AND  p_effective_date BETWEEN ver.date_from AND NVL(ver.date_to, p_effective_date)
   AND NVL(pos.position_control_structure_flg,'N') = 'Y'
   AND  pos.business_group_id =  p_business_group_id;
begin
   if p_business_group_id is null then
      l_business_group_id := NVL(hr_general.get_business_group_id,fnd_profile.value('PER_BUSINESS_GROUP_ID'));
   else
      l_business_group_id := p_business_group_id;
   end if;
   if p_effective_date is null then
      l_effective_date := hr_general.effective_date;
   else
      l_effective_date := p_effective_date;
   end if;
   open csr_pc_version(l_effective_date,l_business_group_id);
   fetch csr_pc_version into l_pc_version;
   close csr_pc_version;
   return l_pc_version;
end;

--
--
/* Budgeted Salary check Enhancement procedures */

procedure  get_assignment_info(
         p_assignment_id   in  number,
         p_effective_date  in  date,
         p_position_id     out nocopy number,
         p_organization_id out nocopy number) is

--
cursor c_assignment(p_assignment_id number, p_effective_date date) is
select position_id, organization_id
from per_all_assignments_f
where assignment_id = p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
begin
  open c_assignment(p_assignment_id, p_effective_date);
  fetch c_assignment into p_position_id, p_organization_id;
  close c_assignment;
end;


function get_cbr_rule_level(
         p_application_id  in number,
         p_message_name    in varchar2,
         p_organization_id in number) return varchar2 is
l_rule_level_cd varchar2(1);
begin
  pqh_utility.get_message_level_cd
                            (p_organization_id       => p_organization_id,
                             p_application_id        => p_application_id,
                             p_message_name          => p_message_name,
                             p_rule_level_cd         => l_rule_level_cd);

  RETURN l_rule_level_cd;
end;


procedure get_position_pc_budget_info(
         p_position_id       in number,
         p_budget_unit_cd    in varchar2,
         p_effective_date    in date,
         p_budget_id         OUT nocopy number,
         p_budget_name       OUT nocopy varchar2,
         p_business_group_id OUT nocopy number,
         p_budget_version_id OUT nocopy number,
         p_budget_start_date OUT nocopy date,
         p_budget_end_date   OUT nocopy date,
         p_currency_code     OUT nocopy varchar2) is
--
cursor c_pc_budget_info(p_position_id number,
                           p_budget_unit_cd in varchar2,
                           p_effective_date date) is
select bgt.budget_id, bgt.budget_name, bgt.business_group_id,
       bver.budget_version_id,
       bgt.budget_start_date, bgt.budget_end_date, bgt.currency_code
from pqh_budgets bgt,
     pqh_budget_versions bver,
     pqh_budget_details  bdet
where bgt.budget_id = bver.budget_id
and   bver.budget_version_id = bdet.budget_version_id
and   bdet.position_id = p_position_id
and   p_effective_date between bgt.budget_start_date and bgt.budget_end_date
and   p_effective_date between bver.date_from and bver.date_to
and   bgt.budgeted_entity_cd = 'POSITION'
and   bgt.position_control_flag = 'Y'
and   (hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(bgt.budget_unit1_id) = p_budget_unit_cd
       or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(bgt.budget_unit2_id) = p_budget_unit_cd
       or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(bgt.budget_unit3_id) = p_budget_unit_cd);
--
begin
  open c_pc_budget_info(p_position_id, p_budget_unit_cd, p_effective_date);
  fetch c_pc_budget_info into
             p_budget_id, p_budget_name, p_business_group_id,
             p_budget_version_id,
             p_budget_start_date, p_budget_end_date, p_currency_code;
  close c_pc_budget_info;
end;


function does_appr_sal_proposal_exist(
                    p_assignment_id number,
                    p_effective_date date) return boolean is
--
cursor c_appr_sal_prop_exist(p_assignment_id number,
                             p_effective_date date) is
select 'x'
from dual
where exists (
         select null
         from per_pay_proposals
         where assignment_id = p_assignment_id
         and p_effective_date >= change_date
         and approved = 'Y'
     );
--
l_dummy varchar2(1);
--
begin
  open c_appr_sal_prop_exist(p_assignment_id, p_effective_date);
  fetch c_appr_sal_prop_exist into l_dummy;
  if c_appr_sal_prop_exist%notfound then
    return false;
  end if;
  return true;
end;

procedure get_asg_salary_basis_info(
                   p_assignment_id number,
                   p_effective_date date,
                   p_element_type_id OUT nocopy number,
                   p_input_value_id  OUT nocopy number) is
--
cursor c_pay_basis_info(p_assignment_id number,
                        p_effective_date date) is
select piv.element_type_id, ppb.input_value_id
from per_all_assignments_f asg,
     per_pay_bases ppb,
     pay_input_values_f piv
where assignment_id = p_assignment_id
and asg.pay_basis_id = ppb.pay_basis_id
and ppb.input_value_id = piv.input_value_id
and p_effective_date between asg.effective_start_date and asg.effective_end_date
and p_effective_date between piv.effective_start_date and piv.effective_end_date;
--
begin
  --
  open c_pay_basis_info(p_assignment_id, p_effective_date);
  fetch c_pay_basis_info into p_element_type_id, p_input_value_id;
  close c_pay_basis_info;
  --
end;

function decode_element(p_element_type_id number) return varchar2 is
cursor c_element_name(p_element_type_id number) is
      select pettl1.element_name
        from pay_element_types_f_tl pettl1
       where pettl1.element_type_id    = p_element_type_id
         and pettl1.language           = userenv('LANG');
--
l_element_name pay_element_types_f_tl.element_name%type;
begin
  open c_element_name(p_element_type_id);
  fetch c_element_name into l_element_name;
  close c_element_name;
  return l_element_name;
end;

function decode_input_value(p_input_value_id number) return varchar2 is
cursor c_input_value_name(p_input_value_id number) is
      select pivtl.name
        from pay_input_values_f_tl pivtl
       where pivtl.input_value_id    = p_input_value_id
         and pivtl.language          = userenv('LANG');
--
l_input_value_name pay_input_values_f_tl.name%type;
begin
  open c_input_value_name(p_input_value_id);
  fetch c_input_value_name into l_input_value_name;
  close c_input_value_name;
  return l_input_value_name;
end;


function is_budget_commt_element(p_budget_id number,
                                 p_element_type_id number) return boolean is
l_check varchar2(10);
begin
    hr_utility.set_location('budget id'||p_budget_id,1);
    hr_utility.set_location('element type id'||p_element_type_id,2);
    select 'X'
    into l_check
    from pqh_bdgt_cmmtmnt_elmnts
    where budget_id = p_budget_id
    and element_type_id = p_element_type_id
    and actual_commitment_type in ('COMMITMENT','BOTH');

    if l_check IS NULL then
       return false;
    else
       return true;
    end if;

exception
   when no_data_found then
    hr_utility.set_location('no data',3);
       return false;
   when too_many_rows then
       return true;
   when others then
       return false;
end;

procedure chk_position_budget(
p_assignment_id    in number,
p_element_type_id  in number default null,
p_input_value_id   in number default null,
p_effective_date   in date,
p_called_from      in varchar2, /* valid values 'ASG' or 'SAL' */
p_old_position_id  in number default null,
p_new_position_id  in number default null
) is
--
l_pos_budgeted_amt number;
l_pos_actuals_amt number;
l_pos_actual_cmmt_total_amt number;
l_pos_commitment_amt number;
l_pos_reallocated_out_amt number;
l_pos_reallocated_in_amt number;
l_pos_reserved_amt number;
l_pos_under_budgeted_amt number;
--
l_asg_organization_id  number;
l_asg_position_id      number;
--
l_budget_id          number;
l_budget_name        pqh_budgets.budget_name%type;
l_business_group_id  number;
l_budget_version_id  number;
l_budget_start_date  date;
l_budget_end_date    date;
l_currency_code      pqh_budgets.currency_code%type;
--
l_salary_element_type_id number;
l_salary_input_value_id  number;
--
l_message_level varchar2(10);
l_proc varchar2(72) := 'pqh_psf_bus.chk_position_budget';
begin
  --
 hr_utility.set_location(l_proc||'Entering',1);
  get_assignment_info(p_assignment_id, p_effective_date, l_asg_position_id, l_asg_organization_id);
  --
 hr_utility.set_location(l_proc,2);
  --
  if (l_asg_position_id is null) then
 hr_utility.set_location(l_proc,3);
    return;
  end if;
  --
  --
  if (p_called_from = 'ASG' and p_old_position_id = l_asg_position_id ) then
 hr_utility.set_location(l_proc,4);
    return;
  end if;
  --
  --
  l_message_level := get_cbr_rule_level(8302,'PQH_SUM_ASG_AMT_GT_BGT_AMT',l_asg_organization_id);
  if (l_message_level not in ('E','W')) then
     hr_utility.set_location(l_proc,5);
    return;
  end if;
  --

 hr_utility.set_location(l_proc||l_asg_position_id,51);
  --
  get_position_pc_budget_info(
         p_position_id       => l_asg_position_id,
         p_budget_unit_cd    => 'MONEY',
         p_effective_date    => p_effective_date,
         p_budget_id         => l_budget_id,
         p_budget_name       => l_budget_name,
         p_business_group_id => l_business_group_id,
         p_budget_version_id => l_budget_version_id,
         p_budget_start_date => l_budget_start_date,
         p_budget_end_date   => l_budget_end_date,
         p_currency_code     => l_currency_code);
  if ( l_budget_version_id is null ) then

 hr_utility.set_location(l_proc,6);
    return;
  end if;
 hr_utility.set_location(l_proc,61);
  --
  --

  --
  --
  if ((p_called_from = 'SAL') or
      (p_called_from = 'ASG'
         and does_appr_sal_proposal_exist(p_assignment_id, p_effective_date))) then
    --
    --
    if p_called_from = 'ASG' then
      get_asg_salary_basis_info(p_assignment_id, p_effective_date,
                       l_salary_element_type_id, l_salary_input_value_id);
    elsif (p_called_from = 'SAL') then
      l_salary_element_type_id := p_element_type_id;
      l_salary_input_value_id := p_input_value_id;
    end if;
    --
    if (not is_budget_commt_element(l_budget_id, l_salary_element_type_id) ) then
      pqh_utility.set_message(8302,'PQH_SAL_NOT_COMMT_ELEMENT',l_asg_organization_id);
      pqh_utility.set_message_token('ELEMENT', decode_element(l_salary_element_type_id));
      pqh_utility.set_message_token('BUDGET', l_budget_name);
      pqh_utility.raise_error;
      return;
    end if;
    --
 hr_utility.set_location(l_proc,7);
    --
  end if;
  --
  --

  --
  --
 hr_utility.set_location(l_proc,71);
  pqh_commitment_pkg.refresh_asg_ele_commitments (
                                       p_assignment_id,
                                       p_effective_date,
                                       p_element_type_id,
                                       p_input_value_id);
 hr_utility.set_location(l_proc,8);
  --
  --

  --
  --
  l_pos_budgeted_amt := budgeted_money(l_asg_position_id,p_effective_date);
  --
  pqh_bdgt_actual_cmmtmnt_pkg.get_pos_money_amounts
  (
   p_budget_version_id         => l_budget_version_id,
   p_position_id               => l_asg_position_id,
   p_start_date                => l_budget_start_date,
   p_end_date                  => l_budget_end_date,
   p_actual_amount             => l_pos_actuals_amt,
   p_commitment_amount         => l_pos_commitment_amt,
   p_total_amount              => l_pos_actual_cmmt_total_amt
  );
 hr_utility.set_location(l_proc,9);
  --
  --
  l_pos_reallocated_out_amt :=
              pqh_reallocation_pkg.get_reallocated_money(
                               p_position_id         => l_asg_position_id
                               ,p_business_group_id  => l_business_group_id
                               ,p_type               => 'DNTD'
                               ,p_start_date         => l_budget_start_date
                               ,p_end_date           => l_budget_end_date
                               ,p_effective_date     => p_effective_date);
  --
  --
  l_pos_reallocated_in_amt :=
              pqh_reallocation_pkg.get_reallocated_money(
                               p_position_id         => l_asg_position_id
                               ,p_business_group_id  => l_business_group_id
                               ,p_type               => 'RCVD'
                               ,p_start_date         => l_budget_start_date
                               ,p_end_date           => l_budget_end_date
                               ,p_effective_date     => p_effective_date);
  --
  --
  l_pos_reserved_amt :=
              pqh_reallocation_pkg.get_reallocated_money(
                               p_position_id         => l_asg_position_id
                               ,p_business_group_id  => l_business_group_id
                               ,p_type               => 'RSRVD'
                               ,p_start_date         => l_budget_start_date
                               ,p_end_date           => l_budget_end_date
                               ,p_effective_date     => p_effective_date);
  --
  --

  --
  --
  l_pos_under_budgeted_amt := nvl(l_pos_budgeted_amt,0)
                            - nvl(l_pos_actual_cmmt_total_amt,0)
                            - nvl(l_pos_reallocated_out_amt,0)
                            + nvl(l_pos_reallocated_in_amt,0)
                            - nvl(l_pos_reserved_amt,0);
  --
  --
 hr_utility.set_location(l_proc,10);
  --
 hr_utility.set_location(l_proc || ' - Budgeted Amt : '||l_pos_budgeted_amt,10);
 hr_utility.set_location(l_proc || ' - Actual Amt : '||l_pos_actuals_amt,10);
 hr_utility.set_location(l_proc || ' - Commitment Amt : '||l_pos_commitment_amt,10);
 hr_utility.set_location(l_proc || ' - Realloc Out Amt : '||l_pos_reallocated_out_amt,10);
 hr_utility.set_location(l_proc || ' - Realloc In Amt : '||l_pos_reallocated_in_amt,10);
 hr_utility.set_location(l_proc || ' - Reserved Amt : '||l_pos_reserved_amt,10);
  --
  --
  if (l_pos_under_budgeted_amt < 0) then
 hr_utility.set_location(l_proc||'Leaving with error',11);

      pqh_utility.set_message(8302,'PQH_SUM_ASG_AMT_GT_BGT_AMT',l_asg_organization_id);
--      pqh_utility.set_message_level_cd(l_message_level);
      pqh_utility.set_message_token('POSITION',
                                hr_general.decode_position(l_asg_position_id));
      pqh_utility.set_message_token('UNDER_BUDGETED_AMT',
                        to_char( -l_pos_under_budgeted_amt,
          fnd_currency.GET_FORMAT_MASK(nvl(l_currency_code,'USD'),length(trunc(l_pos_under_budgeted_amt))+15)
          ));
/*
      pqh_utility.set_message_token('BUDGETED',nvl(l_pos_budgeted_amt,0));
      pqh_utility.set_message_token('ACTUALS',nvl(l_pos_actuals_amt,0));
      pqh_utility.set_message_token('COMMITMENT',nvl(l_pos_commitment_amt,0));
      pqh_utility.set_message_token('REALLOC_OUT',nvl(l_pos_reallocated_out_amt,0));
      pqh_utility.set_message_token('REALLOC_IN',nvl(l_pos_reallocated_in_amt,0));
      pqh_utility.set_message_token('RESERVED',nvl(l_pos_reserved_amt,0));
*/
      pqh_utility.raise_error;
  end if;
  --
 hr_utility.set_location(l_proc||'Leaving',12);
  --
exception
    when others then
      hr_utility.set_location(substr(sqlerrm,1,120),13);
      raise;
end;

end	PQH_PSF_BUS;

/
