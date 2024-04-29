--------------------------------------------------------
--  DDL for Package BEN_RT_ASNT_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RT_ASNT_CACHE" AUTHID CURRENT_USER AS
/* $Header: bertasch.pkh 115.0 2004/02/02 11:54:27 kmahendr noship $*/
--
/*
 * +==============================================================================+
 * |                        Copyright (c) 1997 Oracle Corporation
 * |
 * |                           Redwood Shores, California, USA
 * |
 * |                               All rights reserved.
 * |
 * +==============================================================================+
 * --
 * History
 *   Version    Date       Who        What?
 *  ---------  ---------  ----------
 *--------------------------------------------
 *   115.0    30-Jan-04  kmahendr    Created.
 *---------------------------------------------
 *
 *
 * */
--
-- Global record type.
--
type g_rt_asnt_rec is record
  (id               number
  ,formula_id       number
  ,excld_flag       varchar2(30)
  );
--
type g_rt_asnt_inst_tbl is table of g_rt_asnt_rec index by binary_integer;
--
procedure get_rt_asnt_cache
  (p_vrbl_rt_prfl_id     in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set          out nocopy ben_rt_asnt_cache.g_rt_asnt_inst_tbl
  ,p_inst_count        out nocopy number
  );
--
procedure clear_down_cache;
--
end ben_rt_asnt_cache;

 

/
