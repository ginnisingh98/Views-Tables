--------------------------------------------------------
--  DDL for Package Body PAY_US_MMREF_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MMREF_FUNCTION_PKG" as
/* $Header: pyusmrfn.pkb 120.1.12010000.2 2008/11/05 07:47:35 pannapur ship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_mmref_function_pkg

  Purpose
    The purpose of this package is to support the generation of magnetic tape W2
    reports for US legilsative requirements incorporating magtape resilience
    and the new end-of-year design. New Functions will support the Year end
    reporting in MMREF format initially and will be extended to have more
    format.


  History
   23-Jan-02 fusman        115.0          created
   14-may-02 fusman        115.1          Added Get_Hours_Worked function.
   10-Jun-02 fusman        115.2 2404709  Removed the padding in NH hours calc.
   11-Nov-02 ppanda        115.3          For Rita/CCA city code in
                                            pay_us_city_tax_info_f.city_information1
                                          starts from 6 char position. This changes
                                          made to generalised the Local Mag Tape
   02-Dec-02 ppanda        115.4          Nocopy hint added to OUT and IN OUT parameters
   19-FEB-03 sodhingr      115.5          Changed Get_hours_worked for bug
					  2442629, to pass new balances for SUI
			                  hours by state
   23-Apr-03 fusman        115.6  2873551 Created new function get_sqwl_extra_info to calculate
                                          the SUI_ER_SUBJ_WHABLE and SUI_ER_PRE_TAX.
   15-May-03 fusman        115.7  2873584 Added SSA,ICESA,NJ formula hour calculations to the function.
   16-May-03 fusman        115.8          Changed the data types of values that are being calculated.
   02-Jun-03 fusman        115.9  2985476 Negative hour checking for Non-mmref states.
                                  2873584 Exclusion of Sick hours for WA SQWL.
   29-Aug-03 fusman        115.10 3092981 Split the cursor GET_ARCHIVED_VALUE in Get_Sqwl_Extra_Info
   27-FEB-04 Jgoswami      115.12 3334497 Added out parameters to Get_Sqwl_Extra_Inf
                                          Changed GET_ARCHIVED_VALUE to get value >= 0
   09-MAR-04 JGoswami      115.13 3489556 Modified Get_Hours_Worked function to return
                                          Regular Hours Worked for Vermont (VT).
   07-MAY-04 JGoswami      115.14 3414759 Modified Get_Hours_Worked function to return
                                          Hours  for Minnesota(MN) and Oregon(OR).
   16-JUL-04 JGoswami      115.15 3770719 Modified Get_Hours_Worked function to return
                                          Regular Hours for Minnesota(MN) and Oregon(OR)
                                          when Hours Worked Calculation Method is not set
                                          to Balance.
   25-NOV-07 sjawid        115.16 6613661 Modified Get_Hours_Worked function to return
                                          Worked weeks and hours for the State "RI" and
					  Report type "SSA_SQWL".
	 05-Nov-08 Pannapur      115.17 7458671  Reverted the fix made in 2873584 . Including
	                                          Sick hours for WA SQWL .

*/

  FUNCTION Get_City_Values(p_jurisdiction_code    IN  varchar2,
                           p_effective_date       IN  varchar2,
                           p_input_1              IN varchar2,
                           p_input_2              IN varchar2,
                           p_input_3              IN varchar2,
                           p_input_4              IN varchar2,
                           p_input_5              IN varchar2,
                           sp_out_1               OUT nocopy varchar2,
                           sp_out_2               OUT nocopy varchar2,
                           sp_out_3               OUT nocopy varchar2,
                           sp_out_4               OUT nocopy varchar2,
                           sp_out_5               OUT nocopy varchar2,
                           sp_out_6               OUT nocopy varchar2,
                           sp_out_7               OUT nocopy varchar2,
                           sp_out_8               OUT nocopy varchar2,
                           sp_out_9               OUT nocopy varchar2,
                           sp_out_10              OUT nocopy varchar2)

  return varchar2

  IS

  CURSOR GET_CITY_NAME(c_jurisdiction_code varchar2)
  IS
  SELECT city_name
  FROM pay_us_city_names
  WHERE state_code = substr(c_jurisdiction_code,1,2)
  AND   county_code = substr(c_jurisdiction_code,4,3)
  AND city_code = substr(c_jurisdiction_code,8,4)
  AND primary_flag = 'Y';

  CURSOR GET_CITY_CODE(c_jurisdiction_code varchar2,
                       c_date varchar2)
  IS
