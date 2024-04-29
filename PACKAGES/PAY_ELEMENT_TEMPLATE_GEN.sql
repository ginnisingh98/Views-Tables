--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TEMPLATE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TEMPLATE_GEN" AUTHID CURRENT_USER as
/* $Header: pyetmgen.pkh 115.5 2003/02/05 17:22:24 arashid ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part1 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part1
  (p_effective_date                in     date
  ,p_hr_only                       in     boolean
  ,p_hr_to_payroll                 in     boolean default false
  ,p_template_id                   in     number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part2 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part2
  (p_effective_date                in     date
  ,p_template_id                   in     number
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< zap_core_objects >-------------------------|
-- ----------------------------------------------------------------------------
procedure zap_core_objects
  (p_all_core_objects         in     pay_element_template_util.t_core_objects
  ,p_drop_formula_packages    in     boolean
  );
--
end pay_element_template_gen;

 

/
