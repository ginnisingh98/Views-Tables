--------------------------------------------------------
--  DDL for Package BEN_QUAL_TITL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QUAL_TITL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beqtrapi.pkh 120.0 2005/05/28 11:32:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_qual_titl_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_qual_titl_rt_b
  (
   p_qual_titl_rt_id   in  number
  ,p_object_version_number        in  number
  ,p_effective_date               in  date
  ,p_datetrack_mode               in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_qual_titl_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_qual_titl_rt_a
  (
   p_qual_titl_rt_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
end ben_qual_titl_rt_bk3;

 

/
