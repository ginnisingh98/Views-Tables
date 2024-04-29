--------------------------------------------------------
--  DDL for Package PAY_US_W2_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2_INFO_PKG" AUTHID CURRENT_USER as
/* $Header: pyusw2dt.pkh 120.6.12010000.3 2009/09/16 10:21:40 asgugupt ship $ */


 -- FUNCTION get_w2_data(p_assignment_action_id NUMBER) RETURN l_w2_fields_rec;

  TYPE l_w2_fields_rec IS RECORD(
              control_number     NUMBER,
              federal_ein        VARCHAR2(100),
              employer_name      VARCHAR2(200),
              employer_address   VARCHAR2(500),
              SSN                VARCHAR2(12),
              emp_name           VARCHAR2(200),
              last_name          VARCHAR2(200),
              emp_suffix         VARCHAR2(200),     -- Bug 4523389
              employee_address   VARCHAR2(500),
              wages_tips_compensation  NUMBER,
              fit_withheld       NUMBER,
              ss_wages           NUMBER,
              ss_withheld      NUMBER,
              med_wages        NUMBER,
              med_withheld     NUMBER,
              ss_tips          NUMBER,
              allocated_tips   NUMBER,
              eic_payment      NUMBER,
              dependent_care   NUMBER,
              non_qual_plan    NUMBER,
              stat_employee    VARCHAR2(1),
              retirement_plan  VARCHAR2(1),
              sick_pay         VARCHAR2(1),
              amended          VARCHAR2(20),
              amended_date     DATE);

  PROCEDURE get_w2_data(p_asg_action_id NUMBER,
                              p_tax_unit_id NUMBER,
                              p_year NUMBER,
                              p_error_msg out nocopy VARCHAR2);

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
  RETURN BLOB;

  FUNCTION fetch_w2_xml(p_assignment_action_id Number,
                          p_tax_unit_id NUMBER,
                          p_year NUMBER,
                          p_error_msg out nocopy VARCHAR2,
                          p_is_SS boolean)  RETURN BLOB;

  FUNCTION get_final_xml (p_assignment_action_id Number,
                          p_tax_unit_id NUMBER,
                          p_year NUMBER,
                          p_w2_template_location VARCHAR2,
                          p_inst_template_location VARCHAR2,
                          p_output_location VARCHAR2,
                          p_error_msg out nocopy  VARCHAR2)
  RETURN BLOB;

   TYPE l_w2_fields_tab IS TABLE OF
         l_w2_fields_rec
   INDEX BY BINARY_INTEGER;

   TYPE l_state_local_rec IS RECORD(
              state_code       VARCHAR2(20),
              state_ein         VARCHAR2(200),
              state_wages       VARCHAR2(20),
              state_tax         VARCHAR2(20),
              locality          VARCHAR2(100),
              locality_wages    NUMBER,
              locality_tax      NUMBER);

   TYPE l_state_local_table  IS TABLE OF
          l_state_local_rec
   INDEX BY BINARY_INTEGER;

    TYPE l_state_rec IS RECORD(
              state_code       VARCHAR2(20),
              state_ein         VARCHAR2(200),
              state_wages       VARCHAR2(20),
              state_tax         VARCHAR2(20));

   TYPE l_state_table IS TABLE OF
          l_state_rec
   INDEX BY BINARY_INTEGER;

   TYPE l_local_rec IS RECORD(
              locality          VARCHAR2(100),
              locality_wages    NUMBER,
              locality_tax      NUMBER,
              jurisdiction      VARCHAR2(15),
              state_code        VARCHAR2(10),
              tax_type          VARCHAR2(100));


  TYPE l_local_table IS TABLE OF
         l_local_rec
  INDEX BY BINARY_INTEGER;


   TYPE l_box12_rec IS RECORD(
              box12_meaning      VARCHAR2(100),
              box12_code        VARCHAR2(100));


  TYPE l_box12_table IS TABLE OF
         l_box12_rec
  INDEX BY BINARY_INTEGER;


  TYPE l_box14_rec IS RECORD(
          box14_meaning       VARCHAR2(100),
          box14_code        VARCHAR2(100));


  TYPE l_box14_table IS TABLE OF
         l_box14_rec
  INDEX BY BINARY_INTEGER;


  CURSOR main_block  IS
        SELECT 'Version_Number=X' ,'Version 1.1'
        FROM   sys.dual;

  CURSOR Transfer_Block  IS
