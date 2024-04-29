--------------------------------------------------------
--  DDL for Package Body PAY_CORE_XDO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_XDO_UTILS" as
/* $Header: paycorexdoutil.pkb 120.0.12000000.1 2007/03/21 13:52:03 sausingh noship $ */


Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER) IS

   -- Get request_id
   CURSOR get_request_id (c_pact_id NUMBER)IS
   SELECT request_id
     FROM pay_payroll_actions
    WHERE payroll_action_id = c_pact_id;

   -- Get Application Short Name and Application ID
   CURSOR get_application_detais(c_request_id NUMBER) IS
   SELECT app.application_short_name, fcp.application_id
     FROM fnd_application_vl app,
          fnd_concurrent_programs fcp,
          fnd_concurrent_requests r
    WHERE fcp.concurrent_program_id = r.concurrent_program_id
      AND r.request_id = c_request_id
      and app.application_id = fcp.application_id;


    -- Get template type
    CURSOR get_template_name(c_templ_code xdo_templates_tl.template_code%TYPE) IS
    SELECT template_name --template_type_code
      FROM xdo_templates_vl
     WHERE template_code = c_templ_code;

    CURSOR c_get_templates(l_payroll_action_id NUMBER) IS
      SELECT prv.value,
          prd.report_type,
          prd.report_level,
          prd.report_definition_id,
          nvl(prd.application_short_name,'PAY'),
          prv.definition_type,
          prv.report_variable_id
     FROM pay_report_groups              prg,
          pay_payroll_actions            ppa,
          pay_report_definitions         prd,
          pay_report_categories          prc,
          pay_report_category_components prcc,
          pay_report_variables           prv
    WHERE prg.short_name =
               nvl(pay_core_utils.get_parameter('REP_GROUP',
                                                ppa.legislative_parameters),
                   -1)
      AND ppa.payroll_action_id = l_payroll_action_id
      AND prg.report_group_id = prd.report_group_id
      AND prc.short_name =
               nvl(pay_core_utils.get_parameter('REP_CAT',
                                                ppa.legislative_parameters),
                   -1)
      AND prc.report_category_id = prcc.report_category_id
      AND prcc.report_definition_id = prd.report_definition_id
      AND prv.report_variable_id = prcc.style_sheet_variable_id
    ORDER BY prd.report_definition_id;

    CURSOR c_get_action_parameter(p_param_name VARCHAR2) IS
      SELECT parameter_value
      FROM pay_action_parameters
      where parameter_name = p_param_name;


   ln_req_id               NUMBER;
   ln_current_request_id   NUMBER;
   ln_application_id       NUMBER;
   ln_count                NUMBER;
   lv_proc_name            VARCHAR2(100);
   lv_template_type        xdo_templates_b.template_type_code%TYPE;
   lv_template_code        xdo_templates_tl.template_code%TYPE;
   lv_app_short_name       fnd_application_vl.application_short_name%TYPE;
   lv_template_name        xdo_templates_vl.template_name%TYPE;

   lv_report_definition_id NUMBER;
   lv_definition_type      VARCHAR2(20);
   lv_report_variable_id   NUMBER;
   lv_report_level         VARCHAR2(5);
   p_xdo_run               VARCHAR2(5);
   p_print_files           VARCHAR2(5);
   set_print_option        BOOLEAN;
   set_notification        BOOLEAN;
   copies_buffer           VARCHAR2(80) := NULL;
   print_buffer            VARCHAR2(80) := NULL;
   printer_buffer          VARCHAR2(80) := NULL;
   style_buffer            VARCHAR2(80) := NULL;
   save_buffer             BOOLEAN := NULL;
   save_result             VARCHAR2(1) := NULL;


