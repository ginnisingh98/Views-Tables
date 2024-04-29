--------------------------------------------------------
--  DDL for Package Body PAY_US_LOC_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_LOC_CHANGE" as
/* $Header: pyuslocu.pkb 120.1.12010000.2 2008/08/06 08:33:05 ubhat ship $ */


/* Script to get the vaule of person's assignment detail
    insert the values into temporary table and delete the values from
    temporary table once the data is printed.
*/

PROCEDURE cnt_print_report
IS
      l6_wait           BOOLEAN;
      l6_phase          VARCHAR2(30);
      l6_status         VARCHAR2(30);
      l6_dev_phase      VARCHAR2(30);
      l6_dev_status     VARCHAR2(30);
      l6_message        VARCHAR2(255);
      l_rep_req_id             NUMBER;

      l_session_id      number;

BEGIN
      hr_utility.trace('Entering the cnt_print_report');
      l_rep_req_id := fnd_request.submit_request(application    => 'PAY',
                                                 program        => 'LOCCHNREP');

      select userenv('sessionid')
      into l_session_id
      from dual;

      IF(l_rep_req_id = 0) THEN
           hr_utility.trace(' Error While Location change  Report' );
           hr_utility.raise_error;
      ELSE
         hr_utility.trace(' Concurrent Request Id (Report Spool Request) : '
                                         ||to_char(l_rep_req_id));
      END IF; /* if l_rep_req_id */

      COMMIT;

     /* Wait for report request completion */
      hr_utility.trace('Waiting for the application to get completed ');

      /* Check for Report Request Status */

      l6_wait := fnd_concurrent.wait_for_request
                 (request_id => l_rep_req_id
                 ,interval   => 1
                 ,phase      => l6_phase
                 ,status     => l6_status
                 ,dev_phase  => l6_dev_phase
                 ,dev_status => l6_dev_status
                 ,message    => l6_message);

     hr_utility.trace('Wait completed,Printing output based on the result');

     IF NOT (l6_dev_phase = 'COMPLETE' and l6_dev_status = 'NORMAL') THEN
             hr_utility.trace('SQL Report Exited with error') ;
     ELSE
             hr_utility.trace('SQL Report Successful');
     END IF; /* l6_dev_phase */


     DELETE
       FROM pay_us_rpt_totals
      WHERE attribute20 = 'LOCATION_CHANGE'
      AND   organization_id = l_session_id;

     COMMIT;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
               hr_utility.trace('Exception  : No data Found');
         WHEN OTHERS THEN
              hr_utility.trace('Excption    : When Others');
END cnt_print_report;



PROCEDURE get_insert_values (  p_proc_name                VARCHAR2,
                               p_assignment_id            NUMBER,
                               p_location_id              NUMBER,
                               p_gre_name          IN OUT NOCOPY VARCHAR2,
                               p_full_name         IN OUT NOCOPY VARCHAR2,
                               p_assignment_number IN OUT NOCOPY VARCHAR2,
                               p_location_code     IN OUT NOCOPY VARCHAR2)
IS

 /* cursor to get the person's assignment detail  */

CURSOR  csr_assignment_tax_detail
    IS
SELECT  hou.Name,
        ppf.full_name,
        paf.assignment_number
  FROM
        hr_organization_units hou,
        hr_soft_coding_keyflex hsck,
        per_people_f ppf,
        per_assignments_f paf
 WHERE
        paf.assignment_id = p_assignment_id
   AND  paf.person_id     = ppf.person_id
   AND  paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
   AND  hsck.segment1 = hou.organization_id
-- Changing the cursor to pick up the most recent date
   AND  ppf.effective_start_date = (select max(ppf_inner.effective_start_date)
                                    from per_people_f ppf_inner
                                    where ppf_inner.person_id = ppf.person_id) ;
/* cursor to get location code */

CURSOR  csr_location_code
    IS
SELECT  location_code
  FROM  hr_locations
 WHERE  location_id = p_location_id;

l_proc_name varchar2(50) := 'get_insert_value';

 BEGIN
  hr_utility.trace('In proc : get_insert_values');
  hr_utility.trace('Assignment Id : ' || to_char(p_assignment_id));
  hr_utility.trace('Location Id   :  ' || to_char(p_location_id));

  IF  p_proc_name = 'LOCATION_CHANGE' THEN

        hr_utility.trace('Entering : ' || l_proc_name);

        /* get the detail of the person */

        OPEN csr_assignment_tax_detail;

        FETCH csr_assignment_tax_detail
         INTO p_gre_name,
              p_full_name,
              p_assignment_number;

       IF csr_assignment_tax_detail%NOTFOUND THEN
             hr_utility.trace('csr_assignment_tax_datail_failed');
       END IF;


       CLOSE csr_assignment_tax_detail;


    /* get the location Code for the location id */

       OPEN  csr_location_code;

      FETCH  csr_location_code
       INTO  p_location_code;


   END IF;
   hr_utility.trace('GRE NAME         : ' || p_gre_name);
   hr_utility.trace('Full NAME        : ' || p_full_name);
   hr_utility.trace('Assignment Number: ' || p_assignment_number);
   hr_utility.trace('Location Code    : ' || p_location_code);

   hr_utility.trace('Leaving : ' || l_proc_name);
