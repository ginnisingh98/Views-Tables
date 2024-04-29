--------------------------------------------------------
--  DDL for Package Body BEN_EXT_PREM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_PREM" as
/* $Header: benxprem.pkb 115.5 2003/02/10 11:23:46 rpgupta ship $*/
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_prem.';  -- Global package name
--
-- procedure to initialize the globals -
-- ----------------------------------------------------------------------------
-- |---------------------< initialize_globals >-------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE initialize_globals IS
   --
   l_proc             varchar2(72) := g_package||'initialize_globals';
   --
BEGIN
  --
  hr_utility.set_location('Entering'||l_proc, 5);
  --
    ben_ext_person.g_prem_actl_prem_id := null;
    ben_ext_person.g_prem_mn_amt     := null;
    ben_ext_person.g_prem_mn_uom     := null;
    ben_ext_person.g_prem_mn_mnl_adj := null;
    ben_ext_person.g_prem_mn_cr_mnl_adj     := null;
    ben_ext_person.g_prem_mn_cramt          := null;
    ben_ext_person.g_prem_mn_costalloc_name      := null;
    ben_ext_person.g_prem_mn_costalloc_id        := null;
    ben_ext_person.g_prem_mn_costalloc_flex_01   := null;
    ben_ext_person.g_prem_mn_costalloc_flex_02   := null;
    ben_ext_person.g_prem_mn_costalloc_flex_03   := null;
    ben_ext_person.g_prem_month := null;
    ben_ext_person.g_prem_year := null;
    ben_ext_person.g_prtt_prem_by_mo_id := null;
    ben_ext_person.g_prem_last_upd_date := null ;

  hr_utility.set_location('Exiting'||l_proc, 15);
  --
End initialize_globals;

-- ----------------------------------------------------------------------------
-- |---------------------< premium_total >---------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE premium_total
    (                        p_person_id          in number,
                             p_prtt_enrt_rslt_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             P_effective_date     in date ) is
   --
   l_proc             varchar2(72) := g_package||'premium_total';
   --
 cursor c_mn_prem(l_prtt_enrt_rslt_id number) is
 select prm.val
        ,prm.cr_val
        ,prm.yr_num
        ,prm.mo_num
        ,prm.last_update_date
  from  ben_prtt_prem_by_mo_f        prm
      , ben_prtt_prem_f              ppe
  where ppe.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
  and   ppe.prtt_prem_id = prm.prtt_prem_id
  and   p_effective_date  between  prm.effective_start_date and  prm.effective_end_date
  and   p_effective_date  between  ppe.effective_start_date and  ppe.effective_end_date ;
  l_include  varchar2(1) ;
  l_tot_val     ben_prtt_prem_by_mo_f.val%type ;
  l_tot_cr_val  ben_prtt_prem_by_mo_f.cr_val%type ;
 --
 BEGIN
   --
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   -- Monthly Premium Informations
   ben_ext_person.g_enrt_mntot_prem_amt   := null ;
   ben_ext_person.g_enrt_mntot_prem_cramt := null ;

   --
   FOR prem IN c_mn_prem(p_prtt_enrt_rslt_id) LOOP
        --

       hr_utility.set_location('month'|| prem.mo_num,5381);
       hr_utility.set_location('year' || prem.yr_num,5381);
       ---validating the month and year and update_date
        ben_ext_evaluate_inclusion.evaluate_prem_incl
            (p_last_update_date => prem.last_update_date,
             p_mo_num           => prem.mo_num ,
             p_yr_num           => prem.yr_num ,
             p_effective_date   => p_effective_date,
             p_include          => l_include) ;

        if l_include = 'Y' then
           l_tot_val    := nvl(l_tot_val,0)+nvl(prem.val,0) ;
           l_tot_cr_val := nvl(l_tot_cr_val,0)+nvl(prem.cr_val,0) ;

        end if ;
     --
   END LOOP;
   ben_ext_person.g_enrt_mntot_prem_amt   := l_tot_val ;
   ben_ext_person.g_enrt_mntot_prem_cramt := l_tot_cr_val ;
   --
   hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- premium_total



