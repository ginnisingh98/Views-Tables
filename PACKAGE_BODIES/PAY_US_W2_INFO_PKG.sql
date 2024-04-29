--------------------------------------------------------
--  DDL for Package Body PAY_US_W2_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2_INFO_PKG" as
/* $Header: pyusw2dt.pkb 120.34.12010000.26 2010/01/21 20:58:05 svannian ship $ */
   g_package            CONSTANT VARCHAR2(33) := 'pay_us_w2_info_pkg.';
   l_w2_fields         l_w2_fields_rec;
   l_state_tab         l_state_table;
   l_local_tab         l_local_table;
   l_box12_tab         l_box12_table;
   l_box14_tab         l_box14_table;
   l_state_local_tab   l_state_local_table;
   g_occ_tax_rate      NUMBER;
   g_mh_tax_rate       NUMBER;
   g_mh_tax_limit      NUMBER;
   g_occ_mh_tax_limit  NUMBER;
   g_occ_mh_wage_limit NUMBER;
   g_mh_tax_wage_limit NUMBER;
   g_print_instr       VARCHAR2(1) := 'Y';


   FUNCTION append_to_lob(p_text in varchar)
   RETURN BLOB IS

   text_size NUMBER;
   raw_data RAW(32767);
   temp_blob BLOB;
   BEGIN

     raw_data:=utl_raw.cast_to_raw(p_text);
     text_size:=utl_raw.length(raw_data);

     dbms_lob.createtemporary(temp_blob,false,DBMS_LOB.CALL);
     dbms_lob.open(temp_blob,dbms_lob.lob_readwrite);

     dbms_lob.writeappend(temp_blob,
                  text_size,
                  raw_data
                 );

      IF dbms_lob.ISOPEN(temp_blob)=1  THEN
          hr_utility.trace('Closing temp_lob' );
          dbms_lob.close(temp_blob);
      END IF;

     return temp_blob;
   END;

   FUNCTION check_negative_number (p_data number)
   RETURN VARCHAR2 IS
        l_data       VARCHAR2(250);
   BEGIN
      IF nvl(p_data,0) <=0 THEN
          hr_utility.trace('Negative/zero value '||p_data);
          l_data := '';
      ELSE
          l_data := p_data;
      END IF;

      return l_data;

  END;

   FUNCTION xml_special_chars (p_xml_data VARCHAR2)
   RETURN VARCHAR2 IS
        l_xml_data       VARCHAR2(250);
   BEGIN
        l_xml_data := REPLACE (p_xml_data, '&', '&amp;');
        l_xml_data := REPLACE (l_xml_data, '>', '&gt;');
        l_xml_data := REPLACE (l_xml_data, '<', '&lt;');
        l_xml_data := REPLACE (l_xml_data, '''', '&apos;');
        l_xml_data := REPLACE (l_xml_data, '"', '&quot;');

        return l_xml_data;

  END;

  FUNCTION populate_state_local_table ( l_state_tab l_state_table,
                                         l_local_tab l_local_table)
  RETURN  l_state_local_table IS
  l_curr_state PLS_INTEGER;
  l_curr_local PLS_INTEGER;
  l_stloc_tcnt NUMBER;
  p_write_state BOOLEAN;
  l_prior_local PLS_INTEGER;


  PROCEDURE check_prior_local IS
  BEGIN
    --{ Check for prior local
      hr_utility.trace('In check_prior_local,l_prior_local '||l_prior_local);
      p_write_state := FALSE;
      IF l_prior_local IS NOT NULL THEN

          --hr_utility.trace('Statecode of state is LESS than Local state Code and prior local is not null');
          hr_utility.trace('State Code of current state '||l_state_tab(l_curr_state).state_code);
          --  hr_utility.trace('State Code of current local '||l_local_tab(l_curr_local).state_code);
          hr_utility.trace('State Code of prior local '||l_local_tab(l_prior_local).state_code);

          /* If the state code of prior local is same as current state
             then move the index of the current state */
          IF (l_state_tab(l_curr_state).state_code <>
              l_local_tab(l_prior_local).state_code) THEN
              hr_utility.trace('State Code of prior local matches current state code so setting  p_write_state TRUE');
              p_write_state := TRUE;
          ELSE
              p_write_state := FALSE;
          END IF;
      ELSE
          p_write_state := TRUE;
      END IF;
      --}
   END;

  PROCEDURE write_state_only IS
  BEGIN

       hr_utility.trace('Writing state without local ');

       l_stloc_tcnt := l_state_local_tab.count;
       l_state_local_tab(l_stloc_tcnt).state_code
                 := l_state_tab(l_curr_state).state_code ;
       l_state_local_tab(l_stloc_tcnt).state_ein
                 := l_state_tab(l_curr_state).state_ein ;
       l_state_local_tab(l_stloc_tcnt).state_wages
                 := l_state_tab(l_curr_state).state_wages ;
       l_state_local_tab(l_stloc_tcnt).state_tax
                 := l_state_tab(l_curr_state).state_tax ;
       l_state_local_tab(l_stloc_tcnt).locality := '';
       l_state_local_tab(l_stloc_tcnt).locality_wages := '';
       l_state_local_tab(l_stloc_tcnt).locality_tax := '';
       l_curr_state := l_curr_state + 1;
   END;

  BEGIN -- populate_state_local_table

          l_curr_state := l_state_tab.FIRST;
          l_curr_local := l_local_tab.FIRST;
          l_stloc_tcnt := 0;

          LOOP

          hr_utility.trace('l_state_tab.COUNT '||l_state_tab.COUNT);
          hr_utility.trace('l_local_tab.COUNT '||l_local_tab.COUNT);
          hr_utility.trace('l_curr_state '||l_curr_state);
          hr_utility.trace('l_curr_local '||l_curr_local);

          EXIT WHEN (l_curr_state > l_state_tab.COUNT and
                     l_curr_local > l_local_tab.COUNT)
                    OR (l_curr_state > l_state_tab.COUNT and
                        l_curr_local IS NULL)
		    /* Bug 8313261 : Added the following to exit the loop
				     in case of no data found in l_state_tab */
		    OR (l_curr_state IS NULL AND
		        l_curr_local > l_local_tab.COUNT);

          l_prior_local := l_local_tab.PRIOR(l_curr_local);
          hr_utility.trace('l_prior_local '||l_local_tab.PRIOR(l_curr_local));

          IF (l_curr_state IS NOT NULL AND
              l_curr_local IS NOT NULL ) AND
             (l_curr_state <= l_state_tab.COUNT ) AND
             (l_curr_local <= l_local_tab.COUNT) THEN

              hr_utility.trace('l_state_tab(l_curr_state).state_code '||l_state_tab(l_curr_state).state_code);
              hr_utility.trace('l_local_tab(l_curr_local).state_code '||l_local_tab(l_curr_local).state_code);
              hr_utility.trace('l_curr_state '||l_curr_state);

              IF (l_state_tab(l_curr_state).state_code =
                 l_local_tab(l_curr_local).state_code ) THEN

                 hr_utility.trace('Statecode of state is EQUAL to Local state Code');

                 l_stloc_tcnt := l_state_local_tab.count;

                 hr_utility.trace('l_state_tab(l_curr_state).state_ein '||l_state_tab(l_curr_state).state_ein);
                 hr_utility.trace('l_state_tab(l_curr_state).state_wages '||l_state_tab(l_curr_state).state_wages);
                 hr_utility.trace('l_state_tab(l_curr_state).state_tax '||l_state_tab(l_curr_state).state_tax);
                 /* Check to see if the state code of prior local is same as current state */

                 check_prior_local;

                 IF p_write_state THEN
                    l_state_local_tab(l_stloc_tcnt).state_code
                           := l_state_tab(l_curr_state).state_code ;

                    l_state_local_tab(l_stloc_tcnt).state_ein
                           := l_state_tab(l_curr_state).state_ein ;

                    l_state_local_tab(l_stloc_tcnt).state_wages
                           := l_state_tab(l_curr_state).state_wages ;

                    l_state_local_tab(l_stloc_tcnt).state_tax
                           := l_state_tab(l_curr_state).state_tax ;

                    l_state_local_tab(l_stloc_tcnt).locality
                            := l_local_tab(l_curr_local).locality ;

                    l_state_local_tab(l_stloc_tcnt).locality_wages
                           := l_local_tab(l_curr_local).locality_wages;

                    l_state_local_tab(l_stloc_tcnt).locality_tax
                           := l_local_tab(l_curr_local).locality_tax;

                ELSE
                    l_state_local_tab(l_stloc_tcnt).state_code
                           := l_state_tab(l_curr_state).state_code;

                    l_state_local_tab(l_stloc_tcnt).state_ein
                           := '' ;

                    l_state_local_tab(l_stloc_tcnt).state_wages
                           := '' ;

                    l_state_local_tab(l_stloc_tcnt).state_tax
                           := '' ;

                    l_state_local_tab(l_stloc_tcnt).locality
                            := l_local_tab(l_curr_local).locality ;

                    l_state_local_tab(l_stloc_tcnt).locality_wages
                           := l_local_tab(l_curr_local).locality_wages;

                    l_state_local_tab(l_stloc_tcnt).locality_tax
                           := l_local_tab(l_curr_local).locality_tax;
                END IF;
                -- l_curr_state := l_state_tab.NEXT(l_curr_state);
                 /* Just move the index for the current local as one state
                    may have multiple locals */
                -- l_curr_local := l_local_tab.NEXT(l_curr_local);
                  l_curr_local := l_curr_local + 1;

--{
             ELSIF (l_state_tab(l_curr_state).state_code <
                    l_local_tab(l_curr_local).state_code ) THEN
               check_prior_local;
               IF p_write_state THEN
                hr_utility.trace('current state doesnot match with prior state, so write current state only');
                write_state_only;
               ELSE
                 hr_utility.trace('current state matches with prior state, move to next state');
                 l_curr_state := l_curr_state + 1;
               END IF;
--}
             ELSE
                 hr_utility.trace('Statecode of state is greater than Local state Code');
                 l_stloc_tcnt := l_state_local_tab.count;

                 l_state_local_tab(l_stloc_tcnt).state_code
                           := l_local_tab(l_curr_local).state_code ;

                 l_state_local_tab(l_stloc_tcnt).state_ein
                           := '';

                 l_state_local_tab(l_stloc_tcnt).state_wages
                           := '' ;

                 l_state_local_tab(l_stloc_tcnt).state_tax
                           := '' ;

                 l_state_local_tab(l_stloc_tcnt).locality
                           := l_local_tab(l_curr_local).locality ;

                 l_state_local_tab(l_stloc_tcnt).locality_wages
                           := l_local_tab(l_curr_local).locality_wages;

                 l_state_local_tab(l_stloc_tcnt).locality_tax
                           := l_local_tab(l_curr_local).locality_tax;

                  l_curr_local := l_curr_local + 1;
             END IF;

-- if l_curr_local is not null and l_curr_state is null
         ELSIF (l_curr_state IS NULL and l_curr_local IS NOT NULL)
                OR  (l_curr_state > l_state_tab.COUNT AND
                     l_curr_local <= l_local_tab.COUNT) THEN

                 hr_utility.trace('Current state is null and curr local is NOT null');
                 hr_utility.trace('Current state is null and curr local is NOT null, l_curr_local '||l_curr_local);
                 hr_utility.trace('Locality '||l_local_tab(l_curr_local).locality);
                 hr_utility.trace('l_local_tab(l_curr_local).locality_tax '||l_local_tab(l_curr_local).locality_tax);
                 hr_utility.trace('l_local_tab(l_curr_local).locality_wages '||l_local_tab(l_curr_local).locality_wages);


                 l_stloc_tcnt := l_state_local_tab.count;
                 l_state_local_tab(l_stloc_tcnt).state_code
                           := '' ;

                 l_state_local_tab(l_stloc_tcnt).state_ein
                               := '';

                 l_state_local_tab(l_stloc_tcnt).state_wages
                           := '';

                 l_state_local_tab(l_stloc_tcnt).state_tax
                           := '' ;

                 l_state_local_tab(l_stloc_tcnt).locality
                           := l_local_tab(l_curr_local).locality ;

                 l_state_local_tab(l_stloc_tcnt).locality_wages
                           := l_local_tab(l_curr_local).locality_wages;

                 l_state_local_tab(l_stloc_tcnt).locality_tax
                           := l_local_tab(l_curr_local).locality_tax;

                  l_curr_local := l_curr_local + 1;

         ELSIF (l_curr_state IS NOT NULL and l_curr_local IS  NULL)
               OR (l_curr_state <= l_state_tab.COUNT AND
                   l_curr_local > l_local_tab.COUNT) THEN

                 hr_utility.trace('Current state is not null and curr local is null');
                 hr_utility.trace('l_curr_state '||l_curr_state);
                 hr_utility.trace('l_curr_local '||l_curr_local);

                 check_prior_local;
                 IF p_write_state THEN
                    hr_utility.trace('current state doesnot match with prior state, so write current state only');
                   write_state_only;
                 ELSE
                    hr_utility.trace('current state matches with prior state, move to next state');
                   l_curr_state := l_curr_state + 1;

                 END IF;
         ELSE
            hr_utility.trace('Completed populating all states and locals');
            exit;
         END IF;
         END LOOP;

     return l_state_local_tab;
  END;

  PROCEDURE get_w2_data(p_asg_action_id NUMBER,
                        p_tax_unit_id NUMBER,
                        p_year NUMBER,
                        p_error_msg out nocopy VARCHAR2)
--       RETURN l_w2_fields_rec
    IS
       l_sl_total_count  number;
       l_sl_count        number ;
       l_b12_total_count number;
       l_b12_count       number;
       l_b14_total_count number;
       l_b14_count       number;
       l_local_total_count  number;
       l_nr_jd           varchar2(11);
       l_nr_flag         varchar2(1);
       l_locality        varchar2(100);
       l_locality_wages  number;
       l_locality_tax    number;
       l_jurisdiction    varchar2(15);
       l_state_code      varchar2(10);
       l_tax_type        varchar2(100);
       l_box14_boonmh_value number;
       l_nj_state_printed        VARCHAR2(1);
       l_hi_state_printed        VARCHAR2(1); /* 6519495 */
       l_nj_planid               VARCHAR2(20);
       l_corrected_date          DATE;
       l_profile_date            DATE;
       l_agent_tax_unit_id       number;
       l_error_msg               VARCHAR2(500);
       l_business_group_id       number;
       l_org_federal_ein         VARCHAR2(100);
       l_org_employer_name       VARCHAR2(200);
       l_org_address             VARCHAR2(500);
       l_live_profile_option     VARCHAR2(100);
       l_payroll_action_id       NUMBER;
       l_w2_corrected            VARCHAR2(10);
       p_effective_date          DATE;
       lr_employee_addr          pay_us_get_item_data_pkg.person_name_address;
       p_assignment_id           NUMBER;
       l_person_id              NUMBER;
       l_profile_date_string    VARCHAR2(40);
       /* 6500188 */
       l_first_name             per_all_people_f.first_name%type;
       l_middle_name            per_all_people_f.middle_names%type;
       l_dummy                  varchar2(100);
       l_full_name              per_all_people_f.full_name%type;
       l_nj_sdi1_value          varchar2(20) ;
       l_flipp_id               varchar2(20) ;
       l_state_zero_flag        varchar2(10) ;


    --       PROCEDURE get_employee_info (p_asg_action_id NUMBER) IS

       CURSOR c_get_emp_info (p_asg_action_id NUMBER,
                              p_tax_unit_id NUMBER,
                              p_year NUMBER ) IS
          select puw.assignment_action_id control_number,
                 nvl(ssn,'Applied For') SSN,
  		         first_name||
                 decode(middle_name,null,' ',
                        ' '||substr(middle_name,1,1)||' ') ||
                 pre_name_adjunt emp_name,
                 last_name ,                                      -- Bug 4523389
		 hr_us_w2_rep.get_per_item(p_asg_action_id,
                                          'A_PER_SUFFIX') emp_suffix,
                /* Bug  5575567
                  decode(pa.address_line1,null,null,pa.address_line1 ||'\r')||
                 decode(pa.address_line2,null,null,pa.address_line2||'\r') ||
                 decode(pa.address_line3,null,null,pa.address_line3||'\r') ||
                 decode(pa.town_or_city,null,null,pa.town_or_city ||' ')||
                 decode(pa.region_2,null,null,pa.region_2||' ')|| pa.postal_code                     employee_address,
               */
                 decode(W2_WAGES_TIPS_COMPENSATION,0,'',W2_WAGES_TIPS_COMPENSATION) wages_tips_compensation,
                 decode(W2_FED_IT_WITHHELD,0,'',W2_FED_IT_WITHHELD) fit_withheld,
                 decode(W2_SOCIAL_SECURITY_WAGES,0,'',W2_SOCIAL_SECURITY_WAGES) ss_wages,
                 decode(W2_SST_WITHHELD,0,'',W2_SST_WITHHELD) ss_withheld,
                 decode(W2_MED_WAGES_TIPS,0,'',W2_MED_WAGES_TIPS) med_wages,
                 decode(W2_MED_TAX_WITHHELD,0,'',W2_MED_TAX_WITHHELD) med_withheld,
                 decode(W2_SOCIAL_SECURITY_TIPS,0,'',W2_SOCIAL_SECURITY_TIPS) ss_tips,
                 decode(W2_ALLOCATED_TIPS,0,'',W2_ALLOCATED_TIPS) allocated_tips,
                 decode(W2_ADV_EIC_PAYMENT,0,'',W2_ADV_EIC_PAYMENT) eic_payment,
                 decode(W2_DEPENDENT_CARE_BEN,0,'',W2_DEPENDENT_CARE_BEN) dependent_care,
                 decode(W2_NONQUAL_PLANS,0,'',W2_NONQUAL_PLANS) non_qual_plan,
                 decode(W2_STATUTORY_EMPLOYEE,'X','Y',null,'N',' ','N')
                                                     stat_employee,
                 decode(W2_RETIREMENT_PLAN,'X','Y',null,'N',' ','N')
                                                     retirement_plan,
                 decode(W2_THIRD_PARTY_SICK_PAY,'X','Y',null,
                        'N',' ','N') sick_pay,
                 person_id , puw.assignment_id -- bug 5575567
          from pay_us_wages_w2_v puw
               --per_addresses pa
          where puw.assignment_action_id = p_asg_action_id
         /*  bug 5575567
           and pa.primary_flag = 'Y'
          and pa.person_id = puw.person_id */
          and puw.tax_unit_id = p_tax_unit_id
          and puw.year = p_year;
          --and sysdate between pa.date_from and nvl(pa.date_to,sysdate);


        CURSOR c_get_box12_info (p_asg_action_id NUMBER) IS
           select w2_balance_code,
                  w2_balance_code_value
           from   pay_us_code_w2_v
           where w2_balance_code_value > 0
           and assignment_action_id = p_asg_action_id
           order by w2_balance_code;

        CURSOR c_get_box14_info (p_asg_action_id NUMBER) IS
           SELECT substr(w2_other_meaning,1,10) w2_other_code,
                  w2_other_value
           from pay_us_other_w2_v
           where w2_other_value > 0
           and  assignment_action_id = p_asg_action_id;

/*        CURSOR c_get_box14_boonocc (p_asg_action_id NUMBER) IS
           SELECT 'BOONOCC' w2_other_code,
                  w2_local_income_tax -
                  decode(sign(w2_local_wages - 16666), -1,
                         w2_local_wages * 0.0015, 25) w2_other_value
           from pay_us_locality_w2_v
           where state_abbrev = 'KY'
           and tax_type = 'COUNTY'
           and substr(jurisdiction,1,6) = '18-015'
           and assignment_action_id = p_asg_action_id
           and w2_local_income_tax > 0;


        CURSOR c_get_box14_boonmh (p_asg_action_id NUMBER) IS
           SELECT 'BOONMH' w2_other_code,
                  decode(sign(w2_local_wages - 16666), -1,
                         w2_local_wages * 0.0015, 25) w2_other_value
           from pay_us_locality_w2_v
           where state_abbrev = 'KY'
           and tax_type = 'COUNTY'
           and substr(jurisdiction,1,6) = '18-015'
           and assignment_action_id = p_asg_action_id
           and w2_local_income_tax > 0;
*/
         CURSOR c_get_local_info (p_asg_action_id NUMBER) IS
           SELECT locality_name locality,
                  decode(w2_local_wages,0,'',w2_local_wages) locality_wages,
                  w2_local_income_tax locality_tax,
                  jurisdiction jurisdiction,
                  state_abbrev state_code,
                  tax_type
           FROM pay_us_locality_w2_v
           WHERE assignment_action_id = p_asg_action_id
          /*commented for 4102684
           and W2_LOCAL_INCOME_TAX > 0*/
--           and (jurisdiction <> '18-015-0000')
           order by state_code, tax_type;
/* Bug # 9267579 */
         CURSOR c_get_state_info (p_asg_action_id NUMBER) IS
                  SELECT 1 , substr(state_abbrev,1,2) state_code,
                  substr(state_ein,1,20) state_ein,
                  to_char(decode(W2_STATE_WAGES,0,'',W2_STATE_WAGES),'9999999990.99') state_wages,
                  to_char(decode(W2_STATE_INCOME_TAX,0,'',W2_STATE_INCOME_TAX),'9999999990.99') state_tax
           FROM pay_us_state_w2_v  state
           WHERE assignment_action_id = p_asg_action_id
           and  ( (w2_state_wages > 0) or
	          (W2_STATE_INCOME_TAX > 0) )  /* 6809739  */
					  and state_ein <> 'FLI P.P. #'
					union all
					        SELECT 2 , substr(state_abbrev,1,2) state_code,
                  substr(state_ein,1,20) state_ein,
                  nvl(W2_STATE_WAGES,'') state_wages,
									trim(decode(to_char(to_number(W2_STATE_INCOME_TAX ),'9999999990.99'),'0.0' , ' ',to_char(to_number(W2_STATE_INCOME_TAX ),'9999999990.99') || ' - FLI'  )) state_tax
           FROM pay_us_state_w2_v  state
           WHERE assignment_action_id = p_asg_action_id
           and  ( (w2_state_wages <> ' ') or
	          (to_char(to_number(W2_STATE_INCOME_TAX ),'9999999990.99') <> 0) )  /* 6809739  */
					  and state_ein = 'FLI P.P. #'
           order by state_code , 1 ;

/*        CURSOR c_get_employer_info ( p_tax_unit_id NUMBER, p_year NUMBER) IS
          select federal_ein federal_ein,
                 tax_unit_name employer_name,
                 substr(decode(put.address_line_1,null,null,put.address_line_1||pay_us_w2_info_pkg.EOL),1,45)||
                 substr(decode(put.address_line_2,null,null,put.address_line_2||pay_us_w2_info_pkg.EOL),1,45)||
                 substr(decode(put.address_line_3,null,null,put.address_line_3||pay_us_w2_info_pkg.EOL),1,45)||
                 decode(put.town_or_city,null,null,put.town_or_city||' ')||
                 decode(state,null,null,state||' ')||put.postal_code
                                                 employer_address
          from pay_us_w2_tax_unit_v put
          where tax_unit_id = p_tax_unit_id
          and year = p_year;
*/

          /*Bug 5735076 added by vaprakas*/
          CURSOR c_get_employer_info ( p_tax_unit_id NUMBER, p_year NUMBER) IS
          select federal_ein federal_ein,
                 tax_unit_name employer_name,
                 decode(put.address_line_1,null,null,substr(put.address_line_1,1,45)||pay_us_w2_info_pkg.EOL)||
                 decode(put.address_line_2,null,null,substr(put.address_line_2,1,45)||pay_us_w2_info_pkg.EOL)||
                 decode(put.address_line_3,null,null,substr(put.address_line_3,1,45)||pay_us_w2_info_pkg.EOL)||
                 decode(put.town_or_city,null,null,put.town_or_city||' ')||
                 decode(state,null,null,state||' ')||put.postal_code
                 employer_address
          from pay_us_w2_tax_unit_v put
          where tax_unit_id = p_tax_unit_id
          and year = p_year;
         /*end 5735076*/

       CURSOR c_get_business_group_id ( p_tax_unit_id NUMBER) IS
            select business_group_id
            from hr_all_organization_units /*hr_organization_units*/
            where organization_id = p_tax_unit_id;

       CURSOR c_get_payroll_action (p_asg_action_id NUMBER)IS
            select payroll_action_id
            from pay_assignment_actions
            where assignment_action_id = p_asg_action_id;

       CURSOR c_get_session_date IS
	    SELECT NVL(TO_DATE(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',
					ppa.legislative_parameters),'YYYY/MM/DD'),SYSDATE) session_date
	    FROM pay_payroll_actions ppa
	    WHERE payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

	c_get_session_date_rec		c_get_session_date%ROWTYPE;

    PROCEDURE print_corrected IS
    begin

         /* Code to print Amended/amended date on W-2 */

         l_corrected_date := fnd_date.canonical_to_date(
                                      pay_us_archive_util.get_archive_value(p_asg_action_id,
                                         'A_ARCHIVE_DATE',
                                          p_tax_unit_id));

         hr_utility.trace('Archive Date : ' || l_corrected_date);
       /* l_profile_option := fnd_profile.value('HR_VIEW_ONLINE_W2');
        IF (l_profile_option is null) or (l_profile_option = '') THEN
            l_profile_date := fnd_date.canonical_to_date('4712/12/31');
        ELSE
       */
          OPEN c_get_payroll_action(p_asg_action_id);
          FETCH c_get_payroll_action INTO l_payroll_action_id;
          CLOSE c_get_payroll_action;


        --l_profile_date := fnd_date.canonical_to_date(p_year+1||'/'||l_profile_option);
       -- END IF;
          /* If live profile option is null then allow the view W-2 till end of time
           otherwise check if the archive profile option exist then use the archive
           profile option date else continue using the old logic of appending year,

           */
          l_live_profile_option := fnd_profile.value('HR_VIEW_ONLINE_W2');
         hr_utility.trace('View Online W2 Profile date'||l_live_profile_option);

          IF (l_live_profile_option is null) or (l_live_profile_option = '') THEN
                l_profile_date := fnd_date.canonical_to_date('4712/12/31');
          ELSE
                 --- changed th date format for bug 5656018
               l_profile_date_string :=-- fnd_date.canonical_to_date(
                    -- fnd_date.chardate_to_date(
                      pay_us_archive_util.get_archive_value(l_payroll_action_id,
                                                            'A_VIEW_ONLINE_W2',
                                                             p_tax_unit_id);

             hr_utility.trace('l_profile_date '||l_profile_date_string);

             IF (l_profile_date_string is null) or (l_profile_date_string = '') THEN
                l_profile_date := fnd_date.canonical_to_date(p_year+1||'/'||l_live_profile_option);
                hr_utility.trace('l_profile_date was null , setting to  '||l_profile_date);
             ELSE
                 l_profile_date := -- bug 5656018 fnd_date.chardate_to_date
                                   fnd_date.canonical_to_date(l_profile_date_string);

                 hr_utility.trace('l_profile_date was not null , setting to  '||l_profile_date);

             END IF;
          END IF;

         l_w2_corrected :=pay_us_archive_util.get_archive_value(p_asg_action_id,
                                                            'A_W2_CORRECTED',
                                                             p_tax_unit_id);

          hr_utility.trace('View Online W2 Profile date'||l_live_profile_option);

          /* If the profile option is blank for fixing bug  4947964   and archive
              item , A_W2_CORRECTED is not archived for an employee then it
              will never print 'CORRECTED' which may be incorrect for W-2s which
              were corrected sometime. To fix this either
              archive A_W2_CORRECTED for each employee or set the profile option
              to a date and run Year end preproces rearchive to archive the profile
              option */

         IF l_w2_corrected  IS NULL THEN
           IF l_corrected_date > l_profile_date THEN
               l_w2_fields.amended := 'CORRECTED';
               l_w2_fields.amended_date :=  l_corrected_date;
           END IF;
         ELSIF l_w2_corrected = 'Y' THEN
            l_w2_fields.amended := 'CORRECTED';
            l_w2_fields.amended_date :=  l_corrected_date;
         END IF;

   end; -- end print_corrected}

--{  begin get_w2_data
   BEGIN
         l_sl_count   := 1;
         l_b12_count  :=1;
         l_b14_count  :=1;

         OPEN c_get_business_group_id(p_tax_unit_id);
         FETCH c_get_business_group_id
         INTO l_business_group_id;
         CLOSE c_get_business_group_id;

         hr_utility.trace('Business Group id ' ||l_business_group_id);
	 hr_utility.trace('TRANSFER_PAYROLL_ACTION_ID ' ||pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'));

         IF l_business_group_id is not null THEN
                hr_us_w2_rep.get_agent_tax_unit_id(l_business_group_id
                                              ,p_year
                                              ,l_agent_tax_unit_id
                                              ,l_error_msg);
         END IF;

         hr_utility.trace('Agent Tax unit id ' ||l_agent_tax_unit_id);
         hr_utility.trace('l_error_msg ' ||l_error_msg);
         /* If l_erro_msg is not null then throw error else get remaining data for W2 */
         IF  l_error_msg IS NOT NULL THEN
             p_error_msg := l_error_msg;
         ELSE

            OPEN c_get_employer_info(nvl(l_agent_tax_unit_id, p_tax_unit_id),p_year);
            FETCH c_get_employer_info
            INTO l_w2_fields.federal_ein,
                 l_w2_fields.employer_name,
                 l_w2_fields.employer_address;
            CLOSE c_get_employer_info;

            hr_utility.trace('l_w2_fields.federal_ein ' ||l_w2_fields.federal_ein);
            hr_utility.trace('l_w2_fields.employer_name ' ||l_w2_fields.employer_name);
            hr_utility.trace('l_w2_fields.employer_name ' ||l_w2_fields.employer_name);

            IF  l_agent_tax_unit_id IS NOT NULL THEN

                hr_utility.trace('p_tax_unit_id ' ||p_tax_unit_id);

                OPEN c_get_employer_info(p_tax_unit_id,p_year);
                FETCH c_get_employer_info
                INTO l_org_federal_ein,
                     l_org_employer_name,
                     l_org_address;
                CLOSE c_get_employer_info;
                hr_utility.trace('l_org_federal_ein ' ||l_org_federal_ein);
                hr_utility.trace('l_org_employer_name ' ||l_org_employer_name);
                hr_utility.trace('l_org_address ' ||l_org_address);

                l_w2_fields.employer_address
                    := 'Agent For ' ||substr(l_org_employer_name,1,44)||
                         pay_us_w2_info_pkg.EOL ||
                       l_w2_fields.employer_address;
            END IF;
            /* Bug 	5575567 	*/
            hr_utility.trace(' sysdate ' || sysdate);
            hr_utility.trace(' end of year ' || fnd_date.canonical_to_date(p_year||'/12/31'));

	    /* Start : Bug # 8353425
	       Considering the Session Date instead of System Date while fetching employee's
	       name. The report will now take the employee's current name as of the application
	       session date when the report is run, if the session date is greater than the last
	       day of the year. Otherwise, the Employee W2 Report will take the employee's
	       name that was effective as of the last day of the year.
	       Commenting the following If-Else condition.

            IF (trunc(sysdate) <
                     fnd_date.canonical_to_date(p_year||'/12/31')) THEN
                 p_effective_date := fnd_date.canonical_to_date(p_year||'/12/31');
            ELSE
                 p_effective_date := trunc(sysdate); --Bug 8222402
            END IF;

	    Adding the following lines */

	    OPEN c_get_session_date;
	    FETCH c_get_session_date INTO c_get_session_date_rec;
	    CLOSE c_get_session_date;

	    hr_utility.trace('Application Session Date ' || c_get_session_date_rec.session_date);

	    /*Start Bug 9073693: Since Application session date is sysdate in case of selfservice,
	    Replacing c_get_session_date_rec.session_date with sysdate if it is null */

	    IF (trunc(nvl(c_get_session_date_rec.session_date,sysdate)) <= fnd_date.canonical_to_date(p_year||'/12/31')) THEN -- Bug 9073693
                 p_effective_date := fnd_date.canonical_to_date(p_year||'/12/31');
            ELSE
                 p_effective_date := trunc(nvl(c_get_session_date_rec.session_date,sysdate)); -- Bug 9073693
            END IF;

	    /* End : Bug # 8353425 */

            --p_effective_date := sysdate;  Bug 6443139
            hr_utility.trace(' p_effective_date ' || p_effective_date);

            OPEN c_get_emp_info(p_asg_action_id,p_tax_unit_id, p_year) ;
            FETCH c_get_emp_info
            INTO l_w2_fields.control_number,
                 l_w2_fields.SSN,
  	             l_w2_fields.emp_name,
                 l_w2_fields.last_name,
                 l_w2_fields.emp_suffix, 	-- Bug 4523389
                 -- bug 5575567 l_w2_fields.employee_address,
                 l_w2_fields.wages_tips_compensation,
                 l_w2_fields.fit_withheld,
                 l_w2_fields.ss_wages,
                 l_w2_fields.ss_withheld,
                 l_w2_fields.med_wages,
                 l_w2_fields.med_withheld,
                 l_w2_fields.ss_tips,
                 l_w2_fields.allocated_tips,
                 l_w2_fields.eic_payment,
                 l_w2_fields.dependent_care,
                 l_w2_fields.non_qual_plan,
                 l_w2_fields.stat_employee,
                 l_w2_fields.retirement_plan,
                 l_w2_fields.sick_pay,
                 -- bug 5575567
                 l_person_id ,
                 p_assignment_id ;

             hr_utility.trace('EMP NAME ' ||l_w2_fields.emp_name);
             hr_utility.trace('Control Number ' ||l_w2_fields.control_number);
             IF c_get_emp_info%NOTFOUND THEN
                hr_utility.trace('No Data found for this assignment action id ' ||to_char(p_asg_action_id));
                CLOSE c_get_emp_info;
                raise NO_DATA_FOUND;
             END IF;
             CLOSE c_get_emp_info;
             /* 6500188 */
	      begin
             l_full_name := pay_us_get_item_data_pkg.GET_CONTACT_PERSON_INFO(
                            0 , p_effective_date ,0, ' ' ,
                            ' ' , 'W2' , ' ' , ' ' , ' ' , l_person_id ,
                            ' ' ,  l_dummy , l_dummy , l_dummy , l_dummy , l_dummy , l_dummy ,
                            l_first_name , l_middle_name ,l_w2_fields.last_name );

            /* 6782720  */
       --     l_w2_fields.last_name := initcap(l_w2_fields.last_name);  --Bug 8197352

             select l_first_name||decode(l_middle_name,null,' ',
                                     ' '||substr(l_middle_name,1,1)||' ') ||
                                     hr_us_w2_rep.get_per_item(p_asg_action_id,
                                     'A_PER_PREFIX' ) into l_w2_fields.emp_name  from dual;
             exception when others then null;
             end ;

		 -- bug 7593457
             l_w2_fields.emp_name := initcap(l_w2_fields.emp_name);
		 -- bug 7593457

	     /* Bug # 8689501 : (Start) Added the following lines
		Considering the Session Date instead of System Date while fetching employee's
		address. The report will now take the employee's current primary address
		as of the application session date when the report is run, if the session date
		is greater than the last day of the year. Otherwise, the Employee W2 Report will
		take the employee's primary address as of the last day of the year.*/

	    /* Commenting the following as p_effective_date is now being calculated above
	    (Bug # 8353425)
	    OPEN c_get_session_date;
	    FETCH c_get_session_date INTO c_get_session_date_rec;
	    CLOSE c_get_session_date;

	    hr_utility.trace('Application Session Date ' || c_get_session_date_rec.session_date);

	    IF (trunc(c_get_session_date_rec.session_date) < fnd_date.canonical_to_date(p_year||'/12/31')) THEN
                 p_effective_date := fnd_date.canonical_to_date(p_year||'/12/31');
            ELSE
                 p_effective_date := trunc(c_get_session_date_rec.session_date);
            END IF;
            hr_utility.trace('p_effective_date ' || p_effective_date);*/

	    /* Bug # 8689501 : (End) */

             lr_employee_addr :=
                        pay_us_get_item_data_pkg.GET_PERSON_NAME_ADDRESS(
                            'W2',
                            l_person_id,
                            p_assignment_id,
                            p_effective_date,
                            p_effective_date,
                            'Y', --p_validate,
                            'W2_XML');

              IF lr_employee_addr.addr_line_1 IS NOT NULL THEN
                 l_w2_fields.employee_address := substr(lr_employee_addr.addr_line_1,1,45) ||
                                                  PAY_US_W2_INFO_PKG.EOL;
              END IF;

              IF lr_employee_addr.addr_line_2 IS NOT NULL THEN
                l_w2_fields.employee_address :=   l_w2_fields.employee_address||
                                                 substr(lr_employee_addr.addr_line_2,1,45) ||
                                                      PAY_US_W2_INFO_PKG.EOL;
              END IF;

              IF lr_employee_addr.addr_line_3 IS NOT NULL THEN
                 l_w2_fields.employee_address := l_w2_fields.employee_address||
                                                substr(lr_employee_addr.addr_line_3,1,45) ||
                                                   PAY_US_W2_INFO_PKG.EOL;
              END IF;

               l_w2_fields.employee_address :=l_w2_fields.employee_address ||
                lr_employee_addr.city||' '||
                lr_employee_addr.region_2 ||' '||
                        lr_employee_addr.postal_code;

               if lr_employee_addr.country <> 'US' then
	           l_w2_fields.employee_address := l_w2_fields.employee_address ||' '||
		   lr_employee_addr.country_name;
	       end if;

-- bug 7576131 start
             IF least(nvl(l_w2_fields.wages_tips_compensation,0)
                 ,nvl(l_w2_fields.fit_withheld,0)
                 ,nvl(l_w2_fields.ss_wages,0)
                 ,nvl(l_w2_fields.ss_withheld,0)
                 ,nvl(l_w2_fields.med_wages,0)
                 ,nvl(l_w2_fields.med_withheld,0)
                 ,nvl(l_w2_fields.ss_tips,0)
                 ,nvl(l_w2_fields.allocated_tips,0)
                 ,nvl(l_w2_fields.eic_payment,0)
                 ,nvl(l_w2_fields.dependent_care,0)
--bug 6874650
--                 ,nvl(l_w2_fields.non_qual_plan,0)) <= 0 THEN
                 ,nvl(l_w2_fields.non_qual_plan,0)) < 0 THEN
--bug 6874650
-- bug 7576131 end
               hr_utility.trace('Negative values for atleast one of box1-11 ');
               p_error_msg := 'Negative values for atleast one of box1-11';
             END IF;
--changes for bug 6821345 starts here
--             IF nvl(l_w2_fields.wages_tips_compensation,0) <=0 THEN
          --   IF nvl(l_w2_fields.wages_tips_compensation,0) <0 THEN
--changes for bug 6821345 ends here
           --    hr_utility.trace('Negative/zero value for box1 ');
         --      p_error_msg := 'Negative values for box1';
         --    END IF;

            l_state_zero_flag := 'Y' ;
            l_sl_total_count := 0;
            OPEN c_get_state_info(p_asg_action_id) ;
            LOOP
              hr_utility.trace('In state loop ' );
              l_sl_total_count := l_sl_total_count + 1;
              FETCH c_get_state_info
              INTO  l_dummy,
                    l_state_tab(l_sl_total_count).state_code,
                    l_state_tab(l_sl_total_count).state_ein,
                    l_state_tab(l_sl_total_count).state_wages,
                    l_state_tab(l_sl_total_count).state_tax;
             EXIT WHEN c_get_state_info%NOTFOUND;
               hr_utility.trace('State_code '|| l_state_tab(l_sl_total_count).state_code);
               hr_utility.trace('State_EIN '|| l_state_tab(l_sl_total_count).state_ein);

          if l_state_zero_flag = 'Y' and l_state_tab(l_sl_total_count).state_ein <> 'FLI P.P. #'
					and ( l_state_tab(l_sl_total_count).state_wages > 0  or l_state_tab(l_sl_total_count).state_tax > 0 ) THEN
					l_state_zero_flag := 'N' ;
					end if ;


             IF l_state_tab(l_sl_total_count).state_code = 'NJ' THEN
                l_nj_state_printed := 'Y';

               /* 8251746  */
       --         l_nj_sdi1_value := hr_us_w2_rep.get_w2_arch_bal(p_asg_action_id, 'A_SDI1_EE_WITHHELD_PER_JD_GRE_YTD' ,
       --                          p_tax_unit_id, '31-000-0000', 2);

       --         l_flipp_id := pay_us_archive_util.get_archive_value(p_asg_action_id,
       --                                                    'A_SCL_ASG_US_FLIPP_ID', --A_EXTRA_ASSIGNMENT_INFORMATION_PAY_US_DISABILITY_PLAN_INFO_DF_PLAN_ID'
       --                                                    p_tax_unit_id)   ;

       --         hr_utility.trace('l_flipp_id' || l_flipp_id );
       --         hr_utility.trace('l_nj_sdi1_value' || l_nj_sdi1_value );

       --        if to_number(l_nj_sdi1_value) <> 0 or nvl(l_flipp_id , '') <> '' then
       --           l_sl_total_count := l_sl_total_count + 1;
       --           l_state_tab(l_sl_total_count).state_code   := 'NJ' ;

       --          if l_flipp_id is not null then
       --             hr_utility.trace('inside l_flipp_id chk ' || l_flipp_id );
       --             l_state_tab(l_sl_total_count).state_ein    := 'FLI P.P. #' ;
       --             l_state_tab(l_sl_total_count).state_wages  := l_flipp_id ;
       --          else
       --             l_state_tab(l_sl_total_count).state_ein    := '' ;
       --             l_state_tab(l_sl_total_count).state_wages  := '' ;
       --          end if ;

       --          if to_number(l_nj_sdi1_value) <> 0 then
       --             l_state_tab(l_sl_total_count).state_tax    := to_char(to_number(l_nj_sdi1_value), '9999999990.99')  || ' - FLI' ;
       --          else
       --             l_state_tab(l_sl_total_count).state_tax    := '' ;
       --          end if ;

       --        end if;

             END IF;

	     IF l_state_tab(l_sl_total_count).state_code = 'HI' THEN /* 6519495 */
               l_hi_state_printed := 'Y';
             END IF;

           END LOOP;
           CLOSE c_get_state_info;

          --bug 7576131 start
	   	 IF nvl(l_w2_fields.wages_tips_compensation,0)=0 and
                 nvl(l_w2_fields.fit_withheld,0)=0 and
                 nvl(l_w2_fields.ss_wages,0)=0 and
                 nvl(l_w2_fields.ss_withheld,0)=0 and
                 nvl(l_w2_fields.med_wages,0)=0 and
                 nvl(l_w2_fields.med_withheld,0)=0 and
                 nvl(l_w2_fields.ss_tips,0)=0 and
                 nvl(l_w2_fields.allocated_tips,0)=0 and
                 nvl(l_w2_fields.eic_payment,0)=0 and
                 nvl(l_w2_fields.dependent_care,0)=0 and
		     nvl(l_w2_fields.non_qual_plan,0)=0 and l_state_zero_flag = 'Y' THEN

                hr_utility.trace('Zero values for box1-11 and state wages/withheld');
               p_error_msg := 'Zero values for box1-11 and state wages/withheld ';
		  END IF;
--bug 7576131 end

           l_local_total_count := 0;
           OPEN c_get_local_info(p_asg_action_id) ;
           LOOP
              hr_utility.trace('In local loop ' );
              FETCH c_get_local_info
              INTO  l_locality,
                    l_locality_wages,
                    l_locality_tax,
                    l_jurisdiction,
                    l_state_code,
                    l_tax_type;

              hr_utility.trace('l_locality is '||l_locality);

              EXIT WHEN c_get_local_info%NOTFOUND;
              IF l_locality_tax > 0 THEN
               --  l_local_total_count := l_local_total_count + 1;
                 /* populate the locality table only if the jurisdiction code <> 18-015-000
                 as this needs to be reported in box 14 as occupational and mental health tax*/
                 IF ( l_tax_type = 'COUNTY' and l_jurisdiction = '18-015-0000') THEN
                    hr_utility.trace('Jurisdiction is 18-015-0000 and tax_type is County');
                    IF (l_locality_tax > 0 and l_locality_wages > 0) THEN
                      hr_utility.trace('Locality tax withheld > 0 for KY, Boone county');

                      l_b14_total_count := l_box14_tab.count+1;
                      hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);

               /*         IF (g_mh_tax_rate IS NULL OR g_mh_tax_limit IS NULL
                          OR g_occ_tax_rate IS NULL OR g_occ_mh_tax_limit IS NULL
                          OR g_occ_mh_wage_limit IS NULL OR g_mh_tax_wage_limit  IS NULL )
                       THEN
                           hr_utility.trace('Getting Mental health and Occupational tax limits');
                           hr_us_w2_rep.get_county_tax_info('18-015-0000',
                                                          p_year,
                                                          g_occ_tax_rate,
                                                          g_mh_tax_rate,
                                                          g_mh_tax_limit,
                                                          g_occ_mh_tax_limit,
                                                          g_occ_mh_wage_limit,
                                                          g_mh_tax_wage_limit);
                        END IF;

                        IF l_locality_wages >= g_mh_tax_wage_limit  then
                           l_box14_boonmh_value := g_mh_tax_limit ;
                        ELSE
                           l_box14_boonmh_value := l_locality_wages * (g_mh_tax_rate/100 ) ;
                        END IF; */

                         /* Bug # 5847250 */

                        l_box14_boonmh_value := hr_us_w2_rep.get_w2_arch_bal(p_asg_action_id, 'A_MISC1_COUNTY_TAX_WITHHELD_PER_JD_GRE_YTD' ,
                                                p_tax_unit_id, '18-015-0000', 6);

                        l_box14_tab(l_b14_total_count).box14_code := 'BOONMH';
                        l_box14_tab(l_b14_total_count).box14_meaning := l_box14_boonmh_value;
                        hr_utility.trace('l_box14_tab(l_b14_total_count).box14_meaning '||l_box14_tab(l_b14_total_count).box14_meaning);

                        l_b14_total_count := l_box14_tab.count+1;
                        hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);

                        l_box14_tab(l_b14_total_count).box14_code := 'BOONOCC';
                        l_box14_tab(l_b14_total_count).box14_meaning :=
                                                l_locality_tax - l_box14_boonmh_value;
                    END IF;
                ELSE
                    l_local_total_count := l_local_total_count + 1;
                    l_local_tab(l_local_total_count).locality := l_locality;
                    l_local_tab(l_local_total_count).locality_wages := l_locality_wages;
                    l_local_tab(l_local_total_count).locality_tax := l_locality_tax;
                    l_local_tab(l_local_total_count).jurisdiction := l_jurisdiction;
                    l_local_tab(l_local_total_count).state_code := l_state_code;
                    l_local_tab(l_local_total_count).tax_type := l_tax_type;

                    hr_utility.trace('Locality_code '|| l_local_tab(l_local_total_count).locality);
                    hr_utility.trace('Locality state_code '|| l_local_tab(l_local_total_count).state_code);

                    hr_utility.trace('Locality_jurisdiction '|| l_local_tab(l_local_total_count).jurisdiction);
                    hr_utility.trace('Locality Tax '|| l_local_tab(l_local_total_count).locality_tax);
                    hr_utility.trace('Locality Tax Type '|| l_local_tab(l_local_total_count).tax_type);


                    IF (nvl(l_local_tab(l_local_total_count).locality_tax,0) > 0) THEN
                      IF (l_local_tab(l_local_total_count).tax_type = 'CITY SCHOOL' or
                          l_local_tab(l_local_total_count).tax_type = 'COUNTY SCHOOL' ) THEN

                          hr_utility.trace('Locality Tax Type is County/city school');

                          if l_local_tab(l_local_total_count).state_code = 'OH' then

                             hr_utility.trace('Locality state code is OH');

                             l_local_tab(l_local_total_count).locality
                                    := substr(l_local_tab(l_local_total_count).jurisdiction,5,4)
                                      ||' '||substr(l_local_tab(l_local_total_count).locality,1,8);
                          elsif l_local_tab(l_local_total_count).state_code = 'KY' then
                             hr_utility.trace('Locality state code is KY');
                             l_local_tab(l_local_total_count).locality
                                     := substr(l_local_tab(l_local_total_count).jurisdiction,7,2)
                                         ||' '||substr(l_local_tab(l_local_total_count).locality,1,10);
                          else
                             hr_utility.trace('Locality state code neither OH nor KY');
                             l_local_tab(l_local_total_count).locality
                                     := substr(l_local_tab(l_local_total_count).jurisdiction,4,5)
                                         ||' '||substr(l_local_tab(l_local_total_count).locality,1,7);
                          end if;
                      END IF;
                    END IF;

                    hr_utility.trace('l_local_tab(l_local_total_count).locality is '||l_local_tab(l_local_total_count).locality);
                    IF (l_local_tab(l_local_total_count).state_code = 'IN'
                        and l_local_tab(l_local_total_count).tax_type = 'COUNTY') THEN
                    BEGIN
                       select nvl(value,'N') into l_nr_flag
                       from  ff_database_items fdi,
                             ff_archive_items fai
                       where user_name = 'A_IN_NR_FLAG'
                       and fdi.user_entity_id = fai.user_entity_id
                       and fai.context1 = p_asg_action_id;

                       IF l_nr_flag = 'N' THEN
                       BEGIN
                          select nvl(value,'00-000-0000') into l_nr_jd
                          from ff_database_items fdi,
                               ff_archive_items fai
                          where fdi.user_name = 'A_IN_RES_JD'
                          and fdi.user_entity_id = fai.user_entity_id
                          and context1 = p_asg_action_id;

                          IF substr(l_local_tab(l_local_total_count).jurisdiction,1,2) = '15' THEN
                             IF l_nr_jd <> l_local_tab(l_local_total_count).jurisdiction THEN
                                l_local_tab(l_local_total_count).locality
                                    := 'NR '||substr(l_local_tab(l_local_total_count).locality,1,10);
                             END IF;
                          END IF;
                       EXCEPTION WHEN others THEN
                          null;
                       END;
                       END IF;
                     EXCEPTION WHEN others THEN
                          null;
                     END;
                    END IF;
                 END IF ; /* end of the KY boone county check */
              END IF; /* l_locality_tax > 0 */
          END LOOP;
          CLOSE c_get_local_info;

         /*  l_state_local_tab := populate_state_local_table
                                        (l_state_tab,l_local_tab); */
           l_b12_total_count := 0;
           OPEN c_get_box12_info (p_asg_action_id) ;
           LOOP
              l_b12_total_count := l_b12_total_count + 1;
              FETCH c_get_box12_info
              INTO  l_box12_tab(l_b12_total_count).box12_code,
                    l_box12_tab(l_b12_total_count).box12_meaning;

              EXIT WHEN c_get_box12_info%NOTFOUND;
                hr_utility.trace('In box12 loop '||l_box12_tab(l_b12_total_count).box12_code );
           END LOOP;
           CLOSE c_get_box12_info ;

          -- l_b14_total_count := l_box14_tab.count;
           OPEN c_get_box14_info (p_asg_action_id) ;
           LOOP
             l_b14_total_count := l_box14_tab.count+1;
             hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);

             FETCH c_get_box14_info
              INTO  l_box14_tab(l_b14_total_count).box14_code,
                    l_box14_tab(l_b14_total_count).box14_meaning;

              EXIT WHEN c_get_box14_info%NOTFOUND;
              hr_utility.trace('In box14 loop ' ||l_box14_tab(l_b14_total_count).box14_code);

           END LOOP;
           CLOSE c_get_box14_info ;
/*
           OPEN c_get_box14_boonocc (p_asg_action_id) ;
           LOOP
             l_b14_total_count := l_box14_tab.count+1;
             hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);

             FETCH c_get_box14_boonocc
              INTO  l_box14_tab(l_b14_total_count).box14_code,
                    l_box14_tab(l_b14_total_count).box14_meaning;

              EXIT WHEN c_get_box14_boonocc%NOTFOUND;
              hr_utility.trace('In c_get_box14_boonocc loop ' ||l_box14_tab(l_b14_total_count).box14_code);

           END LOOP;
           CLOSE c_get_box14_boonocc ;


           OPEN c_get_box14_boonmh (p_asg_action_id) ;
           LOOP
             l_b14_total_count := l_box14_tab.count+1;
             hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);

             FETCH c_get_box14_boonmh
              INTO  l_box14_tab(l_b14_total_count).box14_code,
                    l_box14_tab(l_b14_total_count).box14_meaning;

              EXIT WHEN c_get_box14_boonmh%NOTFOUND;
              hr_utility.trace('In c_get_box14_boonmh loop ' ||l_box14_tab(l_b14_total_count).box14_code);

           END LOOP;
           CLOSE c_get_box14_boonmh ;
*/

hr_utility.trace('l_locality_tax :' || l_locality_tax );
hr_utility.trace('l_hi_state_printed' || l_hi_state_printed );
 If l_hi_state_printed = 'Y' and l_locality_tax > 0 then  /* 6519495  */

    l_b14_total_count := l_box14_tab.count + 1;

    l_box14_tab(l_b14_total_count).box14_meaning := l_local_tab(l_local_total_count).locality_tax ;
    l_box14_tab(l_b14_total_count).box14_code := l_local_tab(l_local_total_count).locality ;
    l_local_tab(l_local_total_count).locality_wages := 0 ;
    l_local_tab(l_local_total_count).locality_tax := 0 ;
    l_local_tab(l_local_total_count).locality := ' ' ;

  end if ;

     l_state_local_tab := populate_state_local_table
                                        (l_state_tab,l_local_tab);


       /* Code to print NJ DI.P.P. #  */
        -- Bug 4544792
        If l_nj_state_printed = 'Y' then
          l_nj_planid := pay_us_archive_util.get_archive_value(p_asg_action_id,
                                                           'A_SCL_ASG_US_NJ_PLAN_ID', --A_EXTRA_ASSIGNMENT_INFORMATION_PAY_US_DISABILITY_PLAN_INFO_DF_PLAN_ID'
                                                           p_tax_unit_id)   ;
          If l_nj_planid IS NOT NULL then
             hr_utility.trace('NJ DIPP plan id: ' || l_nj_planid);
		 --Bug 7361496 Formatting DI P.P. # for last 10 characters to appear in Employee W-2 PDF
		 l_nj_planid := substr(l_nj_planid,length(l_nj_planid)-10+1,length(l_nj_planid));
             l_b14_total_count := l_box14_tab.count + 1;
             l_box14_tab(l_b14_total_count).box14_code := 'DI P.P. # '||l_nj_planid ;
             l_box14_tab(l_b14_total_count).box14_meaning:='';
          end if;
         end if;

         /* Code to print Amended/amended date on W-2 */
         print_corrected();
     END IF; /* l_error_msg is not null */
   END;
-- } end get_w2_data

    FUNCTION create_xml_string (l_w2_fields l_w2_fields_rec,
                                l_box14_codea VARCHAR2,l_box14_meaninga VARCHAR2,
                                l_box14_codeb VARCHAR2,l_box14_meaningb VARCHAR2,
                                l_box14_codec VARCHAR2,l_box14_meaningc VARCHAR2,
                                l_box12_codea VARCHAR2,l_box12_meaninga VARCHAR2,
                                l_box12_codeb VARCHAR2,l_box12_meaningb VARCHAR2,
                                l_box12_codec VARCHAR2,l_box12_meaningc VARCHAR2,
                                l_box12_coded VARCHAR2,l_box12_meaningd VARCHAR2,
                                l_state1_code VARCHAR2,l_state1_ein VARCHAR2,
                                l_state1_wages VARCHAR2,l_state1_tax VARCHAR2,
                                l_local1_wages VARCHAR2,l_local1_tax VARCHAR2,
                                l_locality1 VARCHAR2,
                                l_state2_code VARCHAR2,l_state2_ein VARCHAR2,
                                l_state2_wages VARCHAR2, l_state2_tax VARCHAR2,
                                l_local2_wages VARCHAR2,l_local2_tax VARCHAR2,
                                l_locality2 VARCHAR2,p_year VARCHAR2)
    RETURN BLOB IS
       l_xml_string VARCHAR2(32767);
       l_xml_BLOB   BLOB;
       is_temp varchar2(10);
       text_size NUMBER;
       raw_data RAW(32767);
    begin
          hr_utility.trace('In create XML string ' );
          EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);
          IF (g_print_instr IS NULL) OR (g_print_instr = '') THEN
              g_print_instr := 'Y';
          END IF;
-- Bug 4523389 : added the tag <emp_suffix>
          l_xml_string :='<xapi:data>'||EOL||
          '<w2>'||EOL||
          '<control_number>' || xml_special_chars(l_w2_fields.control_number)||'</control_number>'||EOL||
          '<federal_ein>' || xml_special_chars(l_w2_fields.federal_ein) ||'</federal_ein>'||EOL||
          '<employer_name>'|| xml_special_chars(l_w2_fields.employer_name)||'</employer_name>'||EOL||
          '<employer_address>'|| xml_special_chars(l_w2_fields.employer_address)||'</employer_address>'||EOL||
          '<ssn>' || xml_special_chars(l_w2_fields.ssn) ||'</ssn>'||EOL||
          '<emp_name>' || xml_special_chars(l_w2_fields.emp_name) ||'</emp_name>'||EOL||
          '<last_name>' || xml_special_chars(l_w2_fields.last_name) ||'</last_name>'||EOL||
          '<emp_suffix>' || xml_special_chars(l_w2_fields.emp_suffix) ||'</emp_suffix>'||EOL||
          '<employee_address>' || xml_special_chars(l_w2_fields.employee_address)||'</employee_address>'||EOL||
          '<wages_tips_compensation>' || check_negative_number(l_w2_fields.wages_tips_compensation)  ||'</wages_tips_compensation>'||EOL||
          '<fit_withheld>' || check_negative_number(l_w2_fields.fit_withheld) ||'</fit_withheld>'||EOL||
          '<ss_wages>' || check_negative_number(l_w2_fields.ss_wages)||'</ss_wages>'||EOL||
          '<ss_withheld>' || check_negative_number(l_w2_fields.ss_withheld)||'</ss_withheld>'||EOL||
          '<med_wages>' || check_negative_number(l_w2_fields.med_wages)||'</med_wages>'||EOL||
          '<med_withheld>' || check_negative_number(l_w2_fields.med_withheld)||'</med_withheld>'||EOL||
          '<ss_tips>' ||check_negative_number(l_w2_fields.ss_tips)||'</ss_tips>'||EOL||
          '<allocated_tips>' ||check_negative_number(l_w2_fields.allocated_tips)||'</allocated_tips>'||EOL||
          '<eic_payment>' || check_negative_number(l_w2_fields.eic_payment)||'</eic_payment>'||EOL||
          '<dependent_care>' ||check_negative_number(l_w2_fields.dependent_care)||'</dependent_care>'||EOL||
          '<non_qual_plan>' || check_negative_number(l_w2_fields.non_qual_plan)||'</non_qual_plan>'||EOL||
          '<stat_employee>' || xml_special_chars(nvl(l_w2_fields.stat_employee,'N'))||'</stat_employee>'||EOL||
          '<retirement_plan>' || xml_special_chars(nvl(l_w2_fields.retirement_plan,'N'))||'</retirement_plan>'||EOL||
          '<sick_pay>' || xml_special_chars(nvl(l_w2_fields.sick_pay,'N'))||'</sick_pay>'||EOL||
          '<box14_codea>'||xml_special_chars(l_box14_codea) ||'</box14_codea>' ||EOL||
          '<box14_meaninga>'||xml_special_chars(l_box14_meaninga) ||'</box14_meaninga>' ||EOL||
          '<box14_codeb>'||xml_special_chars(l_box14_codeb) ||'</box14_codeb>' ||EOL||
          '<box14_meaningb>'||xml_special_chars(l_box14_meaningb) ||'</box14_meaningb>' ||EOL||
          '<box14_codec>'||xml_special_chars(l_box14_codec) ||'</box14_codec>' ||EOL||
          '<box14_meaningc>'||xml_special_chars(l_box14_meaningc) ||'</box14_meaningc>' ||EOL||
          '<box12_codea>'||xml_special_chars(l_box12_codea) ||'</box12_codea>' ||EOL||
          '<box12_meaninga>'||xml_special_chars(l_box12_meaninga) ||'</box12_meaninga>' ||EOL||
          '<box12_codeb>'||xml_special_chars(l_box12_codeb) ||'</box12_codeb>' ||EOL||
          '<box12_meaningb>'||xml_special_chars(l_box12_meaningb) ||'</box12_meaningb>' ||EOL||
          '<box12_codec>'||xml_special_chars(l_box12_codec) ||'</box12_codec>' ||EOL||
          '<box12_meaningc>'||xml_special_chars(l_box12_meaningc) ||'</box12_meaningc>' ||EOL||
          '<box12_coded>'||xml_special_chars(l_box12_coded) ||'</box12_coded>' ||EOL||
          '<box12_meaningd>'||xml_special_chars(l_box12_meaningd) ||'</box12_meaningd>' ||EOL||
          '<state1_code>'||xml_special_chars(l_state1_code)||'</state1_code>' ||EOL||
          '<state1_ein>'||xml_special_chars(l_state1_ein)||'</state1_ein>' ||EOL||
          '<state1_wages>'||xml_special_chars(l_state1_wages)||'</state1_wages>' ||EOL||
          '<state1_tax>'||xml_special_chars(l_state1_tax)||'</state1_tax>' ||EOL||
          '<local1_wages>'||check_negative_number(l_local1_wages)||'</local1_wages>' ||EOL||
          '<local1_tax>'||check_negative_number(l_local1_tax)||'</local1_tax>' ||EOL||
          '<locality1>'||xml_special_chars(l_locality1)||'</locality1>' ||EOL||
          '<state2_code>'||xml_special_chars(l_state2_code)||'</state2_code>' ||EOL||
          '<state2_ein>'||xml_special_chars(l_state2_ein)||'</state2_ein>' ||EOL||
          '<state2_wages>'||xml_special_chars(l_state2_wages)||'</state2_wages>' ||EOL||
          '<state2_tax>'||xml_special_chars(l_state2_tax)||'</state2_tax>' ||EOL||
          '<local2_wages>'||check_negative_number(l_local2_wages)||'</local2_wages>' ||EOL||
          '<local2_tax>'||check_negative_number(l_local2_tax)||'</local2_tax>' ||EOL||
          '<locality2>'||xml_special_chars(l_locality2)||'</locality2>' ||EOL||
          '<year>'||xml_special_chars(p_year)||'</year>' ||EOL||
          '<amended>' || xml_special_chars(l_w2_fields.amended)||'</amended>'||EOL||
          '<amended_date>' || xml_special_chars(l_w2_fields.amended_date)||'</amended_date>'||EOL||
          '<print_instruction>'||xml_special_chars(g_print_instr)||'</print_instruction>' ||EOL||
          '</w2>'||EOL||
          '</xapi:data>'||EOL;



          hr_utility.trace('one set XML string ' ||l_xml_string);
          is_temp := dbms_lob.istemporary(l_xml_blob);
          hr_utility.trace('Istemporary(l_xml_blob) ' ||is_temp );

          IF is_temp = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_xml_blob);
          END IF;

          dbms_lob.createtemporary(l_xml_blob,false,DBMS_LOB.CALL);
          dbms_lob.open(l_xml_blob,dbms_lob.lob_readwrite);
          hr_utility.trace('OPENED l_xml_blob ' );

          raw_data:=utl_raw.cast_to_raw(l_xml_string);
          text_size:=utl_raw.length(raw_data);

          dbms_lob.writeappend(l_xml_blob,text_size,raw_data);

          hr_utility.trace('Get Length l_xml_clob ' ||dbms_lob.getlength(l_xml_blob) );
          dbms_lob.close(l_xml_blob);
          return l_xml_blob;
    exception
          when OTHERS then
            dbms_lob.close(l_xml_blob);
            HR_UTILITY.TRACE('sqleerm ' || sqlerrm);
            HR_UTILITY.RAISE_ERROR;

    end create_xml_string;
--} end create_xml_string

    Function fetch_w2_xml(p_assignment_action_id Number,
                          p_tax_unit_id NUMBER,
                          p_year NUMBER,
                          p_error_msg out nocopy VARCHAR2,
                          p_is_SS  boolean)
    return BLOB
    is
       l_xml_blob BLOB ;
       l_out_create_xml BLOB;
       l_box14_codea VARCHAR2(100);
       l_box14_meaninga VARCHAR2(100);
       l_box14_codeb  VARCHAR2(100);
       l_box14_meaningb VARCHAR2(100);
       l_box14_codec VARCHAR2(100);
       l_box14_meaningc VARCHAR2(100);
       l_box12_codea VARCHAR2(100);
       l_box12_meaninga VARCHAR2(100);
       l_box12_codeb VARCHAR2(100);
       l_box12_meaningb VARCHAR2(100);
       l_box12_codec VARCHAR2(100);
       l_box12_meaningc VARCHAR2(100);
       l_box12_coded VARCHAR2(100);
       l_box12_meaningd VARCHAR2(100);
       l_state1_code VARCHAR2(100);
       l_state1_ein VARCHAR2(100);
       l_state1_wages VARCHAR2(100);
       l_state1_tax VARCHAR2(100);
       l_local1_wages VARCHAR2(100);
       l_local1_tax  VARCHAR2(100);
       l_locality1 VARCHAR2(100);
       l_state2_code VARCHAR2(100);
       l_state2_ein VARCHAR2(100);
       l_state2_wages VARCHAR2(100);
       l_state2_tax VARCHAR2(100);
       l_local2_wages VARCHAR2(100);
       l_local2_tax VARCHAR2(100);
       l_locality2  VARCHAR2(100);

       l_b14_total_count       number;
       l_b14_count_completed   number;
       l_b12_total_count       number;
       l_b12_count_completed   number;
       l_sl_total_count        number;
       l_sl_count_completed    number;
       l_local_total_count     number;
       l_local_count_completed number;
       l_state_local_count     number;
       l_state_local_total_count number;
       l_state_local_count_completed number;
       l_w2_set_cnt            number;
       l_is_temp_xml_string VARCHAR2(2);

    begin
       hr_utility.trace('In Fetch w2 xml loop ' );

       l_b14_total_count       := 0;
       l_b14_count_completed   := 0;
       l_b12_total_count       := 0;
       l_b12_count_completed   :=  0;
       l_sl_total_count        :=  0;
       l_sl_count_completed    :=  0;
       l_local_total_count     :=  0;
       l_local_count_completed := 0;
       l_state_local_count     := 0;
       l_state_local_total_count  := 0;
       l_state_local_count_completed :=  0;
       l_w2_set_cnt            := 0;

       get_w2_data(p_assignment_action_id,p_tax_unit_id,p_year,p_error_msg);

       IF p_error_msg IS NULL THEN

          hr_utility.trace('After get W2 data' );

          l_b14_total_count := l_box14_tab.count;
          l_b14_count_completed := 0;
          l_b12_total_count := l_box12_tab.count;
          l_b12_count_completed := 0;
          l_sl_total_count := l_state_tab.count;
          l_sl_count_completed := 0;
          l_local_total_count := l_local_tab.count;
          l_local_count_completed := 0;
          l_state_local_total_count := l_state_local_tab.count;
          l_state_local_count_completed := 0;

          l_is_temp_xml_string := dbms_lob.istemporary(l_xml_blob);
          hr_utility.trace('Istemporary(l_xml_blob) ' ||l_is_temp_xml_string );

          IF l_is_temp_xml_string = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_xml_blob);
          END IF;

          dbms_lob.createtemporary(l_xml_blob,false,DBMS_LOB.CALL);
          dbms_lob.open(l_xml_blob,dbms_lob.lob_readwrite);

        IF (l_b14_total_count = 0) AND
             (l_b12_total_count = 0) AND
             --(l_sl_total_count = 0)
             (l_state_local_total_count = 0) THEN

            hr_utility.trace('In l_b14_total_count and other counts =0 ' );
             -- dbms_lob.append(l_final_xml,p_xml_string);
              l_xml_blob := create_xml_string(l_w2_fields,
                                            l_box14_codea,l_box14_meaninga,
                                            l_box14_codeb,l_box14_meaningb,
                                            l_box14_codec,l_box14_meaningc,
                                            l_box12_codea,l_box12_meaninga,
                                            l_box12_codeb,l_box12_meaningb,
                                            l_box12_codec,l_box12_meaningc,
                                            l_box12_coded,l_box12_meaningd,
                                            l_state1_code,l_state1_ein,
                                            l_state1_wages,l_state1_tax,
                                            l_local1_wages,l_local1_tax,
                                            l_locality1,
                                            l_state2_code,l_state2_ein,
                                            l_state2_wages, l_state2_tax,
                                            l_local2_wages,l_local2_tax,
                                            l_locality2,p_year);
               hr_utility.trace('after getting XML Blob ' );

       ELSE

--{
          LOOP

            hr_utility.trace('In loop to get XML ' );
             hr_utility.trace('l_b14_total_count ' ||l_b14_total_count);
             hr_utility.trace('l_b14_count_completed ' ||l_b14_count_completed);
             hr_utility.trace('l_b12_total_count ' ||l_b12_total_count);
             hr_utility.trace('l_b12_count_completed ' ||l_b12_count_completed);

             hr_utility.trace('l_sl_total_count ' ||l_sl_total_count);
             hr_utility.trace('l_sl_count_completed ' ||l_sl_count_completed);
             hr_utility.trace('l_local_total_count ' ||l_local_total_count);
             hr_utility.trace('l_local_count_completed ' ||l_local_count_completed);
             hr_utility.trace('l_state_local_total_count ' ||l_state_local_total_count);
             hr_utility.trace('l_state_local_count_completed ' ||l_state_local_count_completed);
             hr_utility.trace('l_state_local_tab.COUNT ' ||l_state_local_tab.COUNT);

             EXIT WHEN
                 ((l_b14_total_count = 0) AND
                  (l_b12_total_count = 0 ) AND
                  (l_state_local_count_completed = l_state_local_total_count )) ;

          l_box14_codea := '';
          l_box14_meaninga := '';
          l_box14_codeb := '';
          l_box14_meaningb := '';
          l_box14_codec := '';
          l_box14_meaningc := '';

          IF l_b14_total_count > 0 THEN
                hr_utility.trace('1. l_b14_total_count >0 ' ||l_b14_total_count);
                l_b14_count_completed := l_b14_count_completed + 1 ;
                hr_utility.trace('1. l_b14_count_completed  ' ||l_b14_count_completed);
                l_box14_codea := l_box14_tab(l_b14_count_completed).box14_code;
                l_box14_meaninga := l_box14_tab(l_b14_count_completed).box14_meaning;
                l_b14_total_count := l_b14_total_count -1;
                hr_utility.trace('l_box14_codea ' ||l_box14_codea);
                 hr_utility.trace('l_box14_meaninga ' ||l_box14_meaninga);

          END IF;

          IF l_b14_total_count > 0 THEN
                hr_utility.trace('2. l_b14_total_count >0 ' ||l_b14_total_count);
                l_b14_count_completed := l_b14_count_completed + 1 ;
                hr_utility.trace('2. l_b14_count_completed ' ||l_b14_count_completed);
                l_box14_codeb := l_box14_tab(l_b14_count_completed).box14_code;
                l_box14_meaningb := l_box14_tab(l_b14_count_completed).box14_meaning;
                l_b14_total_count := l_b14_total_count - 1;
                hr_utility.trace('l_box14_codeb ' ||l_box14_codeb);
                hr_utility.trace('l_box14_meaningb ' ||l_box14_meaningb);

          END IF;

          IF l_b14_total_count > 0 THEN
                hr_utility.trace('3. l_b14_total_count >0 ' ||l_b14_total_count);

                l_b14_count_completed := l_b14_count_completed + 1 ;
                hr_utility.trace('3. l_b14_count_completed ' ||l_b14_count_completed);
                l_box14_codec := l_box14_tab(l_b14_count_completed).box14_code;
                l_box14_meaningc := l_box14_tab(l_b14_count_completed).box14_meaning;
                l_b14_total_count := l_b14_total_count -1;
                hr_utility.trace('l_box14_codec ' ||l_box14_codec);
                hr_utility.trace('l_box14_meaningc ' ||l_box14_meaningc);

          END IF;

          l_box12_codea    := '';
          l_box12_meaninga := '';
          l_box12_codeb := '';
          l_box12_meaningb := '';
          l_box12_codec := '';
          l_box12_meaningc := '';
          l_box12_coded := '';
          l_box12_meaningd := '';

          IF l_b12_total_count > 0 THEN
                hr_utility.trace('1. l_b12_total_count >0 ' ||l_b12_total_count);
                l_b12_count_completed := l_b12_count_completed + 1 ;
                l_box12_codea := l_box12_tab(l_b12_count_completed).box12_code;
                l_box12_meaninga := l_box12_tab(l_b12_count_completed).box12_meaning;
                l_b12_total_count := l_b12_total_count -1;

          END IF;

          IF l_b12_total_count > 0 THEN
                hr_utility.trace('2. l_b12_total_count >0 ' ||l_b12_total_count);

                l_b12_count_completed := l_b12_count_completed + 1 ;
                l_box12_codeb := l_box12_tab(l_b12_count_completed).box12_code;
                l_box12_meaningb := l_box12_tab(l_b12_count_completed).box12_meaning;
                l_b12_total_count := l_b12_total_count -1;
          END IF;

          IF l_b12_total_count > 0 THEN
                hr_utility.trace('3. l_b12_total_count >0 ' ||l_b12_total_count);

                l_b12_count_completed := l_b12_count_completed + 1 ;
                l_box12_codec := l_box12_tab(l_b12_count_completed).box12_code;
                l_box12_meaningc := l_box12_tab(l_b12_count_completed).box12_meaning;
                l_b12_total_count := l_b12_total_count -1;
          END IF;

          IF l_b12_total_count > 0 THEN
                hr_utility.trace('4. l_b12_total_count >0 ' ||l_b12_total_count);

                l_b12_count_completed := l_b12_count_completed + 1 ;
                l_box12_coded := l_box12_tab(l_b12_count_completed).box12_code;
                l_box12_meaningd := l_box12_tab(l_b12_count_completed).box12_meaning;
                l_b12_total_count := l_b12_total_count -1;
          END IF;

          l_state1_code := '';
          l_state1_ein := '';
          l_state1_wages := '';
          l_state1_tax := '';
          l_local1_wages := '';
          l_local1_tax := '';
          l_locality1 := '';

          l_state2_code := '';
          l_state2_ein := '';
          l_state2_wages := '';
          l_state2_tax := '';
          l_local2_wages := '';
          l_local2_tax := '';
          l_locality2 := '';


         IF l_state_local_count_completed < l_state_local_total_count THEN
                hr_utility.trace('1. l_state_local_total_count >0 ' ||l_state_local_total_count);

                l_state1_code:=  l_state_local_tab(l_state_local_count_completed).state_code;
                l_state1_ein :=  l_state_local_tab(l_state_local_count_completed).state_ein;
                l_state1_wages:= l_state_local_tab(l_state_local_count_completed).state_wages;
                l_state1_tax :=  l_state_local_tab(l_state_local_count_completed).state_tax;
                l_locality1   := l_state_local_tab(l_state_local_count_completed).locality;
                l_local1_wages:= l_state_local_tab(l_state_local_count_completed).locality_wages;
                l_local1_tax :=  l_state_local_tab(l_state_local_count_completed).locality_tax;
                l_state_local_count_completed := l_state_local_count_completed + 1 ;
               -- l_state_local_total_count := l_state_local_total_count -1;

          END IF;


             hr_utility.trace('l_state_local_total_count ' ||l_state_local_total_count);
             hr_utility.trace('l_state_local_count_completed ' ||l_state_local_count_completed);

          IF l_state_local_count_completed < l_state_local_total_count THEN
                hr_utility.trace('2. l_state_local_total_count >0 ' ||l_state_local_total_count);
                hr_utility.trace('2. l_state_local_total_count >0,l_state_local_count_completed ' ||l_state_local_total_count);

                l_state2_code:= l_state_local_tab(l_state_local_count_completed).state_code;
                l_state2_ein :=   l_state_local_tab(l_state_local_count_completed).state_ein;
                l_state2_wages:= l_state_local_tab(l_state_local_count_completed).state_wages;
                l_state2_tax :=   l_state_local_tab(l_state_local_count_completed).state_tax;
                l_locality2   := l_state_local_tab(l_state_local_count_completed).locality;
                l_local2_wages:= l_state_local_tab(l_state_local_count_completed).locality_wages;
                l_local2_tax :=  l_state_local_tab(l_state_local_count_completed).locality_tax;
          --      l_state_local_total_count := l_state_local_total_count -1;
                l_state_local_count_completed := l_state_local_count_completed + 1 ;

          END IF;

             hr_utility.trace('l_state_local_total_count ' ||l_state_local_total_count);
             hr_utility.trace('l_state_local_count_completed ' ||l_state_local_count_completed);
             hr_utility.trace('l_local_total_count ' ||l_local_total_count);
             hr_utility.trace('l_local_count_completed ' ||l_local_count_completed);

            l_w2_set_cnt := l_w2_set_cnt +1;
            IF l_w2_set_cnt > 1 THEN
                 l_w2_fields.wages_tips_compensation := '';
                 l_w2_fields.fit_withheld := '';
                 l_w2_fields.ss_wages := '';
                 l_w2_fields.ss_withheld := '';
                 l_w2_fields.med_wages:= '';
                 l_w2_fields.med_withheld := '';
                 l_w2_fields.ss_tips := '';
                 l_w2_fields.allocated_tips := '';
                 l_w2_fields.eic_payment := '';
                 l_w2_fields.dependent_care := '';
                 l_w2_fields.non_qual_plan := '';
                 l_w2_fields.stat_employee := '';
                 l_w2_fields.retirement_plan := '';
                 l_w2_fields.sick_pay := '';

             END IF;

            l_out_create_xml :=  create_xml_string(l_w2_fields,
                                            l_box14_codea,l_box14_meaninga,
                                            l_box14_codeb,l_box14_meaningb,
                                            l_box14_codec,l_box14_meaningc,
                                            l_box12_codea,l_box12_meaninga,
                                            l_box12_codeb,l_box12_meaningb,
                                            l_box12_codec,l_box12_meaningc,
                                            l_box12_coded,l_box12_meaningd,
                                            l_state1_code,l_state1_ein,
                                            l_state1_wages,l_state1_tax,
                                            l_local1_wages,l_local1_tax,
                                            l_locality1,
                                            l_state2_code,l_state2_ein,
                                            l_state2_wages,
                                            l_state2_tax,
                                            l_local2_wages,l_local2_tax,
                                            l_locality2,p_year);

          hr_utility.trace('After l_out_create_xml, length of LOB ' ||
                            dbms_lob.getlength(l_out_create_xml));
         -- IF l_xml_string is not NULL and l_out_create_xml IS NOT NULL THEN

          dbms_lob.append(l_xml_blob,l_out_create_xml);
          hr_utility.trace('Length of l_xml_blob  ' ||dbms_lob.getlength(l_xml_blob));

         /*  ELSE
               dbms_lob.writeappend(l_xml_string,dbms_lobamount,l_out_create_xml);;*/
        --   END IF;

         END LOOP;
       END IF;
--}
       END IF ; /* p_error_msg is null */
           hr_utility.trace('XML String is ');

           --hr_utility.trace(dbms_lob.substr(l_xml_string,,1));

           return l_xml_blob;
    EXCEPTION
          WHEN OTHERS then
            HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
    END fetch_w2_xml;

    FUNCTION get_final_xml (p_assignment_action_id Number,
                          p_tax_unit_id NUMBER,
                          p_year NUMBER,
                          p_w2_template_location VARCHAR2,
                          p_inst_template_location VARCHAR2,
                          p_output_location VARCHAR2,
                          p_error_msg OUT nocopy VARCHAR2)
    RETURN BLOB IS
         p_xml_blob  BLOB;
         l_final_xml BLOB;
         l_final_xml_string VARCHAR2(32000);
         l_last_xml_string VARCHAR2(32000);
         l_last_xml  BLOB;
         l_is_temp_final_xml VARCHAR2(2);
         l_temp_blob BLOB;

    BEGIN
      -- hr_utility.trace_on(null,'w2');
      hr_utility.trace('Deleting PL/SQL tables');
      l_state_local_tab.delete;
      l_state_tab.delete;
      l_local_tab.delete;
      l_box12_tab.delete;
      l_box14_tab.delete;

      l_w2_fields.amended := '';
      l_w2_fields.amended_date := '';
      EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);

      p_xml_blob := fetch_w2_xml(p_assignment_action_id ,
                          p_tax_unit_id ,
                          p_year,
                          p_error_msg , true);

      hr_utility.trace('dbms_lob.getlength(p_xml_blob) ' ||dbms_lob.getlength(p_xml_blob));

      IF p_error_msg IS NULL THEN
        hr_utility.trace('In final XML p_xml_string ');
       /* hr_utility.trace('XML String '||
                 dbms_lob.substr(p_xml_string,dbms_lob.getlength(p_xml_string),1));
       */
        l_final_xml_string :=
            --  '<?xml version="1.0" encoding="UTF-8" ?>'|| EOL||  Bug 6712851
               '<xapi:requestset xmlns:xapi="http://xmlns.oracle.com/oxp/xapi">'||EOL||
               '<xapi:request>'||EOL||
               '<xapi:delivery>'||EOL||
               '<xapi:filesystem output="'||p_output_location||'" />'||EOL||
               '</xapi:delivery>'||EOL||
               '<xapi:document output-type="pdf">'||EOL||
      --         '<xapi:template type="pdf" location="'||p_w2_template_location||'">'||EOL;
               '<xapi:template type="pdf" location="${templateName1}">'||EOL;
            --  '<xapi:template type="pdf" location="${templateName1}">'||EOL;


       hr_utility.trace('1. final 1. XML l_final_xml '||
       dbms_lob.substr(l_final_xml,dbms_lob.getlength(l_final_xml),1));

         l_last_xml_string := '</xapi:template>'||EOL||
           --   '<xapi:template type="pdf" location="'||p_inst_template_location||'">'||EOL||
               '<xapi:template type="pdf" location="${templateName2}">'||EOL||
              -- '<xapi:template type="pdf" location="${templateName2}">'||EOL||
               '<xapi:data />'|| EOL||
               '</xapi:template>'||EOL||
               '</xapi:document>'||EOL||
               '</xapi:request>'||EOL||
               '</xapi:requestset>';

          l_is_temp_final_xml := dbms_lob.istemporary(l_final_xml);
          hr_utility.trace('Istemporary(l_xml_string) ' ||l_is_temp_final_xml );

          IF l_is_temp_final_xml = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_final_xml);
          END IF;

        dbms_lob.createtemporary(l_final_xml,false,DBMS_LOB.CALL);
        dbms_lob.open(l_final_xml,dbms_lob.lob_readwrite);
        l_final_xml := append_to_lob(l_final_xml_string);
        --dbms_lob.writeappend(l_final_xml,length(l_final_xml_string),l_final_xml_string);

        hr_utility.trace('Get Length l_final_xml ' ||dbms_lob.getlength(l_final_xml) );

        dbms_lob.append(l_final_xml,p_xml_blob);

        --dbms_lob.writeappend(l_final_xml,length(l_last_xml_string),l_last_xml_string);
        dbms_lob.createtemporary(l_temp_blob,false,DBMS_LOB.CALL);
        dbms_lob.open(l_temp_blob,dbms_lob.lob_readwrite);
        l_temp_blob := append_to_lob(l_last_xml_string);
        dbms_lob.append(l_final_xml,l_temp_blob);

       /* Added ISOPEN condition for bug 3899583 */
        IF DBMS_LOB.isopen(l_final_xml) = 1 THEN
           hr_utility.trace('Closing l_final_xml' );
           dbms_lob.close(l_final_xml);
        END IF;
        IF dbms_lob.ISOPEN(p_xml_blob)=1  THEN
           hr_utility.trace('Closing p_xml_blob' );
           dbms_lob.close(p_xml_blob);
        END IF;
        IF dbms_lob.ISOPEN(l_temp_blob)=1  THEN
           hr_utility.trace('Closing l_temp_blob' );
           dbms_lob.close(l_temp_blob);
        END IF;
      ELSE
            dbms_lob.createtemporary(l_final_xml,false,DBMS_LOB.CALL);
            dbms_lob.open(l_final_xml,dbms_lob.lob_readwrite);
            l_final_xml := append_to_lob(p_error_msg);

            hr_utility.trace(' get final cml, p_error_msg '||p_error_msg);

      END IF ; /* p_error_msg is null */
       hr_utility.trace('dbms_lob.getlength(l_final_xml) ' ||dbms_lob.getlength(l_final_xml));

       return l_final_xml;
    EXCEPTION
          WHEN OTHERS then
             /* Added ISOPEN condition for bug 3899583 */
             IF dbms_lob.ISOPEN(l_final_xml)=1 THEN
               hr_utility.trace('Raising exception and Closing l_final_xml' );
               dbms_lob.close(l_final_xml);
             END IF;
             IF dbms_lob.ISOPEN(p_xml_blob)=1 THEN
                hr_utility.trace('Raising exception and Closing p_xml_string' );
                dbms_lob.close(p_xml_blob);
             END IF;
             IF dbms_lob.ISOPEN(l_temp_blob)=1  THEN
                hr_utility.trace('Closing l_temp_blob' );
                dbms_lob.close(l_temp_blob);
             END IF;


             HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
             raise;
    END get_final_xml;


    PROCEDURE fetch_w2_xm IS

        lc_emp_blob               BLOB;
        l_error_msg               VARCHAR2(200);
        l_assignment_action_id    NUMBER;
        l_main_assignment_action_id    NUMBER;
        l_tax_unit_id             NUMBER;
        l_year                    NUMBER;
        l_final_xml               BLOB;
        l_final_xml_string        VARCHAR2(32767);
        l_last_xml_string         VARCHAR2(32767);
        l_last_xml                CLOB;
        l_is_temp_final_xml       VARCHAR2(2);
        l_output_location         VARCHAR2(100);
        l_instr_template          VARCHAR2(100);
        EOL                       VARCHAR2(10);
        l_log                     VARCHAR2(100);
        buffer                    VARCHAR2(32767);
        amount                    NUMBER := 255;
        position                  VARCHAR2(1) :=1;
        l_temp_blob               BLOB;
        text_size NUMBER;
        raw_data RAW(32767);


        CURSOR c_get_params IS
         SELECT paa1.assignment_action_id, -- archiver asg action
               paa.assignment_action_id,
               hr_us_w2_mt.get_parameter('GRE_ID',ppa.legislative_parameters),
               hr_us_w2_mt.get_parameter('Year',ppa.legislative_parameters),
               hr_us_w2_mt.get_parameter('p_instr_template',ppa.legislative_parameters),
               hr_us_w2_mt.get_parameter('print_instrunction',ppa.legislative_parameters)
         FROM pay_assignment_actions paa,
              pay_payroll_actions ppa,
              pay_assignment_actions paa1,
              pay_payroll_actions ppa1
         where ppa.payroll_action_id = paa.payroll_action_id
         and ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
         and paa.assignment_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
         and paa.serial_number = paa1.assignment_action_id
         and paa1.payroll_action_id = ppa1.payroll_action_id
         and ppa1.report_type = 'YREND'
         and ppa1.action_type = 'X'
         and ppa1.action_status = 'C'
         and ppa1.effective_date = ppa.effective_date;
    BEGIN
         --hr_utility.trace_on(null,'w2');
         EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);
         hr_utility.trace('In fetch_w2_xm');

         hr_utility.trace('Deleting PL/SQL tables');
         l_state_local_tab.delete;
         l_state_tab.delete;
         l_local_tab.delete;
         l_box12_tab.delete;
         l_box14_tab.delete;
         l_w2_fields.amended := '';
         l_w2_fields.amended_date := '';

         OPEN c_get_params;
         FETCH c_get_params INTO
         l_assignment_action_id, l_main_assignment_action_id,
         l_tax_unit_id, l_year,l_instr_template,g_print_instr;
         CLOSE c_get_params;

         l_output_location := get_outfile;

          hr_utility.trace('l_assignment_action_id ' ||l_assignment_action_id);
          hr_utility.trace('l_main_assignment_action_id ' ||l_main_assignment_action_id);
          hr_utility.trace('l_tax_unit_id ' ||l_tax_unit_id);
          hr_utility.trace('l_year ' ||l_year);
          hr_utility.trace('l_output_location ' ||l_output_location);
          hr_utility.trace('l_instr_template ' ||l_instr_template);


          lc_emp_blob  := fetch_w2_xml(l_assignment_action_id,
                                       l_tax_unit_id,
                                       l_year,
                                       l_error_msg, false);
          hr_utility.trace('XML String is ');
          IF ((dbms_lob.getlength(lc_emp_blob) >0) and (l_error_msg IS NULL) )THEN

            --hr_utility.trace(dbms_lob.substr(lc_emp_blob,dbms_lob.getlength(lc_emp_blob),1));

            l_final_xml_string :=    /* 6712851 '<?xml version="1.0" encoding="UTF-8" ?>'|| EOL|| */
               '<xapi:requestset xmlns:xapi="http://xmlns.oracle.com/oxp/xapi">'||EOL||
               '<xapi:request>'||EOL||
               '<xapi:delivery>'||EOL||
               '<xapi:filesystem output="'||l_output_location||'" />'||EOL||
               '</xapi:delivery>'||EOL||
               '<xapi:document output-type="pdf">'||EOL||
               '<xapi:template type="pdf" location="${templateName1}">'||EOL;

            l_last_xml_string := '</xapi:template>'||EOL;

            IF ( l_instr_template IS NOT null) THEN
               l_last_xml_string :=  l_last_xml_string||
               '<xapi:template type="pdf" location="${templateName2}">'||EOL||
               '<xapi:data />'|| EOL||
               '</xapi:template>'||EOL;
            END IF;

            l_last_xml_string := l_last_xml_string ||
               '</xapi:document>'||EOL||
               '</xapi:request>'||EOL||
               '</xapi:requestset>'||EOL;


            l_is_temp_final_xml := dbms_lob.istemporary(l_final_xml);
            hr_utility.trace('Istemporary(l_xml_string) ' ||l_is_temp_final_xml );

            IF l_is_temp_final_xml = 1 THEN
              DBMS_LOB.FREETEMPORARY(l_final_xml);
            END IF;

            dbms_lob.createtemporary(l_final_xml,false,DBMS_LOB.CALL);
            dbms_lob.open(l_final_xml,dbms_lob.lob_readwrite);

            dbms_lob.createtemporary(l_temp_blob,false,DBMS_LOB.CALL);
            dbms_lob.open(l_temp_blob,dbms_lob.lob_readwrite);

            raw_data:=utl_raw.cast_to_raw(l_final_xml_string);
            text_size:=utl_raw.length(raw_data);

           -- dbms_lob.writeappend(l_final_xml,text_size,raw_data);

            /*dbms_lob.writeappend(l_final_xml,
                  utl_raw.length(utl_raw.cast_to_raw(l_final_xml_string)),
                  utl_raw.cast_to_raw(l_final_xml_string)
                 );*/
             l_temp_blob := append_to_lob(l_final_xml_string);
             dbms_lob.append(l_final_xml,l_temp_blob);

            --dbms_lob.writeappend(l_final_xml,length(l_final_xml_string),l_final_xml_string);

            hr_utility.trace('Get Length l_final_xml ' ||dbms_lob.getlength(l_final_xml) );

            dbms_lob.append(l_final_xml,lc_emp_blob);

            raw_data:=utl_raw.cast_to_raw(l_last_xml_string);
            text_size:=utl_raw.length(raw_data);

            --dbms_lob.writeappend(l_final_xml,text_size,raw_data);

            /*dbms_lob.writeappend(l_final_xml,
                  utl_raw.length(utl_raw.cast_to_raw(l_last_xml_string)),
                  utl_raw.cast_to_raw(l_last_xml_string)
                 );*/


            l_temp_blob := append_to_lob(l_last_xml_string);
            dbms_lob.append(l_final_xml,l_temp_blob);
            --dbms_lob.writeappend(l_final_xml,length(l_last_xml_string),l_last_xml_string);

            IF DBMS_LOB.isopen(l_final_xml) = 1 THEN
               hr_utility.trace('Closing l_final_xml' );
               dbms_lob.close(l_final_xml);
            END IF;
            IF dbms_lob.ISOPEN(lc_emp_blob)=1  THEN
               hr_utility.trace('Closing lc_emp_blob' );
               dbms_lob.close(lc_emp_blob);
            END IF;
            IF dbms_lob.ISOPEN(l_temp_blob)=1  THEN
               hr_utility.trace('Closing l_temp_blob' );
               dbms_lob.close(l_temp_blob);
            END IF;

            hr_utility.trace('dbms_lob.getlength(l_final_xml) ' ||dbms_lob.getlength(l_final_xml));

            pay_core_files.write_to_magtape_lob(l_final_xml);
           -- hr_utility.trace('Length of  pay_mag_tape.g_clob_value ' ||dbms_lob.getlength(pay_mag_tape.g_clob_value));

          END IF; /*dbms_lob.getlength(lc_emp_blob) >0*/
     --     l_is_temp_xml_string := dbms_lob.istemporary(pay_mag_tape.g_clob_value);

    EXCEPTION
          WHEN OTHERS then
             /* Added ISOPEN condition for bug 3899583 */
             IF dbms_lob.ISOPEN(l_final_xml)=1 THEN
               hr_utility.trace('Raising exception and Closing l_final_xml' ||sqlerrm);
               dbms_lob.close(l_final_xml);
             END IF;
             IF dbms_lob.ISOPEN(lc_emp_blob)=1 THEN
                hr_utility.trace('Raising exception and Closing p_xml_string' );
                dbms_lob.close(lc_emp_blob);
             END IF;
            IF dbms_lob.ISOPEN(l_temp_blob)=1  THEN
               hr_utility.trace('Closing l_temp_blob' );
               dbms_lob.close(l_temp_blob);
            END IF;

             HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
             raise;
    END;

    PROCEDURE get_footers IS

         l_footer_xml CLOB;
         l_last_xml_string VARCHAR2(32000);
         l_is_temp_final_xml VARCHAR2(2);
    BEGIN
           EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);
           l_last_xml_string :=
           '</EMPLOYEES>'||EOL;
           l_is_temp_final_xml := dbms_lob.istemporary(l_footer_xml);
           hr_utility.trace('Istemporary(l_footer_xml) ' ||l_is_temp_final_xml );

           IF l_is_temp_final_xml = 1 THEN
             DBMS_LOB.FREETEMPORARY(l_footer_xml);
           END IF;

           dbms_lob.createtemporary(l_footer_xml,false,DBMS_LOB.CALL);
           dbms_lob.open(l_footer_xml,dbms_lob.lob_readwrite);
           dbms_lob.writeappend(l_footer_xml,length(l_last_xml_string),l_last_xml_string);

           hr_utility.trace('In Get footers,Length of  length(l_footer_xml) ' ||dbms_lob.getlength(l_footer_xml));

           --dbms_lob.append(pay_mag_tape.g_clob_value,l_footer_xml);
           pay_core_files.write_to_magtape_lob(l_last_xml_string);
           --pay_core_files.write_to_magtape_lob(dbms_lob.substr(l_footer_xml,dbms_lob.getlength(l_footer_xml),1));

          --hr_utility.trace('In Get footers,Length of  pay_mag_tape.g_clob_value ' ||dbms_lob.getlength(pay_mag_tape.g_clob_value));
    END;

    PROCEDURE get_headers IS

         l_final_xml CLOB;
         l_final_xml_string VARCHAR2(32000);
         l_is_temp_final_xml VARCHAR2(2);
    BEGIN
            EOL    := fnd_global.local_chr(13)||fnd_global.local_chr(10);
            l_final_xml_string :=
              -- '<?xml version="1.0" encoding="UTF-8" ?>'|| EOL|| Bug 6712851
               '<EMPLOYEES>'||EOL;

           l_is_temp_final_xml := dbms_lob.istemporary(l_final_xml);
           hr_utility.trace('Istemporary(l_final_xml) ' ||l_is_temp_final_xml );

           IF l_is_temp_final_xml = 1 THEN
             DBMS_LOB.FREETEMPORARY(l_final_xml);
           END IF;

           dbms_lob.createtemporary(l_final_xml,false,DBMS_LOB.CALL);
           dbms_lob.open(l_final_xml,dbms_lob.lob_readwrite);
           dbms_lob.writeappend(l_final_xml,length(l_final_xml_string),l_final_xml_string);
           --dbms_lob.append(pay_mag_tape.g_clob_value,l_final_xml);
           pay_core_files.write_to_magtape_lob(l_final_xml_string);
           --pay_core_files.write_to_magtape_lob(dbms_lob.substr(l_final_xml_string,dbms_lob.getlength(l_final_xml_string),1));
           --hr_utility.trace('Length of  pay_mag_tape.g_clob_value ' ||dbms_lob.getlength(pay_mag_tape.g_clob_value));
    END;

function get_outfile return VARCHAR2 is
     TEMP_UTL varchar2(512);
     l_log    varchar2(100);
     l_out    varchar2(100);
begin
  hr_utility.trace('In get_out_file,g_temp_dir  ' ||g_temp_dir );

   if g_temp_dir  is null then
      -- use first entry of utl_file_dir as the g_temp_dir
       select translate(ltrim(value),',',' ')
        into TEMP_UTL
        from v$parameter
       where name = 'utl_file_dir';

      if (instr(TEMP_UTL,' ') > 0 and TEMP_UTL is not null) then
        select substrb(TEMP_UTL, 1, instr(TEMP_UTL,' ') - 1)
          into g_temp_dir
          from dual ;
      elsif (TEMP_UTL is not null) then
           g_temp_dir := TEMP_UTL;
      end if;

      if (TEMP_UTL is null or g_temp_dir is null ) then
         raise no_data_found;
      end if;
   end if;
   hr_utility.trace('In get_out_file,g_temp_dir  ' ||g_temp_dir );

   FND_FILE.get_names(l_log,l_out);

   l_out := g_temp_dir ||'/'||l_out;
   hr_utility.trace('In get_out_file,l_out  ' ||l_out );

   return l_out;

   exception
      when no_data_found then
         return null;
      when others then
         return null;
end get_outfile;
END PAY_US_W2_INFO_PKG;

/
