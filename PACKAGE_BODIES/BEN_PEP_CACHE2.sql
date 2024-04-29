--------------------------------------------------------
--  DDL for Package Body BEN_PEP_CACHE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEP_CACHE2" as
/* $Header: benpepc2.pkb 120.0.12000000.5 2007/07/02 21:19:36 mkommuri noship $ */
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	      Author	   Comments
  ---------  ---------	---------- --------------------------------------------
  115.0      30-May-05	mhoyes     Created.
  115.1      23-May-07	gsehgal    bug 5947031 All pil records are not being
	                                 fetched in get_peppil_list
  115.2      02-Jul-07  mkommuri   this version could be ignored
  115.3      26-Jun-07  mkommuri   bug6138732 updated cursor is at
                                   ben_pep_cache2.write_pilepo_cache cursor
                                   c_pilinstance
  115.4      02-Jul-07  mkommuri   same as 115.3. updated this hisotry
  -----------------------------------------------------------------------------
*/
--
-- Globals.
--
g_package varchar2(50) := 'ben_pep_cache2.';
--
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
procedure get_peppil_list
  (p_person_id      in     number
  ,p_effective_date in     date
  --
  ,p_peppil_va      in out nocopy benutils.g_number_table
  )
is
  --
  l_proc varchar2(72) := 'get_pep_list';
  --
  l_allpilid_va    benutils.g_number_table := benutils.g_number_table();
  l_outpilid_va    benutils.g_number_table := benutils.g_number_table();
  --
  l_outpil_en      pls_integer;
  l_peppil_id      number;
  --
  cursor c_perpillist
    (c_person_id number
    )
  is
    select pil.per_in_ler_id
    from ben_per_in_ler pil
    where pil.person_id = c_person_id
    and   pil.per_in_ler_stat_cd not in ('VOIDD', 'BCKDT')
    order by pil.per_in_ler_id desc;
  --
  cursor c_pilpepexists
    (c_pil_id   number
    ,c_eff_date date
    )
  is
    select pep.per_in_ler_id
    from ben_elig_per_f pep
    where pep.per_in_ler_id = c_pil_id
    and c_eff_date
      between pep.effective_start_date and pep.effective_end_date
    and rownum=1;

  cursor c_pilepoexists
    (c_pil_id   number
    ,c_eff_date date
    )
  is
    select epo.per_in_ler_id
    from ben_elig_per_opt_f epo
    where epo.per_in_ler_id = c_pil_id
    and c_eff_date
      between epo.effective_start_date and epo.effective_end_date
    and rownum=1;
  --
begin
  --
  open c_perpillist
    (c_person_id => p_person_id
    );
  fetch c_perpillist BULK COLLECT INTO l_allpilid_va;
  close c_perpillist;
  --
  if l_allpilid_va.count > 0
  then
    --
    l_outpil_en := 1;
    --
    for pilvaen in l_allpilid_va.first..l_allpilid_va.last
    loop
      --
      open c_pilpepexists
        (c_pil_id   => l_allpilid_va(pilvaen)
        ,c_eff_date => p_effective_date
        );
      fetch c_pilpepexists into l_peppil_id;
      if c_pilpepexists%found
      then
        --
        l_outpilid_va.extend(1);
        l_outpilid_va(l_outpil_en) := l_peppil_id;
        l_outpil_en := l_outpil_en+1;
        --
      -- bug 5947031
			else
         OPEN c_pilepoexists (c_pil_id        => l_allpilid_va (pilvaen),
                              c_eff_date      => p_effective_date
                             );

         FETCH c_pilepoexists
          INTO l_peppil_id;

         IF c_pilepoexists%FOUND
         THEN
            --
            l_outpilid_va.EXTEND (1);
            l_outpilid_va (l_outpil_en) := l_peppil_id;
            l_outpil_en := l_outpil_en + 1;

         END IF;

         CLOSE c_pilepoexists;
				 -- END bug 5947031
      end if;
      close c_pilpepexists;
      --
    end loop;
    --
  end if;
  --
  p_peppil_va := l_outpilid_va;
  --
