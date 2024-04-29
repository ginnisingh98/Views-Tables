--------------------------------------------------------
--  DDL for Package HR_COMP_ELEMENT_OUTCOME_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMP_ELEMENT_OUTCOME_BK3" AUTHID CURRENT_USER as
/* $Header: peceoapi.pkh 120.1 2005/10/02 02:13 aroussel $ */
-- ----------------------------------------------------------------------------
-- |------------------< delete_element_outcome_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_outcome_b
  (p_comp_element_outcome_id       in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------< delete_element_outcome_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_outcome_a
  (p_comp_element_outcome_id       in     number
  ,p_object_version_number         in     number
  );
end hr_comp_element_outcome_bk3;

 

/
