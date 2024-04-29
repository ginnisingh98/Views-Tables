--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_ELEMENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_ELEMENTS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcreapi.pkh 120.4 2006/04/21 15:18:07 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_element_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_element_b
 ( p_effective_date                in     date
  ,p_criteria_rate_element_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_element_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_element_a
 ( p_effective_date                in     date
  ,p_criteria_rate_element_id      in     number
  ,p_object_version_number         in     number
  );


end PQH_CRITERIA_RATE_ELEMENTS_BK3;

 

/