end get_peppil_list;
--
procedure write_pilpep_cache
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_pilpep_cache';
  --
  l_perpilid_va                     benutils.g_number_table := benutils.g_number_table();
  --
  l_los_val_va                      benutils.g_number_table := benutils.g_number_table();
  l_age_val_va                      benutils.g_number_table := benutils.g_number_table();
  l_comp_ref_amt_va                 benutils.g_number_table := benutils.g_number_table();
  l_hrs_wkd_val_va                  benutils.g_number_table := benutils.g_number_table();
  l_pct_fl_tm_val_va                benutils.g_number_table := benutils.g_number_table();
  l_cmbn_age_n_los_val_va           benutils.g_number_table := benutils.g_number_table();
  l_age_uom_va                      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_los_uom_va                      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_comp_ref_uom_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_hrs_wkd_bndry_perd_cd_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_los_flag_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_age_flag_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_hrs_wkd_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_cmp_lvl_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_pct_fl_tm_flag_va           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_comb_age_and_los_flag_va    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_los_val_va                   benutils.g_number_table := benutils.g_number_table();
  l_rt_age_val_va                   benutils.g_number_table := benutils.g_number_table();
  l_rt_comp_ref_amt_va              benutils.g_number_table := benutils.g_number_table();
  l_rt_hrs_wkd_val_va               benutils.g_number_table := benutils.g_number_table();
  l_rt_pct_fl_tm_val_va             benutils.g_number_table := benutils.g_number_table();
  l_rt_cmbn_age_n_los_val_va        benutils.g_number_table := benutils.g_number_table();
  l_rt_age_uom_va                   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_los_uom_va                   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_comp_ref_uom_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_hrs_wkd_bndry_perd_cd_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_los_flag_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_age_flag_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_hrs_wkd_flag_va          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_cmp_lvl_flag_va          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_pct_fl_tm_flag_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_cmb_age_los_flg_va       benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_ovrid_svc_dt_va                 benutils.g_date_table := benutils.g_date_table();
  l_prtn_ovridn_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_prtn_ovridn_thru_dt_va          benutils.g_date_table := benutils.g_date_table();
  l_once_r_cntug_cd_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_elig_flag_va                    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_pgm_id_va                       benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va                      benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va                        benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va                      benutils.g_number_table := benutils.g_number_table();
  l_prtn_strt_dt_va                 benutils.g_date_table := benutils.g_date_table();
  l_prtn_end_dt_va                  benutils.g_date_table := benutils.g_date_table();
  l_object_version_number_va        benutils.g_number_table := benutils.g_number_table();
  l_elig_per_id_va                  benutils.g_number_table := benutils.g_number_table();
  l_per_in_ler_id_va                benutils.g_number_table := benutils.g_number_table();
  --
  l_hv                              pls_integer;
  l_not_hash_found                  boolean;
  --
  l_pil_cnt                         pls_integer;
  --
  cursor c_pilinstance
    (c_effective_date DATE
    ,c_pil_id         NUMBER
    )
  is
    SELECT tab1.los_val,
           tab1.age_val,
           tab1.comp_ref_amt,
           tab1.hrs_wkd_val,
           tab1.pct_fl_tm_val,
           tab1.cmbn_age_n_los_val,
           tab1.age_uom,
           tab1.los_uom,
           tab1.comp_ref_uom,
           tab1.hrs_wkd_bndry_perd_cd,
           tab1.frz_los_flag,
           tab1.frz_age_flag,
           tab1.frz_hrs_wkd_flag,
           tab1.frz_cmp_lvl_flag,
           tab1.frz_pct_fl_tm_flag,
           tab1.frz_comb_age_and_los_flag,
           tab1.rt_los_val,
           tab1.rt_age_val,
           tab1.rt_comp_ref_amt,
           tab1.rt_hrs_wkd_val,
           tab1.rt_pct_fl_tm_val,
           tab1.rt_cmbn_age_n_los_val,
           tab1.rt_age_uom,
           tab1.rt_los_uom,
           tab1.rt_comp_ref_uom,
           tab1.rt_hrs_wkd_bndry_perd_cd,
           tab1.rt_frz_los_flag,
           tab1.rt_frz_age_flag,
           tab1.rt_frz_hrs_wkd_flag,
           tab1.rt_frz_cmp_lvl_flag,
           tab1.rt_frz_pct_fl_tm_flag,
           tab1.rt_frz_comb_age_and_los_flag,
           tab1.ovrid_svc_dt,
           tab1.prtn_ovridn_flag,
           tab1.prtn_ovridn_thru_dt,
           tab1.once_r_cntug_cd,
           tab1.elig_flag,
           tab1.pgm_id,
           tab1.ptip_id,
           tab1.pl_id,
           tab1.plip_id,
           tab1.prtn_strt_dt,
           tab1.prtn_end_dt,
           tab1.object_version_number,
           tab1.elig_per_id,
           tab1.per_in_ler_id
    from ben_elig_per_f tab1
    where tab1.per_in_ler_id = c_pil_id
    and   c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    order by  tab1.pgm_id, tab1.pl_id, tab1.plip_id;
  --
  cursor c_nopilinstance
    (c_effective_date DATE
    ,c_person_id      NUMBER
    )
  is
    SELECT tab1.los_val,
           tab1.age_val,
           tab1.comp_ref_amt,
           tab1.hrs_wkd_val,
           tab1.pct_fl_tm_val,
           tab1.cmbn_age_n_los_val,
           tab1.age_uom,
           tab1.los_uom,
           tab1.comp_ref_uom,
           tab1.hrs_wkd_bndry_perd_cd,
           tab1.frz_los_flag,
           tab1.frz_age_flag,
           tab1.frz_hrs_wkd_flag,
           tab1.frz_cmp_lvl_flag,
           tab1.frz_pct_fl_tm_flag,
           tab1.frz_comb_age_and_los_flag,
           tab1.rt_los_val,
           tab1.rt_age_val,
           tab1.rt_comp_ref_amt,
           tab1.rt_hrs_wkd_val,
           tab1.rt_pct_fl_tm_val,
           tab1.rt_cmbn_age_n_los_val,
           tab1.rt_age_uom,
           tab1.rt_los_uom,
           tab1.rt_comp_ref_uom,
           tab1.rt_hrs_wkd_bndry_perd_cd,
           tab1.rt_frz_los_flag,
           tab1.rt_frz_age_flag,
           tab1.rt_frz_hrs_wkd_flag,
           tab1.rt_frz_cmp_lvl_flag,
           tab1.rt_frz_pct_fl_tm_flag,
           tab1.rt_frz_comb_age_and_los_flag,
           tab1.ovrid_svc_dt,
           tab1.prtn_ovridn_flag,
           tab1.prtn_ovridn_thru_dt,
           tab1.once_r_cntug_cd,
           tab1.elig_flag,
           tab1.pgm_id,
           tab1.ptip_id,
           tab1.pl_id,
           tab1.plip_id,
           tab1.prtn_strt_dt,
           tab1.prtn_end_dt,
           tab1.object_version_number,
           tab1.elig_per_id,
           tab1.per_in_ler_id
    from ben_elig_per_f tab1
    where tab1.per_in_ler_id is null
    and   tab1.person_id = c_person_id
    and   c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    order by  tab1.pgm_id, tab1.pl_id, tab1.plip_id;
  --
