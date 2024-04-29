--------------------------------------------------------
--  DDL for Package Body PAY_US_EMP_DT_TAX_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMP_DT_TAX_VAL" AS
/* $Header: pyusdtvl.pkb 120.2.12000000.1 2007/01/18 02:19:43 appldev noship $ */
/*

    +======================================================================+
    |                Copyright (c) 1997 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+

    Package Body Name :  pay_us_emp_dt_tax_val

    Package File Name :  pyusdtvl.pkb

    Description : This package declares functions which are used for creating
                  and manipulating tax records for an assignment.

    Change List:
    ------------

    Name           Date       Version Bug     Text

    Amita Chauhan  07-AUG-97  40.0            Created.

    Amita Chauhan  15-JUL-98  40.1            Merging the branch version
                                              into the 10.7 code tree.
    Amita Chauhan  15-APR-99  40.2            Added the check for 'US Payroll'
                                              install before checking for
                                              future dated change in location.
                                              - Bug# 863905.
    achauhan       16-JUN-99  110.11         Changed the null to exit if
                                             csr_get_next_locations not found
                                             in case of FUTURE_CHANGE.
    djoshi         24-dec-99                 Added a funciton that returns
                                             whether over-ride exits or
                                             not.Modified the script to also
                                             check for the over-ride.
    achauhan       07-feb-2000 40.8          Made changes in get_all_work_codes
                                             for Bug# 1186065 and 1179274.
    dscully        21-jun-2000 40.9          Modified check_delete_row to
                                             prevent deletion of work, tax, and
                                             live locations in all situations
    ahanda         22-JUL-2000 40.10         Changed the procedure
                                             get_all_work_codes for performance
                                             reasons.
    dscully	   9-AUG-2000  40.11/110.15  Changed reference to sysdate
					     to p_session_date in
					     get_all_work_codes
    tclewis    26-JAN-2004 115.9              11.5.10 performance changes on the
                                             following cursors:
                                             csr_check_state_purge, csr_check_county_purge,
                                             csr_check_city_purge, csr_chk_payroll
    ardsouza       29-JAN-2004 115.10        Added dbdrv: command, SET VERIFY OFF
                                             and NOCOPY hint for GSCC compliance.
    sudedas        20-APR-2006 115.11 4563092 One message added to check_payroll_run
    sudedas        11-Sep-2006 115.12 5486281 Turning Off SUI Wage Base Override Functionality .
    ========================================================================
*/

/* Check override state,county,city */

FUNCTION  check_resi_override ( p_assignment_id  in number,
                             p_session_date  date,
                             p_state_code in varchar2,
                             p_county_code in varchar2,
                             p_city_code   in varchar2
                             )
RETURN  varchar2
IS

       CURSOR   csr_chk_res_state
           IS
       SELECT  pus1.state_code,
               pus.state_code
         FROM  pay_us_states pus,
               pay_us_states pus1,
               per_addresses pa,
               per_assignments_f paf
        WHERE  paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  paf.person_id     = pa.person_id
          AND  p_session_date BETWEEN pa.date_from
                                  AND nvl(pa.date_to,to_date('12/31/4712','mm/dd/yyyy'))
          AND  pus.state_abbrev = nvl(pa.add_information17,pa.region_2)
          AND  pus1.state_abbrev = pa.region_2
          AND  pa.primary_flag = 'Y';

       CURSOR  csr_chk_res_county
           IS
       SELECT  pus1.state_code,
               puc1.county_code,
               pus.state_code,
               puc.county_code
         FROM  pay_us_states pus,
               pay_us_states pus1,
               pay_us_counties puc,
               pay_us_counties puc1,
               per_addresses pa,
               per_assignments_f paf
        WHERE  paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  paf.person_id     = pa.person_id
          AND  p_session_date BETWEEN pa.date_from
                                  AND nvl(pa.date_to,to_date('12/31/4712','mm/dd/yyyy'))
          AND  pus.state_abbrev = nvl(pa.add_information17,pa.region_2)
          AND  pus.state_code   = puc.state_code
          AND  puc.county_name  = nvl(pa.add_information19,pa.region_1)
          AND  pus1.state_abbrev = pa.region_2
          AND  pus1.state_code  = puc1.state_code
          AND  puc1.county_name = pa.region_1
          AND  pa.primary_flag = 'Y';



        CURSOR csr_chk_res_city
    IS  SELECT pus1.state_code,
               puc1.county_code,
               pucy1.city_code,
               pus.state_code,
               puc.county_code,
               pucy.city_code
         FROM  pay_us_states pus,
               pay_us_states pus1,
               pay_us_counties puc,
               pay_us_counties puc1,
               pay_us_city_names pucy,
               pay_us_city_names pucy1,
               per_addresses pa,
               per_assignments_f paf
        WHERE  paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  paf.person_id     = pa.person_id
          AND  p_session_date BETWEEN pa.date_from
                                  AND nvl(pa.date_to,to_date('12/31/4712','mm/dd/yyyy'))
          AND  pus.state_abbrev = nvl(pa.add_information17,pa.region_2)
          AND  pus.state_code   = puc.state_code
          AND  puc.county_name  = nvl(pa.add_information19,pa.region_1)
          AND  pus1.state_abbrev = pa.region_2
          AND  pus1.state_code  = puc1.state_code
          AND  puc1.county_name = pa.region_1
          AND  pucy.state_code  = pus.state_code
          AND  pucy.state_code  = puc.state_code
          AND  pucy.county_code = puc.county_code
          AND  pucy1.state_code = puc1.state_code
          AND  pucy1.county_code = puc1.county_code
          AND  pucy.city_name  = nvl(pa.add_information18,pa.town_or_city)
          AND  pucy1.city_name  = pa.town_or_city
          AND  pa.primary_flag = 'Y';



     l_nml_res_state varchar2(2);
     l_ovr_res_state varchar2(2);
     l_nml_res_county_code varchar2(3);
     l_ovr_res_county_code varchar2(3);
     l_nml_res_city_code   varchar2(4);
     l_ovr_res_city_code varchar2(4);
     l_cb_ovr_res varchar2(1);

   BEGIN

           /*Check if there is res. override state */
             IF   p_state_code  IS NOT NULL
              AND p_county_code IS NULL
              AND p_city_code   IS NULL
             THEN

                  OPEN  csr_chk_res_state;

                  FETCH csr_chk_res_state INTO l_nml_res_state,l_ovr_res_state;

                  IF csr_chk_res_state%NOTFOUND THEN
                            l_cb_ovr_res  := 'N';
                  END IF;

                  CLOSE csr_chk_res_state;

                 IF (p_state_code = l_ovr_res_state
                     and l_nml_res_state <> l_ovr_res_state
                      ) THEN
                          l_cb_ovr_res := 'Y';
                 ELSE
                          l_cb_ovr_res := 'N';
                 END IF;
	     END IF;
             /* check for res. override county */

               IF p_state_code  IS NOT NULL
              AND p_county_code IS NOT NULL
              AND p_city_code   IS NULL  THEN

                   OPEN  csr_chk_res_county;
                  FETCH  csr_chk_res_county
                   INTO  l_nml_res_state,
                         l_nml_res_county_code,
                         l_ovr_res_state,
                         l_ovr_res_county_code;

                IF csr_chk_res_county%NOTFOUND THEN
                            l_cb_ovr_res := 'N';
                END IF;

                CLOSE csr_chk_res_county;

                /* check if the over-ride is same as the normal check box */

                IF       (      p_state_code   = l_ovr_res_state
                           and  p_county_code  = l_ovr_res_county_code)
                           and  (NOT( (l_nml_res_state = l_ovr_res_state) and
                                      (l_nml_res_county_code = l_ovr_res_county_code)))
                THEN
                         l_cb_ovr_res := 'Y';
                ELSE
                         l_cb_ovr_res := 'N';
                END IF;

               END IF;

               /* check if there is any res. override city */

               IF p_state_code  IS NOT NULL
              AND p_county_code IS NOT NULL
              AND p_city_code   IS NOT NULL  THEN


                /* Check for the override resident city */

                 OPEN  csr_chk_res_city;
                FETCH 	csr_chk_res_city
                 INTO   l_nml_res_state,
                        l_nml_res_county_code,
                        l_nml_res_city_code,
                        l_ovr_res_state,
                        l_ovr_res_county_code,
                        l_ovr_res_city_code;

                IF csr_chk_res_city%NOTFOUND THEN
                            l_cb_ovr_res := 'N';
                END IF;

                CLOSE csr_chk_res_city;


                IF       p_state_code   = l_ovr_res_state
                    and  p_county_code  = l_ovr_res_county_code
                    and  p_city_code    = l_ovr_res_city_code
                    and  (NOT(       (l_nml_res_state = l_ovr_res_state)
                                 and (l_nml_res_county_code = l_ovr_res_county_code)
                                 and (l_nml_res_city_code = l_ovr_res_city_code)
                              )
                          )
                THEN
                         l_cb_ovr_res := 'Y';
                ELSE
                         l_cb_ovr_res := 'N';
                END IF;
                END IF;
                return l_cb_ovr_res;

   END check_resi_override ;


