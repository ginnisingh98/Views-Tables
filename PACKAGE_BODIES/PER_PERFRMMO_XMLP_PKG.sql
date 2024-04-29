--------------------------------------------------------
--  DDL for Package Body PER_PERFRMMO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERFRMMO_XMLP_PKG" AS
/* $Header: PERFRMMOB.pls 120.1 2008/03/06 10:35:04 amakrish noship $ */

function CF_GET_HEADERFormula return Number is

begin


  C_COUNT_PREVIOUS_PERIOD := perfrphr.get_emp_total(P_PERIOD_START_DATE - 1,
                                                     P_ESTABLISHMENT_ID,
                                                     NULL,
                                                     NULL,
                                                     'INCLUDE_MMO_HEADCOUNT',
                                                     P_INCLUDE_SUSPENDED);

   C_COUNT_PERIOD := perfrphr.get_emp_total(P_PERIOD_END_DATE,
                                             P_ESTABLISHMENT_ID,
                                             NULL,
                                             NULL,
                                             'INCLUDE_MMO_HEADCOUNT',
                                             P_INCLUDE_SUSPENDED);


   C_COUNT_MEN := perfrphr.get_emp_total(P_PERIOD_END_DATE,
                                          P_ESTABLISHMENT_ID,
                                          NULL,
                                          'M',
                                          'INCLUDE_MMO_HEADCOUNT',
                                          P_INCLUDE_SUSPENDED);

   C_COUNT_WOMEN := perfrphr.get_emp_total(P_PERIOD_END_DATE,
                                            P_ESTABLISHMENT_ID,
                                            NULL,
                                            'F',
                                            'INCLUDE_MMO_HEADCOUNT',
                                            P_INCLUDE_SUSPENDED);

   C_TEMPORARY   := perfrphr.get_emp_total(P_PERIOD_END_DATE,
                                            P_ESTABLISHMENT_ID,
                                            NULL,
                                            NULL,
                                            'INCLUDE_MMO_TEMPORARY',
                                            P_INCLUDE_SUSPENDED);


  --raise_application_error(-20001,C_COUNT_PREVIOUS_PERIOD||','||C_COUNT_PERIOD||','||C_COUNT_MEN||','||C_COUNT_WOMEN||','||C_TEMPORARY);
  return(1);
end;

function BeforeReport return boolean is
begin
   --hr_standard.event('BEFORE REPORT');
   P_FORMULA_ID := hr_fr_mmo.Get_formula(P_BUSINESS_GROUP_ID,P_SESSION_DATE);
   if (P_FORMULA_ID = 0) Then
      return(FALSE);
   else
      return (TRUE);
   end if;
end;

function c_get_nationalityformula(NATIONALITY in varchar2) return varchar2 is
lc_nationality   varchar2(2);
begin

                  if (NATIONALITY IS NOT NULL) Then
      begin
         lc_nationality := hruserdt.get_table_value (P_BUSINESS_GROUP_ID,
                                                     'NATIONALITY',
                                                     'MMO_NATIONALITY',
                                                     NATIONALITY,
                                                     P_PERIOD_START_DATE);
         if lc_nationality = 'FR' then
            lc_nationality := 'F';
         elsif lc_nationality = 'EU' then
            lc_nationality := 'C';
         else
            lc_nationality := ' ';
         end if;
       exception when no_data_found then
         lc_nationality := ' ';
       end;
   end if;
   return lc_nationality;
end;

function c_get_asgformula(PERSON_ID1 in number, START_DATE in date, END_DATE in date) return number is

ln_start_asg_id      number;
ln_end_asg_id        number;
lc_start_job         varchar2(240);
lc_start_job_pcs     varchar2(150);
lc_end_job           varchar2(240);
lc_end_job_pcs       varchar2(150);
lc_start_reason          varchar2(80);
lc_end_reason            varchar2(80);
ld_effective_start_date  date;

lid                  per_jobs.job_id%type;

