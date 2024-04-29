--------------------------------------------------------
--  DDL for Package BEN_CMBN_PLIP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_PLIP_BK3" AUTHID CURRENT_USER as
/* $Header: becplapi.pkh 120.0 2005/05/28 01:14:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CMBN_PLIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CMBN_PLIP_b
  (
   p_cmbn_plip_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CMBN_PLIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CMBN_PLIP_a
  (
   p_cmbn_plip_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_CMBN_PLIP_bk3;

 

/