FUNCTION  check_work_override ( p_assignment_id  in number,
                             p_session_date  date,
                             p_state_code in varchar2,
                             p_county_code in varchar2,
                             p_city_code   in varchar2
                             )
RETURN varchar2
IS      CURSOR csr_work_state
     IS SELECT pus1.state_code,
               pus.state_code,
               paf.location_id,
               hscf.segment18
          FROM pay_us_states pus,
               pay_us_states pus1,
               hr_locations hl,
               hr_locations hl1,
               hr_soft_coding_keyflex hscf,
               per_assignments_f paf
         WHERE paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
          AND  hl.location_id = nvl(hscf.segment18,paf.location_id)
          AND  pus.state_abbrev = nvl(hl.loc_information17,hl.region_2)
          AND  hl1.location_id = paf.location_id
          AND  pus1.state_abbrev = nvl(hl1.loc_information17,hl1.region_2);


CURSOR csr_work_county
     IS SELECT pus1.state_code,
               puc1.county_code,
               pus.state_code,
               puc.county_code,
               paf.location_id,
               hscf.segment18
          FROM pay_us_states pus,
               pay_us_states pus1,
               pay_us_counties puc,
               pay_us_counties puc1,
               hr_locations hl,
               hr_locations hl1,
               hr_soft_coding_keyflex hscf,
               per_assignments_f paf
         WHERE paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
          AND  hl.location_id = nvl(hscf.segment18,paf.location_id)
          AND  pus.state_abbrev = nvl(hl.loc_information17,hl.region_2)
          AND  hl1.location_id = paf.location_id
          AND  pus1.state_abbrev = nvl(hl1.loc_information17,hl1.region_2)
          AND  pus1.state_code = puc1.state_code
          AND  pus.state_code  = puc.state_code
          AND  puc.county_name   = nvl(hl.loc_information19,hl.region_1)
          and  puc1.county_name  = nvl(hl1.loc_information19,hl1.region_1);


 CURSOR csr_work_city
     IS SELECT pus1.state_code,
               puc1.county_code,
               pucy1.city_code,
               pus.state_code,
               puc.county_code,
               pucy.city_code,
               paf.location_id,
               hscf.segment18
          FROM pay_us_states pus,
               pay_us_states pus1,
               pay_us_counties puc,
               pay_us_counties puc1,
               pay_us_city_names pucy,
               pay_us_city_names pucy1,
               hr_locations hl,
               hr_locations hl1,
               hr_soft_coding_keyflex hscf,
               per_assignments_f paf
         WHERE paf.assignment_id = p_assignment_id
          AND  p_session_date BETWEEN paf.effective_start_date
                                  AND paf.effective_end_date
          AND  hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
          AND  hl.location_id = nvl(hscf.segment18,paf.location_id)
          AND  pus.state_abbrev = nvl(hl.loc_information17,hl.region_2)
          AND  hl1.location_id = paf.location_id
          AND  pus1.state_abbrev = nvl(hl1.loc_information17,hl1.region_2)
          AND  pus1.state_code = puc1.state_code
          AND  pus.state_code  = puc.state_code
          AND  puc.county_name   = nvl(hl.loc_information19,hl.region_1)
          and  puc1.county_name  = nvl(hl1.loc_information19,hl1.region_1)
          AND  pucy.state_code   = pus.state_code
          AND  pucy.county_code  = puc.county_code
          AND  pucy.city_name    = nvl(hl.loc_information18,hl.town_or_city)
          AND  pucy1.state_code  = puc1.state_code
          AND  pucy1.county_code  = puc1.county_code
          AND  pucy1.city_name   = nvl(hl1.loc_information18,hl1.town_or_city);



  l_nml_work_state varchar2(2);
  l_ovr_work_state varchar2(2);
  l_nml_work_county_code varchar2(3);
  l_ovr_work_county_code varchar2(3);
  l_nml_work_city_code   varchar2(4);
  l_ovr_work_city_code   varchar2(4);
  l_nml_work_location_id varchar2(60);
  l_ovr_work_location_id varchar2(60);
  l_cb_ovr_work varchar2(1);

 BEGIN
          /* Initialize the value of parameter to be 'N' */

         IF   p_state_code  IS NOT NULL
              AND p_county_code IS NULL
              AND p_city_code   IS NULL
         THEN

              OPEN  csr_work_state;

             FETCH  csr_work_state
              INTO  l_nml_work_state,
                    l_ovr_work_state,
                    l_nml_work_location_id,
                    l_ovr_work_location_id;

                    IF csr_work_state%NOTFOUND THEN
                            l_cb_ovr_work  := 'N';
                    END IF;

                  CLOSE csr_work_state;
                 IF (p_state_code = l_ovr_work_state
                     and l_nml_work_state <> l_ovr_work_state
                      ) THEN
                          l_cb_ovr_work := 'Y';
                 ELSE
                          l_cb_ovr_work := 'N';
                 END IF;
	   END IF;
                       /* county Work Checking  */

            IF    p_state_code  IS NOT NULL
              AND p_county_code IS NOT NULL
              AND p_city_code   IS NULL
         THEN

              OPEN  csr_work_county;

             FETCH  csr_work_county
              INTO  l_nml_work_state,
                    l_nml_work_county_code,
                    l_ovr_work_state,
                    l_ovr_work_county_code,
                    l_nml_work_location_id,
                    l_ovr_work_location_id;

                    IF csr_work_county%NOTFOUND THEN
                            l_cb_ovr_work  := 'N';
                    END IF;

                  CLOSE csr_work_county;
                 IF (    p_state_code  = l_ovr_work_state
                     and p_county_code = l_ovr_work_county_code
                     and (NOT(     (l_nml_work_state = l_ovr_work_state)
                               and (l_nml_work_county_code = l_ovr_work_county_code)
                             )
                         )
                    )
                 THEN
                          l_cb_ovr_work := 'Y';
                 ELSE
                          l_cb_ovr_work := 'N';
                 END IF;
	   END IF;
                  /* checking city */

        IF       ( p_state_code  IS NOT NULL
              AND p_county_code IS NOT NULL
              AND p_city_code   IS NOT NULL )
         THEN

              OPEN  csr_work_city;

             FETCH  csr_work_city
              INTO  l_nml_work_state,
                    l_nml_work_county_code,
                    l_nml_work_city_code,
                    l_ovr_work_state,
                    l_ovr_work_county_code,
                    l_ovr_work_city_code,
                    l_nml_work_location_id,
                    l_ovr_work_location_id;

                    IF csr_work_city%NOTFOUND THEN
                            l_cb_ovr_work  := 'N';
                    END IF;

                  CLOSE csr_work_city;

                 IF (         p_state_code = l_ovr_work_state
                     AND      p_county_code = l_ovr_work_county_code
                     AND      p_city_code  = l_ovr_work_city_code
                     AND      (NOT(    (l_nml_work_state = l_ovr_work_state)
                                    and(l_nml_work_county_code = l_ovr_work_county_code)
                                    and(l_nml_work_city_code  = l_ovr_work_city_code)
                                   )
                               )
                      ) THEN
                          l_cb_ovr_work := 'Y';
                 ELSE
                          l_cb_ovr_work := 'N';
                 END IF;
	   END IF;




    return l_cb_ovr_work;

 END check_work_override;



/* Name         : check_payroll_run
   Purpose      : If datetrack mode is 'DELETE_NEXT_CHANGE' or 'FUTURE_CHANGE'
                  the procedure will check whether there is any future record
                  with different location id. If there is it will give and
                  error message to the user.
                  For all modes if location id is changed it will  check
                  if a payroll has been run for the assignment,
                  within a given time period. The return value will be set
                  accordingly which will be used to raise warning message
*/

function check_payroll_run (  p_assignment_id        in number,
                              p_new_location_code    in varchar2,
                              p_new_location_id      in number,
                              p_session_date         in date,
			                     p_effective_start_date in date,
			                     p_effective_end_date   in date,
                              p_mode                 in varchar2) return varchar2 is


  l_code                    number;
  l_location_id             number;
  l_location_id_changed     number := 0;
  l_returned_warning        varchar2(240) := NULL;
  check_payroll_enabled     number := 1;
  l_fed_row_found           varchar2(1) := 'N';
  l_payroll_installed       boolean := FALSE;

  cursor csr_chk_loc_change is
  select paf.location_id
  from   PER_ASSIGNMENTS_F paf
  where  paf.assignment_id = p_assignment_id
  and    p_session_date between paf.effective_start_date
        and paf.effective_end_date;

  cursor csr_get_next_locations  is
    select paf1.location_id
    from per_assignments_f paf1
    where paf1.assignment_id = p_assignment_id
    and paf1.effective_start_date > p_effective_end_date
    order by paf1.effective_start_date;

  cursor csr_chk_payroll is
