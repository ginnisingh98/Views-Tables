--------------------------------------------------------
--  DDL for Package BEN_CLPSE_LF_EVT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLPSE_LF_EVT_BK3" AUTHID CURRENT_USER as
/* $Header: beclpapi.pkh 120.0 2005/05/28 01:04:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_clpse_lf_evt_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_clpse_lf_evt_b
  (p_clpse_lf_evt_id             in number
  ,p_object_version_number       in number
  ,p_effective_date              in date
  ,p_datetrack_mode              in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_clpse_lf_evt_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_clpse_lf_evt_a
  (p_clpse_lf_evt_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
--
end ben_clpse_lf_evt_bk3;

 

/
