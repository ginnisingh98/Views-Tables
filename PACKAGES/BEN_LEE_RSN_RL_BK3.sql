--------------------------------------------------------
--  DDL for Package BEN_LEE_RSN_RL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LEE_RSN_RL_BK3" AUTHID CURRENT_USER as
/* $Header: belrrapi.pkh 120.0 2005/05/28 03:36:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Lee_Rsn_Rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Lee_Rsn_Rl_b
  (
   p_lee_rsn_rl_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Lee_Rsn_Rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Lee_Rsn_Rl_a
  (
   p_lee_rsn_rl_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Lee_Rsn_Rl_bk3;

 

/
