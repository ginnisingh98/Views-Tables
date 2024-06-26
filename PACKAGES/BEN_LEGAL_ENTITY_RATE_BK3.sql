--------------------------------------------------------
--  DDL for Package BEN_LEGAL_ENTITY_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LEGAL_ENTITY_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: belglapi.pkh 120.0 2005/05/28 03:23:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LEGAL_ENTITY_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LEGAL_ENTITY_RATE_b
  (
   p_lgl_enty_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LEGAL_ENTITY_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LEGAL_ENTITY_RATE_a
  (
   p_lgl_enty_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_LEGAL_ENTITY_RATE_bk3;

 

/
