--------------------------------------------------------
--  DDL for Package Body PAY_US_FS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_FS_UPD_PKG" as
/* $Header: pyusfsup.pkb 120.0 2005/05/29 09:30 appldev noship $ */



PROCEDURE update_report_fs_rec (p_pest_state_code     IN VARCHAR2,
                                           p_pest_fs_code        IN VARCHAR2,
                                           p_pest_id             IN NUMBER,
                                           p_session_id          IN NUMBER,
                                           p_bug_number          IN NUMBER,
                                           p_new_fs_code         IN VARCHAR2 )

IS

BEGIN

   begin

        insert into pay_us_rpt_totals
                    (attribute1, value1, value2, state_code, attribute2,
                     attribute3, attribute4, business_group_id, session_id,
                     tax_unit_id)
		        select  ppf.full_name ,
                        paf.assignment_id ,
                        paf.person_id ,
                        taxrule.state_code ,
                        to_char(taxrule.effective_start_date, 'DD-MON-YYYY'),
                        to_char(taxrule.effective_end_date, 'DD-MON-YYYY'),
                        taxrule.filing_status_code ,
                        taxrule.business_group_id ,
                        p_session_id, p_bug_number
  			    from pay_us_emp_state_tax_rules_f taxrule,
       		  	     per_assignments_f paf,
       			     per_all_people_f ppf
 		        where taxrule.state_code = p_pest_state_code
   		        and   taxrule.filing_status_code = p_pest_fs_code
                and   emp_state_tax_rule_id = p_pest_id
    		    and   taxrule.assignment_id = paf.assignment_id
                and   taxrule.effective_start_date between
                                              paf.effective_start_date
                                          and paf.effective_end_date
                and   taxrule.business_group_id = paf.business_group_id
                and   paf.person_id             = ppf.person_id
                and   taxrule.effective_start_date between
                                              ppf.effective_start_date
                                          and ppf.effective_end_date

--                order by paf.assignment_id
                ;

   exception
      when no_data_found then
            null;
   end;


   update pay_us_emp_state_tax_rules_f
   set    filing_status_code = p_new_fs_code
   where  state_code = p_pest_state_code
   and    filing_status_code =  p_pest_fs_code
   and    emp_state_tax_rule_id = p_pest_id;

END update_report_fs_rec;

PROCEDURE update_filing_status(
                          p_tax_rule_id_start IN NUMBER,
                          p_tax_rule_id_end   IN NUMBER )

IS
CURSOR filing_status_cur IS
select state_code, filing_status_code, emp_state_tax_rule_id
  from pay_us_emp_state_tax_rules_f
 where emp_state_tax_rule_id between
       p_tax_rule_id_start and p_tax_rule_id_end ;

filing_status_rec        filing_status_cur%ROWTYPE;

l_error_message_text  varchar2(240);
l_session_id          number  ;
l_bug_no              number;

BEGIN

l_bug_no              := 2735805 ;

hr_utility.trace('Entering pay_us_fs_upd_pkg.update_filing_status');

hr_utility.trace('The start tax rule id is:  '||to_char(p_tax_rule_id_start));
hr_utility.trace('The start tax rule id is:  '||to_char(p_tax_rule_id_end));

select userenv('sessionid')
  into l_session_id
  from dual;


OPEN filing_status_cur ;
             LOOP
             FETCH filing_status_cur into filing_status_rec;
             EXIT WHEN filing_status_cur%NOTFOUND;

hr_utility.set_location('pay_us_fs_upd_pkg.update_filing_status',1);


          IF    filing_status_rec.state_code = '03' and
                filing_status_rec.filing_status_code in ( '04', '03', '02' )
                THEN
                hr_utility.set_location('Arizona',2);


                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
/* removed updates of Arkansas and Calif as they are not valid updates */

/*          ELSIF filing_status_rec.state_code = '04' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Arkansas',3);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '05' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('California',4);


                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
*/

          ELSIF filing_status_rec.state_code = '06' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Colorado ',5);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

