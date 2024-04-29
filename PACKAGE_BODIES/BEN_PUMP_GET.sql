--------------------------------------------------------
--  DDL for Package Body BEN_PUMP_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PUMP_GET" as
/* $Header: bedpget.pkb 120.3 2007/11/28 13:42:53 sallumwa noship $ */
/*
  NOTES
    Please refer to the package header for documentation on these
    functions.
*/
/*---------------------------------------------------------------------------*/
/*----------------------- constant definitions ------------------------------*/
/*---------------------------------------------------------------------------*/
END_OF_TIME   constant date := to_date('4712/12/31', 'YYYY/MM/DD');
START_OF_TIME constant date := to_date('0001/01/01', 'YYYY/MM/DD');
HR_API_G_VARCHAR2 constant varchar2(128) := hr_api.g_varchar2;
HR_API_G_NUMBER constant number := hr_api.g_number;
HR_API_G_DATE constant date := hr_api.g_date;
--
/* returns an acty_base_rt_id */
function get_acty_base_rt_id1
( p_data_pump_always_call in varchar2,
  p_business_group_id    in number,
  p_acty_base_rate_name1 in varchar2 default null,
  p_acty_base_rate_num1  in number   default null,
  p_effective_date       in date
) return number is
  l_acty_base_rt_id number;
begin
  IF p_acty_base_rate_num1 IS NOT NULL and p_acty_base_rate_num1 <> HR_API_G_NUMBER THEN
    l_acty_base_rt_id := p_acty_base_rate_num1 ;
  ELSIF p_acty_base_rate_name1 IS NOT NULL THEN
  select abr.acty_base_rt_id
  into   l_acty_base_rt_id
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate_name1
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  END IF;
  return(l_acty_base_rt_id);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_id1', sqlerrm, p_business_group_id, p_acty_base_rate_name1, p_effective_date);
  raise;
end get_acty_base_rt_id1;
--
/* returns an acty_base_rt_id2 */
function get_acty_base_rt_id2
( p_data_pump_always_call in varchar2,
  p_business_group_id       in number,
  p_acty_base_rate_name2    in varchar2 default null,
  p_acty_base_rate_num2     in number   default null,
  p_effective_date          in date
) return number is
  l_acty_base_rt_id number;
begin
  IF p_acty_base_rate_num2 IS NOT NULL and p_acty_base_rate_num2 <> HR_API_G_NUMBER THEN
    l_acty_base_rt_id := p_acty_base_rate_num2 ;
  ELSIF p_acty_base_rate_name2 IS NOT NULL THEN
  select abr.acty_base_rt_id
  into   l_acty_base_rt_id
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate_name2
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  END IF;
  return(l_acty_base_rt_id);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_id2', sqlerrm, p_business_group_id, p_acty_base_rate_name2, p_effective_date);
  raise;
end get_acty_base_rt_id2;
--
/* returns an acty_base_rt_id */
function get_acty_base_rt_id3
( p_data_pump_always_call in varchar2,
  p_business_group_id       in number,
  p_acty_base_rate_name3    in varchar2 default null,
  p_acty_base_rate_num3     in number   default null,
  p_effective_date          in date
) return number is
  l_acty_base_rt_id number;
begin
  IF p_acty_base_rate_num3 IS NOT NULL and p_acty_base_rate_num3 <> HR_API_G_NUMBER THEN
    l_acty_base_rt_id := p_acty_base_rate_num3 ;
  ELSIF p_acty_base_rate_name3 IS NOT NULL THEN
  select abr.acty_base_rt_id
  into   l_acty_base_rt_id
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate_name3
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  END IF;
  return(l_acty_base_rt_id);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_id3', sqlerrm, p_business_group_id, p_acty_base_rate_name3, p_effective_date);
  raise;
end get_acty_base_rt_id3;
--
/* returns an acty_base_rt_id4 */
function get_acty_base_rt_id4
( p_data_pump_always_call in varchar2,
  p_business_group_id       in number,
  p_acty_base_rate_name4    in varchar2 default null,
  p_acty_base_rate_num4     in number   default null,
  p_effective_date          in date
) return number is
  l_acty_base_rt_id number;
begin
  IF p_acty_base_rate_num4 IS NOT NULL and p_acty_base_rate_num4 <> HR_API_G_NUMBER THEN
    l_acty_base_rt_id := p_acty_base_rate_num4 ;
  ELSIF p_acty_base_rate_name4 IS NOT NULL THEN
  select abr.acty_base_rt_id
  into   l_acty_base_rt_id
  from   ben_acty_base_rt_f abr
  where  abr.name                  = p_acty_base_rate_name4
  and    abr.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         abr.effective_start_date and abr.effective_end_date;
  END IF;
  return(l_acty_base_rt_id);
