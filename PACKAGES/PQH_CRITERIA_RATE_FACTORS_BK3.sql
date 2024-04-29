--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_FACTORS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_FACTORS_BK3" AUTHID CURRENT_USER as
/* $Header: pqcrfapi.pkh 120.4 2006/04/21 15:17:33 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_factor_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_factor_b
 ( p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_criteria_rate_factor_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_factor_a
 ( p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_object_version_number         in     number
  );


end PQH_CRITERIA_RATE_FACTORS_BK3;

 

/