/* City code starts from 5 instead of 4 in city_information1 column in
   pay_us_city_tax_info_f table. This changes made to generalise the Local Mag Tape */
  SELECT substr(city_information1,1,5),
         substr(city_information1,6)
  FROM  pay_us_city_tax_info_f
  WHERE  to_date(c_date,'dd-mm-yyyy') between effective_start_date
                and effective_end_date
  AND jurisdiction_code = c_jurisdiction_code;

  l_city_value varchar2(10);
  l_city_id varchar2(10);
  l_city_name pay_us_city_names.city_name%TYPE;

  Begin

     hr_utility.trace('Get_City_Values');
     hr_utility.trace('p_jurisdiction_code = '||p_jurisdiction_code);

     OPEN GET_CITY_NAME(p_jurisdiction_code);
     hr_utility.trace('OPEN GET_CITY_NAME');
     FETCH GET_CITY_NAME INTO l_city_name;
     hr_utility.trace('FETCH GET_CITY_NAME '||l_city_name);

     IF GET_CITY_NAME%NOTFOUND THEN

        hr_utility.trace('No city found with this jurisdiction code = '||p_jurisdiction_code);
        pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','A');
        pay_core_utils.push_token('record_name','jurisdiction '||p_jurisdiction_code);
        pay_core_utils.push_token('description','City not found in pay_us_city_names.');
        l_city_name := ' ';

     END IF;

     CLOSE GET_CITY_NAME;

     OPEN GET_CITY_CODE(p_jurisdiction_code,p_effective_date);
     hr_utility.trace('OPEN GET_CITY_CODE');
     FETCH GET_CITY_CODE INTO l_city_value,l_city_id;
     hr_utility.trace('FETCH GET_CITY_CODE '||l_city_id);

     IF GET_CITY_CODE%NOTFOUND THEN

        hr_utility.trace('No city information found for jurisdiction code = '||p_jurisdiction_code);
        pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','A');
        pay_core_utils.push_token('record_name','jurisdiction '||p_jurisdiction_code
                                                       ||' in '||'pay_us_city_tax_info_f');
        pay_core_utils.push_token('description','City tax infm not found.');

        sp_out_1 := ' ';
        sp_out_2 := ' ';

     ELSIF GET_CITY_CODE%FOUND THEN

        sp_out_1 := l_city_value;
        sp_out_2 := l_city_id;
        hr_utility.trace('city information found');
        hr_utility.trace('l_city_value = '||l_city_value);
        hr_utility.trace('l_city_id = '||l_city_id);

     END IF;

     RETURN l_city_name;

  END;


  FUNCTION Get_Hours_Worked(
                          p_report_type          IN  varchar2,
                          p_report_qualifier     IN  varchar2,
                          p_record_name          IN varchar2,
                          p_regular_hours        IN number,
                          p_sui_er_gross         IN number,
                          p_gross_earnings       IN number,
                          p_asg_hours            IN number,
                          p_asg_freq             IN varchar2,
                          p_scl_asg_work_sch     IN varchar2,
                          p_input_1              IN varchar2,
                          p_input_2              IN varchar2,
                          sp_out_1               IN OUT nocopy varchar2,
                          sp_out_2               IN OUT nocopy varchar2,
                          sp_out_3               IN OUT nocopy varchar2,
                          sp_out_4               IN OUT nocopy varchar2,
                          sp_out_5               IN OUT nocopy varchar2)


  return varchar2 IS
  l_hours_worked number(10) :=0;
  l_hours_per_week number(10);
  l_output_hours varchar2(100);
  l_add_days date;
  lv_jd_sick_hrs number(10);
  lv_jd_vacn_hrs number(10);
  lv_jd_reg_hrs number(10);
  lv_jd_ot_hrs number(10);

  Begin

     hr_utility.trace('Get_Hours_Worked');
     hr_utility.trace('p_report_qualifier = '||p_report_qualifier);
     hr_utility.trace('p_scl_asg_work_sch = '||p_scl_asg_work_sch);
     hr_utility.trace('p_input_1 = '||p_input_1);

     /* Bug:2873584 WA does not include Sick hours. */
     /* Bug :7458671 WA include sick hours for non-Qualified plans */
     /*IF p_report_qualifier = 'WA_SQWL' THEN

        sp_out_1 :=0;

     END IF; */

     IF p_gross_earnings <> 0 THEN
	IF p_input_2 = 'B' THEN

           /* sp_out_1 = A_SUI_SICK_HOURS_BY_STATE_PER_JD_GRE_QTD
              sp_out_2 = A_SUI_VACATION_HOURS_BY_STATE_PER_JD_GRE_QTD
              sp_out_3 = A_SUI_REGULAR_HOURS_BY_STATE_PER_JD_GRE_QTD
              sp_out_4 = A_SUI_OVERTIME_HOURS_BY_STATE_PER_JD_GRE_QTD */

              lv_jd_sick_hrs := sp_out_1;
              lv_jd_vacn_hrs := sp_out_2;
              lv_jd_reg_hrs := sp_out_3;
              lv_jd_ot_hrs := sp_out_4;

	       l_hours_worked := nvl(to_number(sp_out_1),0) + nvl(to_number(sp_out_2),0)
				+ nvl(to_number(sp_out_3),0) + nvl(to_number(sp_out_4),0);

                hr_utility.trace('sp_out_1 = '||sp_out_1);
                hr_utility.trace('sp_out_2 = '||sp_out_2);
                hr_utility.trace('sp_out_3 = '||sp_out_3);
                hr_utility.trace('sp_out_4 = '||sp_out_4);
	ELSE
	        l_hours_worked := p_regular_hours*p_sui_er_gross/p_gross_earnings;
        	hr_utility.trace('p_regular_hours = '||to_char(p_regular_hours));
	        hr_utility.trace('p_sui_er_gross = '||to_char(p_sui_er_gross));
       		hr_utility.trace('p_gross_earnings = '||to_char(p_gross_earnings));
	        hr_utility.trace('p_gross_earnings <>0. l_hours_worked = '||to_char(l_hours_worked));
	END IF;
     END IF;

     IF l_hours_worked <0 THEN /* Negative Hour checking*/

        IF ((p_report_qualifier = 'MA_SQWL') OR
            (p_report_qualifier = 'OH_SQWL') OR
            (p_report_qualifier = 'WY_SQWL') OR
            (p_report_qualifier = 'DE_SQWL') OR
            (p_report_qualifier = 'NJ_SQWL') OR
            (p_report_qualifier = 'PA_SQWL')) THEN

            sp_out_5 :='Y';
            hr_utility.trace(' l_hours_worked is negative = '||to_char(l_hours_worked));

        END IF;

     END IF;

        IF p_scl_asg_work_sch = '99999' THEN

            hr_utility.trace('p_scl_asg_work_sch = 99999 ');

           l_add_days := fffunc.add_days(sysdate,6);
           l_hours_per_week :=  hr_us_ff_udfs.Standard_Hours_Worked(
                                                    p_asg_hours,
                                                    sysdate,
                                                    l_add_days,
                                                    p_asg_freq);
           hr_utility.trace('p_report_qualifier = NH.p_scl_asg_work_sch  was defaulted');
           hr_utility.trace('l_add_days = '||l_add_days);
           hr_utility.trace('l_hours_per_week = '||to_char(l_hours_per_week));

        ELSE

           l_hours_per_week := hr_us_ff_udfs.work_schedule_total_hours(to_number(p_input_1),
                                                                       p_scl_asg_work_sch,
                                                                       null,
                                                                       null);
           hr_utility.trace('p_scl_asg_work_sch = '||p_scl_asg_work_sch);
           hr_utility.trace('l_hours_per_week = '||to_char(l_hours_per_week));


        END IF;

        IF l_hours_per_week = 0 THEN

           l_output_hours := '00';

        ELSE

           hr_utility.trace('l_hours_per_week <> 0 ');
           hr_utility.trace('l_hours_worked = '||l_hours_worked);
           l_output_hours := lpad(to_char(ceil(l_hours_worked/l_hours_per_week)),2,'0');
           hr_utility.trace('l_output_hours = '||l_output_hours);

           IF to_number(l_output_hours) > 14 THEN

              l_output_hours := 14;

           END IF;

        END IF;


     IF p_report_type = 'SSA_SQWL' THEN

         hr_utility.trace('SSA_SQWL');

        IF p_report_qualifier = 'WY_SQWL' THEN

           hr_utility.trace('WY');
           l_output_hours := '00';
           sp_out_1 := to_char(l_hours_worked);

        ELSIF p_report_qualifier = 'DE_SQWL' THEN

              hr_utility.trace('DE l_output_hours  '||l_output_hours);
              l_output_hours :=lpad(l_output_hours,2,'0');

	ELSIF p_report_qualifier = 'RI_SQWL' THEN  /*bug 6613661*/

              hr_utility.trace('RI l_output_hours  '||l_output_hours);
              l_output_hours :=lpad(l_output_hours,2,'0');
              sp_out_1 := to_char(round(l_hours_worked));
        ELSE

              l_output_hours := lpad(' ',2);

        END IF;

     ELSIF p_report_type = 'ICESA_SQWL' THEN

           IF ((p_report_qualifier = 'MA_SQWL') OR
              (p_report_qualifier = 'OH_SQWL') OR
              (p_report_qualifier = 'PA_SQWL')) THEN

               l_output_hours := lpad(l_output_hours,2,'0');

           ELSIF ((p_report_qualifier = 'KY_SQWL') OR
                  (p_report_qualifier = 'KS_SQWL') OR
                  (p_report_qualifier = 'OK_SQWL')) THEN

                   l_output_hours:=  lpad(' ', 2);
           ELSIF (p_report_qualifier = 'VT_SQWL') THEN
                   l_output_hours := to_char(l_hours_worked);

           ELSE

                    l_output_hours:= '00';

           END IF;

           IF ((p_report_qualifier = 'KS_SQWL') OR
              (p_report_qualifier = 'KY_SQWL') OR
              (p_report_qualifier = 'OH_SQWL')) THEN

                sp_out_1 := lpad(' ',3);

           ELSE

                sp_out_1 := lpad('0',3,'0');

           END IF;

     ELSIF p_report_type = 'MMREF_SQWL' THEN

        IF (p_report_qualifier = 'MN_SQWL') THEN

            IF p_input_2 = 'B' THEN
	       l_hours_worked := nvl(to_number(lv_jd_sick_hrs),0) + nvl(to_number(lv_jd_vacn_hrs),0)
				+ nvl(to_number(lv_jd_reg_hrs),0) + nvl(to_number(lv_jd_ot_hrs),0);
            END IF;

        ELSIF (p_report_qualifier = 'OR_SQWL') THEN /*Bug:2286335. */

            IF p_input_2 = 'B' THEN
	       l_hours_worked := nvl(to_number(lv_jd_reg_hrs),0) + nvl(to_number(lv_jd_ot_hrs),0);
            END IF;


              IF l_hours_worked >999 THEN

                 l_hours_worked := 999;

              END IF;
           hr_utility.trace('l_hours_worked = '||l_hours_worked);

         END IF;

          hr_utility.trace('Report Qualifier = '||p_report_qualifier ||'and l_hours_worked = '||l_hours_worked);
           RETURN to_char(l_hours_worked); -- hours worked for MN and OR

    ELSE

        IF p_report_qualifier = 'NJ_SQWL' THEN

           l_output_hours := lpad(l_output_hours,2,'0');

        ELSIF p_report_qualifier = 'WA_SQWL' THEN

           RETURN to_char(l_hours_worked);

        END IF;

    END IF;


   RETURN l_output_hours;

  End;

