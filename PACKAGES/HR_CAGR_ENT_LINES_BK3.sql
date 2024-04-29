--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_LINES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_LINES_BK3" AUTHID CURRENT_USER as
/* $Header: pepclapi.pkh 120.2 2006/10/18 09:24:31 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_entitlement_line_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_entitlement_line_b
  (
   p_cagr_entitlement_line_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_entitlement_line_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_entitlement_line_a
  (
   p_cagr_entitlement_line_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end hr_cagr_ent_lines_bk3;

/