/* 11.5.10 changes  performance modification. original code
   commented out below. */
    select 1
      from per_assignments_f paf
           ,pay_payroll_actions ppa
           ,pay_assignment_actions paa
      where paf.assignment_id = p_assignment_id
      and    ppa.payroll_id = paf.payroll_id
      and    ppa.action_type in ('E', 'Q','R')
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    paa.assignment_id =  paf.assignment_id
      and    trunc(ppa.date_earned) between p_effective_start_date
     								and     p_effective_end_date;

/*

    select 1
	from PAY_ASSIGNMENT_ACTIONS paa
	where paa.assignment_id = p_assignment_id
	and exists(
           select 1
           from PAY_PAYROLL_ACTIONS ppa
           where ppa.payroll_action_id = paa.payroll_action_id
           and ppa.action_type in ('E','Q','R')
           and trunc(ppa.date_earned) between p_effective_start_date
     												   and p_effective_end_date );
*/

  cursor csr_chk_fed_row is
  select 'Y'
  from dual
  where exists (select null
                from PAY_US_EMP_FED_TAX_RULES_F pef
                where pef.assignment_id = p_assignment_id);

  cursor c_get_state_code(p_location_id in number) is
  select 	pus.state_code
  from 	pay_us_states pus,
	hr_locations hl
  where	hl.location_id = p_location_id
  and	pus.state_abbrev = nvl(loc_information17,region_2);


   l_work_state_code       pay_us_states.state_code%type ;
   l_new_work_state_code   pay_us_states.state_code%type ;
   l_work_state_name       pay_us_states.state_name%type ;
   l_work_county_code      pay_us_counties.county_code%type ;
   l_work_county_name      pay_us_counties.county_name%type ;
   l_work_city_code        pay_us_city_names.city_code%type ;
   l_work_city_name        pay_us_city_names.city_name%type ;

   l_returned_warning1       varchar2(240) := NULL;

begin

  l_payroll_installed := hr_utility.chk_product_install(
                             p_product     => 'Oracle Payroll',
                             p_legislation => 'US');

-- Added for SUI Wage Base enh
-- Turning Off SUI Wage Base Override Functionality due to Bug# 5486281
/*
   get_work_codes(p_assignment_id,
                  p_session_date,
		  l_work_state_code,
		  l_work_county_code,
		  l_work_city_code,
		  l_work_state_name,
		  l_work_county_name,
		  l_work_city_name) ;

   open c_get_state_code(p_new_location_id) ;
   fetch c_get_state_code into l_new_work_state_code ;
   if c_get_state_code%notfound then
      close c_get_state_code ;
   end if ;
*/
   if p_mode = 'DELETE_NEXT_CHANGE' and l_payroll_installed then

    hr_utility.set_location('pay_us_emp_dt_tax_rules.check_payroll_run - opening cursor ',1);
    open csr_get_next_locations;
    fetch csr_get_next_locations into l_location_id;

    if csr_get_next_locations%NOTFOUND then
      NULL;
    else
     if l_location_id <> p_new_location_id then
         check_payroll_enabled   := 0;
         fnd_message.set_name ('PAY', 'PAY_52282_FUTR_LOC_CHNG_EXISTS');
         fnd_message.set_token('current_location_id',p_new_location_code);
         app_exception.raise_exception;              /* raise error message */
     else
         check_payroll_enabled   := 1;
     end if;
     close csr_get_next_locations;
    end if;
   end if; /* end checking of DELETE_NEXT_CHANGE */

   if p_mode = 'FUTURE_CHANGE' and l_payroll_installed then

    hr_utility.set_location('pay_us_emp_dt_tax_rules.check_payroll_run - opening cursor ',2);
    open csr_get_next_locations;
    loop
         check_payroll_enabled   := 1;
         fetch csr_get_next_locations into l_location_id;
         if csr_get_next_locations%NOTFOUND then
           exit;
         else
           if l_location_id <> p_new_location_id then
               check_payroll_enabled   := 0;
               fnd_message.set_name ('PAY', 'PAY_52282_FUTR_LOC_CHNG_EXISTS');
               fnd_message.set_token('current_location_id',p_new_location_code);
         app_exception.raise_exception;              /* raise error message */
               close csr_get_next_locations;
               exit;
           end if;
         end if;
    end loop;
    close csr_get_next_locations;
   end if;      /* end checking of FUTURE_CHANGE */

/* Payroll Run will be checked only if Payroll is installed  and legislation is US */

 if l_payroll_installed then
     hr_utility.set_location('pay_us_emp_dt_tax_rules.check_payroll_run - opening cursor csr_loc_change',3);
     open csr_chk_loc_change;
     hr_utility.set_location('pay_us_emp_dt_tax_rules.check_payroll_run - opening cursor',4);
     fetch csr_chk_loc_change into l_location_id;

    if csr_chk_loc_change%FOUND then

     /*  Existence of payroll run will be checked only if location_id has
			changed. Before checking for change in location see if any tax records
         exist at all or not. This is needed to be done because a default
         location is assigned to the assignment that is created for a new
         person */

         -- hr_utility.set_location('pay_us_emp_tax_rules.check_payroll_run...location changed',31) ;
         -- This is being added as part of SUI Wage Base Override enh
         -- Turning Off SUI Wage Base Override Functionality due to Bug# 5486281
         /*
         if l_work_state_code <> l_new_work_state_code then
             fnd_message.set_name('PAY', 'PAY_52388_SUI_TAX_LOC_CHNG') ;
             l_returned_warning1 := fnd_message.get ;
         end if ;
         */

     open csr_chk_fed_row;
     fetch csr_chk_fed_row into l_fed_row_found;
     if csr_chk_fed_row%NOTFOUND then
        l_fed_row_found := 'N';
     end if;
     close csr_chk_fed_row;

     if l_fed_row_found = 'Y' then

       if l_location_id <> p_new_location_id then
         l_location_id_changed := 1;
         if check_payroll_enabled=1 then
				/* This is checked because if mode is DELETE-NEXT-CHANGE */
            /* or DELETE-FUTURE-CHANGE and location_id is different */
            /* in any of the next records user will get an error  */
            /* and there is no need to check for the payroll run */

            open csr_chk_payroll;
            hr_utility.set_location('pay_us_emp_dt_tax_rules.check_payroll_run - fetching cursor',4);
            fetch csr_chk_payroll into l_code;

            if csr_chk_payroll%FOUND then
              hr_utility.set_location('pay_us_emp_tax_rules.check_payroll_run - payroll found',5);
               fnd_message.set_name ('PAY', 'PAY_52232_TAX_LOC_CHNG');
               l_returned_warning :=  fnd_message.get;
              close csr_chk_payroll;
            else
               hr_utility.set_location('pay_us_emp_tax_rules.check_payroll_run - No payroll run',6);
               fnd_message.set_name ('PAY', 'PAY_52233_TAX_LOC_CHNG_OVRD');
               l_returned_warning :=  fnd_message.get;
               close csr_chk_payroll;
           end if;   /* End csr_chk_payroll%found */
         end if;     /* End check_payroll_run_enabled=1 */
      else
           l_location_id_changed := 0;
      end if;        /* End l_location_id <> p_new_location_id */
    end if;          /* Federal record found */
   end if;           /* End csr_chk_loc_change%NOTFOUND */
 end if;             /* hr_utility.chk_product_install */

 return l_returned_warning1 || l_returned_warning;

end check_payroll_run;


/* Name       : check_in_work_location

   Purpose    : To check if the state has ever been assigned as the state of
                a work location for the assignment.

   Parameter  : ret_code = 1    -> State/County/City has been assigned
                                   as work location
                                   of the assignment.
                ret_code = 0    -> State/County/City has never been
                                   assigned as the work location of
                                   the assignment.
		ret_code = 2	-> State/County/City has been assigned as the
				   taxation location of assignment.
*/

procedure check_in_work_location ( p_assignment_id  in number,
                                   p_state_code     in varchar2,
                                   p_county_code    in varchar2,
                                   p_city_code      in varchar2,
                                   p_ret_code       in out NOCOPY number,
                                   p_ret_text       in out NOCOPY varchar2) is

  l_code number;

/* Cursor to check if the state has been assigned as the state of a work
   location of the assignment. */

/* begin modifications - dscully 21-JUN-2000 */
/* modified cursors to check _both_ mailing and taxation address, instead of one or the other */
/* created three new cursors to check taxation location jurisdictions */

