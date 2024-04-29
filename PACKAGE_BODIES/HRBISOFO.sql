--------------------------------------------------------
--  DDL for Package Body HRBISOFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRBISOFO" AS
/* $Header: hrbisofo.pkb 115.0 99/07/15 19:38:50 porting shi $ */


-----------------------------------------------------------------------------
--                                                                         --
--  FUNCTION 	                                                           --
--      primary_sales_job                                                  --
--                                                                         --
--  PARAMETERS:                                                            --
--      p_person_id             sales persons id                           --
--                                                                         --
--  RETURNS                                                                --
--      Name of primary sales job ID. If no job is found then null is      --
--      returned.                                                          --
--                                                                         --
--  DESCRIPTION                                                            --
--      This function returns a persons current primary sales job. All     --
--      sales jobs must be defined as part of the pre-defined Revenue      --
--      generating job category. If the person has more than one current   --
--      sales assignment then the primary assignment will be used in       --
--      preference to any other. If the person has more than one sales job --
--      where none are the primary assignment then the assignment with the --
--      earliest starting date will be used.                               --
--                                                                         --
--                                                                         --
-----------------------------------------------------------------------------
--
FUNCTION primary_sales_job
          (p_person_id in NUMBER) return NUMBER is

 v_job_id per_jobs.job_id%TYPE;             -- job ID

 cursor c_job is
  select job.job_id
  from	 per_people_x       peo
  ,	 per_jobs           job
  ,	 per_assignments_x  asg
  ,	 per_job_extra_info inf
  ,	 hr_lookups         lkp
  where  lkp.lookup_type = 'JOB_CATEGORIES'
  and    lkp.lookup_code = inf.jei_information1
  and    inf.jei_information1 = 'RG'
  and    inf.information_type = 'Job Category'
  and    job.job_id = inf.job_id
  and    job.job_id = asg.job_id
  and    trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  and    peo.person_id = asg.person_id
  and    peo.person_id = p_person_id
  order by 1,decode(asg.primary_flag,'Y',1,2),asg.effective_start_date;


BEGIN
--
-- get the primary sales job for this person
--
 open c_job;
 fetch c_job into v_job_id;
 if c_job%notfound then
  v_job_id := '';
 end if;
 close c_job;
 return v_job_id;

EXCEPTION

 when others then
  return null;

END;

-----------------------------------------------------------------------------
-- End of package
-----------------------------------------------------------------------------

END hrBisOfo;

/