begin
  --
  get_peppil_list
    (p_person_id      => p_person_id
    ,p_effective_date => p_effective_date
    --
    ,p_peppil_va      => l_perpilid_va
    );
  --
  l_pil_cnt := 0;
  --
  if l_perpilid_va.count > 0
  then
    --
    for pilvaen in l_perpilid_va.first..l_perpilid_va.last
    loop
      --
      open c_pilinstance
        (c_effective_date => p_effective_date
        ,c_pil_id         => l_perpilid_va(pilvaen)
        );
      fetch c_pilinstance BULK COLLECT INTO l_los_val_va,
                                            l_age_val_va,
                                            l_comp_ref_amt_va,
                                            l_hrs_wkd_val_va,
                                            l_pct_fl_tm_val_va,
                                            l_cmbn_age_n_los_val_va,
                                            l_age_uom_va,
                                            l_los_uom_va,
                                            l_comp_ref_uom_va,
                                            l_hrs_wkd_bndry_perd_cd_va,
                                            l_frz_los_flag_va,
                                            l_frz_age_flag_va,
                                            l_frz_hrs_wkd_flag_va,
                                            l_frz_cmp_lvl_flag_va,
                                            l_frz_pct_fl_tm_flag_va,
                                            l_frz_comb_age_and_los_flag_va,
                                            l_rt_los_val_va,
                                            l_rt_age_val_va,
                                            l_rt_comp_ref_amt_va,
                                            l_rt_hrs_wkd_val_va,
                                            l_rt_pct_fl_tm_val_va,
                                            l_rt_cmbn_age_n_los_val_va,
                                            l_rt_age_uom_va,
                                            l_rt_los_uom_va,
                                            l_rt_comp_ref_uom_va,
                                            l_rt_hrs_wkd_bndry_perd_cd_va,
                                            l_rt_frz_los_flag_va,
                                            l_rt_frz_age_flag_va,
                                            l_rt_frz_hrs_wkd_flag_va,
                                            l_rt_frz_cmp_lvl_flag_va,
                                            l_rt_frz_pct_fl_tm_flag_va,
                                            l_rt_frz_cmb_age_los_flg_va,
                                            l_ovrid_svc_dt_va,
                                            l_prtn_ovridn_flag_va,
                                            l_prtn_ovridn_thru_dt_va,
                                            l_once_r_cntug_cd_va,
                                            l_elig_flag_va,
                                            l_pgm_id_va,
                                            l_ptip_id_va,
                                            l_pl_id_va,
                                            l_plip_id_va,
                                            l_prtn_strt_dt_va,
                                            l_prtn_end_dt_va,
                                            l_object_version_number_va,
                                            l_elig_per_id_va,
                                            l_per_in_ler_id_va;
      close c_pilinstance;
      --
      if l_pgm_id_va.count > 0
      then
        --
        for vaen in l_pgm_id_va.first..l_pgm_id_va.last
        loop
          --
          l_hv := mod(nvl(l_pgm_id_va(vaen),1)
                     +nvl(l_pl_id_va(vaen),2)
                     +nvl(l_plip_id_va(vaen),3)
                  +nvl(l_ptip_id_va(vaen),4) ,ben_hash_utility.get_hash_key);
          --
          while ben_pep_cache.g_pilpep_instance.exists(l_hv)
          loop
            --
            l_hv := l_hv+g_hash_jump;
            --
          end loop;
          --
          ben_pep_cache.g_pilpep_instance(l_hv).pgm_id                := l_pgm_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).pl_id                 := l_pl_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).plip_id               := l_plip_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).ptip_id               := l_ptip_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).prtn_strt_dt          := l_prtn_strt_dt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).los_val               := l_los_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).age_val               := l_age_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).comp_ref_amt          := l_comp_ref_amt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).hrs_wkd_val           := l_hrs_wkd_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).pct_fl_tm_val         := l_pct_fl_tm_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).cmbn_age_n_los_val    := l_cmbn_age_n_los_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).age_uom               := l_age_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).los_uom               := l_los_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).comp_ref_uom          := l_comp_ref_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).hrs_wkd_bndry_perd_cd := l_hrs_wkd_bndry_perd_cd_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_los_flag          := l_frz_los_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_age_flag          := l_frz_age_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_hrs_wkd_flag      := l_frz_hrs_wkd_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_cmp_lvl_flag      := l_frz_cmp_lvl_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_pct_fl_tm_flag    := l_frz_pct_fl_tm_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).frz_comb_age_and_los_flag := l_frz_comb_age_and_los_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_los_val            := l_rt_los_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_age_val            := l_rt_age_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_comp_ref_amt       := l_rt_comp_ref_amt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_hrs_wkd_val        := l_rt_hrs_wkd_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_pct_fl_tm_val      := l_rt_pct_fl_tm_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_cmbn_age_n_los_val := l_rt_cmbn_age_n_los_val_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_age_uom            := l_rt_age_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_los_uom            := l_rt_los_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_comp_ref_uom       := l_rt_comp_ref_uom_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_hrs_wkd_bndry_perd_cd := l_rt_hrs_wkd_bndry_perd_cd_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_los_flag       := l_rt_frz_los_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_age_flag       := l_rt_frz_age_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_hrs_wkd_flag   := l_rt_frz_hrs_wkd_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_cmp_lvl_flag   := l_rt_frz_cmp_lvl_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_pct_fl_tm_flag := l_rt_frz_pct_fl_tm_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_comb_age_and_los_flag := l_rt_frz_cmb_age_los_flg_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).ovrid_svc_dt          := l_ovrid_svc_dt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).prtn_ovridn_flag      := l_prtn_ovridn_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).prtn_ovridn_thru_dt   := l_prtn_ovridn_thru_dt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).once_r_cntug_cd       := l_once_r_cntug_cd_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).elig_flag             := l_elig_flag_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).elig_per_id           := l_elig_per_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).prtn_end_dt           := l_prtn_end_dt_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).per_in_ler_id         := l_per_in_ler_id_va(vaen);
          ben_pep_cache.g_pilpep_instance(l_hv).object_version_number := l_object_version_number_va(vaen);
          --
        end loop;
        --
      end if;
      --
      l_pil_cnt := l_pil_cnt+1;
      --
    end loop;
    --
  end if;
  --
  -- When no per in lers exist that are not backed out and voided then
  -- look for eligibility with a null per in ler.
  --
  if l_pil_cnt = 0
  then
    --
    open c_nopilinstance
      (c_effective_date => p_effective_date
      ,c_person_id      => p_person_id
      );
    fetch c_nopilinstance BULK COLLECT INTO l_los_val_va,
                                            l_age_val_va,
                                            l_comp_ref_amt_va,
                                            l_hrs_wkd_val_va,
                                            l_pct_fl_tm_val_va,
                                            l_cmbn_age_n_los_val_va,
                                            l_age_uom_va,
                                            l_los_uom_va,
                                            l_comp_ref_uom_va,
                                            l_hrs_wkd_bndry_perd_cd_va,
                                            l_frz_los_flag_va,
                                            l_frz_age_flag_va,
                                            l_frz_hrs_wkd_flag_va,
                                            l_frz_cmp_lvl_flag_va,
                                            l_frz_pct_fl_tm_flag_va,
                                            l_frz_comb_age_and_los_flag_va,
                                            l_rt_los_val_va,
                                            l_rt_age_val_va,
                                            l_rt_comp_ref_amt_va,
                                            l_rt_hrs_wkd_val_va,
                                            l_rt_pct_fl_tm_val_va,
                                            l_rt_cmbn_age_n_los_val_va,
                                            l_rt_age_uom_va,
                                            l_rt_los_uom_va,
                                            l_rt_comp_ref_uom_va,
                                            l_rt_hrs_wkd_bndry_perd_cd_va,
                                            l_rt_frz_los_flag_va,
                                            l_rt_frz_age_flag_va,
                                            l_rt_frz_hrs_wkd_flag_va,
                                            l_rt_frz_cmp_lvl_flag_va,
                                            l_rt_frz_pct_fl_tm_flag_va,
                                            l_rt_frz_cmb_age_los_flg_va,
                                            l_ovrid_svc_dt_va,
                                            l_prtn_ovridn_flag_va,
                                            l_prtn_ovridn_thru_dt_va,
                                            l_once_r_cntug_cd_va,
                                            l_elig_flag_va,
                                            l_pgm_id_va,
                                            l_ptip_id_va,
                                            l_pl_id_va,
                                            l_plip_id_va,
                                            l_prtn_strt_dt_va,
                                            l_prtn_end_dt_va,
                                            l_object_version_number_va,
                                            l_elig_per_id_va,
                                            l_per_in_ler_id_va;
    close c_nopilinstance;
    --
    if l_pgm_id_va.count > 0
    then
      --
      for vaen in l_pgm_id_va.first..l_pgm_id_va.last
      loop
        --
        l_hv := mod(nvl(l_pgm_id_va(vaen),1)
                   +nvl(l_pl_id_va(vaen),2)
                   +nvl(l_plip_id_va(vaen),3)
                +nvl(l_ptip_id_va(vaen),4) ,ben_hash_utility.get_hash_key);
        --
        while ben_pep_cache.g_pilpep_instance.exists(l_hv)
        loop
          --
          l_hv := l_hv+g_hash_jump;
          --
        end loop;
        --
        ben_pep_cache.g_pilpep_instance(l_hv).pgm_id                := l_pgm_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).pl_id                 := l_pl_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).plip_id               := l_plip_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).ptip_id               := l_ptip_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).prtn_strt_dt          := l_prtn_strt_dt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).los_val               := l_los_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).age_val               := l_age_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).comp_ref_amt          := l_comp_ref_amt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).hrs_wkd_val           := l_hrs_wkd_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).pct_fl_tm_val         := l_pct_fl_tm_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).cmbn_age_n_los_val    := l_cmbn_age_n_los_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).age_uom               := l_age_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).los_uom               := l_los_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).comp_ref_uom          := l_comp_ref_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).hrs_wkd_bndry_perd_cd := l_hrs_wkd_bndry_perd_cd_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_los_flag          := l_frz_los_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_age_flag          := l_frz_age_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_hrs_wkd_flag      := l_frz_hrs_wkd_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_cmp_lvl_flag      := l_frz_cmp_lvl_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_pct_fl_tm_flag    := l_frz_pct_fl_tm_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).frz_comb_age_and_los_flag := l_frz_comb_age_and_los_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_los_val            := l_rt_los_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_age_val            := l_rt_age_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_comp_ref_amt       := l_rt_comp_ref_amt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_hrs_wkd_val        := l_rt_hrs_wkd_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_pct_fl_tm_val      := l_rt_pct_fl_tm_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_cmbn_age_n_los_val := l_rt_cmbn_age_n_los_val_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_age_uom            := l_rt_age_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_los_uom            := l_rt_los_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_comp_ref_uom       := l_rt_comp_ref_uom_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_hrs_wkd_bndry_perd_cd := l_rt_hrs_wkd_bndry_perd_cd_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_los_flag       := l_rt_frz_los_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_age_flag       := l_rt_frz_age_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_hrs_wkd_flag   := l_rt_frz_hrs_wkd_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_cmp_lvl_flag   := l_rt_frz_cmp_lvl_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_pct_fl_tm_flag := l_rt_frz_pct_fl_tm_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).rt_frz_comb_age_and_los_flag := l_rt_frz_cmb_age_los_flg_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).ovrid_svc_dt          := l_ovrid_svc_dt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).prtn_ovridn_flag      := l_prtn_ovridn_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).prtn_ovridn_thru_dt   := l_prtn_ovridn_thru_dt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).once_r_cntug_cd       := l_once_r_cntug_cd_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).elig_flag             := l_elig_flag_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).elig_per_id           := l_elig_per_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).prtn_end_dt           := l_prtn_end_dt_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).per_in_ler_id         := l_per_in_ler_id_va(vaen);
        ben_pep_cache.g_pilpep_instance(l_hv).object_version_number := l_object_version_number_va(vaen);
        --
      end loop;
      --
    end if;
    --
  end if;
  --
