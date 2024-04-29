--------------------------------------------------------
--  DDL for Package PAY_LINK_INPUT_VALUES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LINK_INPUT_VALUES_BK1" AUTHID CURRENT_USER as
/* $Header: pylivapi.pkh 120.1 2005/10/02 02:32:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_link_input_values_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_link_input_values_b
  (p_effective_date             in   date
  ,p_datetrack_update_mode      in   varchar2
  ,p_link_input_value_id        in   number
  ,p_element_link_id            in   number
  ,p_input_value_id             in   number
  ,p_costed_flag                in   varchar2
  ,p_default_value              in   varchar2
  ,p_max_value                  in   varchar2
  ,p_min_value                  in   varchar2
  ,p_warning_or_error           in   varchar2
  ,p_object_version_number      in   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_link_input_values_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_link_input_values_a
  (p_effective_date             in   date
  ,p_datetrack_update_mode      in   varchar2
  ,p_link_input_value_id        in   number
  ,p_element_link_id            in   number
  ,p_input_value_id             in   number
  ,p_costed_flag                in   varchar2
  ,p_default_value              in   varchar2
  ,p_max_value                  in   varchar2
  ,p_min_value                  in   varchar2
  ,p_warning_or_error           in   varchar2
  ,p_effective_start_date       in   date
  ,p_effective_end_date         in   date
  ,p_object_version_number      in   number
  ,p_pay_basis_warning          in   boolean
  ,p_default_range_warning      in   boolean
  ,p_default_formula_warning    in   boolean
  ,p_assignment_id_warning      in   boolean
  ,p_formula_message            in   varchar2
  );
--
end PAY_LINK_INPUT_VALUES_bk1;

 

/
