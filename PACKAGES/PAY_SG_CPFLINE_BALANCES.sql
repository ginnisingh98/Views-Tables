--------------------------------------------------------
--  DDL for Package PAY_SG_CPFLINE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_CPFLINE_BALANCES" AUTHID CURRENT_USER as
/* $Header: pysgcpfb.pkh 120.0.12000000.1 2007/01/18 01:29:22 appldev noship $ */
       ------------------------------------------------------
       -- Global Variables used in function get_balance_value
       ------------------------------------------------------
       global_exist_emp boolean := true;
       global_bal_count number  := 0 ;
       ------------------------------------------------------
       -- Record Used in function get_balance_value
       -- Bug No:3298317 Added column permit_type
       -- Bug No:4226037 Added column termination_date
       ------------------------------------------------------
       type dup_employee_store_rec is record
           ( cpf_acc_number          varchar2(150),
             legal_name              varchar2(150),
             employee_number         varchar2(30),
	     permit_type             per_people_f.per_information6%type,
             department              varchar2(200),
             assignment_id           per_all_assignments_f.assignment_id%type,
             assignment_action_id    pay_assignment_actions.assignment_action_id%type,
             tax_unit_id             pay_assignment_actions.tax_unit_id%type,
             effective_date          pay_payroll_actions.effective_date%type,
             cl_record_status        varchar2(1),
             mf_record_status        varchar2(1),
             termination_date        pay_action_information.action_information19%type
           );
       --
       type dup_employee_store_tab is table of dup_employee_store_rec  index by binary_integer;
       t_dup_emp_rec dup_employee_store_tab;
       ------------------------------------------------------------
       -- This function is called from company_identification cursor
       ------------------------------------------------------------
       function stat_type_amount
           ( p_payroll_action_id in  number,
             p_stat_type         in  varchar2 )
       return number ;
       ------------------------------------------------------------
       -- This function is called from company_identification cursor
       ------------------------------------------------------------
       function balance_amount
           ( p_payroll_action_id in  number,
             p_balance_name      in  varchar2 )
       return number ;
       ------------------------------------------------------------
       -- This function is called from company_identification cursor
       ------------------------------------------------------------
       function stat_type_count
           ( p_payroll_action_id  in number,
             p_stat_type          in varchar2 )
       return number;
       --------------------------------------------------------------------------
       -- This function is called from existing_employee and new_employee cursors
       --------------------------------------------------------------------------
       function get_balance_value
           (  p_employee_type        in  varchar2,
              p_assignment_id        in  per_all_assignments_f.assignment_id%type,
              p_cpf_acc_number       in  varchar2,
              p_department           in  varchar2,
              p_assignment_action_id in  varchar2,
              p_tax_unit_id          in  varchar2,
              p_balance_name         in  varchar2,
	      p_balance_value        in  varchar2,
	      p_payroll_action_id    in  number  ,
	      p_permit_type          in  per_people_f.per_information6%type  )
       return varchar2  ;
       --------------------------------------------------------------------------
       --Bug# 3501950
       -- This function is called from company_identification cursor
       --------------------------------------------------------------------------
       function get_cpf_interest
           (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
       return varchar2;
       --------------------------------------------------------------------------
       --Bug# 3501950
       -- This function is called from company_identification cursor
       --------------------------------------------------------------------------
       function get_fwl_interest
           (c_payroll_action_id in pay_payroll_actions.payroll_action_id%type)
       return varchar2;
end pay_sg_cpfline_balances;

 

/