PROCEDURE set_print_options(req_id NUMBER) IS
BEGIN
     hr_utility.trace ('Entering set_print_options');

      select number_of_copies,
        printer,
        print_style,
        save_output_flag
      into  copies_buffer,
        printer_buffer,
        style_buffer,
        save_result
      from  fnd_concurrent_requests
      where request_id = fnd_number.canonical_to_number(req_id);

        hr_utility.trace ('number_of_copies '||copies_buffer);
        hr_utility.trace ('printer '||printer_buffer);
        hr_utility.trace ('print_style '||style_buffer);
        hr_utility.trace ('save_output_flag '||save_result);

      if (save_result='Y') then
        save_buffer:=true;
      elsif (save_result='N') then
        save_buffer:=false;
      else
        save_buffer:=NULL;
      end if;

       set_print_option :=FND_REQUEST.set_print_options(
                   printer        => printer_buffer,
                   style          => style_buffer,
                   copies         => copies_buffer,
                   save_output    => save_buffer,
                   print_together => print_buffer);

    -- Bug 3487186 Added by ssmukher
       set_notification := fnd_Request.USE_CURRENT_NOTIFICATION;

     hr_utility.trace ('Leaving set_print_options');

END;

BEGIN

   lv_proc_name := 'PAY_AC_UTILITY.ARCHIVE_DEINIT';
   hr_utility.trace ('Entering '|| lv_proc_name);
   hr_utility.trace ('p_payroll_action_id '|| p_payroll_action_id);

   OPEN c_get_action_parameter('PRINT_FILES');
   FETCH c_get_action_parameter
   INTO p_print_files;
   CLOSE c_get_action_parameter;

   OPEN c_get_action_parameter('RUN_XDO');
   FETCH c_get_action_parameter
   INTO p_xdo_run;
   CLOSE c_get_action_parameter;

   hr_utility.trace ('p_xdo_run '|| p_xdo_run);
   hr_utility.trace ('p_print_files '|| p_print_files);

   IF (p_xdo_run = 'N') and (p_print_files = 'N') THEN


     OPEN get_request_id(p_payroll_action_id);
     FETCH get_request_id INTO ln_current_request_id;
     CLOSE get_request_id;

     OPEN get_application_detais(ln_current_request_id);
     FETCH get_application_detais INTO lv_app_short_name
                                    ,ln_application_id;
     CLOSE get_application_detais;

     ln_count := 1;

     OPEN c_get_templates(p_payroll_action_id);
     LOOP
        FETCH c_get_templates
        INTO lv_template_code, lv_template_type, lv_report_level,
             lv_report_definition_id, lv_app_short_name,
             lv_definition_type, lv_report_variable_id;

        EXIT WHEN c_get_templates%NOTFOUND;

        OPEN get_template_name(lv_template_code);
        FETCH get_template_name INTO lv_template_name;
        CLOSE get_template_name;

      -- pay_archive.remove_report_actions(p_payroll_action_id);

       hr_utility.trace ('ln_current_request_id '|| ln_current_request_id);
       hr_utility.trace ('lv_template_code '|| lv_template_code);
       hr_utility.trace ('ln_application_id '|| ln_application_id);
       hr_utility.trace ('lv_template_type '|| lv_template_type);

        set_print_options(ln_current_request_id);

        ln_req_id := fnd_request.submit_request
                            (  application    => 'PAY',
                               program        => 'PAYGENXDOREPORT',
                               argument1      => 'Y',
                               argument2      => ln_current_request_id,
                               argument3      => lv_template_code,
                               argument4      => lv_app_short_name,
                               argument5      => 'Y',
                               argument6      => lv_template_type,
                               argument7      => 'Y', --- calledFromDeinit
                               argument8      => lv_report_level, -- report_level
                               argument9      => 'STANDARD' -- report_level
                               );

       hr_utility.trace ('Submitted PAYGENXDOREP,ln_req_id '|| ln_req_id);

       request_list(ln_count) := ln_req_id;
       ln_count := ln_count + 1;


   END LOOP;

   END IF; /* print_files & xdo_run*/
   hr_utility.trace ('Leaving '|| lv_proc_name);
end ARCHIVE_DEINIT;

/* Procedure to remove data from pay_file_details*/
PROCEDURE del_file_details(pactid IN NUMBER) IS

Type file_detid_list is Table of pay_file_details.file_detail_id%type;
fdetlst file_detid_list;

