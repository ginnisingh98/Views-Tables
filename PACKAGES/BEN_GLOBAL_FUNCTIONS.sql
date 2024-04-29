--------------------------------------------------------
--  DDL for Package BEN_GLOBAL_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GLOBAL_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: beglbfnc.pkh 120.1 2006/05/02 07:08:49 rbingi noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      18-Dec-00	mhoyes     Created.
  115.3      02-May-06  rbingi     Added opt_id to get_par id procs
                                   Added proc get_vpf_par_pgm_r_pl_id
  -----------------------------------------------------------------------------
*/
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
function is_plnip_related
  (p_pl_id   in number
  ,p_oipl_id in number
  )
return varchar2;
--
function get_par_plnip_id
  (p_pl_id   in number
  ,p_oipl_id in number
  ,p_opt_id  in number default null
  )
return number;
--
function get_par_pgm_id
  (p_pgm_id         in number
  ,p_ptip_id        in number
  ,p_pl_id          in number
  ,p_plip_id        in number
  ,p_oipl_id        in number
  ,p_oiplip_id      in number
  ,p_opt_id         in number default null
  )
return number;
--
function is_monetary_abr
  (p_acty_base_rt_id in number
  )
return varchar2;
--
function get_abr_par_pgm_id
  (p_acty_base_rt_id in number
  )
return number;
--
function get_abr_par_plnip_id
  (p_acty_base_rt_id in number
  )
return number;
--
function get_ecr_abrpar_pgm_id
  (p_enrt_rt_id in number
  )
return number;
--
function round_monetary_value
  (p_rnd_code_type    in varchar2
  ,p_rounding_cd      in varchar2
  ,p_rounding_rl      in varchar2
  ,p_effective_date   in date
  ,p_monetary_value   in number
  )
return number;
--
function get_vpf_par_pgm_r_pl_id
 (p_vrbl_rt_prfl_id in number,
  p_vpf_usg_cd      in varchar2,
  p_pgm_nip_lvl     in varchar2
  )
return number;
--
END ben_global_functions;

/