--changes for Bug 8876216
/*    SELECT 'TRANSFER_ACT_ID=P', paa.assignment_action_id
    FROM   pay_assignment_actions paa
    WHERE  paa.payroll_action_id =
         pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');*/

 SELECT 'TRANSFER_ACT_ID=P', mt.assignment_action_id
 from hr_organization_units hou
 , hr_locations_all hl
 , per_periods_of_service pps
 , per_assignments_f paf
 , pay_assignment_actions mt
 , pay_payroll_actions ppa
 where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
       and mt.payroll_action_id = ppa.payroll_action_id
       and paf.assignment_id = mt.assignment_id
       and paf.effective_start_date = (select max(paf2.effective_start_date) from per_assignments_f paf2
			                                 where paf2.assignment_id = paf.assignment_id
				                               and paf2.effective_start_date <= to_date('31-DEC-'||hr_us_w2_mt.get_parameter('Year',ppa.legislative_parameters),'DD/MM/YYYY'))
       and paf.effective_end_date >= to_date('01-JAN-'||hr_us_w2_mt.get_parameter('Year',ppa.legislative_parameters),'DD/MM/YYYY')
       and paf.assignment_type = 'E'
       and pps.period_of_service_id = paf.period_of_service_id
       and pps.person_id = paf.person_id
       and hl.location_id = paf.location_id
       and hou.organization_id = paf.organization_id
       and hou.business_group_id + 0 = ppa.business_group_id
 order by decode(hr_us_w2_mt.get_parameter('S1',ppa.legislative_parameters), 'Employee_Name',
  hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'SSN',nvl(hr_us_w2_rep.get_per_item( to_number(mt.serial_number), 'A_PER_NATIONAL_IDENTIFIER'), 'Applied For'),
 'Zip_Code',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'Organization',hou.name, 'Location',hl.location_code,
 'Termination_Reason', decode(leaving_reason,null,'ZZ',hr_us_w2_rep.get_leav_reason(leaving_reason)),
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD'))),
 decode(hr_us_w2_mt.get_parameter('S2',ppa.legislative_parameters), 'Employee_Name',
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'SSN',nvl(hr_us_w2_rep.get_per_item(to_number(mt.serial_number), 'A_PER_NATIONAL_IDENTIFIER'), 'Applied For'),
 'Zip_Code',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'Organization',hou.name, 'Location',hl.location_code,
 'Termination_Reason',decode(leaving_reason,null,'ZZ',hr_us_w2_rep.get_leav_reason(leaving_reason)),
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD'))),
 decode(hr_us_w2_mt.get_parameter('S3',ppa.legislative_parameters), 'Employee_Name',
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'SSN',nvl(hr_us_w2_rep.get_per_item( to_number(mt.serial_number), 'A_PER_NATIONAL_IDENTIFIER'), 'Applied For'),
 'Zip_Code',hr_us_w2_rep.get_w2_postal_code( paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')),
 'Organization',hou.name, 'Location',hl.location_code, 'Termination_Reason',decode(leaving_reason,null,'ZZ',hr_us_w2_rep.get_leav_reason(leaving_reason)),
 hr_us_w2_rep.get_w2_employee_name(paf.person_id,to_date(hr_us_w2_mt.get_parameter('EFFECTIVE_DATE',ppa.legislative_parameters),'YYYY/MM/DD')));

--changes for Bug 8876216

  CURSOR c_get_asg_action IS
     SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

  PROCEDURE get_headers ;
  PROCEDURE get_footers;
  PROCEDURE fetch_w2_xm;
  FUNCTION get_outfile return VARCHAR2;

  level_cnt   NUMBER :=0;
  EOL         VARCHAR2(20) := fnd_global.local_chr(13)||fnd_global.local_chr(10);
  g_temp_dir   VARCHAR2(512);
END pay_us_w2_info_pkg;

/