end write_pilpep_cache;
--
procedure write_pilepo_cache
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) :=  'write_pilepo_cache';
  --
  l_allpilid_va                     benutils.g_number_table := benutils.g_number_table();
  l_perpilid_va                     benutils.g_number_table := benutils.g_number_table();
  --
  l_los_val_va                      benutils.g_number_table := benutils.g_number_table();
  l_age_val_va                      benutils.g_number_table := benutils.g_number_table();
  l_comp_ref_amt_va                 benutils.g_number_table := benutils.g_number_table();
  l_hrs_wkd_val_va                  benutils.g_number_table := benutils.g_number_table();
  l_pct_fl_tm_val_va                benutils.g_number_table := benutils.g_number_table();
  l_cmbn_age_n_los_val_va           benutils.g_number_table := benutils.g_number_table();
  l_age_uom_va                      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_los_uom_va                      benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_comp_ref_uom_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_hrs_wkd_bndry_perd_cd_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_los_flag_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_age_flag_va                 benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_hrs_wkd_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_cmp_lvl_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_pct_fl_tm_flag_va           benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_frz_comb_age_and_los_flag_va    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_los_val_va                   benutils.g_number_table := benutils.g_number_table();
  l_rt_age_val_va                   benutils.g_number_table := benutils.g_number_table();
  l_rt_comp_ref_amt_va              benutils.g_number_table := benutils.g_number_table();
  l_rt_hrs_wkd_val_va               benutils.g_number_table := benutils.g_number_table();
  l_rt_pct_fl_tm_val_va             benutils.g_number_table := benutils.g_number_table();
  l_rt_cmbn_age_n_los_val_va        benutils.g_number_table := benutils.g_number_table();
  l_rt_age_uom_va                   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_los_uom_va                   benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_comp_ref_uom_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_hrs_wkd_bndry_perd_cd_va     benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_los_flag_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_age_flag_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_hrs_wkd_flag_va          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_cmp_lvl_flag_va          benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_pct_fl_tm_flag_va        benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_rt_frz_cmb_age_los_flg_va benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_ovrid_svc_dt_va                 benutils.g_date_table := benutils.g_date_table();
  l_prtn_ovridn_flag_va             benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_prtn_ovridn_thru_dt_va          benutils.g_date_table := benutils.g_date_table();
  l_once_r_cntug_cd_va              benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_elig_flag_va                    benutils.g_varchar2_table := benutils.g_varchar2_table();
  l_pgm_id_va                       benutils.g_number_table := benutils.g_number_table();
  l_ptip_id_va                      benutils.g_number_table := benutils.g_number_table();
  l_pl_id_va                        benutils.g_number_table := benutils.g_number_table();
  l_plip_id_va                      benutils.g_number_table := benutils.g_number_table();
  l_opt_id_va                       benutils.g_number_table := benutils.g_number_table();
  l_prtn_strt_dt_va                 benutils.g_date_table := benutils.g_date_table();
  l_prtn_end_dt_va                  benutils.g_date_table := benutils.g_date_table();
  l_elig_per_opt_id_va              benutils.g_number_table := benutils.g_number_table();
  l_object_version_number_va        benutils.g_number_table := benutils.g_number_table();
  l_elig_per_id_va                  benutils.g_number_table := benutils.g_number_table();
  l_per_in_ler_id_va                benutils.g_number_table := benutils.g_number_table();
  l_pep_psd_va                      benutils.g_date_table := benutils.g_date_table();
  l_pep_ped_va                      benutils.g_date_table := benutils.g_date_table();
  l_pil_stcd_va                     benutils.g_varchar2_table := benutils.g_varchar2_table();
  --
  l_hv                              pls_integer;
  l_not_hash_found                  boolean;
  l_exclude                         boolean;
  --
  l_pil_cnt                         pls_integer;
  --
  cursor c_pilinstance
    (c_effective_date DATE
    ,c_pil_id         NUMBER
    )
  is
      SELECT   tab1.los_val
              ,tab1.age_val
              ,tab1.comp_ref_amt
              ,tab1.hrs_wkd_val
              ,tab1.pct_fl_tm_val
              ,tab1.cmbn_age_n_los_val
              ,tab1.age_uom
              ,tab1.los_uom
              ,tab1.comp_ref_uom
              ,tab1.hrs_wkd_bndry_perd_cd
              ,tab1.frz_los_flag
              ,tab1.frz_age_flag
              ,tab1.frz_hrs_wkd_flag
              ,tab1.frz_cmp_lvl_flag
              ,tab1.frz_pct_fl_tm_flag
              ,tab1.frz_comb_age_and_los_flag
              ,tab1.rt_los_val
              ,tab1.rt_age_val
              ,tab1.rt_comp_ref_amt
              ,tab1.rt_hrs_wkd_val
              ,tab1.rt_pct_fl_tm_val
              ,tab1.rt_cmbn_age_n_los_val
              ,tab1.rt_age_uom
              ,tab1.rt_los_uom
              ,tab1.rt_comp_ref_uom
              ,tab1.rt_hrs_wkd_bndry_perd_cd
              ,tab1.rt_frz_los_flag
              ,tab1.rt_frz_age_flag
              ,tab1.rt_frz_hrs_wkd_flag
              ,tab1.rt_frz_cmp_lvl_flag
              ,tab1.rt_frz_pct_fl_tm_flag
              ,tab1.rt_frz_comb_age_and_los_flag
              ,tab1.ovrid_svc_dt
              ,tab1.prtn_ovridn_flag
              ,tab1.prtn_ovridn_thru_dt
              ,tab1.once_r_cntug_cd
              ,tab1.elig_flag
              ,tab2.pgm_id
              ,tab2.ptip_id
              ,tab2.pl_id
              ,tab2.plip_id
              ,tab1.opt_id
              ,tab1.prtn_strt_dt
              ,tab1.prtn_end_dt
              ,tab1.elig_per_opt_id
              ,tab1.object_version_number
              ,tab2.elig_per_id
              ,tab2.per_in_ler_id
              ,tab2.prtn_strt_dt pep_psd
              ,tab2.prtn_end_dt pep_ped
              ,tab3.per_in_ler_stat_cd
    from ben_elig_per_opt_f tab1,
         ben_elig_per_f tab2,
         ben_per_in_ler tab3
    where tab1.opt_id is not null
    and   tab1.elig_per_id = tab2.elig_per_id
    and   tab3.per_in_ler_id = tab1.per_in_ler_id
    and   c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and   c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    and   tab1.per_in_ler_id = c_pil_id
    order by  tab1.opt_id, tab2.pl_id, tab2.pgm_id;
  --
  cursor c_nopilinstance
    (c_effective_date DATE
    ,c_person_id      NUMBER
    )
  is
      SELECT   tab1.los_val
              ,tab1.age_val
              ,tab1.comp_ref_amt
              ,tab1.hrs_wkd_val
              ,tab1.pct_fl_tm_val
              ,tab1.cmbn_age_n_los_val
              ,tab1.age_uom
              ,tab1.los_uom
              ,tab1.comp_ref_uom
              ,tab1.hrs_wkd_bndry_perd_cd
              ,tab1.frz_los_flag
              ,tab1.frz_age_flag
              ,tab1.frz_hrs_wkd_flag
              ,tab1.frz_cmp_lvl_flag
              ,tab1.frz_pct_fl_tm_flag
              ,tab1.frz_comb_age_and_los_flag
              ,tab1.rt_los_val
              ,tab1.rt_age_val
              ,tab1.rt_comp_ref_amt
              ,tab1.rt_hrs_wkd_val
              ,tab1.rt_pct_fl_tm_val
              ,tab1.rt_cmbn_age_n_los_val
              ,tab1.rt_age_uom
              ,tab1.rt_los_uom
              ,tab1.rt_comp_ref_uom
              ,tab1.rt_hrs_wkd_bndry_perd_cd
              ,tab1.rt_frz_los_flag
              ,tab1.rt_frz_age_flag
              ,tab1.rt_frz_hrs_wkd_flag
              ,tab1.rt_frz_cmp_lvl_flag
              ,tab1.rt_frz_pct_fl_tm_flag
              ,tab1.rt_frz_comb_age_and_los_flag
              ,tab1.ovrid_svc_dt
              ,tab1.prtn_ovridn_flag
              ,tab1.prtn_ovridn_thru_dt
              ,tab1.once_r_cntug_cd
              ,tab1.elig_flag
              ,tab2.pgm_id
              ,tab2.ptip_id
              ,tab2.pl_id
              ,tab2.plip_id
              ,tab1.opt_id
              ,tab1.prtn_strt_dt
              ,tab1.prtn_end_dt
              ,tab1.elig_per_opt_id
              ,tab1.object_version_number
              ,tab2.elig_per_id
              ,tab2.per_in_ler_id
              ,tab2.prtn_strt_dt pep_psd
              ,tab2.prtn_end_dt pep_ped
    from ben_elig_per_opt_f tab1,
         ben_elig_per_f tab2
    where tab2.per_in_ler_id is null
    and   tab2.person_id = c_person_id
    and   tab1.opt_id is not null
    and   tab1.elig_per_id = tab2.elig_per_id
    and   c_effective_date
      between tab1.effective_start_date and tab1.effective_end_date
    and   c_effective_date
      between tab2.effective_start_date and tab2.effective_end_date
    order by  tab1.opt_id, tab2.pl_id, tab2.pgm_id;
  --