FUNCTION Get_Sqwl_Extra_Info(p_payroll_action_id        NUMBER, --CONTEXT
                             p_tax_unit_id              NUMBER, --CONTEXT
                             p_report_type          IN  varchar2,
                             p_report_qualifier     IN  varchar2,
                             p_input_1              IN  varchar2,
                             p_input_2              IN  varchar2,
                             p_input_3              IN  varchar2,
                             p_output_1             IN OUT nocopy varchar2,
                             p_output_2             IN OUT nocopy varchar2,
                             p_output_3             IN OUT nocopy varchar2)

return varchar2
IS

TYPE arch_columns IS RECORD(
     p_user_name ff_database_items.user_name%type,
     p_archived_value ff_archive_items.value%type);

  arch_rec arch_columns;

  TYPE arch_infm IS TABLE OF arch_rec%TYPE
  INDEX BY BINARY_INTEGER;

  arch_table arch_infm;

l_count number(10) := 0;
l_output_value varchar2(100);
l_entity_id FF_USER_ENTITIES.USER_ENTITY_ID%TYPE;

/*Bug:3092981 */

CURSOR GET_ENTITY_ID(C_USER_NAME FF_USER_ENTITIES.USER_ENTITY_NAME%TYPE)
IS
SELECT USER_ENTITY_ID
FROM   FF_USER_ENTITIES
WHERE  USER_ENTITY_NAME = C_USER_NAME;