EXCEPTION
    WHEN OTHERS THEN
    hr_utility.trace('Leaving : ' || l_proc_name || ' With Erorr' );

END  get_insert_values ;


/* Mapping of the Temp. table and value are as follows
   tax_unit_name       -     GRE_NAME
   location_code       -     LOCATION_code
   full_name           -     Attribute1
   EMP_assignement_no  -     ATTRUBITE2
   effective_start_date-     ATTRIBUTE3
   effective_end_date  -     ATTRIBUTE4
   error message       -     ATTRIBUTE5
 */

procedure  put_into_temp_table(
                                  p_tax_unit_name in varchar2,
                                  p_location_code in varchar2,
                                  p_emp_full_name in varchar2,
                                  p_assignment_number in varchar2,
                                  p_effective_start_date in date,
                                  p_effective_end_date  in date,
				  p_error in varchar2
                                  )
IS
l_success_failure_indicator number;
l_proc_name               varchar2(50) := 'put_into_temp_table';
l_session_id              number;

BEGIN
       hr_utility.trace('Entering :' || l_proc_name);

       select userenv('sessionid')
       into l_session_id
       from dual;

        INSERT
          INTO    pay_us_rpt_totals
               (
                  organization_id,
                  gre_name,
                  location_name,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute20
               )
        VALUES (
                  l_session_id,
                  p_tax_unit_name,
                  p_location_code,
                  p_emp_full_name,
                  p_assignment_number,
                  to_char(p_effective_start_date,'mm/dd/yyyy'),
                  to_char(p_effective_end_date,'mm/dd/yyyy'),
                  p_error,
                  'LOCATION_CHANGE');


        hr_utility.trace('Leaving : ' || l_proc_name);
EXCEPTION

     WHEN others THEN
        hr_utility.trace('Error in the Instertion into temporary Table');
END put_into_temp_table;


procedure update_tax(errbuf     OUT     NOCOPY VARCHAR2,
                     retcode    OUT     NOCOPY NUMBER,
                     p_location_id in number) is

 l_ret_code             number;
 l_ret_text		varchar2(1000);
 l_assignment_id        per_assignments_f.assignment_id%type;
 l_gre_name             hr_tax_units_v.name%type;
 l_location_code         hr_locations.location_code%type;
 l_full_name            per_people_f.full_name%type;
 l_assignment_number    per_assignments_f.assignment_number%type;
 l_location_id		number;
 l_error		varchar2(1000);
 l_assignment_status    varchar2(1);

 l_tbl_location_id   number;
 l_tbl_start_date    date;
 l_tbl_end_date      date;
 l_tmp_location_id   number;

 cur_location_id number;
 cur_ovr_location_id number;
 cur_start_date  date;
 cur_end_date    date;



 /* Get the employees who have the location. */
/* Rmonge 18-NOV-2002  Modifying cursor to add ASSIGMENT_TYPE  */
/* We need to check if the assignment being process is a Benefits Assignment.*/
/* If it is then, we do not want to process the record */


 cursor csr_get_employee (p_loc_id number) is
  select  /*+ index(hsck HR_SOFT_CODING_KEYFLEX_PK) */ paf.assignment_id assignment_id,
	      paf.person_id,
          max(paf.effective_end_date) effective_end_date,
          min(paf.effective_start_date) effective_start_date,
          paf.business_group_id,
          paf.assignment_type
  from    per_all_assignments_f paf,
	      hr_soft_coding_keyflex hsck
  where  (paf.location_id = p_loc_id
  or      hsck.segment18 = to_char(p_loc_id))   -- #3056158
  and 	  hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
  group by assignment_id,
	      paf.person_id,
          paf.business_group_id,
          paf.assignment_type
  ;

 Cursor csr_assignment_locations(p_assignment_id number,
				      p_def_date date) is
  select   paf.location_id,
           hsck.segment18,
           paf.effective_start_date,
           paf.effective_end_date
  from     per_all_assignments_f paf,
           hr_soft_coding_keyflex hsck
  where    paf.assignment_id = p_assignment_id
  and      hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
  and      effective_start_date >= p_def_date
  order by effective_start_date;

begin
    --hr_utility.trace_on(NULL,'PYLC');
    hr_utility.trace('In Proc. UPDATE_TAX');

     for emp_rec in csr_get_employee(p_location_id) loop
     l_error := ' '; --bug 3265603

/*   Rmonge 18-JAN-2002  BUG 2110744 */

