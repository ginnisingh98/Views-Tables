--------------------------------------------------------
--  DDL for Package Body PAY_BACM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BACM" AS
/* $Header: pybacsmd.pkb 115.0 99/07/17 05:43:43 porting ship $ */
FUNCTION is_date_valid( ass_act_id in number ,
                        ov_rid_date IN DATE,
                        per_pro_date IN DATE)
                              RETURN VARCHAR IS
--
  assign_act_id  number := ass_act_id;
  ov_date DATE :=  ov_rid_date;
  p_proc_date DATE := per_pro_date;
  rr_date varchar(11):= '01-01-1900';
--
BEGIN
      select prrv.result_value into rr_date
          from
                  pay_element_types                 pet,
                 pay_input_values                  piv,
                 pay_run_result_values             prrv,
                  pay_run_results                   prr
           where  prr.assignment_action_id
                          = assign_act_id
           and    prrv.run_result_id
                         = prr.run_result_id
           and    pet.element_type_id
                         = prr.element_type_id
           and    pet.element_name
                         = 'BACS Process Date'
           and    piv.input_value_id
                          = prrv.input_value_id
           and    piv.name
                          = 'Process Date';
--
if to_date(rr_date, 'DD-MON-YYYY') = per_pro_date then
      Return 'TRUE';
elsif (to_date(rr_date, 'DD-MON-YYYY') < per_pro_date and
      per_pro_date = ov_rid_date) then
      return 'TRUE';
else
      return 'FALSE';
end if;
--
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       return 'FALSE';
    WHEN OTHERS THEN
       return 'FALSE';
END is_date_valid;
END pay_bacm;

/
