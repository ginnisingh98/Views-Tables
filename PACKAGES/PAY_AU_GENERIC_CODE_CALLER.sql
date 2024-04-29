--------------------------------------------------------
--  DDL for Package PAY_AU_GENERIC_CODE_CALLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_GENERIC_CODE_CALLER" AUTHID CURRENT_USER as
  --  $Header: pyaugcc.pkh 115.3 2002/12/04 06:15:02 ragovind ship $

  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create AU HRMS generic code caller package.
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Reference Description
  --  -----------+--------+---------+-------------
  --  03 Dec 2002 Ragovind 2689226   Added NOCOPY for the functions get_module_parameters, retrieve_variable and added dbdrv command
  --  28 Feb 2000 JTurner            Renamed script and objects to use country
  --                                 identifier of "AU" instead of "NZ"
  --  30 NOV 1999 JTURNER  N/A       Created

  -----------------------------------------------------------------------------
  -- public global declarations
  -----------------------------------------------------------------------------

  type t_variable_store_rec is record
  (name                           pay_au_module_parameters.internal_name%type
  ,data_type                      pay_au_module_parameters.data_type%type
  ,value                          pay_au_module_parameters.constant_value%type) ;

  type t_variable_store_tab
    is table of t_variable_store_rec
    index by binary_integer ;

  v_variable_store                t_variable_store_tab ;

  type t_parameter_store_rec is record
  (internal_name                  pay_au_module_parameters.internal_name%type
  ,data_type                      pay_au_module_parameters.data_type%type
  ,input_flag                     pay_au_module_parameters.input_flag%type
  ,context_flag                   pay_au_module_parameters.context_flag%type
  ,output_flag                    pay_au_module_parameters.output_flag%type
  ,result_flag                    pay_au_module_parameters.result_flag%type
  ,error_message_flag             pay_au_module_parameters.error_message_flag%type
  ,function_return_flag           pay_au_module_parameters.function_return_flag%type
  ,external_name                  pay_au_module_parameters.external_name%type
  ,database_item_name             pay_au_module_parameters.database_item_name%type
  ,constant_value                 pay_au_module_parameters.constant_value%type) ;

  type t_parameter_store_tab
    is table of t_parameter_store_rec
    index by binary_integer ;

  -----------------------------------------------------------------------------
  --  execute_process procedure
  -----------------------------------------------------------------------------

  procedure execute_process
  (p_business_group_id            in     number
  ,p_effective_date               in     date
  ,p_process_id                   in     number
  ,p_assignment_action_id         in     number
  ,p_input_store                  in     t_variable_store_tab) ;

  -----------------------------------------------------------------------------
  --  store_variable procedure
  -----------------------------------------------------------------------------

  procedure store_variable
  (p_name                         in     varchar2
  ,p_data_type                    in     varchar2
  ,p_value                        in     varchar2) ;

  -----------------------------------------------------------------------------
  --  retrieve_variable procedure
  -----------------------------------------------------------------------------

  procedure retrieve_variable
  (p_name                         in     varchar2
  ,p_data_type                    in     varchar2
  ,p_value                        out NOCOPY varchar2) ;

  -----------------------------------------------------------------------------
  --  execute_procedure procedure
  -----------------------------------------------------------------------------

  procedure execute_procedure
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_procedure_name               in     varchar2) ;

  -----------------------------------------------------------------------------
  --  execute_function procedure
  -----------------------------------------------------------------------------

  procedure execute_function
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_function_name                in     varchar2) ;

  -----------------------------------------------------------------------------
  --  execute_procedure_function procedure
  -----------------------------------------------------------------------------

  procedure execute_procedure_function
  (p_module_id                    in     number
  ,p_package_name                 in     varchar2
  ,p_procedure_function_name      in     varchar2
  ,p_mode                         in     varchar2) ;

  -----------------------------------------------------------------------------
  --  execute_formula procedure
  -----------------------------------------------------------------------------

  procedure execute_formula
  (p_module_id                    in     number
  ,p_formula_name                 in     varchar2) ;

  -----------------------------------------------------------------------------
  --  save_result procedure
  -----------------------------------------------------------------------------

  procedure save_result
  (p_database_item_name           in     varchar2
  ,p_result_value                 in     varchar2) ;

  -----------------------------------------------------------------------------
  --  get_module_parameters procedure
  -----------------------------------------------------------------------------

  procedure get_module_parameters
  (p_module_id                    in     number
  ,p_parameters                   out NOCOPY t_parameter_store_tab) ;

end pay_au_generic_code_caller ;

 

/
