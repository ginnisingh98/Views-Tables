--------------------------------------------------------
--  DDL for Package BEN_CEP_CACHE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CEP_CACHE1" AUTHID CURRENT_USER AS
/* $Header: bencepc1.pkh 120.0 2005/06/24 07:35:13 appldev noship $ */
--
procedure write_cobcep_odcache
  (p_effective_date  in     date
  ,p_pgm_id          in     number default hr_api.g_number
  ,p_pl_id           in     number default hr_api.g_number
  ,p_oipl_id         in     number default hr_api.g_number
  ,p_plip_id         in     number default hr_api.g_number
  ,p_ptip_id         in     number default hr_api.g_number
  -- Grade/Step
  ,p_vrbl_rt_prfl_id in     number default hr_api.g_number
  -- Grade/Step
  --
  ,p_hv                 out nocopy  pls_integer
  );
--
END ben_cep_cache1;

 

/