begin
  --
  get_peppil_list
    (p_person_id      => p_person_id
    ,p_effective_date => p_effective_date
    --
    ,p_peppil_va      => l_perpilid_va
    );
  --
  if l_perpilid_va.count > 0
  then
    --
    l_pil_cnt := 0;
    --
    for pilvaen in l_perpilid_va.first..l_perpilid_va.last
    loop
      --
      open c_pilinstance
        (c_effective_date => p_effective_date
        ,c_pil_id         => l_perpilid_va(pilvaen)
        );
      fetch c_pilinstance BULK COLLECT INTO l_los_val_va,
                                         l_age_val_va,
                                         l_comp_ref_amt_va,
                                         l_hrs_wkd_val_va,
                                         l_pct_fl_tm_val_va,
                                         l_cmbn_age_n_los_val_va,
                                         l_age_uom_va,
                                         l_los_uom_va,
                                         l_comp_ref_uom_va,
                                         l_hrs_wkd_bndry_perd_cd_va,
                                         l_frz_los_flag_va,
                                         l_frz_age_flag_va,
                                         l_frz_hrs_wkd_flag_va,
                                         l_frz_cmp_lvl_flag_va,
                                         l_frz_pct_fl_tm_flag_va,
                                         l_frz_comb_age_and_los_flag_va,
                                         l_rt_los_val_va,
                                         l_rt_age_val_va,
                                         l_rt_comp_ref_amt_va,
                                         l_rt_hrs_wkd_val_va,
                                         l_rt_pct_fl_tm_val_va,
                                         l_rt_cmbn_age_n_los_val_va,
                                         l_rt_age_uom_va,
                                         l_rt_los_uom_va,
                                         l_rt_comp_ref_uom_va,
                                         l_rt_hrs_wkd_bndry_perd_cd_va,
                                         l_rt_frz_los_flag_va,
                                         l_rt_frz_age_flag_va,
                                         l_rt_frz_hrs_wkd_flag_va,
                                         l_rt_frz_cmp_lvl_flag_va,
                                         l_rt_frz_pct_fl_tm_flag_va,
                                         l_rt_frz_cmb_age_los_flg_va,
                                         l_ovrid_svc_dt_va,
                                         l_prtn_ovridn_flag_va,
                                         l_prtn_ovridn_thru_dt_va,
                                         l_once_r_cntug_cd_va,
                                         l_elig_flag_va,
                                         l_pgm_id_va,
                                         l_ptip_id_va,
                                         l_pl_id_va,
                                         l_plip_id_va,
                                         l_opt_id_va,
                                         l_prtn_strt_dt_va,
                                         l_prtn_end_dt_va,
                                         l_elig_per_opt_id_va,
                                         l_object_version_number_va,
                                         l_elig_per_id_va,
                                         l_per_in_ler_id_va,
                                         l_pep_psd_va,
                                         l_pep_ped_va,
                                         l_pil_stcd_va;
      close c_pilinstance;
      --
      if l_los_val_va.count > 0
      then
        --
        for vaen in l_los_val_va.first..l_los_val_va.last
        loop
          --
          l_exclude := false;
          --
          -- Exclude for PIL status codes
          --
          if l_pil_stcd_va(vaen) = 'VOIDD'
            or l_pil_stcd_va(vaen) = 'BCKDT'
          then
            --
            l_exclude := true;
            --
          end if;
          --
          if not l_exclude
          then
            --
            l_hv := mod(nvl(l_opt_id_va(vaen),1)+nvl(l_pgm_id_va(vaen),2)
                    +nvl(l_pl_id_va(vaen),3) +nvl(l_plip_id_va(vaen),4),
                    ben_hash_utility.get_hash_key);
            --
            while ben_pep_cache.g_optpilepo_instance.exists(l_hv)
            loop
              --
              l_hv := l_hv+g_hash_jump;
              --
            end loop;
            --
            ben_pep_cache.g_optpilepo_instance(l_hv).opt_id := l_opt_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).pgm_id := l_pgm_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).pl_id := l_pl_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).plip_id := l_plip_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).prtn_strt_dt := l_prtn_strt_dt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).los_val := l_los_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).age_val := l_age_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).comp_ref_amt := l_comp_ref_amt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).hrs_wkd_val := l_hrs_wkd_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).pct_fl_tm_val := l_pct_fl_tm_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).cmbn_age_n_los_val := l_cmbn_age_n_los_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).age_uom := l_age_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).los_uom := l_los_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).comp_ref_uom := l_comp_ref_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).hrs_wkd_bndry_perd_cd := l_hrs_wkd_bndry_perd_cd_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_los_flag := l_frz_los_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_age_flag := l_frz_age_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_hrs_wkd_flag := l_frz_hrs_wkd_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_cmp_lvl_flag := l_frz_cmp_lvl_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_pct_fl_tm_flag := l_frz_pct_fl_tm_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).frz_comb_age_and_los_flag := l_frz_comb_age_and_los_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_los_val := l_rt_los_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_age_val := l_rt_age_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_comp_ref_amt := l_rt_comp_ref_amt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_hrs_wkd_val := l_rt_hrs_wkd_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_pct_fl_tm_val := l_rt_pct_fl_tm_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_cmbn_age_n_los_val := l_rt_cmbn_age_n_los_val_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_age_uom := l_rt_age_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_los_uom := l_rt_los_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_comp_ref_uom := l_rt_comp_ref_uom_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_hrs_wkd_bndry_perd_cd := l_rt_hrs_wkd_bndry_perd_cd_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_los_flag := l_rt_frz_los_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_age_flag := l_rt_frz_age_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_hrs_wkd_flag := l_rt_frz_hrs_wkd_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_cmp_lvl_flag := l_rt_frz_cmp_lvl_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_pct_fl_tm_flag := l_rt_frz_pct_fl_tm_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_comb_age_and_los_flag := l_rt_frz_cmb_age_los_flg_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).ovrid_svc_dt := l_ovrid_svc_dt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).prtn_ovridn_flag := l_prtn_ovridn_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).prtn_ovridn_thru_dt := l_prtn_ovridn_thru_dt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).once_r_cntug_cd := l_once_r_cntug_cd_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).elig_flag := l_elig_flag_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).prtn_end_dt := l_prtn_end_dt_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).elig_per_opt_id := l_elig_per_opt_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).object_version_number := l_object_version_number_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).elig_per_id := l_elig_per_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).per_in_ler_id := l_per_in_ler_id_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).pep_prtn_strt_dt := l_pep_psd_va(vaen);
            ben_pep_cache.g_optpilepo_instance(l_hv).pep_prtn_end_dt := l_pep_ped_va(vaen);
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      l_pil_cnt := l_pil_cnt+1;
      --
    end loop;
    --
    -- When no per in lers exist that are not backed out and voided then
    -- look for eligibility with a null per in ler.
    --
    if l_pil_cnt = 0
    then
      --
      open c_nopilinstance
        (c_effective_date => p_effective_date
        ,c_person_id      => p_person_id
        );
      fetch c_nopilinstance BULK COLLECT INTO l_los_val_va,
                                         l_age_val_va,
                                         l_comp_ref_amt_va,
                                         l_hrs_wkd_val_va,
                                         l_pct_fl_tm_val_va,
                                         l_cmbn_age_n_los_val_va,
                                         l_age_uom_va,
                                         l_los_uom_va,
                                         l_comp_ref_uom_va,
                                         l_hrs_wkd_bndry_perd_cd_va,
                                         l_frz_los_flag_va,
                                         l_frz_age_flag_va,
                                         l_frz_hrs_wkd_flag_va,
                                         l_frz_cmp_lvl_flag_va,
                                         l_frz_pct_fl_tm_flag_va,
                                         l_frz_comb_age_and_los_flag_va,
                                         l_rt_los_val_va,
                                         l_rt_age_val_va,
                                         l_rt_comp_ref_amt_va,
                                         l_rt_hrs_wkd_val_va,
                                         l_rt_pct_fl_tm_val_va,
                                         l_rt_cmbn_age_n_los_val_va,
                                         l_rt_age_uom_va,
                                         l_rt_los_uom_va,
                                         l_rt_comp_ref_uom_va,
                                         l_rt_hrs_wkd_bndry_perd_cd_va,
                                         l_rt_frz_los_flag_va,
                                         l_rt_frz_age_flag_va,
                                         l_rt_frz_hrs_wkd_flag_va,
                                         l_rt_frz_cmp_lvl_flag_va,
                                         l_rt_frz_pct_fl_tm_flag_va,
                                         l_rt_frz_cmb_age_los_flg_va,
                                         l_ovrid_svc_dt_va,
                                         l_prtn_ovridn_flag_va,
                                         l_prtn_ovridn_thru_dt_va,
                                         l_once_r_cntug_cd_va,
                                         l_elig_flag_va,
                                         l_pgm_id_va,
                                         l_ptip_id_va,
                                         l_pl_id_va,
                                         l_plip_id_va,
                                         l_opt_id_va,
                                         l_prtn_strt_dt_va,
                                         l_prtn_end_dt_va,
                                         l_elig_per_opt_id_va,
                                         l_object_version_number_va,
                                         l_elig_per_id_va,
                                         l_per_in_ler_id_va,
                                         l_pep_psd_va,
                                         l_pep_ped_va;
      close c_nopilinstance;
      --
      if l_los_val_va.count > 0
      then
        --
        for vaen in l_los_val_va.first..l_los_val_va.last
        loop
          --
          l_hv := mod(nvl(l_opt_id_va(vaen),1)+nvl(l_pgm_id_va(vaen),2)
                  +nvl(l_pl_id_va(vaen),3) +nvl(l_plip_id_va(vaen),4),
                  ben_hash_utility.get_hash_key);
          --
          while ben_pep_cache.g_optpilepo_instance.exists(l_hv)
          loop
            --
            l_hv := l_hv+g_hash_jump;
            --
          end loop;
          --
          ben_pep_cache.g_optpilepo_instance(l_hv).opt_id := l_opt_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).pgm_id := l_pgm_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).pl_id := l_pl_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).plip_id := l_plip_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).prtn_strt_dt := l_prtn_strt_dt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).los_val := l_los_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).age_val := l_age_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).comp_ref_amt := l_comp_ref_amt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).hrs_wkd_val := l_hrs_wkd_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).pct_fl_tm_val := l_pct_fl_tm_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).cmbn_age_n_los_val := l_cmbn_age_n_los_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).age_uom := l_age_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).los_uom := l_los_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).comp_ref_uom := l_comp_ref_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).hrs_wkd_bndry_perd_cd := l_hrs_wkd_bndry_perd_cd_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_los_flag := l_frz_los_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_age_flag := l_frz_age_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_hrs_wkd_flag := l_frz_hrs_wkd_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_cmp_lvl_flag := l_frz_cmp_lvl_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_pct_fl_tm_flag := l_frz_pct_fl_tm_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).frz_comb_age_and_los_flag := l_frz_comb_age_and_los_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_los_val := l_rt_los_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_age_val := l_rt_age_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_comp_ref_amt := l_rt_comp_ref_amt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_hrs_wkd_val := l_rt_hrs_wkd_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_pct_fl_tm_val := l_rt_pct_fl_tm_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_cmbn_age_n_los_val := l_rt_cmbn_age_n_los_val_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_age_uom := l_rt_age_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_los_uom := l_rt_los_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_comp_ref_uom := l_rt_comp_ref_uom_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_hrs_wkd_bndry_perd_cd := l_rt_hrs_wkd_bndry_perd_cd_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_los_flag := l_rt_frz_los_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_age_flag := l_rt_frz_age_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_hrs_wkd_flag := l_rt_frz_hrs_wkd_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_cmp_lvl_flag := l_rt_frz_cmp_lvl_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_pct_fl_tm_flag := l_rt_frz_pct_fl_tm_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).rt_frz_comb_age_and_los_flag := l_rt_frz_cmb_age_los_flg_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).ovrid_svc_dt := l_ovrid_svc_dt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).prtn_ovridn_flag := l_prtn_ovridn_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).prtn_ovridn_thru_dt := l_prtn_ovridn_thru_dt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).once_r_cntug_cd := l_once_r_cntug_cd_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).elig_flag := l_elig_flag_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).prtn_end_dt := l_prtn_end_dt_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).elig_per_opt_id := l_elig_per_opt_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).object_version_number := l_object_version_number_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).elig_per_id := l_elig_per_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).per_in_ler_id := l_per_in_ler_id_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).pep_prtn_strt_dt := l_pep_psd_va(vaen);
          ben_pep_cache.g_optpilepo_instance(l_hv).pep_prtn_end_dt := l_pep_ped_va(vaen);
          --
        end loop;
        --
      end if;
      --
    end if;
    --
  end if;
  --
end write_pilepo_cache;
--
end ben_pep_cache2;

/