HR_UTILITY.TRACE('THE ASSIGNMENT TYPE IS '||emp_rec.assignment_type);
       if emp_rec.assignment_type <> 'B'  Then

HR_UTILITY.TRACE('Assignment Type is not B');

        l_tmp_location_id := null;
        l_tbl_location_id := null;
        l_tbl_start_date := null;
        l_tbl_end_date := null;

        Open csr_assignment_locations(emp_rec.assignment_id,
                                      emp_rec.effective_start_date);
         Fetch csr_assignment_locations
          into cur_location_id,
               cur_ovr_location_id,
               cur_start_date,
               cur_end_date;

         if csr_assignment_locations%FOUND then
            --

            if cur_location_id = p_location_id or cur_ovr_location_id = p_location_id then
               l_tmp_location_id := p_location_id;
            else
               l_tmp_location_id := cur_location_id;
            end if;


            l_tbl_location_id := l_tmp_location_id;
            l_tbl_start_date := cur_start_date;
            l_tbl_end_date := cur_end_date;
            While csr_assignment_locations%FOUND loop
               --
               hr_utility.set_location('update_tax', 55);
               --
               --
               -- Store all assignment records.
               --
               Fetch csr_assignment_locations
                  into cur_location_id,
                       cur_ovr_location_id,
                       cur_start_date,
                       cur_end_date;

               if csr_assignment_locations%FOUND then
hr_utility.trace('Assignment location found ');
hr_utility.trace('Cur location id is ' || to_char(cur_location_id));
hr_utility.trace('P_location_id is ' || to_char(p_location_id));
hr_utility.trace('cur_ovr_location_id is '||to_char(cur_ovr_location_id));

                  if cur_location_id = p_location_id or cur_ovr_location_id = p_location_id then
                     l_tmp_location_id := p_location_id;
                  else
                     l_tmp_location_id := cur_location_id;
                  end if;
hr_utility.trace('l_tbl_location_id is '|| to_char(l_tbl_location_id));

                  if l_tbl_location_id <> l_tmp_location_id then
hr_utility.trace('l_tbl_location_id <> l_tmp_location id ');

                     if l_tbl_location_id = p_location_id then
hr_utility.trace('l_tbl_location_id = p_location_id ');
                        begin

		                  pay_us_emp_dt_tax_rules.default_tax_with_validation(
			              p_assignment_id        => emp_rec.assignment_id,
                          p_person_id            => emp_rec.person_id,
                          p_effective_start_date => l_tbl_start_date,
                          p_effective_end_date   => l_tbl_end_date,
                          p_session_date         => l_tbl_start_date,
                          p_business_group_id    => emp_rec.business_group_id,
                          p_from_form            => 'Assignment',
                          p_mode                 => 'CORRECTION',
                          p_location_id          => p_location_id,
                          p_return_code          => l_ret_code,
                          p_return_text          => l_ret_text);

		                  l_error := null;

                	    exception
	                    When others then
		                l_error := SQLERRM;
	                   end;
                     end if;
                     l_tbl_location_id := l_tmp_location_id;
                     l_tbl_start_date := cur_start_date;
                     l_tbl_end_date := cur_end_date;
                  else
                     l_tbl_end_date := cur_end_date;
                  end if;
               else
 hr_utility.trace('l_tbl_location_id = p_location_id');

                     if l_tbl_location_id = p_location_id then
                        begin
  		                  pay_us_emp_dt_tax_rules.default_tax_with_validation(
			              p_assignment_id        => emp_rec.assignment_id,
                          p_person_id            => emp_rec.person_id,
                          p_effective_start_date => l_tbl_start_date,
                          p_effective_end_date   => l_tbl_end_date,
                          p_session_date         => l_tbl_start_date,
                          p_business_group_id    => emp_rec.business_group_id,
                          p_from_form            => 'Assignment',
                          p_mode                 => 'CORRECTION',
                          p_location_id          => p_location_id,
                          p_return_code          => l_ret_code,
                          p_return_text          => l_ret_text);
                	    exception
	                    When others then
		                l_error := SQLERRM;
	                   end;

                     end if;
               end if;
            End loop;
          end if;
          close csr_assignment_locations;

         get_insert_values(
			'LOCATION_CHANGE',
                        emp_rec.assignment_id,
                        p_location_id,
                        l_gre_name,
                        l_full_name,
                        l_assignment_number,
                        l_location_code);

         put_into_temp_table(p_tax_unit_name => l_gre_name ,
                        p_location_code => l_location_code ,
                        p_emp_full_name => l_full_name ,
                        p_assignment_number => l_assignment_number,
                        p_effective_start_date => emp_rec.effective_start_date ,
                        p_effective_end_date => emp_rec.effective_end_date ,
			p_error => l_error);

         end if; /* assignment_type <> 'B' */
    	end loop;


    cnt_print_report;
end update_tax;
end pay_us_loc_change;

/
