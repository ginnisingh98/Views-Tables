--------------------------------------------------------
--  DDL for Package BEN_OPT_PLTYP_IN_PGM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_PLTYP_IN_PGM_BK3" AUTHID CURRENT_USER as
/* $Header: beotpapi.pkh 120.0 2005/05/28 09:57:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_opt_pltyp_in_pgm_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_opt_pltyp_in_pgm_b
  (
   p_optip_id                       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_opt_pltyp_in_pgm_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_opt_pltyp_in_pgm_a
  (
   p_optip_id                       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_opt_pltyp_in_pgm_bk3;

 

/