CURSOR csr_check_state is
       select 1
       from   HR_LOCATIONS           hrl,
              PER_ASSIGNMENTS_F      paf
       where  paf.assignment_id   = p_assignment_id
       and    hrl.location_id     = paf.location_id
       and    exists (select null
                      from PAY_US_STATES pus
               where pus.state_abbrev in (hrl.loc_information17,hrl.region_2)
               and pus.state_code  = p_state_code);

CURSOR csr_check_ovrd_state is
       select 1
       from   HR_LOCATIONS           hrl,
              HR_SOFT_CODING_KEYFLEX hscf,
              PER_ASSIGNMENTS_F      paf
       where  paf.assignment_id   = p_assignment_id
       and    hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
       and    hrl.location_id     = hscf.segment18
       and    exists (select null
                      from PAY_US_STATES pus
               where pus.state_abbrev in (hrl.loc_information17,hrl.region_2)
               and pus.state_code  = p_state_code);

/* Cursor to check if the county has been assigned as the county of a work
   location of the assignment. */

CURSOR csr_check_county is
       select 1
       from   HR_LOCATIONS        hrl,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    hrl.location_id     = paf.location_id
       and    exists (select null
                      from PAY_US_COUNTIES puc,
                           PAY_US_STATES pus
               where ((pus.state_abbrev = hrl.loc_information17
		       and puc.county_name  = hrl.loc_information19)
		      or
		      (pus.state_abbrev = hrl.region_2
		       and puc.county_name  = hrl.region_1))
               and pus.state_code   = p_state_code
               and puc.state_code   = pus.state_code
               and puc.county_code  = p_county_code);

CURSOR csr_check_ovrd_county is
       select 1
       from   HR_LOCATIONS        hrl,
              HR_SOFT_CODING_KEYFleX hscf,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
       and    hrl.location_id     = hscf.segment18
       and    exists (select null
                      from PAY_US_COUNTIES puc,
                           PAY_US_STATES pus
               where ((pus.state_abbrev = hrl.loc_information17
		       and puc.county_name  = hrl.loc_information19)
		      or
		      (pus.state_abbrev = hrl.region_2
		       and puc.county_name  = hrl.region_1))
               and pus.state_code   = p_state_code
               and puc.state_code   = pus.state_code
               and puc.county_code  = p_county_code);

/* Cursor to check if the city has been assigned as the city of a work
   location of the assignment. */

CURSOR csr_check_city is
       select 1
       from   HR_LOCATIONS        hrl,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    hrl.location_id     = paf.location_id
       and    exists (select null
                      from PAY_US_CITY_NAMES   puci,
                           PAY_US_COUNTIES puco,
                           PAY_US_STATES pus
               where ((pus.state_abbrev = hrl.loc_information17
               	       and puco.county_name  = hrl.loc_information19
                       and puci.city_name   = hrl.loc_information18)
		      or
		      (pus.state_abbrev = hrl.region_2
               	       and puco.county_name  = hrl.region_1
                       and puci.city_name   = hrl.town_or_city))
               and pus.state_code   = p_state_code
               and puco.state_code  = pus.state_code
               and puco.county_code = p_county_code
               and puci.state_code  = pus.state_code
               and puci.county_code = puco.county_code
               and puci.city_code   = p_city_code);

CURSOR csr_check_ovrd_city is
       select 1
       from   HR_LOCATIONS        hrl,
              HR_SOFT_CODING_KEYFLEX hscf,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
       and    hrl.location_id     = hscf.segment18
       and    exists (select null
                      from PAY_US_CITY_NAMES   puci,
                           PAY_US_COUNTIES puco,
                           PAY_US_STATES pus
               where ((pus.state_abbrev = hrl.loc_information17
               	       and puco.county_name  = hrl.loc_information19
                       and puci.city_name   = hrl.loc_information18)
		      or
		      (pus.state_abbrev = hrl.region_2
               	       and puco.county_name  = hrl.region_1
                       and puci.city_name   = hrl.town_or_city))
               and pus.state_code   = p_state_code
               and puco.state_code  = pus.state_code
               and puco.county_code = p_county_code
               and puci.state_code  = pus.state_code
               and puci.county_code = puco.county_code
               and puci.city_code   = p_city_code);

begin

     if (p_state_code is not null and p_county_code is null
         and p_city_code is null)
     then

         /* Check if the state has been assigned to the work location */

         open csr_check_state;

         fetch csr_check_state into l_code;

         if csr_check_state%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_work_location' ||
               ' - found work location',1);
            p_ret_code := 1;
            p_ret_text := 'State assigned to work location';
         else

	    open csr_check_ovrd_state;
	    fetch csr_check_ovrd_state into l_code;
	    if csr_check_ovrd_state%FOUND then
	            hr_utility.set_location(
	               'pay_us_emp_tax_rules.check_in_work_location' ||
	               ' - found taxation location',1);
	            p_ret_code := 2;
	            p_ret_text := 'State assigned to taxation location';
	    else
	            hr_utility.set_location(
	               'pay_us_emp_tax_rules.check_in_work_location' ||
	               ' - not in  work or taxation location',1);
	            p_ret_code := 0;
	            p_ret_text := 'State not assigned to work or taxation location';

	    end if;

	    close csr_check_ovrd_state;
         end if;

         close csr_check_state;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is null)
     then

         /* Check if the county has been assigned to the work location */

         open csr_check_county;

         fetch csr_check_county into l_code;

         if csr_check_county%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_work_location' ||
               ' - found work location',2);
            p_ret_code := 1;
            p_ret_text := 'County assigned to work location';
         else
            open csr_check_ovrd_county;

            fetch csr_check_ovrd_county into l_code;

            if csr_check_ovrd_county%FOUND then

            	hr_utility.set_location(
            	   'pay_us_emp_tax_rules.check_in_work_location' ||
            	   ' - found taxation location',2);
            	p_ret_code := 2;
            	p_ret_text := 'County assigned to taxation location';

	   else

            	hr_utility.set_location(
            	   'pay_us_emp_tax_rules.check_in_work_location' ||
            	   ' - not in work location',2);
            	p_ret_code := 0;
            	p_ret_text := 'County not assigned to work or taxation location';

	   end if;

	   close csr_check_ovrd_county;
         end if;

         close csr_check_county;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is not null)
     then

         /* Check if the city has been assigned to the work location */

         open csr_check_city;

         fetch csr_check_city into l_code;

         if csr_check_city%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_work_location' ||
               ' - found work location',3);
            p_ret_code := 1;
            p_ret_text := 'City assigned to work location';

         else

            open csr_check_ovrd_city;

            fetch csr_check_ovrd_city into l_code;

            if csr_check_ovrd_city%FOUND then

            	hr_utility.set_location(
            	   'pay_us_emp_tax_rules.check_in_work_location' ||
            	   ' - found taxationk location',3);
            	p_ret_code := 2;
            	p_ret_text := 'City assigned to taxation location';

	    else
            	hr_utility.set_location(
            	   'pay_us_emp_tax_rules.check_in_work_location' ||
            	   ' - not in work location',7);
            	p_ret_code := 0;
            	p_ret_text := 'City not assigned to work or taxation location';
	    end if;

	    close csr_check_ovrd_city;

         end if;

         close csr_check_city;

     end if;

/* end modifications - dscully 21-JUN-2000 */

end check_in_work_location;


/* Name       : check_in_res_addr

   Purpose    : To check if the state has ever been assigned as the state
                of a resident address for the assignment.

   Parameter  : ret_code = 1    -> State/County/City has been assigned
                                   as resident address of the assignment.
                ret_code = 0    -> State/County/City has never been
                                   assigned as resident address of
                                   the assignment.
*/


procedure check_in_res_addr ( p_assignment_id  in number,
                              p_state_code     in varchar2,
                              p_county_code    in varchar2,
                              p_city_code      in varchar2,
                              p_ret_code       in out NOCOPY number,
                              p_ret_text       in out NOCOPY varchar2) is

  l_code number;

/* Cursor to check if the state has been assigned as the state of a
   resident address of the assignment. */

/* begin modifications - dscully 21-JUN-2000 */
/* modified cursors to check _both_ mailing and taxation address, instead of one or the other */

CURSOR csr_check_state is
       select 1
       from   PER_ADDRESSES       pa,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    pa.person_id        = paf.person_id
       and    exists (select null
                      from PAY_US_STATES pus
                        where pus.state_abbrev in (pa.add_information17,pa.region_2)
                          and pus.state_code   = p_state_code);

/* Cursor to check if the county has been assigned as the county of a
   resident address of the assignment. */

