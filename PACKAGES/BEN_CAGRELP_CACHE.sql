--------------------------------------------------------
--  DDL for Package BEN_CAGRELP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CAGRELP_CACHE" AUTHID CURRENT_USER AS
/* $Header: benelpc1.pkh 120.0 2005/05/28 08:57:21 appldev noship $ */
--
type g_elp_cache_rec is record
  (eligy_prfl_id   number
  ,pk_id           number
  ,short_code      varchar2(30)
  ,v230_val        varchar2(30)
  ,num_val         number
  ,num_val1        number
  ,excld_flag      varchar2(100)
  ,criteria_score  number
  ,criteria_weight number
  );
--
type g_elp_cache is varray(1000000) of g_elp_cache_rec;
--
procedure elpegn_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpemp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpect_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpedr_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpedd_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpest_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpeqt_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpeps_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpepn_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure elpesp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  );
--
procedure clear_down_cache;
--
END ben_cagrelp_cache;

 

/
