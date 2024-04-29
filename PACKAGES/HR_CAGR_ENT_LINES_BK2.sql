--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_LINES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_LINES_BK2" AUTHID CURRENT_USER as
/* $Header: pepclapi.pkh 120.2 2006/10/18 09:24:31 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_entitlement_line_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_entitlement_line_b
  (
   p_cagr_entitlement_line_id       in  number
  ,p_mandatory                      in  varchar2
  ,p_value                          in  varchar2
  ,p_range_from                     in  varchar2
  ,p_range_to                       in  varchar2
  ,p_grade_spine_id             in  number
  ,p_parent_spine_id                in  number
  ,p_cagr_entitlement_id            in  number
  ,p_status                         in  varchar2
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_step_id                        in  number
  ,p_from_step_id                   in  number
  ,p_to_step_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_entitlement_line_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_entitlement_line_a
  (
   p_cagr_entitlement_line_id       in  number
  ,p_mandatory                      in  varchar2
  ,p_value                          in  varchar2
  ,p_range_from                     in  varchar2
  ,p_range_to                       in  varchar2
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_grade_spine_id             in  number
  ,p_parent_spine_id                in  number
  ,p_cagr_entitlement_id            in  number
  ,p_status                         in  varchar2
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_step_id                        in  number
  ,p_from_step_id                   in  number
  ,p_to_step_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end hr_cagr_ent_lines_bk2;

/