CURSOR csr_check_county is
       select 1
       from   PER_ADDRESSES       pa,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    pa.person_id        = paf.person_id
       and    exists (select null
                      from PAY_US_COUNTIES puc,
                           PAY_US_STATES pus
                      where ((pus.state_abbrev = pa.add_information17
                              and puc.county_name  = pa.add_information19)
			     or
			     (pus.state_abbrev = pa.region_2
                              and puc.county_name  = pa.region_1))
                        and pus.state_code   = p_state_code
                        and puc.state_code   = pus.state_code
                        and puc.county_code  = p_county_code);

/* Cursor to check if the city has been assigned as the city of a
   resident address of the assignment. */

CURSOR csr_check_city is
       select 1
       from   PER_ADDRESSES       pa,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id   = p_assignment_id
       and    pa.person_id        = paf.person_id
       and    exists (select null
                      from PAY_US_CITY_NAMES   puci,
                           PAY_US_COUNTIES puco,
                           PAY_US_STATES pus
                      where ((pus.state_abbrev = pa.add_information17
                              and puco.county_name = pa.add_information19
                              and puci.city_name   = pa.add_information18)
			     or
			     (pus.state_abbrev = pa.region_2
                              and puco.county_name = pa.region_1
                              and puci.city_name   = pa.town_or_city))
                        and pus.state_code   = p_state_code
                        and puco.state_code  = pus.state_code
                        and puco.county_code = p_county_code
                        and puci.state_code  = pus.state_code
                        and puci.county_code = puco.county_code
                        and puci.city_code   = p_city_code);

/* end modifications - dscully 21-JUN-2000 */

begin

     if (p_state_code is not null and p_county_code is null
         and p_city_code is null)
     then

         /* Check if the state has been assigned to the resident addr.*/

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - opening cursor',1);

         open csr_check_state;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - fetching cursor',2);

         fetch csr_check_state into l_code;

         if csr_check_state%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr' ||
               ' - found work location',3);

            p_ret_code := 1;
            p_ret_text := 'State assigned to resident address.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr'||
               ' - did not find work location',4);

            p_ret_code := 0;
            p_ret_text := 'State not assigned to resident address.';

         end if;

         close csr_check_state;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is null)
     then

         /* Check if the county has been assigned to resident addr. */

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - opening cursor',5);

         open csr_check_county;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - fetching cursor',6);

         fetch csr_check_county into l_code;

         if csr_check_county%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr' ||
               ' - found work location',7);

            p_ret_code := 1;
            p_ret_text := 'County assigned to resident address.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr'||
               ' - did not find work location',8);

            p_ret_code := 0;
            p_ret_text := 'County not assigned to resident address.';

         end if;

         close csr_check_county;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is not null)
     then

         /* Check if the city has been assigned to resident addr. */

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - opening cursor',9);

         open csr_check_city;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.check_in_res_addr'||
            ' - fetching cursor',10);

         fetch csr_check_city into l_code;

         if csr_check_city%FOUND then
            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr' ||
               ' - found work location',11);

            p_ret_code := 1;
            p_ret_text := 'City assigned to resident address.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.check_in_res_addr'||
               ' - did not find work location',12);

            p_ret_code := 0;
            p_ret_text := 'City not assigned to resident address.';

         end if;

         close csr_check_city;

     end if;

end check_in_res_addr;


/* Name       : payroll_check_for_purge

   Purpose    : Before a state tax rules record is allowed to be purged,
                a call will be made to this procedure to check if a
                payroll has been run for that state.
                Similary before a county/city tax rules record is
                allowed to be purged, a check will be made by calling
                this procedure to check if it has been used in a
                payroll run or not.
                Refer Business Rule#12 under 'New Business Rules'
                section of the W4 date track HLD.

   Parameter  : ret_code = 1    -> Payroll has been run for the
                                   State/County/City.
                ret_code = 0    -> Payroll has not been run for the
                                   State/County/City.
*/

procedure payroll_check_for_purge ( p_assignment_id  in number,
                                    p_state_code     in varchar2,
                                    p_county_code    in varchar2,
                                    p_city_code      in varchar2,
                                    p_ret_code       in out NOCOPY number,
                                    p_ret_text       in out NOCOPY varchar2) is

  l_code     number;

/* Cursor to check if a payroll has been run for the state. */

CURSOR csr_check_state_purge is
/* 11.5.10 changes  performance modification. original code
   commented out below. */

    select 1
      from per_assignments_f paf
           ,pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_run_results prr
      where  substr(prr.jurisdiction_code,1,2) = p_state_code
      and    paf.assignment_id = p_assignment_id
      and    ppa.payroll_id = paf.payroll_id
      and    ppa.action_type in ('E', 'Q','R')
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    paa.assignment_id =  paf.assignment_id
      and    paa.assignment_action_id = prr.assignment_action_id ;

/*       select 1
       from   pay_run_results   prr,
              pay_assignment_actions paa
       where  substr(prr.jurisdiction_code,1,2) = p_state_code
         and  paa.assignment_action_id = prr.assignment_action_id
         and  paa.assignment_id = p_assignment_id
         and exists ( select null
                      from pay_payroll_actions ppa
                      where ppa.payroll_action_id = paa.payroll_action_id
                        and ppa.action_type in ('E','Q','R'));
*/
/* Cursor to check if a payroll has been run for the county. */

CURSOR csr_check_county_purge is
/* 11.5.10 changes  performance modification. original code
   commented out below. */
    select 1
      from per_assignments_f paf
           ,pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_run_results prr
      where  substr(prr.jurisdiction_code,1,6) = p_state_code || '-'||
                                                 p_county_code
      and    paf.assignment_id = p_assignment_id
      and    ppa.payroll_id = paf.payroll_id
      and    ppa.action_type in ('E', 'Q','R')
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    paa.assignment_id =  paf.assignment_id
      and    paa.assignment_action_id = prr.assignment_action_id ;

/*
       select 1
       from   pay_run_results   prr,
              pay_assignment_actions paa
       where  substr(prr.jurisdiction_code,1,6) = p_state_code || '-'||
                                                  p_county_code
         and  paa.assignment_action_id = prr.assignment_action_id
         and  paa.assignment_id = p_assignment_id
         and exists ( select null
                      from pay_payroll_actions ppa
                      where ppa.payroll_action_id = paa.payroll_action_id
                        and ppa.action_type in ('E','Q','R'));
*/

/* Cursor to check if a payroll has been run for the city. */

CURSOR csr_check_city_purge is

/* 11.5.10 changes  performance modification. original code
   commented out below. */
    select 1
      from per_assignments_f paf
           ,pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_run_results prr
       where  prr.jurisdiction_code = p_state_code || '-'||
                                        p_county_code ||'-'||p_city_code
      and    paf.assignment_id = p_assignment_id
      and    ppa.payroll_id = paf.payroll_id
      and    ppa.action_type in ('E', 'Q','R')
      and    ppa.payroll_action_id = paa.payroll_action_id
      and    paa.assignment_id =  paf.assignment_id
      and    paa.assignment_action_id = prr.assignment_action_id ;

/*       select 1
       from   pay_run_results   prr,
              pay_assignment_actions paa
       where  prr.jurisdiction_code = p_state_code || '-'||
                                        p_county_code ||'-'||p_city_code
         and  paa.assignment_action_id = prr.assignment_action_id
         and  paa.assignment_id = p_assignment_id
         and exists ( select null
                      from pay_payroll_actions ppa
                      where ppa.payroll_action_id = paa.payroll_action_id
                        and ppa.action_type in ('E','Q','R'));
*/

begin

     if (p_state_code is not null and p_county_code is null
         and p_city_code is null)
     then

         /* Check if payroll has been run the state tax rule record */

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - opening cursor',1);

         open csr_check_state_purge;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - fetching cursor',2);

         fetch csr_check_state_purge into l_code;

         if csr_check_state_purge%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge' ||
               ' - found work location',3);

            p_ret_code := 1;
            p_ret_text := 'Payroll has been run for the state.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge'||
               ' - did not find work location',4);

            p_ret_code := 0;
            p_ret_text := 'Payroll has not been run for the state.';

         end if;

         close csr_check_state_purge;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is null)
     then

         /* Check if the county has been assigned to the work location */

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - opening cursor',5);

         open csr_check_county_purge;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - fetching cursor',6);

         fetch csr_check_county_purge into l_code;

         if csr_check_county_purge%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge' ||
               ' - found work location',7);

            p_ret_code := 1;
            p_ret_text := 'Payroll has been run for the county.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge'||
               ' - did not find work location',8);

            p_ret_code := 0;
            p_ret_text := 'Payroll has not been run for the county.';

         end if;

         close csr_check_county_purge;

     elsif (p_state_code is not null and p_county_code is not null
            and p_city_code is not null)
     then

         /* Check if the city has been assigned to the work location */

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - opening cursor',9);

         open csr_check_city_purge;

         hr_utility.set_location(
            'pay_us_emp_tax_rules.payroll_check_for_purge'||
            ' - fetching cursor',10);

         fetch csr_check_city_purge into l_code;

         if csr_check_city_purge%FOUND then

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge' ||
               ' - found work location',11);

            p_ret_code := 1;
            p_ret_text := 'Payroll has been run for the city.';

         else

            hr_utility.set_location(
               'pay_us_emp_tax_rules.payroll_check_for_purge'||
               ' - did not find work location',12);

            p_ret_code := 0;
            p_ret_text := 'Payroll has not been run for the city.';

         end if;

         close csr_check_city_purge;

     end if;

