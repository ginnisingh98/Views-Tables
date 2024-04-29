--------------------------------------------------------
--  DDL for Package PQH_RMR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RMR_RKI" AUTHID CURRENT_USER as
/* $Header: pqrmrrhi.pkh 120.0 2005/05/29 02:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_rate_matrix_rate_id          in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_rate_matrix_node_id          in number
  ,p_criteria_rate_defn_id        in number
  ,p_min_rate_value               in number
  ,p_max_rate_value               in number
  ,p_mid_rate_value               in number
  ,p_rate_value                   in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pqh_rmr_rki;

 

/
