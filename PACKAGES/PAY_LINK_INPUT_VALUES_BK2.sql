--------------------------------------------------------
--  DDL for Package PAY_LINK_INPUT_VALUES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LINK_INPUT_VALUES_BK2" AUTHID CURRENT_USER as
/* $Header: pylivapi.pkh 120.1 2005/10/02 02:32:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_link_input_values_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_link_input_values_b
  (p_effective_date             in      date
  ,p_datetrack_delete_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_object_version_number      in      number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_link_input_values_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_link_input_values_a
  (p_effective_date             in      date
  ,p_datetrack_delete_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_effective_start_date       in      date
  ,p_effective_end_date         in      date
  ,p_object_version_number      in      number
  );
--
end PAY_LINK_INPUT_VALUES_bk2;

 

/