--
-- ----------------------------------------------------------------------------
-- |---------------------< main >---------------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE main
    (                        p_person_id          in number,
                             p_prtt_enrt_rslt_id  in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             P_effective_date     in date ) is
   --
   l_proc             varchar2(72) := g_package||'main';
   --
 cursor c_mn_prem(l_prtt_enrt_rslt_id number) is
  select apr.actl_prem_id
        ,prm.val
        ,prm.uom
        ,prm.cr_val
        ,prm.mnl_adj_flag
        ,prm.cr_mnl_adj_flag
        ,prm.yr_num
        ,prm.mo_num
        ,prm.last_update_date
        ,csk.concatenated_segments
        ,csk.cost_allocation_keyflex_id
        ,csk.segment1
        ,csk.segment2
        ,csk.segment3
        ,apr.actl_prem_typ_cd
        ,prm.prtt_prem_by_mo_id
  from  ben_prtt_prem_by_mo_f        prm
      , ben_prtt_prem_f              ppe
      , ben_actl_prem_f              apr
      , pay_cost_allocation_keyflex  csk
  where ppe.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
  and   ppe.prtt_prem_id = prm.prtt_prem_id
  and   ppe.actl_prem_id = apr.actl_prem_id
  and   prm.cost_allocation_keyflex_id = csk.cost_allocation_keyflex_id(+)
  --and   prm.yr_num = to_number(to_char(p_effective_date,'YYYY'))
  --and   prm.mo_num = to_number(to_char(p_effective_date,'MM'))
  and   p_effective_date  between  prm.effective_start_date and  prm.effective_end_date
  and   p_effective_date  between  ppe.effective_start_date and  ppe.effective_end_date
  and   p_effective_date  between  apr.effective_start_date and  apr.effective_end_date ;
  l_include  varchar2(1) ;

 --
 BEGIN
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   -- Monthly Premium Informations
   hr_utility.set_location('result idd' || p_prtt_enrt_rslt_id,5380);
   --
   FOR prem IN c_mn_prem(p_prtt_enrt_rslt_id) LOOP
        --
        hr_utility.set_location('  prtt prrem  id' || prem.prtt_prem_by_mo_id,5380);
        initialize_globals;
          -- fetch premium information into globals
          --
          --l_include := 'Y';
          --if p_ext_crit_prfl_id is  not null then
               ben_ext_evaluate_inclusion.evaluate_prem_incl
                (p_last_update_date => prem.last_update_date,
                 p_mo_num           => prem.mo_num ,
                 p_yr_num           => prem.yr_num ,
                 p_effective_date   => p_effective_date,
                 p_include          => l_include) ;
          --end if ;
          if  l_include = 'Y' then
             --
             hr_utility.set_location(' month ' ||  prem.mo_num , 119);
             hr_utility.set_location(' year  ' ||  prem.yr_num , 119);

             ben_ext_person.g_prem_actl_prem_id := prem.actl_prem_id;
             ben_ext_person.g_prem_mn_amt := prem.val;
             ben_ext_person.g_prem_mn_uom := prem.uom;
             ben_ext_person.g_prem_month  := prem.mo_num;
             ben_ext_person.g_prem_year   := prem.yr_num;
             ben_ext_person.g_prem_mn_cramt := prem.cr_val;
             ben_ext_person.g_prem_mn_mnl_adj := prem.mnl_adj_flag;
             ben_ext_person.g_prem_mn_cr_mnl_adj := prem.cr_mnl_adj_flag;
             ben_ext_person.g_prem_mn_costalloc_name := prem.concatenated_segments;
             ben_ext_person.g_prem_mn_costalloc_id := prem.cost_allocation_keyflex_id;
             ben_ext_person.g_prem_mn_costalloc_flex_01 := prem.segment1;
             ben_ext_person.g_prem_mn_costalloc_flex_02 := prem.segment2;
             ben_ext_person.g_prem_mn_costalloc_flex_03 := prem.segment3;
             ben_ext_person.g_prem_type := prem.actl_prem_typ_cd;
             ben_ext_person.g_prtt_prem_by_mo_id := prem.prtt_prem_by_mo_id;
             ben_ext_person.g_prem_last_upd_date := prem.last_update_date;
             --
             hr_utility.set_location(' month ' ||    ben_ext_person.g_prem_month , 119);
             hr_utility.set_location(' year  ' ||  ben_ext_person.g_prem_year  , 119);
             -- format and write
             --
             ben_ext_fmt.process_ext_recs(p_ext_rslt_id       => p_ext_rslt_id,
                                     p_ext_file_id       => p_ext_file_id,
                                     p_data_typ_cd       => p_data_typ_cd,
                                     p_ext_typ_cd        => p_ext_typ_cd,
                                     p_rcd_typ_cd        => 'D',
                                     p_low_lvl_cd        => 'PR',
                                     p_person_id         => p_person_id,
                                     p_chg_evt_cd        => p_chg_evt_cd,
                                     p_business_group_id => p_business_group_id,
                                     p_effective_date    => p_effective_date
                                     );
        end if ;
     --
   END LOOP;
   --
hr_utility.set_location('Exiting'||l_proc, 15);

 END; -- main
--
END; -- package

/
