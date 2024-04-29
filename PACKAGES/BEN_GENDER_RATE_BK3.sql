--------------------------------------------------------
--  DDL for Package BEN_GENDER_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GENDER_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: begnrapi.pkh 120.0 2005/05/28 03:07:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GENDER_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENDER_RATE_b
  (
   p_gndr_rt_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_GENDER_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENDER_RATE_a
  (
   p_gndr_rt_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_GENDER_RATE_bk3;

 

/