end payroll_check_for_purge;

procedure check_school_district (p_assignment  in number,
                                 p_start_date in date,
                                 p_end_date   in date,
                                 p_mode       in varchar2,
                                 p_rowid      in varchar2) is

  l_code number;

  cursor chk_ins_sd is
    select 1
    from PAY_US_EMP_COUNTY_TAX_RULES_F pcf
    where pcf.assignment_id = p_assignment
    and   pcf.school_district_code is not null
    and   pcf.effective_end_date >= p_start_date
    and   pcf.effective_start_date <= p_end_date
    UNION ALL
    select 1
    from PAY_US_EMP_CITY_TAX_RULES_F pcif
    where pcif.assignment_id = p_assignment
    and   pcif.school_district_code is not null
    and   pcif.effective_end_date >= p_start_date
    and   pcif.effective_start_date <= p_end_date;

  cursor chk_upd_sd is
    select 1
    from PAY_US_EMP_COUNTY_TAX_RULES_F pcf
    where pcf.assignment_id = p_assignment
    and   pcf.school_district_code is not null
    and   pcf.effective_end_date >= p_start_date
    and   pcf.effective_start_date <= p_end_date
    and   rowid <> chartorowid(p_rowid)
    UNION ALL
    select 1
    from PAY_US_EMP_CITY_TAX_RULES_F pcif
    where pcif.assignment_id = p_assignment
    and   pcif.school_district_code is not null
    and   pcif.effective_end_date >= p_start_date
    and   pcif.effective_start_date <= p_end_date
    and   rowid <> chartorowid(p_rowid);
  begin

     if p_mode = 'I' then

        open chk_ins_sd;
        fetch chk_ins_sd into l_code;

        if chk_ins_sd%FOUND then
           fnd_message.set_name ('PAY', 'PAY_52300_TAX_SD_ASGN');
           fnd_message.raise_error;
        end if;

        close chk_ins_sd;

     elsif p_mode = 'U' then

        open chk_upd_sd;
        fetch chk_upd_sd into l_code;

        if chk_upd_sd%FOUND then
           fnd_message.set_name ('PAY', 'PAY_52300_TAX_SD_ASGN');
           fnd_message.raise_error;
        end if;

        close chk_upd_sd;

     end if;


  end check_school_district;

function check_locations (  p_assignment_id        in number,
			    p_effective_start_date in date,
			    p_business_group_id    in number) return boolean is

  cursor csr_get_curr_loc is
  select location_id,
         effective_start_date,
         effective_end_date
  from  per_assignments_f
  where assignment_id = p_assignment_id
  and   business_group_id + 0 = p_business_group_id
  and   p_effective_start_date between effective_start_date
        and effective_end_date;

  cursor csr_get_future_locations (p_validation_date date)is
  select location_id
  from   per_assignments_f
  where  assignment_id = p_assignment_id
  and   business_group_id + 0 = p_business_group_id
  and    effective_start_date > p_validation_date;

  l_curr_loc_id       number;
  l_next_loc_id       number;
  l_curr_eff_start_dt date;
  l_curr_eff_end_dt   date;
  l_found             boolean;

  begin

       open csr_get_curr_loc;

       fetch csr_get_curr_loc into l_curr_loc_id,
                               l_curr_eff_start_dt,
                               l_curr_eff_end_dt;

      if csr_get_curr_loc%NOTFOUND then
         fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
         fnd_message.set_token('PROCEDURE',
                        'pay_us_emp_dt_tax_rules.check_locations');
         fnd_message.set_token('STEP','1');
         fnd_message.raise_error;
         close csr_get_curr_loc;

      end if;

      close csr_get_curr_loc;

      l_found := FALSE;

      open csr_get_future_locations(l_curr_eff_end_dt);

      loop
          fetch csr_get_future_locations into l_next_loc_id;
          exit when csr_get_future_locations%NOTFOUND;
          if l_next_loc_id <> l_curr_loc_id then
             l_found := TRUE;
             exit;
          end if;
      end loop;

      close csr_get_future_locations;

      return l_found;

end check_locations;


procedure  get_res_codes (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_state_code        out NOCOPY varchar2,
                          p_res_county_code       out NOCOPY varchar2,
                          p_res_city_code         out NOCOPY varchar2,
                          p_res_state_name        out NOCOPY varchar2,
                          p_res_county_name       out NOCOPY varchar2,
                          p_res_city_name         out NOCOPY varchar2) is

/* Cursor to get the resident state, county and city codes */
cursor csr_get_res is
       select pus.state_code,
	      puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
       from   PAY_US_CITY_NAMES   puci,
              PAY_US_COUNTIES     puc,
              PAY_US_STATES       pus,
              PER_ADDRESSES       pa,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    pa.person_id              = paf.person_id
       and    pa.primary_flag           = 'Y'
       and    p_session_date between pa.date_from and
                                     nvl(pa.date_to,p_session_date)
       and    pus.state_abbrev          = nvl(pa.add_information17,pa.region_2)
       and    puc.state_code            = pus.state_code
       and    puc.county_name           = nvl(pa.add_information19,pa.region_1)
       and    puci.state_code           = pus.state_code
       and    puci.county_code          = puc.county_code
       and    puci.city_name         = nvl(pa.add_information18,pa.town_or_city);

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_res_work',1);

  /* Get the resident address details */

  open  csr_get_res;

  fetch csr_get_res into p_res_state_code,
                         p_res_county_code,
                         p_res_city_code,
                         p_res_state_name,
                         p_res_county_name,
                         p_res_city_name;

  if csr_get_res%NOTFOUND then

     p_res_state_code      := null;
     p_res_county_code     := null;
     p_res_city_code       := null;
     p_res_state_name      := null;
     p_res_county_name     := null;
     p_res_city_name       := null;

  end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_res_work',2);

  close csr_get_res;

end get_res_codes;


/* Name     : get_work_codes
   Purpose  : To get the work state code, work state name, work city code,
              work city name, work county code and work county name. This
              procedure will also be called by the tax form PAYEETAX.fmb,
              to get the names of the wok state and localities */

procedure  get_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       out NOCOPY varchar2,
                           p_work_county_code      out NOCOPY varchar2,
                           p_work_city_code        out NOCOPY varchar2,
                           p_work_state_name       out NOCOPY varchar2,
                           p_work_county_name      out NOCOPY varchar2,
                           p_work_city_name        out NOCOPY varchar2) is

/* Cursor to get the work state, county and city */

cursor csr_get_work is
       select pus.state_code,
              puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
       from   PAY_US_CITY_NAMES      puci,
              PAY_US_COUNTIES        puc,
              PAY_US_STATES          pus,
              HR_LOCATIONS           hrl,
              HR_SOFT_CODING_KEYFLEX hscf,
              PER_ASSIGNMENTS_F      paf
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    hscf.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
       and    nvl(hscf.segment18,paf.location_id) = hrl.location_id
       and    pus.state_abbrev         = nvl(hrl.loc_information17,hrl.region_2)
       and    puc.state_code           = pus.state_code
       and    puc.county_name          = nvl(hrl.loc_information19,hrl.region_1)
       and    puci.state_code          = pus.state_code
       and    puci.county_code         = puc.county_code
       and    puci.city_name      = nvl(hrl.loc_information18,hrl.town_or_city);

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',1);

  /* Get the work location details */

  open  csr_get_work;

  fetch csr_get_work into p_work_state_code,
                          p_work_county_code,
                          p_work_city_code,
                          p_work_state_name,
                          p_work_county_name,
                          p_work_city_name;

  if csr_get_work%NOTFOUND then

     p_work_state_code   := null;
     p_work_county_code  := null;
     p_work_city_code    := null;
     p_work_state_name   := null;
     p_work_county_name  := null;
     p_work_city_name    := null;

  end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',3);

  close csr_get_work;

end get_work_codes;


/* Name      : check_jurisdiction_exists
   Purpose   : To check if the tax record already exists for a jurisdcition
               or not
*/