CURSOR GET_ARCHIVED_VALUE
       (C_PAYROLL_ACTION_ID PAY_ASSIGNMENT_ACTIONS.PAYROLL_ACTION_ID%TYPE,
        C_TAX_UNIT_ID PAY_ASSIGNMENT_ACTIONS.TAX_UNIT_ID%TYPE,
        C_USER_ENTITY_ID FF_USER_ENTITIES.USER_ENTITY_ID%TYPE)
IS
SELECT SUM(FAI.VALUE),COUNT(FAI.ARCHIVE_ITEM_ID)
FROM FF_ARCHIVE_ITEMS FAI,
      PAY_ASSIGNMENT_ACTIONS PAA
WHERE PAA.PAYROLL_ACTION_ID = C_PAYROLL_ACTION_ID
AND   PAA.TAX_UNIT_ID = C_TAX_UNIT_ID
AND   FAI.CONTEXT1 = TO_CHAR(PAA.ASSIGNMENT_ACTION_ID)
AND   FAI.USER_ENTITY_ID = C_USER_ENTITY_ID
AND   FAI.VALUE >= 0;


Begin

    hr_utility.trace('Get_Sqwl_Extra_Info');

   arch_table(1).p_user_name:='A_SUI_ER_SUBJ_WHABLE_PER_JD_GRE_QTD';
   arch_table(2).p_user_name:='A_SUI_ER_PRE_TAX_REDNS_PER_JD_GRE_QTD';

    FOR i in arch_table.first .. arch_table.last loop

        OPEN GET_ENTITY_ID(arch_table(i).p_user_name);

        FETCH GET_ENTITY_ID INTO l_entity_id;

        IF GET_ENTITY_ID%NOTFOUND THEN

          hr_utility.trace('User entity id  not found for '||arch_table(i).p_user_name);

       END IF;


        hr_utility.trace('l_entity_id =  '||to_char(l_entity_id));

        OPEN GET_ARCHIVED_VALUE(p_payroll_action_id,
                           p_tax_unit_id,
                           l_entity_id);

        FETCH GET_ARCHIVED_VALUE INTO arch_table(i).p_archived_value, l_count;


        hr_utility.trace('Value =  '||arch_table(i).p_archived_value);
        hr_utility.trace('Count =  '||l_count);

       IF GET_ARCHIVED_VALUE%NOTFOUND THEN

          hr_utility.trace('Archived value not found for '||arch_table(i).p_user_name);

       END IF;

       CLOSE GET_ARCHIVED_VALUE;
       CLOSE GET_ENTITY_ID;

        p_output_1 := to_char(l_count);
   END LOOP;

 l_output_value := to_char((to_number(arch_table(1).p_archived_value)-to_number(arch_table(2).p_archived_value))*100);

    hr_utility.trace('p_output_1 =  '||p_output_1);
 RETURN l_output_value;

End;


END pay_us_mmref_function_pkg;

/
