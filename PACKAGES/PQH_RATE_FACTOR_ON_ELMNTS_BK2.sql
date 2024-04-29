--------------------------------------------------------
--  DDL for Package PQH_RATE_FACTOR_ON_ELMNTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_FACTOR_ON_ELMNTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqrfeapi.pkh 120.2 2005/11/30 15:00:21 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_factor_on_elmnt_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_factor_on_elmnt_b
 (
   p_effective_date               in     date
  ,p_rate_factor_on_elmnt_id      in     number
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_factor_id      in     number
  ,p_rate_factor_val_record_tbl   in     varchar2
  ,p_rate_factor_val_record_col   in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rate_factor_on_elmnt_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_factor_on_elmnt_a
  (
   p_effective_date               in     date
  ,p_rate_factor_on_elmnt_id      in     number
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_factor_id      in     number
  ,p_rate_factor_val_record_tbl   in     varchar2
  ,p_rate_factor_val_record_col   in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );


end PQH_RATE_FACTOR_ON_ELMNTS_BK2;

 

/