/* No Conversion required for Connecticut

          ELSIF filing_status_rec.state_code = '07' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Connecticut',6);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '05' ) ;
*/

          ELSIF filing_status_rec.state_code = '08' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Delaware',7);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '11' and
                filing_status_rec.filing_status_code = '04'
                THEN
                hr_utility.set_location('Georgia',8);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '12' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Hawaii',9);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '13' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Idaho',10);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

           ELSIF filing_status_rec.state_code = '14' and
                 filing_status_rec.filing_status_code in ( '03', '02')
                 THEN
                 hr_utility.set_location('Illinois',11);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '15' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Indiana',12);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '16' and
                filing_status_rec.filing_status_code in ('03', '04')
                THEN
                hr_utility.set_location('Iowa',13);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '17' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Kansas',14);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '18' and
                filing_status_rec.filing_status_code in ( '04', '03','02')
                THEN
                hr_utility.set_location('Kentucky',15);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' )  ;

          ELSIF filing_status_rec.state_code = '19' and
                filing_status_rec.filing_status_code in ( '04', '03', '02' )
                THEN
                hr_utility.set_location('Louisiana',16);


                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '20' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Maine',17);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '21' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Maryland',18);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '22' and
                filing_status_rec.filing_status_code in ( '02', '04')
                THEN
                hr_utility.set_location('Massachusetts',19);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '23' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Michigan',20);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '24' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Minnesota',22);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
/* There is no requirement to convert Head of Household FS for
   Misourri */

/*
          ELSIF filing_status_rec.state_code = '26' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Missouri',23);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
*/

          ELSIF filing_status_rec.state_code = '27' and
                filing_status_rec.filing_status_code IN (  '03' )
                THEN
                hr_utility.set_location('Montana',24);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '28' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Nebraska',25);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
/*
          ELSIF filing_status_rec.state_code = '31' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('New Jersey',26);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
*/

          ELSIF filing_status_rec.state_code = '32' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('New Mexico',27);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '33' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('New York',28);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

/*  Bug 3455165: "Qualified Widower" no longer a valid filing status for New York State */

          ELSIF filing_status_rec.state_code = '33' and
                filing_status_rec.filing_status_code = '05'  --Qualifying Widower
                THEN
                hr_utility.set_location('New York',28);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

/* There is not requirement to convert Head of Household
   for North Carolina */

/*
          ELSIF filing_status_rec.state_code = '34' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('North Carolina',29);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;
*/

          ELSIF filing_status_rec.state_code = '35' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('North Dakota',30);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '36' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Ohio',31);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '37' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Oklahoma',32);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' )  ;

          ELSIF filing_status_rec.state_code = '37' and
                filing_status_rec.filing_status_code = '04'
                THEN
                hr_utility.set_location('Oklahoma',32.1);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' )  ;

          ELSIF filing_status_rec.state_code = '39' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Pennsylvania',33);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '40' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Rhode Island',34);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '41' and
                filing_status_rec.filing_status_code in ( '03' )
                THEN
                hr_utility.set_location('South Carolina',35);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '46' and
                filing_status_rec.filing_status_code = '03'
                THEN
                hr_utility.set_location('Vermont',36);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '47' and
                filing_status_rec.filing_status_code in ( '03', '02')
                THEN
                hr_utility.set_location('Virginia',37);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          ELSIF filing_status_rec.state_code = '49' and
                filing_status_rec.filing_status_code in  ( '02', '03' )
                THEN
                hr_utility.set_location('West Virginia',38);

                update_report_fs_rec (
                                            p_pest_state_code =>
                                              filing_status_rec.state_code,
                                            p_pest_fs_code         =>
                                              filing_status_rec.filing_status_code,
                                            p_pest_id             =>
                                              filing_status_rec.emp_state_tax_rule_id,
                                            p_session_id          => l_session_id,
                                            p_bug_number          => l_bug_no,
                                            p_new_fs_code         => '01' ) ;

          END IF;
          commit;

hr_utility.set_location('pay_us_fs_upd_pkg.update_filing_status',40);

             END LOOP ;
CLOSE filing_status_cur ;

hr_utility.set_location('pay_us_fs_upd_pkg.update_filing_status',45);

EXCEPTION
  WHEN OTHERS THEN
        l_error_message_text := to_char(SQLCODE)||SQLERRM||
                             ' Program error contact support';
        rollback;

hr_utility.set_location('pay_us_fs_upd_pkg.update_filing_status',50);
raise_application_error(-20001,l_error_message_text);

--
--
--
--commit;
END update_filing_status ;
--
--
--
--

END pay_us_fs_upd_pkg;


/