procedure check_jurisdiction_exists (p_assignment_id        in number,
                                     p_jurisdiction_code    in varchar2,
                                     p_ret_code             in out NOCOPY number,
                                     p_ret_text             in out NOCOPY varchar2) is


  l_code         number;


  /* Cursor to check if age record already exists for a jurisdiction.
     Since a %age tax record cannot exist without a tax rule record,
     doing a check on the tax rule tables will will be same as doing
     a check on the element entries table. */

  cursor csr_check_state (p_jurisdiction varchar2) is
  select 1
  from   PAY_US_EMP_STATE_TAX_RULES_F str
  where  str.assignment_id = p_assignment_id
  and    str.jurisdiction_code = p_jurisdiction;

  cursor csr_check_county (p_jurisdiction varchar2) is
  select 1
  from   PAY_US_EMP_COUNTY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    ctr.jurisdiction_code = p_jurisdiction;

  cursor csr_check_city (p_jurisdiction varchar2) is
  select 1
  from   PAY_US_EMP_CITY_TAX_RULES_F ctr
  where  ctr.assignment_id = p_assignment_id
  and    ctr.jurisdiction_code = p_jurisdiction;

  begin

      /* state */
      if substr(p_jurisdiction_code,3,9) = '-000-0000' then

      	 open csr_check_state(p_jurisdiction_code);
      	 fetch csr_check_state into l_code ;
      	 if csr_check_state%NOTFOUND then
       	   p_ret_code := 1;
       	   p_ret_text := '%age record not found ';
      	 else
       	   p_ret_code := 0;
       	   p_ret_text := '%age record found ';
      	 end if;
      	 close csr_check_state;

       /* County */
      elsif substr(p_jurisdiction_code,3,4) <> '-000' and
            substr(p_jurisdiction_code,7,5) = '-0000' then

      	 open csr_check_county(p_jurisdiction_code);
      	 fetch csr_check_county into l_code;
      	 if csr_check_county%NOTFOUND then
       	   p_ret_code := 1;
       	   p_ret_text := '%age record not found ';
      	 else
       	   p_ret_code := 0;
       	   p_ret_text := '%age record found ';
      	 end if;
      	 close csr_check_county;

       /* City */
       else

      	 open csr_check_city(p_jurisdiction_code);
      	 fetch csr_check_city into l_code;
      	 if csr_check_city%NOTFOUND then
       	   p_ret_code := 1;
       	   p_ret_text := '%age record not found ';
      	 else
       	   p_ret_code := 0;
       	   p_ret_text := '%age record found ';
      	 end if;
      	 close csr_check_city;

       end if;

end check_jurisdiction_exists;


procedure check_delete_tax_row ( p_assignment_id in number,
                                 p_state_code    in varchar2,
                                 p_county_code   in varchar2,
                                 p_city_code     in varchar2) is

  l_ret_code             number;
  l_ret_text             varchar2(240);
  l_jurisdiction_code    varchar2(11);
  l_effective_start_date date;
  l_payroll_installed    boolean := FALSE;

  begin

         /* Check if payroll has been installed or not */

         l_payroll_installed := hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                                               p_legislation => 'US');

        /* Check if the state/county/city has been assigned to a
           work location */

        l_ret_code := 0;
        l_ret_text := null;

        pay_us_emp_dt_tax_val.check_in_work_location (
                                  p_assignment_id    => p_assignment_id,
                                  p_state_code       => p_state_code,
                                  p_county_code      => p_county_code,
                                  p_city_code        => p_city_code,
                                  p_ret_code         => l_ret_code,
                                  p_ret_text         => l_ret_text);

	/* begin modifications - dscully 21-JUN-2000 */

        if l_ret_code = 1 then

           if p_state_code is not null and p_county_code is null
              and p_city_code is null then

             fnd_message.set_name('PAY', 'PAY_52293_TAX_STDEL_LOC');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is null then

             fnd_message.set_name('PAY', 'PAY_52294_TAX_CODEL_LOC');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is not null then

             fnd_message.set_name('PAY', 'PAY_52295_TAX_CIEL_LOC');
             fnd_message.raise_error;

           end if;

        elsif l_ret_code = 2 then

           if p_state_code is not null and p_county_code is null
              and p_city_code is null then

             fnd_message.set_name('PAY', 'PAY_76860_TAX_STDEL_TAX_LOC');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is null then

             fnd_message.set_name('PAY', 'PAY_76861_TAX_CODEL_TAX_LOC');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is not null then

             fnd_message.set_name('PAY', 'PAY_76862_TAX_CIDEL_TAX_LOC');
             fnd_message.raise_error;

           end if;

        end if;


	/* end modifications - dscully 21-JUN-2000 */

        /* Check if the state/county/city has been assigned to
           the resident address */

        l_ret_code := 0;
        l_ret_text := null;

        pay_us_emp_dt_tax_val.check_in_res_addr (
                                  p_assignment_id    => p_assignment_id,
                                  p_state_code       => p_state_code,
                                  p_county_code      => p_county_code,
                                  p_city_code        => p_city_code,
                                  p_ret_code         => l_ret_code,
                                  p_ret_text         => l_ret_text);

        if l_ret_code <> 0 then

           if p_state_code is not null and p_county_code is null
              and p_city_code is null then

             /* fnd_message.set_name('Cannot delete. State assigned to resident address') */
             fnd_message.set_name('PAY', 'PAY_52296_TAX_STDEL_RES');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is null then

             /* fnd_message.set_name('Cannot delete. County assigned to resident address') */
             fnd_message.set_name('PAY', 'PAY_52297_TAX_CODEL_RES');
             fnd_message.raise_error;

           elsif p_state_code is not null and p_county_code is not null
              and p_city_code is not null then

             /* fnd_message.set_name('Cannot delete. City assigned to resident address') */
             fnd_message.set_name('PAY', 'PAY_52298_TAX_CIDEL_RES');
             fnd_message.raise_error;

           end if;

        end if;

        /* Check if payroll has been run for the state/county/city */

        if l_payroll_installed then

           l_ret_code := 0;
           l_ret_text := null;

           pay_us_emp_dt_tax_val.payroll_check_for_purge (
                                     p_assignment_id    => p_assignment_id,
                                     p_state_code       => p_state_code,
                                     p_county_code      => p_county_code,
                                     p_city_code        => p_city_code,
                                     p_ret_code         => l_ret_code,
                                     p_ret_text         => l_ret_text);

           if l_ret_code <> 0 then

              if p_state_code is not null and p_county_code is null
                 and p_city_code is null then

                /* fnd_message.set_name('Cannot delete. Payroll has been run ') */
                fnd_message.set_name('PAY', 'PAY_52235_TAX_RULE_DELETE');
                fnd_message.raise_error;

              elsif p_state_code is not null and p_county_code is not null
                 and p_city_code is null then

                /* fnd_message.set_name('Cannot delete. Payroll has been run ') */
                fnd_message.set_name('PAY', 'PAY_52235_TAX_RULE_DELETE');
                fnd_message.raise_error;

              elsif p_state_code is not null and p_county_code is not null
                 and p_city_code is not null then

                /* fnd_message.set_name('Cannot delete. Payroll has been run ') */
                fnd_message.set_name('PAY', 'PAY_52235_TAX_RULE_DELETE');
                fnd_message.raise_error;

              end if;

           end if;

       end if;

end check_delete_tax_row;

/* Name     : get_all_work_codes
   Purpose  : To get the work state code, work state name, work city code,
              work city name, work county code,work county name, override work
              state code, override work state name, override work city code,
              override work city name, override work county code and override
              work county name. */

procedure  get_all_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       in out NOCOPY varchar2,
                           p_work_county_code      in out NOCOPY varchar2,
                           p_work_city_code        in out NOCOPY varchar2,
                           p_work_state_name       in out NOCOPY varchar2,
                           p_work_county_name      in out NOCOPY varchar2,
                           p_work_city_name        in out NOCOPY varchar2,
                           p_work1_state_code      in out NOCOPY varchar2,
                           p_work1_county_code     in out NOCOPY varchar2,
                           p_work1_city_code       in out NOCOPY varchar2,
                           p_work1_state_name      in out NOCOPY varchar2,
                           p_work1_county_name     in out NOCOPY varchar2,
                           p_work1_city_name       in out NOCOPY varchar2,
                           p_work2_state_code      in out NOCOPY varchar2,
                           p_work2_county_code     in out NOCOPY varchar2,
                           p_work2_city_code       in out NOCOPY varchar2,
                           p_work2_state_name      in out NOCOPY varchar2,
                           p_work2_county_name     in out NOCOPY varchar2,
                           p_work2_city_name       in out NOCOPY varchar2,
                           p_work3_state_code      in out NOCOPY varchar2,
                           p_work3_county_code     in out NOCOPY varchar2,
                           p_work3_city_code       in out NOCOPY varchar2,
                           p_work3_state_name      in out NOCOPY varchar2,
                           p_work3_county_name     in out NOCOPY varchar2,
                           p_work3_city_name       in out NOCOPY varchar2,
                           p_sui_state_code        in out NOCOPY varchar2,
                           p_loc_city              in out NOCOPY varchar2) is



