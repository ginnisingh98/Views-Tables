--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PL_DSGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PL_DSGN_PKG" as
/* $Header: bencwbpl.pkb 120.3.12010000.2 2010/02/02 11:51:13 sgnanama ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_pl_dsgn_pkg.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- --------------------------------------------------------------------------
-- |------------------------< get_opt_ordr_in_grp >-------------------------|
-- --------------------------------------------------------------------------
-- This is an internal functional called by refresh_pl_dsgn.
--
-- Cursor csr_grp_opt_ordr finds all the opt ids attached to the given group
-- plan and orders them on oipl_ordr_num. The result is placed in l_grp_opt
-- by refresh_pl_dsgn procedure before starint any process.
--
-- For a given oipl which is attached to a group oipl, this function
-- get_opt_ordr_in_grp finds the order num of the option in the group options
-- by searching l_grp_opt.
--
type grp_opt_type is table of ben_oipl_f.opt_id%type;
g_grp_opt grp_opt_type;
--
function get_opt_ordr_in_grp(oipl_opt in number)
return number is
--
   l_proc     varchar2(72) := g_package||'get_opt_ordr_in_grp';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if g_grp_opt.count = 0 then
      return 0;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   for i in g_grp_opt.first .. g_grp_opt.last
   loop
      if g_grp_opt(i) = oipl_opt then
         return i;
      end if;
   end loop;
   -- this case should never happen
   return 0;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end get_opt_ordr_in_grp;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_actual_flag >---------------------------|
-- --------------------------------------------------------------------------
--
-- This function checks whether the given plan is an actual plan or part of
-- a group plan.
--
function get_actual_flag(p_pl_id number
                        ,p_group_pl_id number
                        ,p_effective_date date)
return varchar2 is
--
   l_dummy varchar2(1);
--
   l_proc     varchar2(72) := g_package||'get_actual_flag';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if (p_pl_id <> p_group_pl_id) then
      --pl_id and group_pl_id differs. So this is an actual plan
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 66);
      end if;
      --
      return 'Y';
   else
      -- pl_id and group_pl_id are same. so check if any other plans
      -- attached to this plan(this plan id is used as group_pl_id
      -- in other plans)
      begin
         select null into l_dummy
         from dual
         where exists(select null from ben_pl_f pl
                      where pl.group_pl_id = p_pl_id
                      and pl.pl_id <> p_pl_id
                      and p_effective_date between pl.effective_start_date
                      and pl.effective_end_date);

         -- Some other plans have this pl_id as group_pl_id. So not an
         -- acutal plan
         --
         if g_debug then
            hr_utility.set_location(' Leaving:'|| l_proc, 77);
         end if;
         --
         return 'N';
      exception
         when no_data_found then
            -- no other plans are attached to pl_id. so this is an actual plan
            --
            if g_debug then
               hr_utility.set_location(' Leaving:'|| l_proc, 99);
            end if;
            --
         return 'Y';
      end;
   end if;
end;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_exchg_rate >----------------------------|
-- --------------------------------------------------------------------------
--
function get_exchg_rate(p_from_currency     varchar2
                       ,p_to_currency       varchar2
                       ,p_effective_date    date
                       ,p_business_group_id number)
return number is
   --
   l_exchg_rate number;
   --
   l_proc     varchar2(72) := g_package||'get_exchg_rate';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   l_exchg_rate := hr_currency_pkg.get_rate
            (p_from_currency                      -- From currency
            ,p_to_currency                        -- To currency
            ,p_effective_date                     -- conversion date
            ,hr_currency_pkg.get_rate_type        -- rate type
                        (p_business_group_id    -- bg Id
                        ,p_effective_date         -- conversion date
                        ,'R'));                   -- processing type
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 88);
   end if;
   --
   return l_exchg_rate;
exception
   when others then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 99);
      end if;
      --
      return 1;
end get_exchg_rate;
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_valid_date >---------------------------|
-- --------------------------------------------------------------------------
--
function get_valid_date(p_day          in number
                       ,p_month        in number
                       ,p_start_date   in date
                       ,p_end_date     in date
                       ,p_default_date in date)
return date is
   --
   l_start_mo number(2) := to_number(to_char(p_start_date, 'MM'));
   l_start_yy number(4) := to_number(to_char(p_start_date, 'YYYY'));
   l_end_yy   number(4) := to_number(to_char(p_end_date, 'YYYY'));
   l_year     number(4);
   l_date     date;
   l_proc     varchar2(72) := g_package||'get_valid_date';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if l_start_yy = l_end_yy then
     l_year := l_start_yy;
   elsif p_month >= l_start_mo then
     l_year := l_start_yy;
   else
     l_year := l_end_yy;
   end if;

   l_date := fnd_date.canonical_to_date(l_year||'/'||p_month||'/'||p_day);
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 88);
   end if;
   --
   return l_date;
   --
exception
   when others then
      --
      if g_debug then
         hr_utility.set_location(' Leaving:'|| l_proc, 99);
      end if;
      --
      return p_default_date;
end get_valid_date;
--
-- --------------------------------------------------------------------------
-- |--------------------------< refresh_pl_dsgn >---------------------------|
-- --------------------------------------------------------------------------
--
procedure refresh_pl_dsgn(p_group_pl_id     in number
                         ,p_lf_evt_ocrd_dt in date
                         ,p_effective_date date
                         ,p_refresh_always in varchar2 default 'N') is
   -- cursor to fetch group plan details
   cursor csr_group_pl(p_group_pl_id number
                      ,p_lf_evt_ocrd_dt date
                      ,p_effective_date date) is
   select pl.pl_id                        pl_id
         ,-1                              oipl_id
         ,nvl(p_effective_date,nvl(enp.data_freeze_date,p_lf_evt_ocrd_dt))
                                          effective_date
         ,pl.name                         name
         ,pl.group_pl_id                  group_pl_id
         ,-1                              group_oipl_id
         ,pl.nip_pl_uom                   pl_uom
         ,1                               pl_xchg_rate
         ,null                            opt_count
         ,enp.uses_bdgt_flag              uses_bdgt_flag
         ,enp.prsvr_bdgt_cd               prsrv_bdgt_cd
         ,enp.ws_upd_strt_dt              upd_start_dt
         ,enp.ws_upd_end_dt               upd_end_dt
         ,enp.approval_mode_cd            approval_mode
         ,enp.strt_dt                     enrt_perd_start_dt
         ,enp.end_dt                      enrt_perd_end_dt
         ,yr.start_date                   yr_perd_start_dt
         ,yr.end_date                     yr_perd_end_dt
         ,to_date(null)                   wthn_yr_start_dt
         ,to_date(null)                   wthn_yr_end_dt
         ,wyr.strt_day                    wthn_strt_day
         ,wyr.strt_mo                     wthn_strt_mo
         ,wyr.end_day                     wthn_end_day
         ,wyr.end_mo                      wthn_end_mo
         ,enp.enrt_perd_id                enrt_perd_id
         ,yr.yr_perd_id                   yr_perd_id
         ,enp.business_group_id           business_group_id
         ,enp.perf_revw_strt_dt           perf_revw_strt_dt
         ,enp.asg_updt_eff_date           asg_updt_eff_date
         ,enp.emp_interview_type_cd       emp_interview_typ_cd
         ,enp.sal_chg_reason_cd           salary_change_reason
         ,enp.data_freeze_date            data_freeze_date
   from ben_pl_f pl
       ,ben_popl_enrt_typ_cycl_f petc
       ,ben_enrt_perd enp
       ,ben_yr_perd  yr
       ,ben_wthn_yr_perd wyr
   where pl.pl_id = p_group_pl_id
   and   nvl(p_effective_date,nvl(enp.data_freeze_date,p_lf_evt_ocrd_dt))
         between pl.effective_start_date and pl.effective_end_date
   and   petc.pl_id = pl.pl_id
   and   petc.enrt_typ_cycl_cd = 'COMP'
   and   nvl(p_effective_date,nvl(enp.data_freeze_date,p_lf_evt_ocrd_dt))
         between petc.effective_start_date and petc.effective_end_date
   and   enp.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
   and   enp.asnd_lf_evt_dt = p_lf_evt_ocrd_dt
   and   yr.yr_perd_id = enp.yr_perd_id
   and   wyr.wthn_yr_perd_id (+) = enp.wthn_yr_perd_id;

   -- cursor to fetch the plan details
   -- Bug 3975857 : In cursor CSR_PLS pick up only Active Standard Rates. Added clause <<ACTY_BASE_RT_STAT_CD (+)= 'A'>>
   --               to the cursor query
   cursor csr_pls(p_group_pl_id    number
                 ,p_effective_date date
                 ,p_group_pl_uom   varchar2
                 ,p_group_pl_bg_id number) is
   select pl.pl_id                        pl_id
         ,pl.name                         name
         ,pl.nip_pl_uom                   pl_uom
         ,pl.ordr_num                     pl_ordr_num
         ,get_exchg_rate(p_group_pl_uom      -- From currency
                        ,pl.nip_pl_uom       -- To currency
                        ,p_effective_date    -- conversion date
                        ,p_group_pl_bg_id    -- bg Id
                        )                 pl_xchg_rate
         ,pl.business_group_id            business_group_id
         ,ws.acty_base_rt_id              ws_abr_id
         ,ws.nnmntry_uom                  ws_nnmntry_uom
         ,ws.rndg_cd                      ws_rndg_cd
         ,ws.sub_acty_typ_cd              ws_sub_acty_typ_cd
	      ,ws.element_type_id              ws_element_type_id
	      ,ws.input_value_id               ws_input_value_id
         ,db.acty_base_rt_id              dist_bdgt_abr_id
         ,db.nnmntry_uom                  dist_bdgt_nnmntry_uom
         ,db.rndg_cd                      dist_bdgt_rndg_cd
         ,wb.acty_base_rt_id              ws_bdgt_abr_id
         ,wb.nnmntry_uom                  ws_bdgt_nnmntry_uom
         ,wb.rndg_cd                      ws_bdgt_rndg_cd
         ,rsrv.acty_base_rt_id            rsrv_abr_id
         ,rsrv.nnmntry_uom                rsrv_nnmntry_uom
         ,rsrv.rndg_cd                    rsrv_rndg_cd
         ,es.acty_base_rt_id              elig_sal_abr_id
         ,es.nnmntry_uom                  elig_sal_nnmntry_uom
         ,es.rndg_cd                      elig_sal_rndg_cd
         ,misc1.acty_base_rt_id           misc1_abr_id
         ,misc1.nnmntry_uom               misc1_nnmntry_uom
         ,misc1.rndg_cd                   misc1_rndg_cd
         ,misc2.acty_base_rt_id           misc2_abr_id
         ,misc2.nnmntry_uom               misc2_nnmntry_uom
         ,misc2.rndg_cd                   misc2_rndg_cd
         ,misc3.acty_base_rt_id           misc3_abr_id
         ,misc3.nnmntry_uom               misc3_nnmntry_uom
         ,misc3.rndg_cd                   misc3_rndg_cd
         ,ss.acty_base_rt_id              stat_sal_abr_id
         ,ss.nnmntry_uom                  stat_sal_nnmntry_uom
         ,ss.rndg_cd                      stat_sal_rndg_cd
         ,rec.acty_base_rt_id             rec_abr_id
         ,rec.nnmntry_uom                 rec_nnmntry_uom
         ,rec.rndg_cd                     rec_rndg_cd
         ,tc.acty_base_rt_id              tot_comp_abr_id
         ,tc.nnmntry_uom                  tot_comp_nnmntry_uom
         ,tc.rndg_cd                      tot_comp_rndg_cd
         ,oc.acty_base_rt_id              oth_comp_abr_id
         ,oc.nnmntry_uom                  oth_comp_nnmntry_uom
         ,oc.rndg_cd                      oth_comp_rndg_cd
         ,get_actual_flag(pl.pl_id,pl.group_pl_id,p_effective_date)
                                          actual_flag
         ,pl.nip_acty_ref_perd_cd         acty_ref_perd_cd
         ,bg.legislation_code             legislation_code
         ,benutils.get_pl_annualization_factor(pl.nip_acty_ref_perd_cd)
                                          pl_annulization_factor
         ,decode(pl.pl_id,
                   p_group_pl_id, pl.pl_stat_cd,
                   'A')                   pl_stat_cd
         ,nvl(cur.precision, 2)           uom_precision
         ,enp.enrt_perd_id                enrt_perd_id
         ,enp.yr_perd_id                  yr_perd_id
   from ben_pl_f pl
       ,ben_acty_base_rt_f ws
       ,ben_acty_base_rt_f db
       ,ben_acty_base_rt_f wb
       ,ben_acty_base_rt_f rsrv
       ,ben_acty_base_rt_f es
       ,ben_acty_base_rt_f misc1
       ,ben_acty_base_rt_f misc2
       ,ben_acty_base_rt_f misc3
       ,ben_acty_base_rt_f ss
       ,ben_acty_base_rt_f rec
       ,ben_acty_base_rt_f tc
       ,ben_acty_base_rt_f oc
       ,per_business_groups bg
       ,fnd_currencies cur
       ,ben_popl_enrt_typ_cycl_f petc
       ,ben_enrt_perd enp
   where pl.group_pl_id = p_group_pl_id
   and   p_effective_date between pl.effective_start_date and
         pl.effective_end_date
   and   pl.pl_stat_cd in ('A', 'I')
   and   petc.pl_id = pl.pl_id
   and   petc.enrt_typ_cycl_cd = 'COMP'
   and   p_effective_date between
         petc.effective_start_date and petc.effective_end_date
   and   enp.popl_enrt_typ_cycl_id = petc.popl_enrt_typ_cycl_id
   and   enp.asnd_lf_evt_dt = p_lf_evt_ocrd_dt
   and   ws.pl_id (+) = pl.pl_id
   and   p_effective_date between ws.effective_start_date(+) and
         ws.effective_end_date (+)
   and   ws.acty_typ_cd (+) = 'CWBWS'
   and   ws.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   db.pl_id (+) = pl.pl_id
   and   p_effective_date between db.effective_start_date(+) and
         db.effective_end_date (+)
   and   db.acty_typ_cd (+) = 'CWBDB'
   and   db.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   wb.pl_id (+) = pl.pl_id
   and   p_effective_date between wb.effective_start_date(+) and
         wb.effective_end_date (+)
   and   wb.acty_typ_cd (+) = 'CWBWB'
   and   wb.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   rsrv.pl_id (+) = pl.pl_id
   and   p_effective_date between rsrv.effective_start_date(+) and
         rsrv.effective_end_date (+)
   and   rsrv.acty_typ_cd (+) = 'CWBR'
   and   rsrv.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   es.pl_id (+) = pl.pl_id
   and   p_effective_date between es.effective_start_date(+) and
         es.effective_end_date (+)
   and   es.acty_typ_cd (+) = 'CWBES'
   and   es.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc1.pl_id (+) = pl.pl_id
   and   p_effective_date between misc1.effective_start_date(+) and
         misc1.effective_end_date (+)
   and   misc1.acty_typ_cd (+) = 'CWBMR1'
   and   misc1.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc2.pl_id (+) = pl.pl_id
   and   p_effective_date between misc2.effective_start_date(+) and
         misc2.effective_end_date (+)
   and   misc2.acty_typ_cd (+) = 'CWBMR2'
   and   misc2.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc3.pl_id (+) = pl.pl_id
   and   p_effective_date between misc3.effective_start_date(+) and
         misc3.effective_end_date (+)
   and   misc3.acty_typ_cd (+) = 'CWBMR3'
   and   misc3.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   ss.pl_id (+) = pl.pl_id
   and   p_effective_date between ss.effective_start_date(+) and
         ss.effective_end_date (+)
   and   ss.acty_typ_cd (+) = 'CWBSS'
   and   ss.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   rec.pl_id (+) = pl.pl_id
   and   p_effective_date between rec.effective_start_date(+) and
         rec.effective_end_date (+)
   and   rec.acty_typ_cd (+) = 'CWBRA'
   and   rec.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   tc.pl_id (+) = pl.pl_id
   and   p_effective_date between tc.effective_start_date(+) and
         tc.effective_end_date (+)
   and   tc.acty_typ_cd (+) = 'CWBTC'
   and   tc.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   oc.pl_id (+) = pl.pl_id
   and   p_effective_date between oc.effective_start_date(+) and
         oc.effective_end_date (+)
   and   oc.acty_typ_cd (+) = 'CWBOS'
   and   oc.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   bg.business_group_id = pl.business_group_id
   and   pl.nip_pl_uom = cur.currency_code (+)
   -- Refresh that local/group plan only if no rows exist for the plan.
   and   not exists (select 'Y'
                     from ben_cwb_pl_dsgn dsgn
                     where dsgn.group_pl_id    = p_group_pl_id
                     and   dsgn.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
                     and   dsgn.pl_id          = pl.pl_id);

   -- Bug 3975857 : In cursor CSR_OIPLS pick up only Active Standard Rates. Added clause <<ACTY_BASE_RT_STAT_CD (+)= 'A'>>
   --               to the cursor query
   cursor csr_oipls(p_pl_id number
                   ,p_effective_date date) is
   select oipl.oipl_id              oipl_id
         ,opt.name                  name
         ,group_oipl.oipl_id        group_oipl_id
         ,oipl.hidden_flag          opt_hidden_flag
         ,oipl.opt_id               opt_id
         ,opt.group_opt_id          group_opt_id
         ,oipl.business_group_id    business_group_id
         ,ws.acty_base_rt_id        ws_abr_id
         ,ws.nnmntry_uom            ws_nnmntry_uom
         ,ws.rndg_cd                ws_rndg_cd
         ,ws.sub_acty_typ_cd        ws_sub_acty_typ_cd
         ,ws.element_type_id        ws_element_type_id
         ,ws.input_value_id         ws_input_value_id
         ,db.acty_base_rt_id        dist_bdgt_abr_id
         ,db.nnmntry_uom            dist_bdgt_nnmntry_uom
         ,db.rndg_cd                dist_bdgt_rndg_cd
         ,wb.acty_base_rt_id        ws_bdgt_abr_id
         ,wb.nnmntry_uom            ws_bdgt_nnmntry_uom
         ,wb.rndg_cd                ws_bdgt_rndg_cd
         ,rsrv.acty_base_rt_id      rsrv_abr_id
         ,rsrv.nnmntry_uom          rsrv_nnmntry_uom
         ,rsrv.rndg_cd              rsrv_rndg_cd
         ,es.acty_base_rt_id        elig_sal_abr_id
         ,es.nnmntry_uom            elig_sal_nnmntry_uom
         ,es.rndg_cd                elig_sal_rndg_cd
         ,misc1.acty_base_rt_id     misc1_abr_id
         ,misc1.nnmntry_uom         misc1_nnmntry_uom
         ,misc1.rndg_cd             misc1_rndg_cd
         ,misc2.acty_base_rt_id     misc2_abr_id
         ,misc2.nnmntry_uom         misc2_nnmntry_uom
         ,misc2.rndg_cd             misc2_rndg_cd
         ,misc3.acty_base_rt_id     misc3_abr_id
         ,misc3.nnmntry_uom         misc3_nnmntry_uom
         ,misc3.rndg_cd             misc3_rndg_cd
         ,ss.acty_base_rt_id        stat_sal_abr_id
         ,ss.nnmntry_uom            stat_sal_nnmntry_uom
         ,ss.rndg_cd                stat_sal_rndg_cd
         ,rec.acty_base_rt_id       rec_abr_id
         ,rec.nnmntry_uom           rec_nnmntry_uom
         ,rec.rndg_cd               rec_rndg_cd
         ,tc.acty_base_rt_id        tot_comp_abr_id
         ,tc.nnmntry_uom            tot_comp_nnmntry_uom
         ,tc.rndg_cd                tot_comp_rndg_cd
         ,oc.acty_base_rt_id        oth_comp_abr_id
         ,oc.nnmntry_uom            oth_comp_nnmntry_uom
         ,oc.rndg_cd                oth_comp_rndg_cd
   from ben_oipl_f oipl
       ,ben_opt_f opt
       ,ben_oipl_f group_oipl
       ,ben_pl_f pl
       ,ben_acty_base_rt_f ws
       ,ben_acty_base_rt_f db
       ,ben_acty_base_rt_f wb
       ,ben_acty_base_rt_f rsrv
       ,ben_acty_base_rt_f es
       ,ben_acty_base_rt_f misc1
       ,ben_acty_base_rt_f misc2
       ,ben_acty_base_rt_f misc3
       ,ben_acty_base_rt_f ss
       ,ben_acty_base_rt_f rec
       ,ben_acty_base_rt_f tc
       ,ben_acty_base_rt_f oc
   where oipl.pl_id = p_pl_id
   and   p_effective_date between oipl.effective_start_date and
         oipl.effective_end_date
   and   oipl.oipl_stat_cd in ('A', 'I')
   and   opt.opt_id = oipl.opt_id
   and   p_effective_date between opt.effective_start_date and
         opt.effective_end_date
   and   opt.group_opt_id= group_oipl.opt_id
   and   group_oipl.pl_id = pl.group_pl_id
   and   p_effective_date between group_oipl.effective_start_date and
         group_oipl.effective_end_date
   and   pl.pl_id = oipl.pl_id
   and   p_effective_date between pl.effective_start_date and
         pl.effective_end_date
   and   ws.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between ws.effective_start_date(+) and
         ws.effective_end_date (+)
   and   ws.acty_typ_cd (+) = 'CWBWS'
   and   ws.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   db.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between db.effective_start_date(+) and
         db.effective_end_date (+)
   and   db.acty_typ_cd (+) = 'CWBDB'
   and   db.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   wb.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between wb.effective_start_date(+) and
         wb.effective_end_date (+)
   and   wb.acty_typ_cd (+) = 'CWBWB'
   and   wb.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   rsrv.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between rsrv.effective_start_date(+) and
         rsrv.effective_end_date (+)
   and   rsrv.acty_typ_cd (+) = 'CWBR'
   and   rsrv.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   es.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between es.effective_start_date(+) and
         es.effective_end_date (+)
   and   es.acty_typ_cd (+) = 'CWBES'
   and   es.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc1.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between misc1.effective_start_date(+) and
         misc1.effective_end_date (+)
   and   misc1.acty_typ_cd (+) = 'CWBMR1'
   and   misc1.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc2.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between misc2.effective_start_date(+) and
         misc2.effective_end_date (+)
   and   misc2.acty_typ_cd (+) = 'CWBMR2'
   and   misc2.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   misc3.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between misc3.effective_start_date(+) and
         misc3.effective_end_date (+)
   and   misc3.acty_typ_cd (+) = 'CWBMR3'
   and   misc3.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   ss.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between ss.effective_start_date(+) and
         ss.effective_end_date (+)
   and   ss.acty_typ_cd (+) = 'CWBSS'
   and   ss.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   rec.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between rec.effective_start_date(+) and
         rec.effective_end_date (+)
   and   rec.acty_typ_cd (+) = 'CWBRA'
   and   rec.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   tc.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between tc.effective_start_date(+) and
         tc.effective_end_date (+)
   and   tc.acty_typ_cd (+) = 'CWBTC'
   and   tc.ACTY_BASE_RT_STAT_CD (+)= 'A'
   and   oc.oipl_id (+) = oipl.oipl_id
   and   p_effective_date between oc.effective_start_date(+) and
         oc.effective_end_date (+)
   and   oc.acty_typ_cd (+) = 'CWBOS'
   and   oc.ACTY_BASE_RT_STAT_CD (+)= 'A';
   --
   -- cursor for fetching the ordr_num for oipls of group plan
   cursor csr_grp_opt_ordr(p_group_pl_id number
                          ,p_effective_date date)is
   select opt_id
   from ben_oipl_f
   where pl_id = p_group_pl_id
   and   p_effective_date between effective_start_date and effective_end_date
   order by ordr_num;
   --
   -- ER:8369634
   cursor csr_grp_plan_extra_info
   is
   select PLI_INFORMATION3 post_zero_salary_increase ,
	  PLI_INFORMATION4 show_appraisals_n_days
   from ben_pl_extra_info
   where INFORMATION_TYPE='CWB_CUSTOM_DOWNLOAD'
   and pl_id = p_group_pl_id;


   -- local variable declarations
   l_group_pl_row csr_group_pl%rowtype;
   --
   l_opt_count number;
   l_oipl_ordr_num number;
   --
   l_proc     varchar2(72) := g_package||'refresh_pl_dsgn';
   --
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   if p_refresh_always = 'Y' then
     --
     if g_debug then
       hr_utility.set_location('l_proc'|| l_proc, 17);
     end if;
     --
     -- refresh. delete plans and oipls from the pl_dsgn
     delete from ben_cwb_pl_dsgn
     where group_pl_id = p_group_pl_id
     and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
     --
   end if;
   --
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --
   -- get the group plan row
   open csr_group_pl(p_group_pl_id
                    ,p_lf_evt_ocrd_dt
                    ,p_effective_date);
   fetch csr_group_pl into l_group_pl_row;
   --
   if csr_group_pl%notfound then
      close csr_group_pl;
      return;
   end if;
   close csr_group_pl;
   --
   -- Get the within year dates.
   --
   if l_group_pl_row.wthn_strt_day is null or l_group_pl_row.wthn_strt_mo is null then
     l_group_pl_row.wthn_yr_start_dt :=  l_group_pl_row.yr_perd_start_dt;
   else
     l_group_pl_row.wthn_yr_start_dt := get_valid_date(l_group_pl_row.wthn_strt_day,
                                                       l_group_pl_row.wthn_strt_mo,
                                                       l_group_pl_row.yr_perd_start_dt,
                                                       l_group_pl_row.yr_perd_end_dt,
                                                       l_group_pl_row.yr_perd_start_dt);
   end if;

   if l_group_pl_row.wthn_end_day is null or l_group_pl_row.wthn_end_mo is null then
     l_group_pl_row.wthn_yr_end_dt :=  l_group_pl_row.yr_perd_end_dt;
   else
     l_group_pl_row.wthn_yr_end_dt := get_valid_date(l_group_pl_row.wthn_end_day,
                                                     l_group_pl_row.wthn_end_mo,
                                                     l_group_pl_row.yr_perd_start_dt,
                                                     l_group_pl_row.yr_perd_end_dt,
                                                     l_group_pl_row.yr_perd_end_dt);
   end if;
   --
   -- check for the options in the group plan
   open csr_grp_opt_ordr(p_group_pl_id
                      ,nvl(p_effective_date,nvl(l_group_pl_row.effective_date
                                               ,p_lf_evt_ocrd_dt)));
   fetch csr_grp_opt_ordr bulk collect into g_grp_opt;
   close csr_grp_opt_ordr;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   for pl in csr_pls(p_group_pl_id
                    ,nvl(p_effective_date,nvl(l_group_pl_row.effective_date
                                             ,p_lf_evt_ocrd_dt))
                    ,l_group_pl_row.pl_uom
                    ,l_group_pl_row.business_group_id)
   loop
      --
      if g_debug then
         hr_utility.set_location(l_proc, 40);
      end if;
      --
      -- first insert the oipl rows.
      --
      -- Intialize the count
      l_opt_count := 0;
      --
      for oipl in csr_oipls(pl.pl_id
                   ,nvl(p_effective_date,nvl(l_group_pl_row.effective_date
                                             ,p_lf_evt_ocrd_dt)))
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 50);
         end if;
         --
         --  Increment the count
         l_opt_count := l_opt_count + 1;
         l_oipl_ordr_num := get_opt_ordr_in_grp(oipl.group_opt_id);
          --
         insert into ben_cwb_pl_dsgn
                     (pl_id
                     ,lf_evt_ocrd_dt
                     ,oipl_id
                     ,effective_date
                     ,name
                     ,group_pl_id
                     ,group_oipl_id
                     ,opt_hidden_flag
                     ,opt_id
                     ,pl_uom
                     ,pl_ordr_num
                     ,oipl_ordr_num
                     ,pl_xchg_rate
                     ,uses_bdgt_flag
                     ,prsrv_bdgt_cd
                     ,business_group_id
                     ,ws_abr_id
                     ,ws_nnmntry_uom
                     ,ws_rndg_cd
                     ,ws_sub_acty_typ_cd
                     ,dist_bdgt_abr_id
                     ,dist_bdgt_nnmntry_uom
                     ,dist_bdgt_rndg_cd
                     ,ws_bdgt_abr_id
                     ,ws_bdgt_nnmntry_uom
                     ,ws_bdgt_rndg_cd
                     ,rsrv_abr_id
                     ,rsrv_nnmntry_uom
                     ,rsrv_rndg_cd
                     ,elig_sal_abr_id
                     ,elig_sal_nnmntry_uom
                     ,elig_sal_rndg_cd
                     ,misc1_abr_id
                     ,misc1_nnmntry_uom
                     ,misc1_rndg_cd
                     ,misc2_abr_id
                     ,misc2_nnmntry_uom
                     ,misc2_rndg_cd
                     ,misc3_abr_id
                     ,misc3_nnmntry_uom
                     ,misc3_rndg_cd
                     ,stat_sal_abr_id
                     ,stat_sal_nnmntry_uom
                     ,stat_sal_rndg_cd
                     ,rec_abr_id
                     ,rec_nnmntry_uom
                     ,rec_rndg_cd
                     ,tot_comp_abr_id
                     ,tot_comp_nnmntry_uom
                     ,tot_comp_rndg_cd
                     ,oth_comp_abr_id
                     ,oth_comp_nnmntry_uom
                     ,oth_comp_rndg_cd
                     ,actual_flag
                     ,acty_ref_perd_cd
                     ,legislation_code
                     ,pl_annulization_factor
                     ,pl_stat_cd
                     ,uom_precision
                     ,ws_element_type_id
                     ,ws_input_value_id
                     ,data_freeze_date
                     ,object_version_number)
            values   (pl.pl_id
                     ,p_lf_evt_ocrd_dt
                     ,oipl.oipl_id
                     ,l_group_pl_row.effective_date
                     ,oipl.name
                     ,p_group_pl_id
                     ,oipl.group_oipl_id
                     ,oipl.opt_hidden_flag
                     ,oipl.opt_id
                     ,pl.pl_uom
                     ,pl.pl_ordr_num
                     ,l_oipl_ordr_num
                     ,pl.pl_xchg_rate
                     ,l_group_pl_row.uses_bdgt_flag
                     ,l_group_pl_row.prsrv_bdgt_cd
                     ,oipl.business_group_id
                     ,oipl.ws_abr_id
                     ,oipl.ws_nnmntry_uom
                     ,oipl.ws_rndg_cd
                     ,oipl.ws_sub_acty_typ_cd
                     ,oipl.dist_bdgt_abr_id
                     ,oipl.dist_bdgt_nnmntry_uom
                     ,oipl.dist_bdgt_rndg_cd
                     ,oipl.ws_bdgt_abr_id
                     ,oipl.ws_bdgt_nnmntry_uom
                     ,oipl.ws_bdgt_rndg_cd
                     ,oipl.rsrv_abr_id
                     ,oipl.rsrv_nnmntry_uom
                     ,oipl.rsrv_rndg_cd
                     ,oipl.elig_sal_abr_id
                     ,oipl.elig_sal_nnmntry_uom
                     ,oipl.elig_sal_rndg_cd
                     ,oipl.misc1_abr_id
                     ,oipl.misc1_nnmntry_uom
                     ,oipl.misc1_rndg_cd
                     ,oipl.misc2_abr_id
                     ,oipl.misc2_nnmntry_uom
                     ,oipl.misc2_rndg_cd
                     ,oipl.misc3_abr_id
                     ,oipl.misc3_nnmntry_uom
                     ,oipl.misc3_rndg_cd
                     ,oipl.stat_sal_abr_id
                     ,oipl.stat_sal_nnmntry_uom
                     ,oipl.stat_sal_rndg_cd
                     ,oipl.rec_abr_id
                     ,oipl.rec_nnmntry_uom
                     ,oipl.rec_rndg_cd
                     ,oipl.tot_comp_abr_id
                     ,oipl.tot_comp_nnmntry_uom
                     ,oipl.tot_comp_rndg_cd
                     ,oipl.oth_comp_abr_id
                     ,oipl.oth_comp_nnmntry_uom
                     ,oipl.oth_comp_rndg_cd
                     ,pl.actual_flag
                     ,pl.acty_ref_perd_cd
                     ,pl.legislation_code
                     ,pl.pl_annulization_factor
                     ,'A'
                     ,pl.uom_precision
                     ,oipl.ws_element_type_id
                     ,oipl.ws_input_value_id
                     ,l_group_pl_row.data_freeze_date
                     ,1);        -- new row. so ovn is 1
      end loop; -- of l_oipl_rows

      --
      if g_debug then
         hr_utility.set_location(l_proc, 60);
      end if;
      --
      --insert the plan row
      insert into ben_cwb_pl_dsgn
               (pl_id
               ,lf_evt_ocrd_dt
               ,oipl_id
               ,effective_date
               ,name
               ,group_pl_id
               ,group_oipl_id
               ,pl_uom
               ,pl_ordr_num
               ,pl_xchg_rate
               ,opt_count
               ,uses_bdgt_flag
               ,prsrv_bdgt_cd
               ,upd_start_dt
               ,upd_end_dt
               ,approval_mode
               ,enrt_perd_start_dt
               ,enrt_perd_end_dt
               ,yr_perd_start_dt
               ,yr_perd_end_dt
               ,wthn_yr_start_dt
               ,wthn_yr_end_dt
               ,enrt_perd_id
               ,yr_perd_id
               ,business_group_id
               ,perf_revw_strt_dt
               ,asg_updt_eff_date
               ,emp_interview_typ_cd
               ,salary_change_reason
               ,ws_abr_id
               ,ws_nnmntry_uom
               ,ws_rndg_cd
               ,ws_sub_acty_typ_cd
               ,dist_bdgt_abr_id
               ,dist_bdgt_nnmntry_uom
               ,dist_bdgt_rndg_cd
               ,ws_bdgt_abr_id
               ,ws_bdgt_nnmntry_uom
               ,ws_bdgt_rndg_cd
               ,rsrv_abr_id
               ,rsrv_nnmntry_uom
               ,rsrv_rndg_cd
               ,elig_sal_abr_id
               ,elig_sal_nnmntry_uom
               ,elig_sal_rndg_cd
               ,misc1_abr_id
               ,misc1_nnmntry_uom
               ,misc1_rndg_cd
               ,misc2_abr_id
               ,misc2_nnmntry_uom
               ,misc2_rndg_cd
               ,misc3_abr_id
               ,misc3_nnmntry_uom
               ,misc3_rndg_cd
               ,stat_sal_abr_id
               ,stat_sal_nnmntry_uom
               ,stat_sal_rndg_cd
               ,rec_abr_id
               ,rec_nnmntry_uom
               ,rec_rndg_cd
               ,tot_comp_abr_id
               ,tot_comp_nnmntry_uom
               ,tot_comp_rndg_cd
               ,oth_comp_abr_id
               ,oth_comp_nnmntry_uom
               ,oth_comp_rndg_cd
               ,actual_flag
               ,acty_ref_perd_cd
               ,legislation_code
               ,pl_annulization_factor
               ,pl_stat_cd
               ,uom_precision
               ,ws_element_type_id
               ,ws_input_value_id
               ,data_freeze_date
               ,object_version_number)
            values
               (pl.pl_id
               ,p_lf_evt_ocrd_dt
               ,-1                           -- for plans oipl_id is -1
               ,l_group_pl_row.effective_date
               ,pl.name
               ,p_group_pl_id
               ,-1                           -- for plans group oipl id is -1
               ,pl.pl_uom
               ,pl.pl_ordr_num
               ,pl.pl_xchg_rate
               ,l_opt_count
               ,l_group_pl_row.uses_bdgt_flag
               ,l_group_pl_row.prsrv_bdgt_cd
               ,l_group_pl_row.upd_start_dt
               ,l_group_pl_row.upd_end_dt
               ,l_group_pl_row.approval_mode
               ,l_group_pl_row.enrt_perd_start_dt
               ,l_group_pl_row.enrt_perd_end_dt
               ,l_group_pl_row.yr_perd_start_dt
               ,l_group_pl_row.yr_perd_end_dt
               ,l_group_pl_row.wthn_yr_start_dt
               ,l_group_pl_row.wthn_yr_end_dt
               ,pl.enrt_perd_id
               ,pl.yr_perd_id
               ,pl.business_group_id
               ,l_group_pl_row.perf_revw_strt_dt
               ,l_group_pl_row.asg_updt_eff_date
               ,l_group_pl_row.emp_interview_typ_cd
               ,l_group_pl_row.salary_change_reason
               ,pl.ws_abr_id
               ,pl.ws_nnmntry_uom
               ,pl.ws_rndg_cd
               ,pl.ws_sub_acty_typ_cd
               ,pl.dist_bdgt_abr_id
               ,pl.dist_bdgt_nnmntry_uom
               ,pl.dist_bdgt_rndg_cd
               ,pl.ws_bdgt_abr_id
               ,pl.ws_bdgt_nnmntry_uom
               ,pl.ws_bdgt_rndg_cd
               ,pl.rsrv_abr_id
               ,pl.rsrv_nnmntry_uom
               ,pl.rsrv_rndg_cd
               ,pl.elig_sal_abr_id
               ,pl.elig_sal_nnmntry_uom
               ,pl.elig_sal_rndg_cd
               ,pl.misc1_abr_id
               ,pl.misc1_nnmntry_uom
               ,pl.misc1_rndg_cd
               ,pl.misc2_abr_id
               ,pl.misc2_nnmntry_uom
               ,pl.misc2_rndg_cd
               ,pl.misc3_abr_id
               ,pl.misc3_nnmntry_uom
               ,pl.misc3_rndg_cd
               ,pl.stat_sal_abr_id
               ,pl.stat_sal_nnmntry_uom
               ,pl.stat_sal_rndg_cd
               ,pl.rec_abr_id
               ,pl.rec_nnmntry_uom
               ,pl.rec_rndg_cd
               ,pl.tot_comp_abr_id
               ,pl.tot_comp_nnmntry_uom
               ,pl.tot_comp_rndg_cd
               ,pl.oth_comp_abr_id
               ,pl.oth_comp_nnmntry_uom
               ,pl.oth_comp_rndg_cd
               ,pl.actual_flag
               ,pl.acty_ref_perd_cd
               ,pl.legislation_code
               ,pl.pl_annulization_factor
               ,pl.pl_stat_cd
               ,pl.uom_precision
               ,pl.ws_element_type_id
               ,pl.ws_input_value_id
               ,l_group_pl_row.data_freeze_date
               ,1);              -- new row. so ovn is 1
   end loop; -- l_pl_rows
   --

    --   ER:8369634
    for l_grp_plan_extra_info in csr_grp_plan_extra_info loop
	update ben_cwb_pl_dsgn set
	     post_zero_salary_increase = l_grp_plan_extra_info.post_zero_salary_increase,
	     show_appraisals_n_days = l_grp_plan_extra_info.show_appraisals_n_days
	 where pl_id = p_group_pl_id
	 and lf_evt_ocrd_dt = p_lf_evt_ocrd_dt
	 and group_oipl_id = -1;
    end loop;

   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
end; -- end of refresh_pl_dsgn

--
-- --------------------------------------------------------------------------
-- |--------------------------< delete_pl_dsgn >----------------------------|
-- --------------------------------------------------------------------------
-- Description
-- This procedure deletes the ben_cwb_pl_dsgn table when no cwb data exists.
-- Input parameters
--  p_group_pl_id    : Group Plan Id
--  p_lf_evt_ocrd_dt : Life Event Occured Date
--
procedure delete_pl_dsgn(p_group_pl_id    in number
                        ,p_lf_evt_ocrd_dt in date) is

 cursor c_data_exists is
    select 'Y'
    from   ben_cwb_person_info i
    where  i.group_pl_id    = p_group_pl_id
    and    i.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;

 l_data_exists varchar2(1) := null;

begin

  open c_data_exists;
  fetch c_data_exists into l_data_exists;
  close c_data_exists;

  if l_data_exists is null then
    delete ben_cwb_pl_dsgn pl
    where  pl.group_pl_id   = p_group_pl_id
    and    pl.lf_evt_ocrd_dt = p_lf_evt_ocrd_dt;
  end if;

end delete_pl_dsgn;

end ben_cwb_pl_dsgn_pkg;


/
