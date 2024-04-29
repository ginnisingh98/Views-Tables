--------------------------------------------------------
--  DDL for Package BEN_POPL_RPTG_GRP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_POPL_RPTG_GRP_BK3" AUTHID CURRENT_USER as
/* $Header: bergrapi.pkh 120.0 2005/05/28 11:39:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_RPTG_GRP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_RPTG_GRP_b
  (
   p_popl_rptg_grp_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_POPL_RPTG_GRP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_RPTG_GRP_a
  (
   p_popl_rptg_grp_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_POPL_RPTG_GRP_bk3;

 

/