/* Override Assignment Data */
cursor csr_get_asgn_locations is
      select paf.location_id, hsc.segment18
      from   HR_SOFT_CODING_KEYFLEX hsc,
             PER_ASSIGNMENTS_F      paf
      where  paf.assignment_id        = p_assignment_id
      and    p_session_date between paf.effective_start_date and
                                    paf.effective_end_date
      and    hsc.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

cursor csr_get_work_location(cp_location_id number) is
       select pus.state_code,
              puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
        from  PAY_US_CITY_NAMES   puci,
              PAY_US_COUNTIES     puc,
              PAY_US_STATES       pus,
              HR_LOCATIONS        hrl
       where  hrl.location_id   = cp_location_id
       and    pus.state_abbrev  = hrl.region_2
       and    puc.state_code    = pus.state_code
       and    puc.county_name   = hrl.region_1
       and    puci.state_code   = pus.state_code
       and    puci.county_code  = puc.county_code
       and    puci.city_name    = hrl.town_or_city;

cursor csr_get_override_work_location(cp_location_id number) is
       select pus.state_code,
              puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
        from  PAY_US_CITY_NAMES   puci,
              PAY_US_COUNTIES     puc,
              PAY_US_STATES       pus,
              HR_LOCATIONS        hrl
       where  hrl.location_id  = cp_location_id
       and    pus.state_abbrev = hrl.loc_information17
       and    puc.state_code   = pus.state_code
       and    puc.county_name  = hrl.loc_information19
       and    puci.state_code  = pus.state_code
       and    puci.county_code = puc.county_code
       and    puci.city_name   = hrl.loc_information18;

   l_work_location_id  number;
   l_ovrd_location_id  number;

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',1);
  /* Primary Work Address */
  p_work_state_code   := null;
  p_work_county_code  := null;
  p_work_city_code    := null;
  p_work_state_name   := null;
  p_work_county_name  := null;
  p_work_city_name    := null;

  /* Primary Work Override Address */
  p_work1_state_code   := null;
  p_work1_county_code  := null;
  p_work1_city_code    := null;
  p_work1_state_name   := null;
  p_work1_county_name  := null;
  p_work1_city_name    := null;

  /* Override Work Address */
  p_work2_state_code   := null;
  p_work2_county_code  := null;
  p_work2_city_code    := null;
  p_work2_state_name   := null;
  p_work2_county_name  := null;
  p_work2_city_name    := null;

  /* Override Override Work Address */
  p_work3_state_code   := null;
  p_work3_county_code  := null;
  p_work3_city_code    := null;
  p_work3_state_name   := null;
  p_work3_county_name  := null;
  p_work3_city_name    := null;

  /* Get Assignment Locations */
  open csr_get_asgn_locations;
  fetch csr_get_asgn_locations into
                       l_work_location_id,
                       l_ovrd_location_id;

  /* Get the work location details */
  if csr_get_asgn_locations%found then

     /* Primary Location is found, so get the Primary Work Details
        and Override details for that location (if any). */
     if l_work_location_id is not null then

        open  csr_get_work_location(l_work_location_id);
        fetch csr_get_work_location into
                          /* Primary Work Address */
                             p_work_state_code,
                             p_work_county_code,
                             p_work_city_code,
                             p_work_state_name,
                             p_work_county_name,
                             p_work_city_name;
        close csr_get_work_location;

        open  csr_get_override_work_location(l_work_location_id);
        fetch csr_get_override_work_location into
                          /* Primary Work Override Address */
                             p_work1_state_code,
                             p_work1_county_code,
                             p_work1_city_code,
                             p_work1_state_name,
                             p_work1_county_name,
                             p_work1_city_name;
        close csr_get_override_work_location;

        /* Checking if the Work and Override are same. In Case they are
           setting the paramaters for the Overide Location to NULL */
        if p_work_state_code = p_work1_state_code and
           p_work_county_code = p_work1_county_code and
           p_work_city_code = p_work1_city_code then
           p_work1_state_code   := null;
           p_work1_state_name   := null;
           p_work1_county_code  := null;
           p_work1_county_name  := null;
           p_work1_city_code  := null;
           p_work1_city_name  := null;
        end if;

     end if; /* Primary Location was found for the Assignment */


     /* Override Location is found, so get the Override Work Details
        and Override details for that Override Location (if any). */
     if l_ovrd_location_id is not null then

        open  csr_get_work_location(l_ovrd_location_id);
        fetch csr_get_work_location into
                          /* Override Work Address */
                             p_work2_state_code,
                             p_work2_county_code,
                             p_work2_city_code,
                             p_work2_state_name,
                             p_work2_county_name,
                             p_work2_city_name;

        close csr_get_work_location;

        open  csr_get_override_work_location(l_ovrd_location_id);
        fetch csr_get_override_work_location into
                          /* Override Work Override Address */
                             p_work3_state_code,
                             p_work3_county_code,
                             p_work3_city_code,
                             p_work3_state_name,
                             p_work3_county_name,
                             p_work3_city_name;

        close csr_get_override_work_location;

        /* Checking if the Work Override and Override Override are same.
           In Case they are setting the paramaters for the Overide
           Overide Location to NULL */
        if p_work2_state_code = p_work3_state_code and
              p_work2_county_code = p_work3_county_code and
              p_work2_city_code = p_work3_city_code then
           p_work3_state_code   := null;
           p_work3_state_name   := null;
           p_work3_county_code  := null;
           p_work3_county_name  := null;
           p_work3_city_code  := null;
           p_work3_city_name  := null;
        end if;

     end if; /* Primary Location was found for the Assignment */

  end if; /* Assignment Record Found */
  close csr_get_asgn_locations;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',3);
  if p_work3_state_code is not null then
     p_sui_state_code := p_work3_state_code;
  elsif p_work2_state_code is not null then
     p_sui_state_code := p_work2_state_code;
  elsif p_work1_state_code is not null then
     p_sui_state_code := p_work1_state_code;
  elsif p_work_state_code is not null then
     p_sui_state_code := p_work_state_code;
  end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',4);

  if p_work3_city_code is not null then
     p_loc_city := p_work3_state_code || '-' || p_work3_county_code || '-'||p_work3_city_code;
  elsif p_work2_city_code is not null then
     p_loc_city := p_work2_state_code || '-' || p_work2_county_code || '-'||p_work2_city_code;
  elsif p_work1_city_code is not null then
     p_loc_city := p_work1_state_code || '-' || p_work1_county_code || '-'||p_work1_city_code;
  elsif p_work_city_code is not null then
     p_loc_city := p_work_state_code || '-' || p_work_county_code || '-'||p_work_city_code;
  end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_work_codes',5);
end get_all_work_codes;

procedure  get_orig_res_codes (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_state_code        out NOCOPY varchar2,
                          p_res_county_code       out NOCOPY varchar2,
                          p_res_city_code         out NOCOPY varchar2,
                          p_res_state_name        out NOCOPY varchar2,
                          p_res_county_name       out NOCOPY varchar2,
                          p_res_city_name         out NOCOPY varchar2) is

/* Cursor to get the resident state, county and city codes */
cursor csr_get_res is
       select pus.state_code,
	      puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
       from   PAY_US_CITY_NAMES   puci,
              PAY_US_COUNTIES     puc,
              PAY_US_STATES       pus,
              PER_ADDRESSES       pa,
              PER_ASSIGNMENTS_F   paf
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    pa.person_id              = paf.person_id
       and    pa.primary_flag           = 'Y'
       and    p_session_date between pa.date_from and
                                     nvl(pa.date_to,to_date('12/31/4712','MM/DD/YYYY'))
       and    pus.state_abbrev          = pa.region_2
       and    puc.state_code            = pus.state_code
       and    puc.county_name           = pa.region_1
       and    puci.state_code           = pus.state_code
       and    puci.county_code          = puc.county_code
       and    puci.city_name            = pa.town_or_city;

begin

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_orig_res_codes',1);

  /* Get the resident address details */

  open  csr_get_res;

  fetch csr_get_res into p_res_state_code,
                         p_res_county_code,
                         p_res_city_code,
                         p_res_state_name,
                         p_res_county_name,
                         p_res_city_name;

  if csr_get_res%NOTFOUND then

     p_res_state_code      := null;
     p_res_county_code     := null;
     p_res_city_code       := null;
     p_res_state_name      := null;
     p_res_county_name     := null;
     p_res_city_name       := null;

  end if;

  hr_utility.set_location('pay_us_emp_dt_tax_rules.get_orig_res_codes',2);

  close csr_get_res;

end get_orig_res_codes;
end pay_us_emp_dt_tax_val;

/
