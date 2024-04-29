--------------------------------------------------------
--  DDL for Package HR_GB_PROCESS_P11D_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GB_PROCESS_P11D_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: pygbp11d.pkh 120.5.12010000.4 2010/02/19 09:25:57 krreddy ship $ */
   c_ben_start_date_string CONSTANT pay_input_values_f.NAME%TYPE := 'Benefit Start Date';
   c_ben_end_date_string CONSTANT pay_input_values_f.NAME%TYPE := 'Benefit End Date';
   c_commit_num         CONSTANT NUMBER := 100000;
-- these values will be used in self service code
   g_payroll_action_id NUMBER(9);
   g_person_id         NUMBER;
   g_emp_ref_no        varchar2(150);
   g_employer_name     varchar2(150);
   TYPE l_typ_p11d_fields_rec IS RECORD(
      director_flag                 VARCHAR2(10),
      full_name                     VARCHAR2(150),
      sur_name                      VARCHAR2(150), -- P11D changes 07/08
      fore_name                     VARCHAR2(150), -- P11D changes 07/08
      employee_number               VARCHAR2(150),
      national_ins_no               VARCHAR2(150),
      employers_ref_no              VARCHAR2(150),
      employers_name                VARCHAR2(150),
      date_of_birth                 VARCHAR2(15),
      gender                        VARCHAR2(15),
      a_desc                        VARCHAR2(150),
      a_cost                        VARCHAR2(15),
      a_amg                         VARCHAR2(15),
      a_ce                          VARCHAR2(15),
      b_desc                        VARCHAR2(150),
      b_ce                          VARCHAR2(15),
      b_tnp                         VARCHAR2(15),
      c_cost                        VARCHAR2(15),
      c_amg                         VARCHAR2(15),
      c_ce                          VARCHAR2(15),
      d_ce                          VARCHAR2(15),
      e_ce                          VARCHAR2(15),
      f1_make                       VARCHAR2(150),
      f1_dreg                       VARCHAR2(15),
      f1_efig                       VARCHAR2(15),
      f1_nfig                       VARCHAR2(15),
      f1_esize                      VARCHAR2(15),
      f1_fuel                       VARCHAR2(15),
      f1_start                      VARCHAR2(15),
      f1_end                        VARCHAR2(15),
      f1_lprice                     VARCHAR2(15),
      f1_oprice                     VARCHAR2(15),
      f1_aprice                     VARCHAR2(15),
      f1_cost                       VARCHAR2(15),
      f1_amg                        VARCHAR2(15),
      f1_cc                         VARCHAR2(15),
      f1_fcc                        VARCHAR2(15),
      f1_date_free                  VARCHAR2(15),
      f1_rein_yr                    VARCHAR2(15),
      f2_make                       VARCHAR2(150),
      f2_dreg                       VARCHAR2(15),
      f2_efig                       VARCHAR2(15),
      f2_nfig                       VARCHAR2(15),
      f2_esize                      VARCHAR2(15),
      f2_fuel                       VARCHAR2(15),
      f2_start                      VARCHAR2(15),
      f2_end                        VARCHAR2(15),
      f2_lprice                     VARCHAR2(15),
      f2_oprice                     VARCHAR2(15),
      f2_aprice                     VARCHAR2(15),
      f2_cost                       VARCHAR2(15),
      f2_amg                        VARCHAR2(15),
      f2_cc                         VARCHAR2(15),
      f2_fcc                        VARCHAR2(15),
      f2_date_free                  VARCHAR2(15),
      f2_rein_yr                    VARCHAR2(15),
  --  new fields added for 2003-04 report
      f_date_free                   VARCHAR2(15),
      f_rein_yr                     VARCHAR2(15),
      f_tcce                        VARCHAR2(15),
      f_tfce                        VARCHAR2(15),
      g_ce                          VARCHAR2(15),
      g_cef                         VARCHAR2(15), -- P11D changes 07/08
      h1_njb                        VARCHAR2(15),
      h1_ayb                        VARCHAR2(15),
      h1_aye                        VARCHAR2(15),
      h1_mao                        VARCHAR2(15),
      h1_ip                         VARCHAR2(15),
      h1_dlm                        VARCHAR2(15),
      h1_dld                        VARCHAR2(15),
      h1_ce                         VARCHAR2(15),
      h2_njb                        VARCHAR2(15),
      h2_ayb                        VARCHAR2(15),
      h2_aye                        VARCHAR2(15),
      h2_mao                        VARCHAR2(15),
      h2_ip                         VARCHAR2(15),
      h2_dlm                        VARCHAR2(15),
      h2_dld                        VARCHAR2(15),
      h2_ce                         VARCHAR2(15),
      i_cost                        VARCHAR2(15),
      i_amg                         VARCHAR2(15),
      i_ce                          VARCHAR2(15),
      j_ce                          VARCHAR2(15),
      k_cost                        VARCHAR2(15),
      k_amg                         VARCHAR2(15),
      k_ce                          VARCHAR2(15),
      l_desc                        VARCHAR2(150),
      l_cost                        VARCHAR2(15),
      l_amg                         VARCHAR2(15),
      l_ce                          VARCHAR2(15),
      m_shares                      VARCHAR2(15),
      n_cost                        VARCHAR2(15),
      n_amg                         VARCHAR2(15),
      n_ce                          VARCHAR2(15),
      n_desc                        VARCHAR2(150),
      na_cost                       VARCHAR2(15),
      na_amg                        VARCHAR2(15),
      na_ce                         VARCHAR2(15),
      na_desc                       VARCHAR2(150),
      n_taxpaid                     VARCHAR2(150),
      o1_cost                       VARCHAR2(15),
      o1_amg                        VARCHAR2(15),
      o1_ce                         VARCHAR2(15),
      o2_cost                       VARCHAR2(15),
      o2_amg                        VARCHAR2(15),
      o2_ce                         VARCHAR2(15),
      o3_cost                       VARCHAR2(15),
      o3_amg                        VARCHAR2(15),
      o3_ce                         VARCHAR2(15),
      o4_cost                       VARCHAR2(15),
      o4_amg                        VARCHAR2(15),
      o4_ce                         VARCHAR2(15),
      o5_cost                       VARCHAR2(15),
      o5_amg                        VARCHAR2(15),
      o5_ce                         VARCHAR2(15),
      o6_cost                       VARCHAR2(15),
      o6_amg                        VARCHAR2(15),
      o6_ce                         VARCHAR2(15),
      o6_desc                       VARCHAR2(150),
      o_toi                         VARCHAR2(15) );
  -- this function returns the record because the
  -- p11d ss process can be later used to
  -- produce the paper report.
  -- this was this function can be called in a loop
  -- and later xml string can be generated using the
  -- output.
  TYPE g_typ_act_info_ids  IS TABLE OF Number(15)
  INDEX BY BINARY_INTEGER;
  TYPE g_typ_xml_str  IS TABLE OF Clob
  INDEX BY BINARY_INTEGER;
  type g_xfdf_str_array is table of varchar2(10000)
  index by binary_integer;
  type g_xfdf_blob_array is table of blob
  index by binary_integer;
  type ref_cursor_typ is ref cursor;
   PROCEDURE delete_entries(
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_element_type_id          IN       pay_element_types_f.element_type_id%TYPE,
      p_start_date               IN       VARCHAR2,
      p_end_date                 IN       VARCHAR2,
      p_bus_grp_id               IN       pay_element_types_f.business_group_id%TYPE,
      p_assignment_set_id        In       Number   );
   FUNCTION get_global_value(p_global_name IN VARCHAR2, p_benefit_end_date IN VARCHAR2 DEFAULT '0001/01/01 00:00:00')
      RETURN VARCHAR2;
   FUNCTION sum_and_set_global_var(p_varable_name IN VARCHAR2, p_variable_value IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION check_desc_and_set_global_var(p_varable_name IN VARCHAR2,
                                          p_variable_value IN VARCHAR2,
                                          p_lookup_type IN VARCHAR2 DEFAULT NULL,
                                          p_effective_date IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
  Function max_and_set_global_var(p_variable_name IN Varchar2,
                                  p_variable_datatype IN Varchar2,
                                  p_variable_value IN Varchar2
                                  )
  return varchar2;
   FUNCTION get_incorrect_val_error(p_token1 IN VARCHAR2, p_token2 IN VARCHAR2, p_token3 IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION get_null_error(p_token1 IN VARCHAR2, p_token2 IN VARCHAR2, p_token3 IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION get_error_message(p_applid IN NUMBER, p_message_name IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION get_loan_amount(
      p_archive_payroll_action_id IN      VARCHAR2,
      p_employers_ref_no         IN       VARCHAR2,
--      p_employers_name              IN   VARCHAR2,
      p_person_id                IN       VARCHAR2)
      RETURN VARCHAR2;
/*
  NAME
    get_and_push_message
  DESCRIPTION
    Gets a translated FND message (supplying up to 5 tokens). Tokens are
    not translated. It calls the core func and then pushes the message as
    well
    p_application  - application short name e.g. 'PAY', 'PER'.
    p_message      - message name e.g. 'HR_6153_ALL_PROCEDURE_FAIL'
    p_token_nameN  - name of Nth token.
    p_token_valueN - (string) value for Nth token.
  NOTES
    Returns p_message if the translated message evaluates as null.
*/
   FUNCTION get_and_push_message(
      p_application              IN       VARCHAR2,
      p_message                  IN       VARCHAR2,
      p_stack_level              IN       VARCHAR2 DEFAULT 'A',
      p_token_name1              IN       VARCHAR2 DEFAULT NULL,
      p_token_value1             IN       VARCHAR2 DEFAULT NULL,
      p_token_name2              IN       VARCHAR2 DEFAULT NULL,
      p_token_value2             IN       VARCHAR2 DEFAULT NULL,
      p_token_name3              IN       VARCHAR2 DEFAULT NULL,
      p_token_value3             IN       VARCHAR2 DEFAULT NULL,
      p_token_name4              IN       VARCHAR2 DEFAULT NULL,
      p_token_value4             IN       VARCHAR2 DEFAULT NULL,
      p_token_name5              IN       VARCHAR2 DEFAULT NULL,
      p_token_value5             IN       VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;
  Function fetch_p11d_rep_data (p_assignment_action_id Number)
  return l_typ_p11d_fields_rec;
/*  Function fetch_p11d_rep_data_xml (p_assignment_action_id Number)
  return CLOB;*/
  Function fetch_p11d_rep_data_blob (p_assignment_action_id Number)
  return BLOB;
  Function get_p11d_year
  return varchar2;
  Function get_ben_start_date
  return date;
  Function get_ben_end_date
  return date;
  PROCEDURE update_leg_process_status(
      errbuf                     OUT NOCOPY VARCHAR2,
      retcode                    OUT NOCOPY NUMBER,
      p_payroll_action_id        IN  Number,
      p_new_status               IN  Varchar2
      );
  Function fetch_arch_param_details(
      p_payroll_action_id        IN  Number
      )
   return varchar2;
  Function fetch_leg_process_status(
      p_payroll_action_id        IN  Number
      )
   return varchar2;
  Function fetch_leg_process_runtype(
      p_payroll_action_id        IN  Number
      )
   return varchar2;
  Function fetch_leg_process_notes(
      p_payroll_action_id        IN  Number
      )
   return varchar2;
  function get_lookup_meaning( p_lookup_type varchar2,
                               p_lookup_code varchar2,
                               p_effective_date date)
  return varchar2 ;
  Function fetch_ws1_ref_cursor (p_assignment_action_id Number,
                                 p_record_num OUT NOCOPY Number)
  return ref_cursor_typ;
  Function fetch_ws2_ref_cursor (p_assignment_action_id Number,
                                 p_record_num OUT NOCOPY Number)
  return ref_cursor_typ;
  Function fetch_ws3_ref_cursor (p_assignment_action_id Number,
                                 p_record_num OUT NOCOPY Number)
  return ref_cursor_typ;
  Function fetch_ws4_ref_cursor (p_assignment_action_id Number,
                                 p_record_num OUT NOCOPY Number)
  return ref_cursor_typ;
  Function fetch_ws6_ref_cursor (p_assignment_action_id Number,
                                 p_record_num OUT NOCOPY Number)
  return ref_cursor_typ;
  Function fetch_summary_xfdf_blob (p_assignment_action_id Number,
                                    p_print_Style varchar2)--bug 8241399
                                    -- p_print style parameter added to suppress additional blank page
  return blob;
/*To create xfdf string for Address report*/
/*Bug No. 3201848*/
  Function fetch_address_xfdf_blob (p_assignment_action_id Number,
                                    p_print_Style varchar2,--bug 8241399
				    -- p_print style parameter added to suppress additional blank page
				    p_priv_mark varchar2)--bug 8942337
                                    --p_priv_mark parameter added to print user defined Data
				    --Privacy Marking on the address page

  return blob;
  Function fetch_ws5_data_blob (p_assignment_action_id Number)
  return blob;
  function fetch_numberof_assignments(p_payroll_action_id Number)
  return number;

  function write_magtape_records(p_arch_payroll_action_id number,
                                 p_emp_ref_no varchar2,
                                 p_person_id varchar2,
   				 p_assignment_number    OUT NOCOPY VARCHAR2,
				 p_int_max_amt_outstanding OUT NOCOPY VARCHAR2)
  return number;



  Function rep_assignment_actions(p_payroll_action_id Number,
                              p_assignment_action_id  Number,
                              p_organization_id Number,
                              p_location_code Varchar2,
                              p_org_hierarchy Number,
                              p_assignment_set_id Number,
                              p_sort_order1 Varchar2,
                              p_sort_order2 Varchar2,
                              p_chunk_size  Number,
                              p_chunk_number Number,
                              p_person_type  Varchar2)
  Return ref_cursor_typ;
--Added the below function to fix the EAP bug 9383416
  function validate_display_output(p_assignment_action_id Number)
  return number;
end;

/