Cursor csr_get_file_detl(payroll_act_id in number) is
select file_detail_id
  from pay_file_details
 where source_id = payroll_act_id
    or source_id in (select assignment_action_id
                       from pay_assignment_actions paa
                      where payroll_action_id = payroll_act_id);
BEGIN
--
       Open  csr_get_file_detl(pactid);
       Loop
            Fetch csr_get_file_detl bulk collect into fdetlst limit 1000;
               forall i in 1..fdetlst.count
                delete from pay_file_details
                where file_detail_id = fdetlst(i);

                exit when csr_get_file_detl%notfound;
        End loop;
      Close csr_get_file_detl;
--
END del_file_details;

/* This procedure deletes created actions after the submitted requests gets completed */
PROCEDURE standard_deinit(pactid IN NUMBER) IS
remove_act      VARCHAR2(10);
l_flag          BOOLEAN := TRUE;
l_valid_request BOOLEAN := FALSE;
l_phase         VARCHAR2(80);
l_status        VARCHAR2(80);
l_dev_phase     VARCHAR2(80);
l_dev_status    VARCHAR2(80);
l_message       VARCHAR2(80);
l_proc_name     VARCHAR2(100);
l_xdo_run       VARCHAR2(5);
l_print_files   VARCHAR2(5);

CURSOR c_get_action_parameter(p_param_name VARCHAR2) IS
SELECT parameter_value
  FROM pay_action_parameters
 WHERE parameter_name = p_param_name;

BEGIN
--
   l_proc_name := 'PAY_CORE_XDO_UTILS.STANDARD_DEINIT';
   hr_utility.trace ('Entering '|| l_proc_name);
   request_list.delete;

   archive_deinit(pactid);
   commit;

   OPEN c_get_action_parameter('PRINT_FILES');
   FETCH c_get_action_parameter
   INTO l_print_files;
   CLOSE c_get_action_parameter;

   OPEN c_get_action_parameter('RUN_XDO');
   FETCH c_get_action_parameter
   INTO l_xdo_run;
   CLOSE c_get_action_parameter;

   hr_utility.trace ('l_xdo_run '|| l_xdo_run);
   hr_utility.trace ('l_print_files '|| l_print_files);

   IF (l_xdo_run = 'N') and (l_print_files = 'N') THEN
      loop
      exit when not l_flag;
         for i in request_list.first..request_list.last loop
              hr_utility.trace ('request_list(i)'||request_list(i));
              l_valid_request := fnd_concurrent.get_request_status(
                                 request_id      => request_list(i),
                                 appl_shortname  => 'PAY',
                                 program         => 'PAYGENXDOREPORT',
                                 phase           => l_phase,
                                 status          => l_status,
                                 dev_phase       => l_dev_phase,
                                 dev_status      => l_dev_status,
                                 message         => l_message);

              hr_utility.trace ('l_dev_phase '|| l_dev_phase);
              if (l_valid_request and l_dev_phase not in ('PENDING', 'RUNNING')) then
                  hr_utility.trace ('In l_flag := FALSE');
                  l_flag := FALSE;
              else
                  l_flag := TRUE;
                  hr_utility.trace ('In l_flag := TRUE');
                  exit;
              end if;

              dbms_lock.sleep(20);
              hr_utility.trace ('Waiting for request completion...');

          end loop;
       end loop;
       hr_utility.trace ('All Requests Completed...');

   END IF; -- run_xdo = N and print_files = N
--
      select pay_core_utils.get_parameter('REMOVE_ACT',
                                          pa1.legislative_parameters)
        into remove_act
        from pay_payroll_actions pa1
       where pa1.payroll_action_id = pactid;
--
      if (remove_act is null or remove_act = 'Y') then
         del_file_details(pactid);
         hr_utility.trace ('pay_file_details deleted');
         pay_archive.remove_report_actions(pactid);
         hr_utility.trace ('Removed Payroll and assignment actions');
      end if;

      hr_utility.trace ('Leaving '|| l_proc_name);

END standard_deinit;


END pay_core_xdo_utils;

/