exception
when others then
  hr_data_pump.fail('get_acty_base_rt_id4', sqlerrm, p_business_group_id, p_acty_base_rate_name4, p_effective_date);
  raise;
end get_acty_base_rt_id4;
--
------------------------------ get_pgm_id ---------------------------
/*
  NAME
    get_pgm_id
  DESCRIPTION
    Returns a Program ID.
  NOTES
    This function returns a pgm_id and is designed for use with the Data Pump.
*/
function get_pgm_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_program              in varchar2 default null,
  p_program_num          in number   default null,
  p_effective_date       in date
) return number is
  l_pgm_id number;
begin
  IF p_program_num IS NOT NULL and p_program_num <> HR_API_G_NUMBER THEN
    l_pgm_id := p_program_num ;
  ELSIF p_program IS NOT NULL and p_program <> HR_API_G_VARCHAR2 THEN--Bug : 6652591
  select pgm.pgm_id
  into   l_pgm_id
  from   ben_pgm_f pgm
  where  pgm.name                  = p_program
  and    pgm.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pgm.effective_start_date and pgm.effective_end_date;
  END IF;
  return(l_pgm_id);
exception
when others then
  hr_data_pump.fail('get_pgm_id', sqlerrm, p_business_group_id, p_program,p_program_num, p_effective_date);
  raise;
end get_pgm_id;
--

/* returns a pl_id */
function get_pl_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_plan              in varchar2 default null,
  p_plan_num          in number   default null,
  p_effective_date    in date
) return number is
  l_pl_id number;
begin
  IF p_plan_num IS NOT NULL and p_plan_num <> HR_API_G_NUMBER THEN
    l_pl_id := p_plan_num ;
  ELSIF p_plan IS NOT NULL THEN
  select pln.pl_id
  into   l_pl_id
  from   ben_pl_f pln
  where  pln.name                  = p_plan
  and    pln.business_group_id + 0 = p_business_group_id
  and    p_effective_date between
         pln.effective_start_date and pln.effective_end_date;
  END IF;
  return(l_pl_id);
exception
when others then
  hr_data_pump.fail('get_pl_id', sqlerrm, p_business_group_id, p_plan, p_effective_date);
  raise;
end get_pl_id;
--
/* returns a ended_pl_id */
function get_ended_pl_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_ended_plan        in varchar2 default null,
  p_ended_plan_num    in number   default null,
  p_effective_date    in date
) return number is
  l_pl_id number;
begin
  IF p_ended_plan_num IS NOT NULL and p_ended_plan_num <> HR_API_G_NUMBER THEN
    l_pl_id := p_ended_plan_num ;
  ELSIF p_ended_plan IS NOT NULL THEN
    select pln.pl_id
    into   l_pl_id
    from   ben_pl_f pln
    where  pln.name                  = p_ended_plan
    and    pln.business_group_id + 0 = p_business_group_id
    and    p_effective_date between
           pln.effective_start_date and pln.effective_end_date;
  END IF;
  return(l_pl_id);
exception
when others then
  hr_data_pump.fail('get_ended_pl_id', sqlerrm, p_business_group_id, p_ended_plan, p_effective_date);
  raise;
end get_ended_pl_id;
--
/* returns an opt_id */
function get_opt_id
( p_data_pump_always_call in varchar2,
  p_business_group_id in number,
  p_option            in varchar2 default null,
  p_option_num        in number   default null,
  p_effective_date    in date
) return number is
  l_opt_id number;
begin
  IF p_option_num IS NOT NULL and p_option_num <> HR_API_G_NUMBER THEN
    l_opt_id := p_option_num ;
  ELSIF p_option IS NOT NULL and p_option <> HR_API_G_VARCHAR2 THEN --BUG 6148609
    select opt.opt_id
    into   l_opt_id
    from   ben_opt_f opt
    where  opt.name                  = p_option
    and    opt.business_group_id + 0 = p_business_group_id
    and    p_effective_date between
           opt.effective_start_date and opt.effective_end_date;
  END IF;
  return(l_opt_id);
exception
when others then
  hr_data_pump.fail('get_opt_id', sqlerrm, p_business_group_id, p_option, p_effective_date);
  raise;