begin
   hr_utility.set_location('Entered C_GET_ASG formula', 5);
   begin
      hr_utility.set_location('Get asg_id,start job and start emp cat',10);

          select a.assignment_id,
            jbt.name,
            j.job_id,
            j.job_information1
      into ln_start_asg_id,
           lc_start_job,
           lid,
           lc_start_job_pcs
      from per_all_assignments_f   a,
           per_jobs                j,
           per_jobs_tl             jbt,
           hr_soft_coding_keyflex  s
      where a.person_id              = PERSON_ID1
        and a.primary_flag           = 'Y'
        and a.effective_start_date   = START_DATE
        and a.assignment_type        = 'E'
        and a.job_id                 = jbt.job_id(+)
        and jbt.language(+)          = userenv('LANG')
        and a.job_id                 = j.job_id(+)
        and a.soft_coding_keyflex_id = s.soft_coding_keyflex_id(+);
               IF lid is not null THEN
        per_fr_d2_pkg.get_pcs_code(p_report_qualifier => 'MMO'
                                  ,p_job_id           => lid
                                  ,p_pcs_code         => lc_start_job_pcs
                                  ,p_effective_date   => START_DATE);
        lid := null;
     END IF;
                EXCEPTION
         WHEN OTHERS Then
         Begin
           ln_start_asg_id  := '';
           lc_start_job     := '';
           lc_start_job_pcs := '';
         End;
   end;

   hr_utility.set_location('Get end_asg_id,end job and end emp cat',15);
         begin
      select a.assignment_id,
             a.effective_start_date,
             jbt.name,
             j.job_id,
             j.job_information1
      into ln_end_asg_id,
           ld_effective_start_date,
           lc_end_job,
           lid,
           lc_end_job_pcs
      from per_all_assignments_f   a,
           per_jobs                j,
           per_jobs_tl             jbt,
           hr_soft_coding_keyflex  s
      where a.person_id              = PERSON_ID1
        and a.primary_flag           = 'Y'
        and a.effective_end_date     = END_DATE
        and a.assignment_type        = 'E'
        and a.job_id                 = jbt.job_id(+)
        and jbt.language(+)          = userenv('LANG')
        and a.job_id                 = j.job_id(+)
        and a.soft_coding_keyflex_id = s.soft_coding_keyflex_id(+);
                  IF lid is not null THEN
         per_fr_d2_pkg.get_pcs_code (p_report_qualifier => 'MMO'
                                    ,p_job_id           => lid
                                    ,p_pcs_code         => lc_end_job_pcs
                                    ,p_effective_date   => END_DATE);
         lid := null;
      END IF;
                EXCEPTION
         WHEN OTHERS Then
         Begin
           ln_end_asg_id   := '';
           lc_end_job      := '';
           lc_end_job_pcs  := '';
         end;
   end;

      if to_char(END_DATE,'YYYYMMDD') = '47121231' Then
      C_JOB     := lc_start_job;
      C_JOB_PCS := lc_start_job_pcs;
   else
      C_JOB     := lc_end_job;
      C_JOB_PCS := lc_end_job_pcs;
   end if;


     if ln_start_asg_id is not NULL then
        lc_start_reason := hr_fr_mmo.get_reason(ln_start_asg_id,
                                                fnd_date.date_to_canonical(START_DATE),
                                                P_FORMULA_ID,
                                                'S');
        if (lc_start_reason <> ' ') then
           C_START_REASON  := hruserdt.get_table_value (P_BUSINESS_GROUP_ID,
                                                        'FR_STARTING_REASON',
                                                        'MMO_STARTING_CATEGORY',
                                                        lc_start_reason,
                                                        START_DATE);
        else
           C_START_REASON := '';
        end if;

     end if;

     if (ln_end_asg_id is not NULL) then
        lc_end_reason   := hr_fr_mmo.get_reason(ln_end_asg_id,
                                                fnd_date.date_to_canonical(END_DATE),
                                                P_FORMULA_ID,
                                                'L');
        if (lc_end_reason <> ' ') then
           C_END_REASON  := hruserdt.get_table_value (P_BUSINESS_GROUP_ID,
                                                       'FR_ENDING_REASON',
                                                       'MMO_ENDING_CATEGORY',
                                                       lc_end_reason,
                                                       END_DATE);
        else
           C_END_REASON := '';
        end if;
     end if;

          if (START_DATE NOT BETWEEN P_PERIOD_START_DATE and
                                 P_PERIOD_END_DATE)
        or (START_DATE IS NULL) Then
        C_CHECK_STARTED := 0;
     else
        C_CHECK_STARTED := 1;
     end if;

     if (END_DATE BETWEEN P_PERIOD_START_DATE and
                           P_PERIOD_END_DATE)
        and (END_DATE IS NOT NULL) Then
        C_CHECK_LEFT := 1;
     else
        C_CHECK_LEFT := 0;
     end if;

   return(1);

end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COUNT_PREVIOUS_PERIOD_p return number is
	Begin
	 return C_COUNT_PREVIOUS_PERIOD;
	 END;
 Function C_COUNT_PERIOD_p return number is
	Begin
	 return C_COUNT_PERIOD;
	 END;
 Function C_COUNT_MEN_p return number is
	Begin
	 return C_COUNT_MEN;
	 END;
 Function C_COUNT_WOMEN_p return number is
	Begin
	 return C_COUNT_WOMEN;
	 END;
 Function C_TEMPORARY_p return number is
	Begin
	 return C_TEMPORARY;
	 END;
 Function C_JOB_p return varchar2 is
	Begin
	 return C_JOB;
	 END;
 Function C_JOB_PCS_p return varchar2 is
	Begin
	 return C_JOB_PCS;
	 END;
 Function C_START_REASON_p return varchar2 is
	Begin
	 return C_START_REASON;
	 END;
 Function C_END_REASON_p return varchar2 is
	Begin
	 return C_END_REASON;
	 END;
 Function C_CHECK_STARTED_p return number is
	Begin
	 return C_CHECK_STARTED;
	 END;
 Function C_CHECK_LEFT_p return number is
	Begin
	 return C_CHECK_LEFT;
	 END;
 Function C_EFFECTIVE_START_DATE_p return date is
	Begin
	 return C_EFFECTIVE_START_DATE;
	 END;
 Function P_FORMULA_ID_p return number is
	Begin
	 return P_FORMULA_ID;
	 END;
END PER_PERFRMMO_XMLP_PKG ;

/
