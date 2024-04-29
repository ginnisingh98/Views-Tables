--------------------------------------------------------
--  DDL for Package BEN_CVG_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CVG_CACHE" AUTHID CURRENT_USER AS
/* $Header: bencvgch.pkh 115.3 2002/12/23 12:43:37 lakrish ship $ */
--
-- Get epe plan coverage
--
type g_epeplncvg_cache_rec is record
  (cvg_amt_calc_mthd_id      ben_cvg_amt_calc_mthd_f.cvg_amt_calc_mthd_id%type
  ,comp_lvl_fctr_id          ben_cvg_amt_calc_mthd_f.comp_lvl_fctr_id%type
  ,cvg_mlt_cd                ben_cvg_amt_calc_mthd_f.cvg_mlt_cd%type
  ,bndry_perd_cd             ben_cvg_amt_calc_mthd_f.bndry_perd_cd%type
  ,bnft_typ_cd               ben_cvg_amt_calc_mthd_f.bnft_typ_cd%type
  ,val                       ben_cvg_amt_calc_mthd_f.val%type
  ,nnmntry_uom               ben_cvg_amt_calc_mthd_f.nnmntry_uom%type
  ,mx_val                    ben_cvg_amt_calc_mthd_f.mx_val%type
  ,mn_val                    ben_cvg_amt_calc_mthd_f.mn_val%type
  ,incrmt_val                ben_cvg_amt_calc_mthd_f.incrmt_val%type
  ,rt_typ_cd                 ben_cvg_amt_calc_mthd_f.rt_typ_cd%type
  ,business_group_id         ben_cvg_amt_calc_mthd_f.business_group_id%type
  ,rndg_cd                   ben_cvg_amt_calc_mthd_f.rndg_cd%type
  ,rndg_rl                   ben_cvg_amt_calc_mthd_f.rndg_rl%type
  ,val_calc_rl               ben_cvg_amt_calc_mthd_f.val_calc_rl%type
  ,dflt_val                  ben_cvg_amt_calc_mthd_f.dflt_val%type
  ,entr_val_at_enrt_flag     ben_cvg_amt_calc_mthd_f.entr_val_at_enrt_flag%type
  ,lwr_lmt_val               ben_cvg_amt_calc_mthd_f.lwr_lmt_val%type
  ,lwr_lmt_calc_rl           ben_cvg_amt_calc_mthd_f.lwr_lmt_calc_rl%type
  ,upr_lmt_val               ben_cvg_amt_calc_mthd_f.upr_lmt_val%type
  ,upr_lmt_calc_rl           ben_cvg_amt_calc_mthd_f.upr_lmt_calc_rl%type
  ,cvg_incr_r_decr_only_cd   ben_pl_f.cvg_incr_r_decr_only_cd%type
  ,bnft_or_option_rstrctn_cd ben_pl_f.bnft_or_option_rstrctn_cd%type
  ,mx_cvg_rl                 ben_pl_f.mx_cvg_rl%type
  ,mn_cvg_rl                 ben_pl_f.mn_cvg_rl%type
  );
--
type g_epeplncvg_cache is table of g_epeplncvg_cache_rec index by binary_integer;
--
procedure epeplncvg_getdets
  (p_epe_id                in     number
  ,p_epe_pl_id             in     number
  ,p_epe_plip_id           in     number
  ,p_epe_oipl_id           in     number
  ,p_effective_date        in     date
  ,p_cvgtype_code          in     varchar2
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  );
--
procedure plnplncvg_getdets
  (p_pln_id                in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  );
--
procedure cppplncvg_getdets
  (p_plip_id               in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  );
--
procedure copplncvg_getdets
  (p_oipl_id               in     number
  ,p_effective_date        in     date
  --
  ,p_inst_set                 out nocopy ben_cvg_cache.g_epeplncvg_cache
  ,p_inst_count               out nocopy number
  );
--
-- Get the coverage details for the EPE walking down the comp
-- object tree
--
procedure epecobjtree_getcvgdets
  (p_epe_id         in     number
  ,p_epe_pl_id      in     number
  ,p_epe_plip_id    in     number
  ,p_epe_oipl_id    in     number
  ,p_effective_date in     date
  --
  ,p_cvg_set           out nocopy ben_cvg_cache.g_epeplncvg_cache
  );
--
END ben_cvg_cache;

 

/