end get_opt_id;
--
/* returns an ended_opt_id */
function get_ended_opt_id
( p_data_pump_always_call in varchar2,
  p_business_group_id    in number,
  p_ended_option         in varchar2 default null,
  p_ended_option_num     in number   default null,
  p_effective_date       in date
) return number is
  l_opt_id number;
begin
  --
  IF p_ended_option_num IS NOT NULL and p_ended_option_num <> HR_API_G_NUMBER THEN
    l_opt_id := p_ended_option_num ;
  ELSIF p_ended_option IS NOT NULL THEN
    select opt.opt_id
    into   l_opt_id
    from   ben_opt_f opt
    where  opt.name                  = p_ended_option
    and    opt.business_group_id + 0 = p_business_group_id
    and    p_effective_date between
           opt.effective_start_date and opt.effective_end_date;
  END IF;
  --
  return(l_opt_id);
exception
when others then
  hr_data_pump.fail('get_ended_opt_id', sqlerrm, p_business_group_id, p_ended_option, p_effective_date);
  raise;
end get_ended_opt_id;
--
------------------------------ get_pen_person_id ---------------------------
/*
  NAME
    get_pen_person_id
  DESCRIPTION
    Returns an person_id
  NOTES
    This function returns a eperson_id and is designed for use with the Data Pump.
*/
--
function get_pen_person_id
( p_data_pump_always_call in varchar2,
  p_business_group_id   in number,
  p_employee_number     in varchar2 default null,
  p_national_identifier in varchar2 default null,
  p_full_name           in varchar2 default null,
  p_date_of_birth       in date     default null,
  p_person_num          in number   default null,
  p_effective_date      in date
) return number is
   --
    l_person_id NUMBER;
    value_error exception ;
  begin
    --
    IF p_person_num IS NOT NULL and p_person_num <> HR_API_G_NUMBER THEN
      --
      l_person_id := p_person_num ;
      --
    ELSIF p_employee_number IS NOT NULL THEN
      --
      select person_id
        into l_person_id
        from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and employee_number = p_employee_number ;
      --
    ELSIF p_national_identifier IS NOT NULL THEN
      --
      select person_id
        into l_person_id
       from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and national_identifier = p_national_identifier ;
      --
    ELSIF p_full_name IS NOT NULL AND p_date_of_birth IS NOT NULL THEN
      --
      select person_id
        into l_person_id
       from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and full_name  = p_full_name
        and date_of_birth = p_date_of_birth ;
      --
    ELSE
      --
      raise  value_error;
      --
    END IF;
    --
    --
    return l_person_id ;
    --
  exception when others then
    hr_data_pump.fail('get_pen_person_id', sqlerrm,
                       p_business_group_id, p_employee_number, p_national_identifier,
                       p_full_name,p_date_of_birth, p_effective_date);
    raise;
end get_pen_person_id ;
--

function get_con_person_id
( p_data_pump_always_call in varchar2,
  p_business_group_id   in number,
  p_con_employee_number     in varchar2 default null,
  p_con_national_identifier in varchar2 default null,
  p_con_full_name           in varchar2 default null,
  p_con_date_of_birth       in date     default null,
  p_con_person_num          in number   default null,
  p_effective_date      in date
) return number is
   --
    l_person_id NUMBER;
    value_error exception ;
  begin
    --
    IF p_con_person_num IS NOT NULL and p_con_person_num <> HR_API_G_NUMBER THEN
      --
      l_person_id := p_con_person_num ;
      --
    ELSIF p_con_employee_number IS NOT NULL THEN
      --
      select person_id
        into l_person_id
        from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and employee_number = p_con_employee_number ;
      --
    ELSIF p_con_national_identifier IS NOT NULL THEN
      --
      select person_id
        into l_person_id
       from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and national_identifier = p_con_national_identifier ;
      --
    ELSIF p_con_full_name IS NOT NULL AND p_con_date_of_birth IS NOT NULL THEN
      --
      select person_id
        into l_person_id
       from per_all_people_f
      where business_group_id = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        and full_name  = p_con_full_name
        and date_of_birth = p_con_date_of_birth ;
      --
    /*
    ELSE
      --
      raise  value_error;
      --
    */
    END IF;
    --
    --
    return l_person_id ;
    --
  exception when others then
    hr_data_pump.fail('get_con_person_id', sqlerrm,
                       p_business_group_id, p_con_employee_number, p_con_national_identifier,
                       p_con_full_name,p_con_date_of_birth, p_effective_date);
    raise;
end get_con_person_id ;
--
begin
   -- Initialise the debugging information structure.
   null;

end ben_pump_get;

/
