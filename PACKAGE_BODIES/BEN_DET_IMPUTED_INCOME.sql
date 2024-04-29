--------------------------------------------------------
--  DDL for Package Body BEN_DET_IMPUTED_INCOME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DET_IMPUTED_INCOME" as
/* $Header: bendeimp.pkb 120.1.12010000.4 2010/03/11 08:05:07 krupani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_det_imputed_income.';
--
/*
8716870: Imputed Income Enhancement:
If we de-enroll from a plan subject to imputed income, then before re-evaluating the imputed income rate, any
rate starting before the earliest coverage start date of plan subject to imputed income should be deleted, because
it would be corresponding to the plan that got de-enrolled. procedure delete_past_imp is used for this purpose
*/
procedure delete_past_imp(p_person_id         number,
                          p_per_in_ler_id     number,
                          p_business_group_id number,
                          p_effective_date    date,
                          p_erlst_cvg_strt    date,
                          p_imptd_incm_calc_cd varchar2)
is

--cursor to fetch imputed income plans
cursor c_imp_inc_plan(p_imptd_incm_calc_cd varchar2, p_business_group_id number, p_effective_date date)
is
    select pln.pl_id
    from   ben_pl_f pln
    where  pln.imptd_incm_calc_cd = p_imptd_incm_calc_cd
    and    pln.pl_stat_cd = 'A'
    and    pln.business_group_id = p_business_group_id
    and    p_effective_date between pln.effective_start_date and  pln.effective_end_date;

l_pl_id                 number;

-- cursor to fetch rates starting before earliest coverage start date of plan subject to imputed income
cursor c_del_imp_inc_rt(p_per_in_ler_id number)
    is
    select prv.*
    from ben_prtt_rt_val prv, ben_per_in_ler pil
    where pil.person_id = p_person_id
    and prv.per_in_ler_id = p_per_in_ler_id
    and prv.per_in_ler_id = pil.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and prv.prtt_enrt_rslt_id in (select pen.prtt_enrt_rslt_id
                                    from ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
                                    where pil.person_id = p_person_id
                                    and pen.per_in_ler_id = pil.per_in_ler_id
                                    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                                    and pen.pl_id = l_pl_id
                                    and pen.per_in_ler_id = p_per_in_ler_id
                                    and pen.prtt_enrt_rslt_stat_cd is NULL)
    and prv.rt_strt_dt < p_erlst_cvg_strt
    order by prv.rt_strt_dt desc ;

type l_imp_inc_rt_tab_type is table of c_del_imp_inc_rt%rowtype index by pls_integer;
l_imp_inc_rt_tab        l_imp_inc_rt_tab_type;

l_proc    varchar2(72) := g_package||'delete_past_imp';

BEGIN

    hr_utility.set_location(' Entering: '||l_proc , 11);

    -- get the imputed income plan
    open c_imp_inc_plan(p_imptd_incm_calc_cd, p_business_group_id, p_effective_date);
    fetch c_imp_inc_plan into l_pl_id;
    close c_imp_inc_plan;

    -- Now, we need to pick up the PRVs starting before the above earliest coverage start date of plan subject to imp inc
    hr_utility.set_location (' l_pl_id '||l_pl_id, 2);
    hr_utility.set_location (' p_per_in_ler_id '||p_per_in_ler_id, 2);

    open c_del_imp_inc_rt (p_per_in_ler_id);
    fetch c_del_imp_inc_rt bulk collect into l_imp_inc_rt_tab;
    close c_del_imp_inc_rt;

    hr_utility.set_location('l_imp_inc_rt_tab.count: '||l_imp_inc_rt_tab.count,6080);

    if l_imp_inc_rt_tab.count > 0 then
        for r in l_imp_inc_rt_tab.first..l_imp_inc_rt_tab.last
          loop
             hr_utility.set_location (' delete past rate prv', 2);
             hr_utility.set_location (' l_imp_inc_rt_tab(r).prtt_rt_val_id '||l_imp_inc_rt_tab(r).prtt_rt_val_id, 2);

             -- Nullify the prv_id on enrt_rt
             update ben_enrt_rt set prtt_rt_val_id = NULL
             where prtt_rt_val_id = nvl(l_imp_inc_rt_tab(r).prtt_rt_val_id,-1);

             hr_utility.set_location (' l_imp_inc_rt_tab(r).rt_strt_dt '||l_imp_inc_rt_tab(r).rt_strt_dt, 2);
             -- delete the rate
             ben_prtt_rt_val_api.delete_prtt_rt_val
                  (p_validate                       => false
                  ,p_prtt_rt_val_id                 => l_imp_inc_rt_tab(r).prtt_rt_val_id
                  ,p_enrt_rt_id                     => NULL
                  ,p_person_id                      => p_person_id
                  ,p_business_group_id              => p_business_group_id
                  ,p_object_version_number          => l_imp_inc_rt_tab(r).object_version_number
                  ,p_effective_date                 => l_imp_inc_rt_tab(r).rt_strt_dt);
          end loop;
    end if;
    hr_utility.set_location(' Leaving: '||l_proc , 20);
END delete_past_imp;
--
/* 8716870: procedure delete_imp_inc is addded to delete the future rate and enrollment for imputed shell plan */

procedure delete_imp_inc(p_person_id         number,
                         p_per_in_ler_id     number,
                         p_business_group_id number,
                         p_effective_date    date,
                         p_imptd_incm_calc_cd varchar2)
is

  l_proc       varchar2(60) := g_package||'.delete_imp_inc';
  l_zap                   boolean;
  l_delete                boolean;
  l_future_change         boolean;
  l_delete_next_change    boolean;
  l_mode                  varchar2(20);
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  desc_idx                pls_integer;
  l_pl_id                 number;


    --cursor to fetch imputed income plans
    cursor c_imp_inc_plan(p_imptd_incm_calc_cd varchar2, p_business_group_id number, p_effective_date date)
    is
        select pln.pl_id
        from   ben_pl_f pln
        where  pln.imptd_incm_calc_cd = p_imptd_incm_calc_cd
        and    pln.pl_stat_cd = 'A'
        and    pln.business_group_id = p_business_group_id
        and    p_effective_date between pln.effective_start_date and  pln.effective_end_date;

    -- cursor to fetch imputed income enrollments for deletion
    cursor c_del_imp_inc_enrt(p_per_in_ler_id number)
    is
    select pen.*
    from ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
    where pil.person_id = p_person_id
    and pen.per_in_ler_id = p_per_in_ler_id
    and pen.per_in_ler_id = pil.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and pen.pl_id = l_pl_id
    and pen.enrt_cvg_strt_dt > p_effective_date
    order by pen.effective_start_date, pen.enrt_cvg_strt_dt desc ;
--
    cursor c_del_imp_inc_rt(p_per_in_ler_id number)
    is
    select prv.*
    from ben_prtt_rt_val prv, ben_per_in_ler pil
    where pil.person_id = p_person_id
    and prv.per_in_ler_id = p_per_in_ler_id
    and prv.per_in_ler_id = pil.per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and prv.prtt_enrt_rslt_id in (select pen.prtt_enrt_rslt_id
                                    from ben_prtt_enrt_rslt_f pen, ben_per_in_ler pil
                                    where pil.person_id = p_person_id
                                    and pen.per_in_ler_id = pil.per_in_ler_id
                                    and pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
                                    and pen.pl_id = l_pl_id
                                    and pen.per_in_ler_id = p_per_in_ler_id
                                    and pen.prtt_enrt_rslt_stat_cd is NULL)
    and prv.rt_strt_dt > p_effective_date
    order by prv.rt_strt_dt desc ;

    type l_imp_inc_rt_tab_type is table of c_del_imp_inc_rt%rowtype index by pls_integer;
    l_imp_inc_rt_tab        l_imp_inc_rt_tab_type;
    --
    cursor c_current_epe_pen (p_prtt_enrt_rslt_id number, p_per_in_ler_id number, p_effective_date date)
    is
    select 1
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and pen.per_in_ler_id <> p_per_in_ler_id
    and p_effective_date between pen.effective_start_date and pen.effective_end_date
    and pen.enrt_cvg_thru_dt = hr_api.g_eot;

    l_current_epe_pen c_current_epe_pen%rowtype;

    --
    cursor c_chk_rslt_status (p_prtt_enrt_rslt_id number, p_per_in_ler_id number)
    is
    select prtt_enrt_rslt_id,per_in_ler_id,pl_typ_id,pl_id
    from ben_prtt_enrt_rslt_f
    where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and per_in_ler_id = p_per_in_ler_id
    and prtt_enrt_rslt_Stat_cd is NULL;

    l_rslt_status c_chk_rslt_status%rowtype;


--
   type l_imp_inc_enrt_tab_type is table of c_del_imp_inc_enrt%rowtype index by pls_integer;
   l_imp_inc_enrt_tab        l_imp_inc_enrt_tab_type;
   l_imp_inc_enrt_tab_prior  l_imp_inc_enrt_tab_type;
   l_delrec                  c_del_imp_inc_enrt%rowtype;
--
    cursor c_del_imp_inc_enrt_prior(p_prtt_enrt_rslt_id number,
                                    p_effective_date    date)
    is
    select pen.*
    from ben_prtt_enrt_rslt_f pen
    where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and p_effective_date between pen.effective_start_date and pen.effective_end_date
    and pen.prtt_enrt_rslt_stat_cd is NULL
    order by pen.prtt_enrt_rslt_id, pen.effective_start_date desc;
--
    cursor  c_corr_result_exist (l_per_in_ler_id     number ,
                                 l_prtt_enrt_rslt_id number ) is
    select lcnr.*
    from BEN_LE_CLSN_N_RSTR  lcnr
    where lcnr.bkup_tbl_id          = l_prtt_enrt_rslt_id
      and lcnr.BKUP_TBL_TYP_CD      = 'BEN_PRTT_ENRT_RSLT_F_CORR'
      and lcnr.enrt_cvg_thru_dt     = hr_api.g_eot
      and  lcnr.Per_in_ler_ended_id = l_per_in_ler_id;

     l_corr_pen_rec c_corr_result_exist%rowtype;
--
begin

    hr_utility.set_location('Entering '||l_proc,6054);
    hr_utility.set_location('p_effective_date: '||p_effective_date,6062);
    hr_utility.set_location('p_imptd_incm_calc_cd: '||p_imptd_incm_calc_cd,6063);
    hr_utility.set_location('p_per_in_ler_id: '||p_per_in_ler_id,6064);


    -- get the imputed income plan
    open c_imp_inc_plan(p_imptd_incm_calc_cd, p_business_group_id, p_effective_date);
    fetch c_imp_inc_plan into l_pl_id;
    close c_imp_inc_plan;

    --delete rates first
    hr_utility.set_location (' l_pl_id '||l_pl_id, 2);

    open c_del_imp_inc_rt (p_per_in_ler_id);
    fetch c_del_imp_inc_rt bulk collect into l_imp_inc_rt_tab;
    close c_del_imp_inc_rt;

    hr_utility.set_location('l_imp_inc_rt_tab.count: '||l_imp_inc_rt_tab.count,6080);

    if l_imp_inc_rt_tab.count > 0 then
       for r in l_imp_inc_rt_tab.first..l_imp_inc_rt_tab.last
          loop
	     hr_utility.set_location (' delete future rate prv', 2);
	     hr_utility.set_location (' l_imp_inc_rt_tab(r).prtt_rt_val_id '||l_imp_inc_rt_tab(r).prtt_rt_val_id, 2);

             -- Nullify the prv_id on enrt_rt
             update ben_enrt_rt set prtt_rt_val_id = NULL
             where prtt_rt_val_id = nvl(l_imp_inc_rt_tab(r).prtt_rt_val_id,-1);

             hr_utility.set_location (' l_imp_inc_rt_tab(r).rt_strt_dt '||l_imp_inc_rt_tab(r).rt_strt_dt, 2);
                -- delete the rate
             ben_prtt_rt_val_api.delete_prtt_rt_val
                  (p_validate                       => false
                  ,p_prtt_rt_val_id                 => l_imp_inc_rt_tab(r).prtt_rt_val_id
                  ,p_enrt_rt_id                     => NULL
                  ,p_person_id                      => p_person_id
                  ,p_business_group_id              => p_business_group_id
                  ,p_object_version_number          => l_imp_inc_rt_tab(r).object_version_number
                  ,p_effective_date                 => l_imp_inc_rt_tab(r).rt_strt_dt);
          end loop;
    end if;


    -- delete the existing imputed income enrollments
    open c_del_imp_inc_enrt (p_per_in_ler_id);
    fetch c_del_imp_inc_enrt bulk collect into l_imp_inc_enrt_tab;
    close c_del_imp_inc_enrt;

    hr_utility.set_location('l_imp_inc_enrt_tab.count: '||l_imp_inc_enrt_tab.count,6080);

    if l_imp_inc_enrt_tab.count > 0 then
       for r in l_imp_inc_enrt_tab.first..l_imp_inc_enrt_tab.last
          loop
             --
             --Need to see if the imputed income enrollments existed 1 day prior, since we need the
             --previous record in order to delete future records.
             --
             hr_utility.set_location (' delete imputed enrollment', 2);
             hr_utility.set_location (' l_imp_inc_enrt_tab(r).prtt_enrt_rslt_id '||l_imp_inc_enrt_tab(r).prtt_enrt_rslt_id, 3);
             hr_utility.set_location (' l_imp_inc_enrt_tab(r).effective_start_date '||l_imp_inc_enrt_tab(r).effective_start_date, 3);

             open c_del_imp_inc_enrt_prior(p_prtt_enrt_rslt_id  => l_imp_inc_enrt_tab(r).prtt_enrt_rslt_id,
                                           p_effective_date     => l_imp_inc_enrt_tab(r).effective_start_date - 1);
             fetch c_del_imp_inc_enrt_prior bulk collect into l_imp_inc_enrt_tab_prior;
             close c_del_imp_inc_enrt_prior;


             hr_utility.set_location('l_imp_inc_enrt_tab.count '||l_imp_inc_enrt_tab.count,6685);


             if l_imp_inc_enrt_tab_prior.count > 0 then
                --
                hr_utility.set_location('Prior enrollment exists: ',6685);
                l_zap                := null;
                l_delete             := null;
                l_future_change      := null;
                l_delete_next_change := null;
                l_mode               := null;

                dt_api.find_dt_del_modes
                  (p_effective_date      => l_imp_inc_enrt_tab_prior(l_imp_inc_enrt_tab_prior.first).effective_start_date,
                   p_base_table_name     => 'BEN_PRTT_ENRT_RSLT_F',
                   p_base_key_column     => 'PRTT_ENRT_RSLT_ID',
                   p_base_key_value      => l_imp_inc_enrt_tab_prior(l_imp_inc_enrt_tab_prior.first).prtt_enrt_rslt_id,
                   p_zap                 => l_zap,
                   p_delete              => l_delete,
                   p_future_change       => l_future_change,
                   p_delete_next_change  => l_delete_next_change);

                if l_future_change  then
                  l_mode := hr_api.g_future_change;
                  --
                elsif l_delete_next_change then
                  --
                  l_mode := hr_api.g_delete_next_change;

                end if;
                hr_utility.set_location (' l_mode '||l_mode, 5);
                l_delrec  := l_imp_inc_enrt_tab_prior(l_imp_inc_enrt_tab_prior.first);
                l_imp_inc_enrt_tab_prior.delete;

             else
                hr_utility.set_location('Else - no prior imputed enrollment exists ',6685);
                l_delrec  := l_imp_inc_enrt_tab(r);
                l_mode := hr_api.g_zap;
             end if;
             --


             hr_utility.set_location('----------------------------------------------------------',6690);
             hr_utility.set_location('l_mode: '||l_mode,5363);
             hr_utility.set_location('l_delrec.prtt_enrt_rslt_id: '||l_delrec.prtt_enrt_rslt_id,5363);
             hr_utility.set_location('l_delrec.effective_start_date: '||l_delrec.effective_start_date,5363);
             hr_utility.set_location('l_delrec.effective_end_date: '||l_delrec.effective_end_date,5363);


             --
             l_object_version_number := l_delrec.object_version_number;


             if l_mode = hr_api.g_zap then
                -- check if corr pen rec exists, if yes no zap, just update the corr rec pil_id and ler_id
                open  c_corr_result_exist (l_imp_inc_enrt_tab(r).per_in_ler_id,                                                  l_imp_inc_enrt_tab(r).prtt_enrt_rslt_id);
                fetch c_corr_result_exist into l_corr_pen_rec;

                if c_corr_result_exist%found then

                   hr_utility.set_location(' corr pen rec exists, no zap, upd prev pil_id on pen',6695);

                   -- as corr rec exists, upd the ler_id, pil_id of corr rec on the rslt
                   update ben_prtt_enrt_rslt_f
                   set    ler_id = l_corr_pen_rec.ler_id,
                          per_in_ler_id = l_corr_pen_rec.per_in_ler_id
                   where prtt_enrt_rslt_id = l_corr_pen_rec.bkup_tbl_id
                   and effective_start_date = l_corr_pen_rec.effective_start_date
                   and exists (select 1
                                from ben_per_in_ler
                               where per_in_ler_id = l_corr_pen_rec.per_in_ler_id
                                 and per_in_ler_stat_cd not in ('BCKDT','VOIDD'))
                   and business_group_id = p_business_group_id
                   and person_id = l_corr_pen_rec.person_id;

                   if sql%rowcount > 0 then
                      delete from BEN_LE_CLSN_N_RSTR
    		       where bkup_tbl_id       = nvl(l_corr_pen_rec.bkup_tbl_id,-1)
    		         and Per_in_ler_ended_id = nvl(l_imp_inc_enrt_tab(r).per_in_ler_id,-1)
                         and BKUP_TBL_TYP_CD   = 'BEN_PRTT_ENRT_RSLT_F_CORR';
                   end if;

                   close c_corr_result_exist;
                else
                   close c_corr_result_exist;
                    -- no corr rec exists, so ZAP the result
                   hr_utility.set_location (' ZAP l_delrec.prtt_enrt_rslt_id '||l_delrec.prtt_enrt_rslt_id, 5);
                   ben_prtt_enrt_result_api.delete_prtt_enrt_result
        	             (p_validate                => false,
        	              p_prtt_enrt_rslt_id       => l_delrec.prtt_enrt_rslt_id,
        		      p_effective_start_date    => l_effective_start_date,
        		      p_effective_end_date      => l_effective_end_date,
        		      p_object_version_number   => l_object_version_number,
        		      p_effective_date          => l_delrec.effective_start_date,
        		      p_datetrack_mode          => l_mode,
        		      p_multi_row_validate      => FALSE);
                end if;

             else
                hr_utility.set_location('Deleting enrollment: '||l_delrec.prtt_enrt_rslt_id,6695);

              	ben_prtt_enrt_result_api.delete_prtt_enrt_result
        	             (p_validate                => false,
        	              p_prtt_enrt_rslt_id       => l_delrec.prtt_enrt_rslt_id,
        	              p_effective_start_date    => l_effective_start_date,
        	              p_effective_end_date      => l_effective_end_date,
        	              p_object_version_number   => l_object_version_number,
        	              p_effective_date          => l_delrec.effective_start_date,
        	              p_datetrack_mode          => l_mode,
        	              p_multi_row_validate      => FALSE);
    	     end if;
             --
             l_delrec := null;
          end loop;
    end if;

    hr_utility.set_location('Leaving '||l_proc,6054);

end delete_imp_inc;


--
procedure p_comp_imp_inc_internal
  (p_person_id                      in  number
  ,p_enrt_mthd_cd                   in  varchar2
  ,p_business_group_id              in  number
  ,p_per_in_ler_id                  in  number
  ,p_effective_date                 in  date
  ,p_subj_to_imptd_incm_typ_cd      in  varchar2
  ,p_imptd_incm_calc_cd             in  varchar2
  ,p_validate                       in  boolean  default false
  ,p_no_choice_flag                 in  boolean  default false
  ,p_imp_cvg_strt_dt                in  date     default NULL)    -- 8716870
  is
  --
  cursor c_pil is
    select pil.lf_evt_ocrd_dt,
           pil.ler_id
    from   ben_per_in_ler pil
    where  pil.per_in_ler_id = p_per_in_ler_id;
  --
  l_pil_rec    c_pil%rowtype;
  --
  -- Select the total benefit amount to calculate the
  -- imputed income.
  l_max_le_eff_date date := null;
  -- post tax employee contribution  2897063

  cursor c_post_tax_contrib(p_eot in date) is
     select prv.rt_val , prv.tx_typ_cd,prv.acty_typ_cd
     from   ben_prtt_enrt_rslt_f pen,
            ben_prtt_rt_val prv,
            ben_acty_base_rt_f abr,
            ben_pl_f pln,
            ben_per_in_ler pil
     where  pen.person_id = p_person_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    pen.enrt_cvg_thru_dt = p_eot
     and    pen.business_group_id = p_business_group_id
     and    pen.pl_id = pln.pl_id
     and    pen.sspndd_flag = 'N'
     and    pln.subj_to_imptd_incm_typ_cd =p_subj_to_imptd_incm_typ_cd
     and    pln.pl_stat_cd = 'A'
     and    pln.business_group_id = p_business_group_id
     and    prv.PRTT_RT_VAL_STAT_CD is null
     --and    prv.per_in_ler_id = pen.per_in_ler_id
     and    prv.Rt_end_dt  =   p_eot
     and    prv.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     and    p_effective_date between pln.effective_start_date
            and pln.effective_end_date
     and    prv.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     AND    pen.effective_end_date=hr_api.g_eot
     and    l_max_le_eff_date >= least(pen.effective_start_date,pen.enrt_cvg_strt_dt )
     and   abr.acty_base_rt_id  = prv.acty_base_rt_id
     and   abr.subj_to_imptd_incm_flag  = 'Y'
     and   l_max_le_eff_date   between  abr.effective_start_date and abr.effective_end_date ;

   l_post_tax_rec c_post_tax_contrib%rowtype  ;
   l_post_tax_err_found  varchar2(1) :=  'N'  ;
   l_post_tax_amount    number      := 0 ;
  --
  -- 8716870: commented existing c_ben_amt
  /*
     cursor c_ben_amt(p_highly_comp in varchar2,p_eot in date) is
     select sum(pen.bnft_amt)
     from   ben_prtt_enrt_rslt_f pen,
	    ben_pl_f pln,
            ben_per_in_ler pil
     where  pen.person_id = p_person_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    pen.enrt_cvg_thru_dt = p_eot
     and    pen.business_group_id = p_business_group_id
     and    pen.pl_id = pln.pl_id
     and    pen.sspndd_flag = 'N'
     and    pln.subj_to_imptd_incm_typ_cd =p_subj_to_imptd_incm_typ_cd
     and    pln.pl_stat_cd = 'A'
     and    pln.business_group_id = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     and    p_effective_date between pln.effective_start_date
	    and pln.effective_end_date
-- Bug # - 1675410 - If the coverage start date is after life event occurred date,
-- the above condition does not select result row. As much as per_in_ler_id is
-- existing in pen, it is better to join pil with pen  by per_in_ler_id
     and    pil.per_in_ler_id = pen.per_in_ler_id
     AND    pen.effective_end_date=hr_api.g_eot
 -- Bug 1884964 to restrict pen records from different set
     and    l_max_le_eff_date >= least(pen.effective_start_date,pen.enrt_cvg_strt_dt )
     and exists
           (select 'x'
              from ben_elig_per_f pep
             where pep.pl_id=pen.pl_id
               and nvl(pep.pgm_id,-1)=nvl(pen.pgm_id,-1)
               and pep.person_id=pen.person_id
               and pep.per_in_ler_id = pil.per_in_ler_id
               and pep.pl_hghly_compd_flag = p_highly_comp
               and pep.prtn_strt_dt <= greatest(pen.enrt_cvg_strt_dt,l_max_le_eff_date)
               and pep.business_group_id = pen.business_group_id);
     --
     -- Bug 1312906 : check the person is highly compensated
     -- on enrt_cvg_start date.
     --
--     and  ((pen.enrt_cvg_strt_dt between pep.PRTN_STRT_DT
--           and nvl(pep.PRTN_END_DT,p_eot)
--	   and
--           pep.effective_end_date = p_eot)
--           or
--	  (pep.PRTN_STRT_DT >= pen.enrt_cvg_strt_dt
--	   and
--	   pep.PRTN_STRT_DT =
--             (select min(pep2.PRTN_STRT_DT)
--	      from   ben_elig_per_f pep2
--              where  pep.pl_id=pep2.pl_id
--              and    nvl(pep.pgm_id,-1)=nvl(pep2.pgm_id,-1)
--              and    pep.business_group_id = pep2.business_group_id)
--           and
--           pep.effective_start_date =
--             (select min(pep2.effective_start_date)
--              from   ben_elig_per_f pep2
--              where  pep.pl_id=pep2.pl_id
--              and    pep.prtn_strt_dt=pep2.prtn_strt_dt
--              and    nvl(pep.pgm_id,-1)=nvl(pep2.pgm_id,-1)
--              and    pep.business_group_id = pep2.business_group_id)));

*/

     -- 8716870: Imp Inc Enh : Modified cursor c_ben_amt
     cursor c_ben_amt(p_highly_comp in varchar2,p_cvg_strt_dt date) is
     select sum(pen.bnft_amt)
     from   ben_prtt_enrt_rslt_f pen,
	    ben_pl_f pln,
            ben_per_in_ler pil
     where  pen.person_id = p_person_id
     and    pen.prtt_enrt_rslt_stat_cd is null
--     and    pen.enrt_cvg_thru_dt = p_eot
     and    pen.business_group_id = p_business_group_id
     and    pen.pl_id = pln.pl_id
     and    pen.sspndd_flag = 'N'
     and    pln.subj_to_imptd_incm_typ_cd =p_subj_to_imptd_incm_typ_cd
     and    pln.pl_stat_cd = 'A'
     and    pln.business_group_id = p_business_group_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
     and    p_imp_cvg_strt_dt between pln.effective_start_date
	    and pln.effective_end_date      -- Bug 9436910
-- Bug # - 1675410 - If the coverage start date is after life event occurred date,
-- the above condition does not select result row. As much as per_in_ler_id is
-- existing in pen, it is better to join pil with pen  by per_in_ler_id
     and    pil.per_in_ler_id = pen.per_in_ler_id
     AND    pen.effective_end_date=hr_api.g_eot
 -- Bug 1884964 to restrict pen records from different set
     and    l_max_le_eff_date >= least(pen.effective_start_date,pen.enrt_cvg_strt_dt )
     and    p_cvg_strt_dt between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
     and exists
           (select 'x'
              from ben_elig_per_f pep
             where pep.pl_id=pen.pl_id
               and nvl(pep.pgm_id,-1)=nvl(pen.pgm_id,-1)
               and pep.person_id=pen.person_id
               and pep.per_in_ler_id = pil.per_in_ler_id
               and pep.pl_hghly_compd_flag = p_highly_comp
               and pep.prtn_strt_dt <= greatest(pen.enrt_cvg_strt_dt,l_max_le_eff_date)
               and pep.business_group_id = pen.business_group_id);

     --
     -- Bug 1312906 : check the person is highly compensated
     -- on enrt_cvg_start date.
     --
--     and  ((pen.enrt_cvg_strt_dt between pep.PRTN_STRT_DT
--           and nvl(pep.PRTN_END_DT,p_eot)
--	   and
--           pep.effective_end_date = p_eot)
--           or
--	  (pep.PRTN_STRT_DT >= pen.enrt_cvg_strt_dt
--	   and
--	   pep.PRTN_STRT_DT =
--             (select min(pep2.PRTN_STRT_DT)
--	      from   ben_elig_per_f pep2
--              where  pep.pl_id=pep2.pl_id
--              and    nvl(pep.pgm_id,-1)=nvl(pep2.pgm_id,-1)
--              and    pep.business_group_id = pep2.business_group_id)
--           and
--           pep.effective_start_date =
--             (select min(pep2.effective_start_date)
--              from   ben_elig_per_f pep2
--              where  pep.pl_id=pep2.pl_id
--              and    pep.prtn_strt_dt=pep2.prtn_strt_dt
--              and    nvl(pep.pgm_id,-1)=nvl(pep2.pgm_id,-1)
--              and    pep.business_group_id = pep2.business_group_id)));
    --


  cursor c_imp_inc_plan is
    select pln.pl_id,
           pln.pl_cd
    from   ben_pl_f pln
    where  pln.imptd_incm_calc_cd = p_imptd_incm_calc_cd
    and    pln.pl_stat_cd = 'A'
    and    pln.business_group_id = p_business_group_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  cursor c_enrt_rslt(p_pl_id in number) is
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pen.pl_id,
           pen.oipl_id,
           pen.pgm_id,
           pen.effective_start_date,   -- 8716870
           pen.pl_typ_id
    from   ben_prtt_enrt_rslt_f pen
    where  pen.business_group_id = p_business_group_id and
           pen.prtt_enrt_rslt_stat_cd is null and
          pen.pl_id = p_pl_id and
          pen.oipl_id is null and
          pen.person_id = p_person_id
     AND    l_pil_rec.lf_evt_ocrd_dt between
            pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
     AND    pen.effective_end_date=hr_api.g_eot;
  --
  cursor c_imp_inc_plan2 (p_enrt_cvg_strt_dt date) is -- 8716870
    select pen.prtt_enrt_rslt_id,
           pen.object_version_number,
           pen.pl_id,
           pen.oipl_id,
           pen.pgm_id,
           pen.effective_start_date,                 -- 8716870
           pen.pl_typ_id
    from   ben_pl_f pln,
           ben_prtt_enrt_rslt_f pen
    where  pln.imptd_incm_calc_cd = p_imptd_incm_calc_cd
    and    pln.pl_stat_cd = 'A'
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date
    and    pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.pl_id = pln.pl_id
    and    pen.oipl_id is null
    and    pen.person_id = p_person_id
/* 8716870 code changes */
--  and    pen.effective_end_date = hr_api.g_eot
--  and    pen.enrt_cvg_thru_dt = hr_api.g_eot;
    and p_enrt_cvg_strt_dt between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and pen.effective_end_date = hr_api.g_eot;
/* 8716870 code changes */
  --
  cursor c_elctbl_chc(p_pl_id in number) is
    select epe.ELIG_PER_ELCTBL_CHC_ID,
	   epe.PL_ID,
	   epe.OIPL_ID,
	   epe.PGM_ID,
	   epe.PL_TYP_ID,
	   epe.PER_IN_LER_ID,
           nvl(epe.prtt_enrt_rslt_id,-1) prtt_enrt_rslt_id
           from   ben_elig_per_elctbl_chc epe
           where  epe.per_in_ler_id = p_per_in_ler_id
           and    epe.business_group_id = p_business_group_id
           and    epe.pl_id = p_pl_id
           and    epe.oipl_id is null
           order by prtt_enrt_rslt_id desc;
     --
  cursor c_ecr_prv(p_elig_per_elctbl_chc_id in number) is
    select ecr.enrt_rt_id,
           ecr.acty_base_rt_id,
           ecr.prtt_rt_val_id
    from ben_enrt_rt ecr
    where  ecr.elig_per_elctbl_chc_id = p_elig_per_elctbl_chc_id and
           ecr.business_group_id = p_business_group_id
           and ecr.rt_usg_cd = 'IMPTDINC';
  --
  --
  cursor c_prtt_rt(p_prtt_enrt_rslt_id in number) is
    select prv.prtt_rt_val_id,
           prv.acty_base_rt_id,
           prv.rt_ovridn_flag,     -- Bug 2200139 Override changes
           prv.rt_ovridn_thru_dt   -- Bug 2200139 Override changes
    from   ben_prtt_rt_val prv
    where  prv.business_group_id          = p_business_group_id
    and    prv.prtt_enrt_rslt_id          = p_prtt_enrt_rslt_id
    and    prv.prtt_rt_val_stat_cd is null
    and    prv.rt_end_dt  = hr_api.g_eot;
  --
  cursor c_pgm_enrt_rslt_exists(p_pgm_id in number) is
    select null
    from   ben_prtt_enrt_rslt_f pen,
           ben_pl_f pln
    where  pen.business_group_id = p_business_group_id
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.pgm_id = p_pgm_id
    and    pen.person_id = p_person_id
    and    pen.enrt_cvg_thru_dt =  hr_api.g_eot
    and    pen.effective_end_date= hr_api.g_eot
    and    pln.pl_id = pen.pl_id
    and    pln.subj_to_imptd_incm_typ_cd =p_subj_to_imptd_incm_typ_cd
    and    pln.pl_stat_cd = 'A'
    and    pln.business_group_id = p_business_group_id
    and    p_effective_date between pln.effective_start_date
    and    pln.effective_end_date;

   cursor c_chk_rate_avlbl(p_plan_id in number) is
     select acty_base_rt_id
     from    ben_acty_base_rt_f abr
     where   abr.pl_id=p_plan_id
     and     p_effective_date between abr.effective_start_date  and abr.effective_end_date
     and     abr.business_group_id = p_business_group_id ;


   cursor c_chk_calc (p_abr_id number )  is
     select b.mlt_cd  from
        ben_acty_vrbl_rt_f a   ,
        ben_vrbl_rt_prfl_f b
        where
             a.acty_base_rt_id = p_abr_id
        and  a.vrbl_rt_prfl_id  = b.vrbl_rt_prfl_id
        and a.business_group_id  =p_business_group_id
        and p_effective_date between a.effective_start_date and a.effective_end_date
        and p_effective_date between b.effective_start_date and b.effective_end_date
        and  ( mlt_cd  not in ('FLFX' , 'RL') or  VRBL_RT_TRTMT_CD <> 'RPLC' )
        ;

    l_mlt_cd   ben_vrbl_rt_prfl_f.mlt_cd%type ;

   -- 8716870 code change begins
    -- cursor used to determine l_cvg_strt_dt
    cursor c_pil_popl
    is
    select pil.lf_evt_ocrd_dt, popl.elcns_made_dt, popl.dflt_asnd_dt, popl.dflt_enrt_dt
    from ben_per_in_ler pil, ben_pil_elctbl_chc_popl popl
    where popl.per_in_ler_id (+) = pil.per_in_ler_id
    and pil.per_in_ler_id = p_per_in_ler_id;

    l_pil_popl c_pil_popl%rowtype;

    --
    -- cursor c_pil_epe_imp_inc is called before calling determine dates
    cursor c_pil_epe_imp_inc
    is
    select epe.ELIG_PER_ELCTBL_CHC_ID,
           epe.pgm_id,
           epe.pl_typ_id,
           epe.pl_id,
           epe.fonm_cvg_strt_dt
    from ben_elig_per_elctbl_chc epe,
        ben_per_in_ler pil,
        ben_pl_f pl
    where epe.PER_IN_LER_ID = p_per_in_ler_id
    and pil.per_in_ler_id = p_per_in_ler_id
    and pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD')
    and epe.pl_id = pl.pl_id
    and p_effective_date between pl.effective_start_date and pl.effective_end_date
    and pl.imptd_incm_calc_cd = p_imptd_incm_calc_cd;


    l_pil_epe_imp_inc c_pil_epe_imp_inc%rowtype;

    --
    l_eff_dt date;
    l_cvg_strt_dt date;
    l_enrt_cvg_strt_dt_cd VARCHAR2(30);
    l_enrt_cvg_strt_dt_rl NUMBER;
    l_enrt_cvg_end_dt     DATE;
    l_enrt_cvg_end_dt_cd  VARCHAR2(30);
    l_enrt_cvg_end_dt_rl  NUMBER;
    l_rt_end_dt           DATE;
    l_rt_end_dt_cd        VARCHAR2(30);
    l_rt_end_dt_rl        NUMBER;
    l_enrt_cvg_thru_dt    DATE;

   -- 8716870 code change ends

--
  l_rt_ovridn_rec                c_prtt_rt%rowtype;
  l_plan_rec                     c_imp_inc_plan%rowtype;
  l_enrt_rslt_rec                c_enrt_rslt%rowtype;
  l_elctbl_chc_rec               c_elctbl_chc%rowtype;
  l_elctbl_chc_next_rec          c_elctbl_chc%rowtype;
  l_ecr_prv_rec                  c_ecr_prv%rowtype;
  l_prtt_rt_rec                  c_prtt_rt%rowtype;
  l_tot_ben_amt                  number;
  l_hgh_cmp_amt                  number;
  l_nor_cmp_amt                  number;
  l_tot_sub_to_imp_inc           number  := 0;
  l_imp_inc                      number;
  l_std_imp_inc_ded number;
  --
  l_mn_elcn_value                number;
  l_mx_elcn_value                number;
  l_ann_val                      ben_enrt_rt.ann_val%TYPE;
  l_ann_mn_elcn_val              ben_enrt_rt.ann_mn_elcn_val%TYPE;
  l_ann_mx_elcn_val              ben_enrt_rt.ann_mx_elcn_val%TYPE;
  l_cmcd_val                     ben_enrt_rt.cmcd_val%TYPE;
  l_cmcd_mn_elcn_val             ben_enrt_rt.cmcd_mn_elcn_val%TYPE;
  l_cmcd_mx_elcn_val             ben_enrt_rt.cmcd_mx_elcn_val%TYPE;
  l_cmcd_acty_ref_perd_cd        ben_enrt_rt.cmcd_acty_ref_perd_cd%TYPE;
  l_actl_prem_id                 ben_enrt_rt.actl_prem_id%TYPE;
  l_cvg_calc_amt_mthd_id         ben_enrt_rt.CVG_AMT_CALC_MTHD_ID%TYPE;
  l_bnft_rt_typ_cd               ben_enrt_rt.bnft_rt_typ_cd%TYPE;
  l_rt_typ_cd                    ben_enrt_rt.rt_typ_cd%TYPE;
  l_rt_mlt_cd                    ben_enrt_rt.rt_mlt_cd%TYPE;
  l_comp_lvl_fctr_id             ben_enrt_rt.comp_lvl_fctr_id%TYPE;
  l_entr_ann_val_flag            ben_enrt_rt.entr_ann_val_flag%TYPE;
  l_ptd_comp_lvl_fctr_id         ben_enrt_rt.ptd_comp_lvl_fctr_id%TYPE;
  l_clm_comp_lvl_fctr_id         ben_enrt_rt.clm_comp_lvl_fctr_id%TYPE;
  l_ann_dflt_val                 ben_enrt_rt.ann_dflt_val%TYPE;
  l_rt_strt_dt                   ben_enrt_rt.rt_strt_dt%TYPE;
  l_rt_strt_dt_rl                ben_enrt_rt.rt_strt_dt_rl%TYPE;
  l_rt_strt_dt_cd                ben_enrt_rt.rt_strt_dt_cd%TYPE;
  l_dsply_mn_elcn_val            ben_enrt_rt.dsply_mn_elcn_val%TYPE;
  l_dsply_mx_elcn_val            ben_enrt_rt.dsply_mx_elcn_val%TYPE;
  l_incrt_val                    number;
  l_dflt_elcn_val                number;
  l_acty_ref_perd_cd             varchar2(100);
  l_tx_typ_cd                    varchar2(100);
  l_acty_typ_cd                  varchar2(100);
  l_asgn_on_enrt_flag            varchar2(100);
  l_use_to_calc_net_flx_cr_flag  varchar2(100);
  l_uom                          varchar2(100);
  --
  l_prtt_enrt_rslt_id            ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
  l_prtt_rt_val_id               ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id1              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id2              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id3              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id4              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id5              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id6              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id7              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id8              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id9              ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_prtt_rt_val_id10             ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_effective_start_date         ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
  l_effective_end_date           ben_prtt_enrt_rslt_f.effective_end_date%TYPE;
  l_object_version_number        ben_prtt_enrt_rslt_f.object_version_number%TYPE;
  l_nnmntry_uom                  varchar2(100);
  l_entr_val_at_enrt_flag         varchar2(30);
  l_dsply_on_enrt_flag            varchar2(30);
  l_dpnt_actn_warning             boolean;
  l_ctfn_actn_warning             boolean;
  l_bnf_actn_warning              boolean;
  l_prtt_enrt_interim_id          number;
  L_SUSPEND_FLAG                  varchar2(30);
  l_datetrack_mode                varchar2(30) :=  'INSERT';
  l_RT_USG_CD                     VARCHAR2(30);
  l_BNFT_PRVDR_POOL_ID            NUMBER;
  --
  l_proc    varchar2(72) := g_package||'p_comp_imp_inc_internal';
  --
  Type rate_id_type   is table of ben_enrt_rt.enrt_rt_id%type index by BINARY_INTEGER;
  Type rate_val_type  is table of ben_enrt_rt.val%type index by BINARY_INTEGER;
  --
  rate_id_list                    rate_id_type;
  rate_val_list                   rate_val_type;
  l_count                         number;
  l_result_exists_flag            boolean := FALSE;
  l_choice_exists_flag            boolean := false;
  l_effective_date                date null ;
  l_pp_in_yr_used_num             number;
  l_ordr_num			  number;
  l_iss_val                       number;
  l_pgm_enrt_rslt_exists          varchar2(1);
  l_prflvalue                     varchar2(4000) ;
  l_string                         varchar2(4000) ;
  l_acty_base_rt_id		  number;
  --
  /* 8716870: Imputed Income Enhancement */
  --if the Imputed income enrollment row is in future compared to the effective date use
  --effective date associated with the enrollment row rather than one being passed to the api.
  l_eff_date_for_enrt             date:=null;
  p_global_env_rec                ben_env_object.g_global_env_rec_type;
/* 8716870: Imputed Income Enhancement */

begin
  --
  hr_utility.set_location(' Entering: '||l_proc , 10);
  --
  open  c_pil;
    --
    fetch c_pil into l_pil_rec;
    --
  close c_pil;
  --
  l_max_le_eff_date := greatest(l_pil_rec.lf_evt_ocrd_dt ,p_imp_cvg_strt_dt);      -- Bug 9436910
  hr_utility.set_location (' l_max_le_eff_date '||l_max_le_eff_date , 8.0);
  --
  l_eff_dt:= NULL;
  l_cvg_strt_dt := NULL;
  open c_pil_epe_imp_inc;
  fetch c_pil_epe_imp_inc into l_pil_epe_imp_inc;
    if c_pil_epe_imp_inc%found then
      close c_pil_epe_imp_inc;
      -- determine the enrt_cvg_strt_dt in the context of the life event
      ben_determine_date.rate_and_coverage_dates
         (p_which_dates_cd         => 'B'
         ,p_date_mandatory_flag    => 'N'
         ,p_compute_dates_flag     => 'Y'
         ,p_elig_per_elctbl_chc_id => l_pil_epe_imp_inc.elig_per_elctbl_chc_id
         ,p_business_group_id      => p_business_group_id
         ,P_PER_IN_LER_ID          => p_per_in_ler_id
         ,P_PERSON_ID              => p_person_id
         ,P_PGM_ID                 => l_pil_epe_imp_inc.pgm_id
         ,P_PL_ID                  => l_pil_epe_imp_inc.pl_id
--       ,P_OIPL_ID                => p_oipl_id
         ,p_enrt_cvg_strt_dt       => l_cvg_strt_dt
         ,p_enrt_cvg_strt_dt_cd    => l_enrt_cvg_strt_dt_cd
         ,p_enrt_cvg_strt_dt_rl    => l_enrt_cvg_strt_dt_rl
         ,p_rt_strt_dt             => l_rt_strt_dt
         ,p_rt_strt_dt_cd          => l_rt_strt_dt_cd
         ,p_rt_strt_dt_rl          => l_rt_strt_dt_rl
         ,p_enrt_cvg_end_dt        => l_enrt_cvg_end_dt
         ,p_enrt_cvg_end_dt_cd     => l_enrt_cvg_end_dt_cd
         ,p_enrt_cvg_end_dt_rl     => l_enrt_cvg_end_dt_rl
         ,p_rt_end_dt              => l_rt_end_dt
         ,p_rt_end_dt_cd           => l_rt_end_dt_cd
         ,p_rt_end_dt_rl           => l_rt_end_dt_rl
         ,p_effective_date         => p_effective_date
         );
    else
      close c_pil_epe_imp_inc;
    end if;

    -- 8716870
    hr_utility.set_location (' p_imp_cvg_strt_dt '||p_imp_cvg_strt_dt, 2);
    hr_utility.set_location (' l_cvg_strt_dt '||l_cvg_strt_dt, 2);

    if p_imp_cvg_strt_dt is not null and p_imp_cvg_strt_dt > l_cvg_strt_dt then
      hr_utility.set_location (' re-setting l_cvg_strt_dt ', 2);
      l_cvg_strt_dt := p_imp_cvg_strt_dt;
      l_rt_strt_dt  := p_imp_cvg_strt_dt;
    end if;

    ben_manage_life_events.fonm := 'Y';
    ben_manage_life_events.g_fonm_cvg_strt_dt := l_cvg_strt_dt;
    ben_manage_life_events.g_fonm_rt_strt_dt := l_rt_strt_dt;

    -- 8716870
    hr_utility.set_location (' calling  delete_imp_inc with effective date as l_rt_strt_dt ', 2);
    delete_imp_inc(p_person_id          => p_person_id,
                   p_per_in_ler_id      => p_per_in_ler_id,
                   p_business_group_id  => p_business_group_id,
                   p_effective_date     => nvl(l_rt_strt_dt,l_cvg_strt_dt),
                   p_imptd_incm_calc_cd => p_subj_to_imptd_incm_typ_cd);

    open c_pil_popl;
    fetch c_pil_popl into l_pil_popl;

    if c_pil_popl%found then
      l_eff_dt := nvl(nvl(l_pil_popl.elcns_made_dt, nvl(l_pil_popl.dflt_asnd_dt,l_pil_popl.dflt_enrt_dt)),l_pil_popl.lf_evt_ocrd_dt);
      close c_pil_popl;
    else
      close c_pil_popl;
    end if;

    l_cvg_strt_dt := nvl(nvl(l_cvg_strt_dt, l_pil_epe_imp_inc.fonm_cvg_strt_dt),l_eff_dt);

    open c_ben_amt(p_highly_comp   => 'Y',  p_cvg_strt_dt   => l_cvg_strt_dt);
    fetch c_ben_amt into l_hgh_cmp_amt;
    close c_ben_amt;

    hr_utility.set_location (' l_hgh_cmp_amt '||l_hgh_cmp_amt ,8.1);
    --
    open c_ben_amt(p_highly_comp   => 'N',p_cvg_strt_dt   => l_cvg_strt_dt);
    fetch c_ben_amt into l_nor_cmp_amt;
    close c_ben_amt;

    hr_utility.set_location (' l_nor_cmp_amt '||l_nor_cmp_amt , 8.2);
    --
    if p_subj_to_imptd_incm_typ_cd = 'PRTT' then
      --
      l_std_imp_inc_ded := 50000;
      --
    else
      --
      l_std_imp_inc_ded := 2000;
      --
    end if;
    --
    --Bug 2043374 don't deduct for spouse and dependents if the l_nor_cmp_amt amount is
    -- more than 2000.
    if p_subj_to_imptd_incm_typ_cd = 'PRTT' then
      --
      l_tot_ben_amt := nvl(l_nor_cmp_amt,0) - l_std_imp_inc_ded;
      --
    else
      --
      if nvl(l_nor_cmp_amt,0) > 2000 then
        --
        l_tot_ben_amt := nvl(l_nor_cmp_amt,0) ;
        --
      else
        --
        l_tot_ben_amt := 0 ;
        --
      end if;
      --
    end if;

    --
    if l_tot_ben_amt < 0 then
      --
      l_tot_ben_amt := 0;
      --
    end if;
    --
  l_tot_sub_to_imp_inc := l_tot_ben_amt + nvl(l_hgh_cmp_amt,0);
  --
  hr_utility.set_location('l_tot_sub_to_imp_inc: '||l_tot_sub_to_imp_inc, 10);

  -- if the profile set to 'Y' and eployee contributed pre-tax , deduct the contribution
  --- post tax calcualtion 2897063

  l_prflvalue := fnd_profile.value('BEN_IMPTD_INCM_POST_TAX');
  hr_utility.set_location('Profile:'||l_prflvalue, 99 );
  if l_prflvalue = 'Y' then
     open  c_post_tax_contrib(hr_api.g_eot) ;
     Loop
        fetch c_post_tax_contrib into l_post_tax_rec ;
        exit when c_post_tax_contrib%notfound ;
        if  l_post_tax_rec.tx_typ_cd = 'AFTERTAX'
            and  substr(l_post_tax_rec.acty_typ_cd,1,2) = 'EE' then
            l_post_tax_amount := l_post_tax_amount + nvl(l_post_tax_rec.rt_val,0) ;
        else
           l_post_tax_err_found  := 'Y' ;
        end if ;
        hr_utility.set_location('pdv amount : '||l_post_tax_rec.rt_val  , 10);
     end loop ;
     close c_post_tax_contrib ;
     hr_utility.set_location('post tax : '||l_post_tax_amount || ' found ' || l_post_tax_err_found , 10);

     if l_post_tax_err_found  = 'Y'  then

        if fnd_global.conc_request_id in ( 0,-1) then
           -- Issue a warning to the user.  These will display on the enrt forms.
           ben_warnings.load_warning
            (p_application_short_name  => 'BEN',
             p_message_name            => 'BEN_93397_SUBJ_IMPTD_INCOM_FLG',
             p_person_id => p_person_id);
        else
            --
            fnd_message.set_name('BEN','BEN_93397_SUBJ_IMPTD_INCOM_FLG');
            l_string       := fnd_message.get;
            benutils.write(p_text => l_string);
        end if ;
        --
     end if;
  end if;
  ---- Post tax asmount is deducted after multiplying with factor



  if l_tot_sub_to_imp_inc > 0 then
    --
    open c_imp_inc_plan;
      --
      fetch c_imp_inc_plan into l_plan_rec;
      if c_imp_inc_plan%notfound then
        --
        close c_imp_inc_plan;
        fnd_message.set_name('BEN','BEN_91487_NO_IMP_INC_PLN');
        fnd_message.set_token('PROC',l_proc);
        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
        fnd_message.set_token('IMPTD_INCM_CALC_CD',p_imptd_incm_calc_cd);
        fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
        fnd_message.raise_error;
        --
      end if;
      --
    close c_imp_inc_plan;
    --
    open c_elctbl_chc(l_plan_rec.pl_id);
      --
      fetch c_elctbl_chc into l_elctbl_chc_rec;
      --
      -- Bug 3153375 : As part of eligibility process if deenrollment is
      -- called and choice to imputed income is created then it will not
      -- rate row. If no choice flag is set do not use newly created choice
      -- data.
      --
      if c_elctbl_chc%notfound  or p_no_choice_flag then
        --
        -- Bug 1950602 - If a enrollment result exists and electable choice not there
        -- for a given per_in_ler, still proceed with imputed income computation.
        --
          open c_enrt_rslt(l_plan_rec.pl_id);
            --
            fetch c_enrt_rslt into l_enrt_rslt_rec;
            hr_utility.set_location( ' Prtt_enrt_rslt_id '||l_enrt_rslt_rec.Prtt_enrt_rslt_id , 8.5);
            --
          close c_enrt_rslt;
        if p_no_choice_flag or l_enrt_rslt_rec.pl_id is not null then
          --
          l_elctbl_chc_rec.pl_id         := l_enrt_rslt_rec.pl_id;
          l_elctbl_chc_rec.pgm_id        := l_enrt_rslt_rec.pgm_id;
          l_elctbl_chc_rec.oipl_id       := l_enrt_rslt_rec.oipl_id;
          l_elctbl_chc_rec.pl_typ_id     := l_enrt_rslt_rec.pl_typ_id;
          l_elctbl_chc_rec.per_in_ler_id := p_per_in_ler_id;
          --
        else
          --
          fnd_message.set_name('BEN','BEN_91489_NO_ELCTBL_CHC');
          fnd_message.set_token('PROC',l_proc);
          fnd_message.set_token('PERSON_ID',to_char(p_person_id));
          fnd_message.set_token('PL_ID',to_char(l_plan_rec.pl_id));
          fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
          fnd_message.raise_error;
          --
        end if;
        --
      else
        --
        l_choice_exists_flag := true;
        hr_utility.set_location( ' l_choice_exists_flag ' , 8.6);
        --
        if l_plan_rec.pl_cd = 'MSTBPGM' then
          loop
          --
            open c_pgm_enrt_rslt_exists(l_elctbl_chc_rec.pgm_id);
            fetch c_pgm_enrt_rslt_exists into l_pgm_enrt_rslt_exists;
            if c_pgm_enrt_rslt_exists%found then
              close c_pgm_enrt_rslt_exists;
              exit;
            end if;
            close c_pgm_enrt_rslt_exists;

            fetch c_elctbl_chc into l_elctbl_chc_next_rec;
            exit when c_elctbl_chc%notfound;
            l_elctbl_chc_rec := l_elctbl_chc_next_rec;
            --
          end loop;
          --
        end if;
        --
      end if;
      --
    close c_elctbl_chc;
    --
    --
    -- Get enrollment result for imputed income plan.
    --
    -- If already fetched, do not re-fetch the record.
    --
    if l_enrt_rslt_rec.pl_id is not null then
      --
      l_result_exists_flag := TRUE;
      hr_utility.set_location( '  l_result_exists_flag ' , 8.7);
      --
    else
      --
      open c_enrt_rslt(l_plan_rec.pl_id);
        --
        fetch c_enrt_rslt into l_enrt_rslt_rec;
        if c_enrt_rslt%found then
          --
          l_result_exists_flag := TRUE;
          hr_utility.set_location( '  l_result_exists_flag ' ,8.8);
          --
        end if;
        --
      close c_enrt_rslt;
      --
    end if;
    --
    -- Bug 2200139 Override Changes
    open  c_prtt_rt(l_enrt_rslt_rec.prtt_enrt_rslt_id);
    fetch c_prtt_rt into l_rt_ovridn_rec ;
    if c_prtt_rt%found then
      -- We don't want to recalculate the imputed income rate if it is
      -- Overriden by the user from the Override enrollment form.
      -- If they want this to be recalculated, they can change the
      -- rt_ovridn_thru_dt from the Override enrollment form and
      -- save the enrollment, which will recalculate the rate.
      --
      if -- l_rt_ovridn_rec.rt_ovridn_flag = 'Y' and
         p_enrt_mthd_cd = 'O' and
         p_effective_date <= nvl(l_rt_ovridn_rec.rt_ovridn_thru_dt, p_effective_date-1 ) then
        --
          close c_prtt_rt;
          return;
        --
      end if;
      --
    end if;
    close c_prtt_rt ;
    --
    -- End Bug 2200139 Override changes
    --
    if not(l_result_exists_flag) and
      not(l_choice_exists_flag) and
      p_no_choice_flag then
      -- *** When p_no_choice_flag is ON. ***
      -- No existing results and no imputed income choice, so
      -- no recomputation needs to be done. Just return back.
      return;
      --
    end if;

    /* 8716870 begins */
    --check if the effective start date is greater than effective date being passed to module.
    if l_result_exists_flag then
      if l_enrt_rslt_rec.effective_start_date > p_effective_date then
        l_eff_date_for_enrt := l_enrt_rslt_rec.effective_start_date;
      else
        l_eff_date_for_enrt := p_effective_date;
      end if;
    end if;

    hr_utility.set_location('l_eff_date_for_enrt :'||l_eff_date_for_enrt,1234);
    hr_utility.set_location('p_effective_date    :'||p_effective_date,1234);
    /* 8716870 ends */


    --
    -- Dual procesing for rates, based on whether choice exists.
    -- If choice exists, processing done through enrollment rate,
    -- otherwise through prtt rate val table.
    --
    if l_choice_exists_flag then
      --
      open c_ecr_prv(l_elctbl_chc_rec.elig_per_elctbl_chc_id);
      --
    else
      --
      open  c_prtt_rt(l_enrt_rslt_rec.prtt_enrt_rslt_id);
      --
    end if;
    --
    l_count := 1;
    --
    loop
      --
      if l_choice_exists_flag then
        --
        fetch c_ecr_prv into l_ecr_prv_rec;
        if c_ecr_prv%notfound then
          -- Minimum one rate required.
          if l_count > 1 then
            --
            exit;
            --
          end if;
          --
          close c_ecr_prv;
          -- Start of Bug fix 3027365
                 hr_utility.set_location( ' pl id ' || l_plan_rec.pl_id, 99 ) ;
		  open c_chk_rate_avlbl(l_plan_rec.pl_id);
		  fetch c_chk_rate_avlbl into l_acty_base_rt_id;

		  if c_chk_rate_avlbl%found then
		     close c_chk_rate_avlbl;
                     open c_chk_calc (l_acty_base_rt_id ) ;
                     fetch c_chk_calc into l_mlt_cd ;
                     if c_chk_calc%found then
                        close c_chk_calc ;
             	        fnd_message.set_name('BEN','BEN_93477_VAPRO_IMPUT_FLAT');
      		        fnd_message.set_token('PROC',l_proc);
		        fnd_message.set_token('PERSON_ID',to_char(p_person_id));
		        fnd_message.set_token('PL_ID',to_char(l_plan_rec.pl_id));
		        fnd_message.set_token('ACTY_BASE_RT_ID',to_char(l_acty_base_rt_id));
 		        fnd_message.raise_error;
                     end if ;
                     close c_chk_calc ;
		  else
		     close c_chk_rate_avlbl;
		     fnd_message.set_name('BEN','BEN_91488_NO_IMP_ABR');
		     fnd_message.set_token('PROC',l_proc);
		     fnd_message.set_token('PERSON_ID',to_char(p_person_id));
		     fnd_message.set_token('PL_ID',to_char(l_plan_rec.pl_id));
		     fnd_message.set_token('PER_IN_LER_ID',to_char(p_per_in_ler_id));
		     fnd_message.raise_error;
		  end if;
	  -- End of Bug fix 3027365
          --
        end if;
        --
      else
        --
        fetch c_prtt_rt into l_prtt_rt_rec;
        --
        if c_prtt_rt%notfound then
          --
          exit;
          --
        end if;
        --
        l_ecr_prv_rec.prtt_rt_val_id  := l_prtt_rt_rec.prtt_rt_val_id;
        l_ecr_prv_rec.acty_base_rt_id := l_prtt_rt_rec.acty_base_rt_id;
        --
      end if;
      --
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_determine_activity_base_rt');
      --
      ben_determine_activity_base_rt.main
        (P_PERSON_ID                => p_person_id
        ,P_ELIG_PER_ELCTBL_CHC_ID   => null
        ,P_ENRT_BNFT_ID             => NULL
        ,P_ACTY_BASE_RT_ID          => l_ecr_prv_rec.acty_base_rt_id
        ,P_EFFECTIVE_DATE           => p_effective_date
        ,p_lf_evt_ocrd_dt           => l_pil_rec.lf_evt_ocrd_dt
        ,P_PERFORM_ROUNDING_FLG     => FALSE
        ,p_calc_only_rt_val_flag    => true
        ,p_pgm_id                   => l_elctbl_chc_rec.pgm_id
        ,p_pl_id                    => l_elctbl_chc_rec.pl_id
        ,p_oipl_id                  => l_elctbl_chc_rec.oipl_id
        ,p_pl_typ_id                => l_elctbl_chc_rec.pl_typ_id
        ,p_per_in_ler_id            => l_elctbl_chc_rec.per_in_ler_id
        ,p_ler_id                   => l_pil_rec.ler_id
        ,p_bnft_amt                 => l_tot_sub_to_imp_inc
        ,p_business_group_id        => p_business_group_id
        ,P_VAL                      => rate_val_list(l_count)
        ,P_MN_ELCN_VAL              => l_mn_elcn_value
        ,P_MX_ELCN_VAL              => l_mx_elcn_value
        ,P_ANN_VAL                  => l_ann_val
        ,P_ANN_MN_ELCN_VAL          => l_ann_mn_elcn_val
        ,P_ANN_MX_ELCN_VAL          => l_ann_mx_elcn_val
        ,P_CMCD_VAL                 => l_cmcd_val
        ,P_CMCD_MN_ELCN_VAL         => l_cmcd_mn_elcn_val
        ,P_CMCD_MX_ELCN_VAL         => l_cmcd_mx_elcn_val
        ,P_CMCD_ACTY_REF_PERD_CD    => l_cmcd_acty_ref_perd_cd
        ,P_INCRMT_ELCN_VAL          => l_incrt_val
        ,P_DFLT_VAL                 => l_dflt_elcn_val
        ,P_TX_TYP_CD                => l_tx_typ_cd
        ,P_ACTY_TYP_CD              => l_acty_typ_cd
        ,P_NNMNTRY_UOM              => l_nnmntry_uom
        ,P_ENTR_VAL_AT_ENRT_FLAG    => l_entr_val_at_enrt_flag
        ,P_DSPLY_ON_ENRT_FLAG       => l_dsply_on_enrt_flag
        ,P_USE_TO_CALC_NET_FLX_CR_FLAG  => l_USE_TO_CALC_NET_FLX_CR_FLAG
        ,P_RT_USG_CD                => l_RT_USG_CD
        ,P_BNFT_PRVDR_POOL_ID       => l_BNFT_PRVDR_POOL_ID
        ,P_ACTL_PREM_ID             => l_actl_prem_id
        ,P_CVG_CALC_AMT_MTHD_ID     => l_cvg_calc_amt_mthd_id
        ,P_BNFT_RT_TYP_CD           => l_bnft_rt_typ_cd
        ,P_RT_TYP_CD                => l_rt_typ_cd
        ,P_RT_MLT_CD                => l_rt_mlt_cd
        ,P_COMP_LVL_FCTR_ID         => l_comp_lvl_fctr_id
        ,P_ENTR_ANN_VAL_FLAG        => l_entr_ann_val_flag
        ,P_PTD_COMP_LVL_FCTR_ID     => l_ptd_comp_lvl_fctr_id
        ,P_CLM_COMP_LVL_FCTR_ID     => l_clm_comp_lvl_fctr_id
        ,P_ANN_DFLT_VAL             => l_ann_dflt_val
        ,P_RT_STRT_DT               => l_rt_strt_dt
        ,P_RT_STRT_DT_CD            => l_rt_strt_dt_cd
        ,P_RT_STRT_DT_RL            => l_rt_strt_dt_rl
        ,P_PRTT_RT_VAL_ID           => l_prtt_rt_val_id
        ,p_dsply_mn_elcn_val        => l_dsply_mn_elcn_val
        ,p_dsply_mx_elcn_val        => l_dsply_mx_elcn_val
        ,p_pp_in_yr_used_num        => l_pp_in_yr_used_num
        ,p_ordr_num                 => l_ordr_num
        ,p_iss_val                  => l_iss_val);
      --
      -- Imputed income will always be rate * total subject to imputed income
      --
      hr_utility.set_location('factor before  : '||rate_val_list(l_count)  , 10);
      rate_val_list(l_count) := rate_val_list(l_count)*l_tot_sub_to_imp_inc;
      rate_id_list(l_count) := l_ecr_prv_rec.enrt_rt_id;

      hr_utility.set_location('factor after  : '||rate_val_list(l_count)  , 10);
      --- Post tax contribution deducted here 2897063
      if l_post_tax_amount >  0  then
        if l_post_tax_amount > rate_val_list(l_count) then
           rate_val_list(l_count) :=  0 ;
        else
           rate_val_list(l_count) := rate_val_list(l_count) - l_post_tax_amount ;
        end if ;
      end if ;
      --
      hr_utility.set_location('post deduction  : '||rate_val_list(l_count)  , 10);

      if l_result_exists_flag then
        --
        if l_choice_exists_flag then
          --
          -- result and choice exist, update both in call to
          -- election_information
          -- outside loop. Bug 1295277
          null;
          --
        else
          -- result exists but no choice exists, so just update the rate,
          -- by end-dating the previous rate.
          ben_provider_pools.update_rate
            (p_prtt_rt_val_id      => l_ecr_prv_rec.prtt_rt_val_id,
             p_val                 => rate_val_list(l_count),
             p_prtt_enrt_rslt_id   => l_enrt_rslt_rec.prtt_enrt_rslt_id,
             p_business_group_id   => p_business_group_id,
             p_ended_per_in_ler_id => p_per_in_ler_id,
             p_effective_date      => p_effective_date);
          --
        end if;
        --
      end if;
      --
      l_count := l_count + 1;
      --
    end loop;
    --
    if l_choice_exists_flag then
      --
      close c_ecr_prv;
      --
    else
      --
      close c_prtt_rt;
      --
    end if;
    --
    for l_fill in l_count..10 loop
      --
      rate_id_list(l_fill) := null;
      rate_val_list(l_fill) := null;
      --
    end loop;
    --
    if l_result_exists_flag and
      l_choice_exists_flag then
      --
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_election_information -update');
      -- do update  Bug 1295277
      hr_utility.set_location( '  Case 1 l_result_exists_flag l_choice_exists_flag ' , 9.0);
      ben_election_information.election_information
        (p_validate                => FALSE
        ,p_elig_per_elctbl_chc_id  => l_elctbl_chc_rec.elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id       => l_enrt_rslt_rec.prtt_enrt_rslt_id
        ,p_effective_date          => l_eff_date_for_enrt     --8716870
        ,p_enrt_mthd_cd            => p_enrt_mthd_cd
        ,p_enrt_bnft_id            => null
        ,p_bnft_val                => null
        ,p_enrt_rt_id1             => rate_id_list(1)
        ,p_prtt_rt_val_id1         => l_prtt_rt_val_id1
        ,p_rt_val1                 => rate_val_list(1)
        ,p_enrt_rt_id2             => rate_id_list(2)
        ,p_prtt_rt_val_id2         => l_prtt_rt_val_id2
        ,p_rt_val2                 => rate_val_list(2)
        ,p_enrt_rt_id3             => rate_id_list(3)
        ,p_prtt_rt_val_id3         => l_prtt_rt_val_id3
        ,p_rt_val3                 => rate_val_list(3)
        ,p_enrt_rt_id4             => rate_id_list(4)
        ,p_prtt_rt_val_id4         => l_prtt_rt_val_id4
        ,p_rt_val4                 => rate_val_list(4)
        ,p_enrt_rt_id5             => rate_id_list(5)
        ,p_prtt_rt_val_id5         => l_prtt_rt_val_id5
        ,p_rt_val5                 => rate_val_list(5)
        ,p_enrt_rt_id6             => rate_id_list(6)
        ,p_prtt_rt_val_id6         => l_prtt_rt_val_id6
        ,p_rt_val6                 => rate_val_list(6)
        ,p_enrt_rt_id7             => rate_id_list(7)
        ,p_prtt_rt_val_id7         => l_prtt_rt_val_id7
        ,p_rt_val7                 => rate_val_list(7)
        ,p_enrt_rt_id8             => rate_id_list(8)
        ,p_prtt_rt_val_id8         => l_prtt_rt_val_id8
        ,p_rt_val8                 => rate_val_list(8)
        ,p_enrt_rt_id9             => rate_id_list(9)
        ,p_prtt_rt_val_id9         => l_prtt_rt_val_id9
        ,p_rt_val9                 => rate_val_list(9)
        ,p_enrt_rt_id10            => rate_id_list(10)
        ,p_prtt_rt_val_id10        => l_prtt_rt_val_id10
        ,p_rt_val10                => rate_val_list(10)
        ,p_suspend_flag            => l_suspend_flag
        ,p_called_from_sspnd       => 'N'                      -- 8716870
        ,p_effective_start_date    => l_effective_start_date
        ,p_effective_end_date      => l_effective_end_date
        ,p_object_version_number   => l_object_version_number
        ,p_prtt_enrt_interim_id    => l_prtt_enrt_interim_id
        ,p_business_group_id       => p_business_group_id
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_dpnt_actn_warning       => l_dpnt_actn_warning
        ,p_bnf_actn_warning        => l_bnf_actn_warning
        ,p_ctfn_actn_warning       => l_ctfn_actn_warning
        ,p_imp_cvg_strt_dt         => p_imp_cvg_strt_dt); -- 8716870
      --
    elsif NOT(l_result_exists_flag) then
      --
      fnd_message.set_name('BEN','BEN_91333_CALLING_PROC');
      fnd_message.set_token('PROC','ben_election_information-insert');
      -- do insert.
      hr_utility.set_location('Effective Date '||p_effective_date , 1399);
      hr_utility.set_location('p_enrt_mthd_cd ' ||p_enrt_mthd_cd , 1399 ) ;

   hr_utility.set_location('Befor plan_id'||to_char(l_elctbl_chc_rec.pl_id) , 1399);
   hr_utility.set_location('Conc Req Id '||fnd_global.conc_request_id , 1399);
   hr_utility.set_location('lf date'|| l_pil_rec.lf_evt_ocrd_dt,1399);
   hr_utility.set_location('p_enrt_mthd_cd '||p_enrt_mthd_cd , 1399 );
     -- Bug 1561138 When automatic enrollment is run for an imputted income
     --             plan take the effective date as the minimum of
     --             life event occured date and effective date passed.
     --            This is done only in case of batch process from a
     --           concurrent request sumbission.
      l_effective_date := p_effective_date ;

      if p_enrt_mthd_cd = 'A'
            AND fnd_global.conc_request_id <> -1
      then
         --
      hr_utility.set_location('Automatic enrollmant case' , 1399);
         if p_effective_date > l_pil_rec.lf_evt_ocrd_dt
         then
            l_effective_date := l_pil_rec.lf_evt_ocrd_dt ;
         hr_utility.set_location('Automatic enrollment eff date altered', 1399);
         hr_utility.set_location('Date passed is :'||l_effective_date, 1399) ;
         end if;
         --
      end if;

      --
      ben_election_information.election_information
        (p_validate                => FALSE
        ,p_elig_per_elctbl_chc_id  => l_elctbl_chc_rec.elig_per_elctbl_chc_id
        ,p_prtt_enrt_rslt_id       => l_prtt_enrt_rslt_id
        ,p_effective_date          => p_effective_date
        ,p_enrt_mthd_cd            => p_enrt_mthd_cd
        ,p_enrt_bnft_id            => null
        ,p_bnft_val                => null
        ,p_enrt_rt_id1             => rate_id_list(1)
        ,p_prtt_rt_val_id1         => l_prtt_rt_val_id1
        ,p_rt_val1                 => rate_val_list(1)
        ,p_enrt_rt_id2             => rate_id_list(2)
        ,p_prtt_rt_val_id2         => l_prtt_rt_val_id2
        ,p_rt_val2                 => rate_val_list(2)
        ,p_enrt_rt_id3             => rate_id_list(3)
        ,p_prtt_rt_val_id3         => l_prtt_rt_val_id3
        ,p_rt_val3                 => rate_val_list(3)
        ,p_enrt_rt_id4             => rate_id_list(4)
        ,p_prtt_rt_val_id4         => l_prtt_rt_val_id4
        ,p_rt_val4                 => rate_val_list(4)
        ,p_enrt_rt_id5             => rate_id_list(5)
        ,p_prtt_rt_val_id5         => l_prtt_rt_val_id5
        ,p_rt_val5                 => rate_val_list(5)
        ,p_enrt_rt_id6             => rate_id_list(6)
        ,p_prtt_rt_val_id6         => l_prtt_rt_val_id6
        ,p_rt_val6                 => rate_val_list(6)
        ,p_enrt_rt_id7             => rate_id_list(7)
        ,p_prtt_rt_val_id7         => l_prtt_rt_val_id7
        ,p_rt_val7                 => rate_val_list(7)
        ,p_enrt_rt_id8             => rate_id_list(8)
        ,p_prtt_rt_val_id8         => l_prtt_rt_val_id8
        ,p_rt_val8                 => rate_val_list(8)
        ,p_enrt_rt_id9             => rate_id_list(9)
        ,p_prtt_rt_val_id9         => l_prtt_rt_val_id9
        ,p_rt_val9                 => rate_val_list(9)
        ,p_enrt_rt_id10            => rate_id_list(10)
        ,p_prtt_rt_val_id10        => l_prtt_rt_val_id10
        ,p_rt_val10                => rate_val_list(10)
        ,p_suspend_flag            => l_suspend_flag
        ,p_called_from_sspnd       => 'N'                   -- 8716870
        ,p_effective_start_date    => l_effective_start_date
        ,p_effective_end_date      => l_effective_end_date
        ,p_object_version_number   => l_object_version_number
        ,p_prtt_enrt_interim_id    => l_prtt_enrt_interim_id
        ,p_business_group_id       => p_business_group_id
        ,p_datetrack_mode          => l_datetrack_mode
        ,p_dpnt_actn_warning       => l_dpnt_actn_warning
        ,p_bnf_actn_warning        => l_bnf_actn_warning
        ,p_ctfn_actn_warning       => l_ctfn_actn_warning
        ,p_imp_cvg_strt_dt         => p_imp_cvg_strt_dt); -- 8716870
      --
    end if;
    --
  else
    --
    hr_utility.set_location( '  Case 3   ' , 9.2);
    open c_imp_inc_plan2(l_cvg_strt_dt); -- 8716870
      --
      fetch c_imp_inc_plan2 into l_enrt_rslt_rec;
      if c_imp_inc_plan2%found then
        --
        /* 8716870 */
        --check if the effective start date is greater than effective date being passed to module.
        if l_enrt_rslt_rec.effective_start_date > p_effective_date then
          l_eff_date_for_enrt := l_enrt_rslt_rec.effective_start_date;
        else
          l_eff_date_for_enrt := p_effective_date;
        end if;

        hr_utility.set_location('l_eff_date_for_enrt :'||l_eff_date_for_enrt,1234);
        hr_utility.set_location('p_effective_date    :'||p_effective_date,1234);

        /* 8716870 */
        ben_prtt_enrt_result_api.delete_enrollment
          (p_prtt_enrt_rslt_id     => l_enrt_rslt_rec.prtt_enrt_rslt_id,
           p_per_in_ler_id         => p_per_in_ler_id,
           p_object_version_number => l_enrt_rslt_rec.object_version_number,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_effective_date        => l_eff_date_for_enrt,       --8716870
           p_datetrack_mode        => hr_api.g_delete,
           p_business_group_id     => p_business_group_id,
           p_source                => 'bendeimp',
           p_multi_row_validate    => FALSE);
        --
      end if;
      --
    close c_imp_inc_plan2;
    --
  end if;
  --
  /* 8716870 begins */
  if nvl(l_eff_date_for_enrt,p_effective_date)<>p_effective_date then
    --if we used a different effective date than p_effective_date then store it again in
    --Environment objects. We have just called a heavy duty api (ben_election_information/ben_prtt_enrt_result_api)
    --with an effective date different from what was supposed to be used. This may have stored this date in the
    --env objects. This date is not required for any other modules so we query to see if this value was written and
    --if so we will overwrite it with the original effective date.
    ben_env_object.get(p_rec    => p_global_env_rec);

      hr_utility.set_location('l_eff_date_for_enrt:'||l_eff_date_for_enrt,1234);
      hr_utility.set_location('p_effective_date:'||p_effective_date,1234);
      hr_utility.set_location('p_global_env_rec.effective_date:'||p_global_env_rec.effective_date,1234);


    if (p_global_env_rec.effective_date = l_eff_date_for_enrt) then
      ben_env_object.init
       (p_business_group_id => p_global_env_rec.business_group_id
       ,p_effective_date    => p_effective_date
       ,p_thread_id         => p_global_env_rec.thread_id
       ,p_chunk_size        => p_global_env_rec.chunk_size
       ,p_threads           => p_global_env_rec.threads
       ,p_max_errors        => p_global_env_rec.max_errors
       ,p_benefit_action_id => p_global_env_rec.benefit_action_id
       ,p_audit_log_flag    => p_global_env_rec.audit_log_flag
       );
    end if;
  end if;
  /* 8716870 ends */

  hr_utility.set_location('Leaving: '||l_proc , 10);
  --
end p_comp_imp_inc_internal;
--

/* 8716870 : Added procedure redo_imp_inc
*/
procedure  redo_imp_inc(p_person_id         number,
                        p_enrt_mthd_cd      varchar2,
                        p_business_group_id number,
                        p_per_in_ler_id     number,
                        p_effective_date    date,
                        p_validate          in  boolean  default false,
                        p_no_choice_flag    boolean default false)
is
  l_imp_cvg_strt_dt date;

  -- cursor to pick all enrollments subject to imputed income
  cursor c_enrt_subj_to_imp
  is
  select pen.prtt_enrt_rslt_id, pen.enrt_cvg_strt_Dt,pl.subj_to_imptd_incm_typ_cd
  from   ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil,
         ben_pl_f pl
  where  pen.pl_id = pl.pl_id
    and  pen.sspndd_flag = 'N'
    and  pen.per_in_ler_id = pil.per_in_ler_id
    and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and  pen.person_id = pil.person_id
    and  pen.prtt_enrt_rslt_stat_cd is NULL
    and  p_effective_date between pl.effective_start_date and pl.effective_end_date
    and  pen.enrt_cvg_thru_dt = hr_api.g_eot
    and  pen.effective_end_date = hr_api.g_eot
--    and  p_effective_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and  pen.person_id = p_person_id
  --and  pil.person_id = p_person_id
    and  pil.per_in_ler_id  = p_per_in_ler_id
    and  subj_to_imptd_incm_typ_cd is not null
  union
  select pen.prtt_enrt_rslt_id, pen.enrt_cvg_strt_Dt,pl.subj_to_imptd_incm_typ_cd
  from   ben_prtt_enrt_rslt_f pen,
         ben_elig_per_elctbl_chc epe,
	 ben_pl_f pl,
	 ben_per_in_ler pil
  where  epe.per_in_ler_id <> pen.per_in_ler_id
    and  pen.pl_id = pl.pl_id
    and  epe.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
    and  epe.per_in_ler_id = pil.per_in_ler_id
    and  nvl(epe.pl_id,-1) = nvl(pen.pl_id,-1)
    and  nvl(epe.oipl_id,-1) = nvl(pen.oipl_id,-1)
    and  epe.elctbl_flag = 'N'
    and  epe.crntly_enrd_flag = 'Y'
    and  pen.sspndd_flag = 'N'
    and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and  pen.prtt_enrt_rslt_stat_cd is NULL
    and  p_effective_date between pl.effective_start_date and pl.effective_end_date
--    and  p_effective_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
    and  pen.enrt_cvg_thru_dt = hr_api.g_eot
    and  pen.effective_end_date = hr_api.g_eot
    and  pen.person_id = pil.person_id
    and  pen.person_id = p_person_id
    and  epe.per_in_ler_id = p_per_in_ler_id
    and  pl.subj_to_imptd_incm_typ_cd is not null
  order  by 2 ;

  l_enrt_subj_to_imp c_enrt_subj_to_imp%rowtype;
  l_effective_date date;



  -- This is similar to cursor c_enrt_subj_to_imp used for participant. When not opened in loop, it will fetch the earliest
  -- enrollment in terms of coverage start date
  cursor c_erlst_cvg_strt(p_imptd_incm_typ_cd varchar2)
  is
  select pen.prtt_enrt_rslt_id, pen.enrt_cvg_strt_Dt,pl.subj_to_imptd_incm_typ_cd
  from   ben_prtt_enrt_rslt_f pen,
         ben_per_in_ler pil,
         ben_pl_f pl
  where  pen.pl_id = pl.pl_id
    and  pen.sspndd_flag = 'N'
    and  pen.per_in_ler_id = pil.per_in_ler_id
    and  pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
    and  pen.person_id = pil.person_id
    and  pen.prtt_enrt_rslt_stat_cd is NULL
    and  p_effective_date between pl.effective_start_date and pl.effective_end_date
    and  pen.enrt_cvg_thru_dt = hr_api.g_eot
    and  pen.effective_end_date = hr_api.g_eot
    and  pen.person_id = p_person_id
    and  pil.person_id = p_person_id
    and  pil.per_in_ler_id  = p_per_in_ler_id
    and  pl.subj_to_imptd_incm_typ_cd = p_imptd_incm_typ_cd
  order  by 2;

l_erlst_cvg_strt c_erlst_cvg_strt%rowtype;
l_found_prtt            boolean := FALSE;
l_found_dpnt            boolean := FALSE;
l_found_sps             boolean := FALSE;

l_proc    varchar2(72) := g_package||'redo_imp_inc';

begin
  hr_utility.set_location(' Entering ' || l_proc , 11);
  hr_utility.set_location(' p_per_in_ler_id '||p_per_in_ler_id, 10);
  hr_utility.set_location(' p_person_id '||p_person_id, 10);

  -- Open cursor c_erlst_cvg_strt for participant, spouse and dependent imputed income. We need to delete any imputed
  -- income rate starting before the earliest coverage start date. Such a rate would correspond to a de-enrolled plan
  -- subject to imputed income

  open c_erlst_cvg_strt(p_imptd_incm_typ_cd => 'PRTT');
  fetch c_erlst_cvg_strt into l_erlst_cvg_strt;
    if c_erlst_cvg_strt%found then
      l_found_prtt := TRUE;
   end if;
  close c_erlst_cvg_strt;

  hr_utility.set_location('l_erlst_cvg_strt.enrt_cvg_strt_dt '||l_erlst_cvg_strt.enrt_cvg_strt_dt, 20);
  hr_utility.set_location('l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd '||l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd, 20);

  if l_found_prtt then
      delete_past_imp(p_person_id          => p_person_id,
                      p_per_in_ler_id      => p_per_in_ler_id,
                      p_business_group_id  => p_business_group_id,
                      p_effective_date     => p_effective_date,
		      p_erlst_cvg_strt     => l_erlst_cvg_strt.enrt_cvg_strt_dt,
                      p_imptd_incm_calc_cd => 'PRTT');
  end if;

  l_erlst_cvg_strt := NULL;

  open c_erlst_cvg_strt(p_imptd_incm_typ_cd => 'DPNT');
  fetch c_erlst_cvg_strt into l_erlst_cvg_strt;
    if c_erlst_cvg_strt%found then
      l_found_dpnt := TRUE;
    end if;
  close c_erlst_cvg_strt;

  hr_utility.set_location('dpnt l_erlst_cvg_strt.enrt_cvg_strt_dt '||l_erlst_cvg_strt.enrt_cvg_strt_dt, 20);
  hr_utility.set_location('dpnt l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd '||l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd, 20);

  if l_found_dpnt then
      delete_past_imp(p_person_id          => p_person_id,
                      p_per_in_ler_id      => p_per_in_ler_id,
                      p_business_group_id  => p_business_group_id,
                      p_effective_date     => p_effective_date,
		      p_erlst_cvg_strt     => l_erlst_cvg_strt.enrt_cvg_strt_dt,
                      p_imptd_incm_calc_cd => 'DPNT');
  end if;

  l_erlst_cvg_strt := NULL;

  open c_erlst_cvg_strt(p_imptd_incm_typ_cd => 'SPS');
  fetch c_erlst_cvg_strt into l_erlst_cvg_strt;
    if c_erlst_cvg_strt%found then
      l_found_sps := TRUE;
    end if;
  close c_erlst_cvg_strt;

  hr_utility.set_location('sps l_erlst_cvg_strt.enrt_cvg_strt_dt '||l_erlst_cvg_strt.enrt_cvg_strt_dt, 20);
  hr_utility.set_location('sps l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd '||l_erlst_cvg_strt.subj_to_imptd_incm_typ_cd, 20);

  if l_found_sps then
      delete_past_imp(p_person_id          => p_person_id,
                      p_per_in_ler_id      => p_per_in_ler_id,
                      p_business_group_id  => p_business_group_id,
                      p_effective_date     => p_effective_date,
		      p_erlst_cvg_strt     => l_erlst_cvg_strt.enrt_cvg_strt_dt,
                      p_imptd_incm_calc_cd => 'SPS');
  end if;

  -- pick up all enrollments subject to imputed income and call p_comp_imp_inc_internal for each such enrollment
  -- by passing effective_date as the coverage start date

  open c_enrt_subj_to_imp;
  loop
    fetch c_enrt_subj_to_imp into l_enrt_subj_to_imp;
    exit when c_enrt_subj_to_imp%notfound;
    l_imp_cvg_strt_dt := l_enrt_subj_to_imp.enrt_cvg_strt_dt ;

    l_effective_date := p_effective_date;     -- Bug 9436910

    hr_utility.set_location('l_imp_cvg_strt_dt '||l_imp_cvg_strt_dt, 10);
    hr_utility.set_location('l_effective_date '||l_effective_date, 10);
    hr_utility.set_location('l_enrt_subj_to_imp.prtt_enrt_rslt_id '||l_enrt_subj_to_imp.prtt_enrt_rslt_id, 10);

    if l_enrt_subj_to_imp.subj_to_imptd_incm_typ_cd ='PRTT' then
       hr_utility.set_location('recalc imputed income PRTT ', 1635);

       p_comp_imp_inc_internal
         (p_person_id                   => p_person_id
         ,p_enrt_mthd_cd                => p_enrt_mthd_cd
         ,p_business_group_id           => p_business_group_id
         ,p_per_in_ler_id               => p_per_in_ler_id
         ,p_effective_date              => l_effective_date
         ,p_subj_to_imptd_incm_typ_cd   => 'PRTT'
         ,p_imptd_incm_calc_cd          => 'PRTT'
         ,p_validate                    => p_validate
         ,p_no_choice_flag              => p_no_choice_flag
         ,p_imp_cvg_strt_dt             => l_imp_cvg_strt_dt
         );

    elsif l_enrt_subj_to_imp.subj_to_imptd_incm_typ_cd ='SPS' then

       hr_utility.set_location('recalc imputed income sps', 1675);

       p_comp_imp_inc_internal
          (p_person_id                   => p_person_id
          ,p_enrt_mthd_cd                => p_enrt_mthd_cd
          ,p_business_group_id           => p_business_group_id
          ,p_per_in_ler_id               => p_per_in_ler_id
          ,p_effective_date              => l_effective_date
          ,p_subj_to_imptd_incm_typ_cd   => 'SPS'
          ,p_imptd_incm_calc_cd          => 'SPS'
          ,p_validate                    => p_validate
          ,p_no_choice_flag              => p_no_choice_flag
          ,p_imp_cvg_strt_dt             => l_imp_cvg_strt_dt
         );

    elsif l_enrt_subj_to_imp.subj_to_imptd_incm_typ_cd ='DPNT' then
       hr_utility.set_location('recalc imputed income dpnt', 1690);

       p_comp_imp_inc_internal
           (p_person_id                   => p_person_id
           ,p_enrt_mthd_cd                => p_enrt_mthd_cd
           ,p_business_group_id           => p_business_group_id
           ,p_per_in_ler_id               => p_per_in_ler_id
           ,p_effective_date              => l_effective_date
           ,p_subj_to_imptd_incm_typ_cd   => 'DPNT'
           ,p_imptd_incm_calc_cd          => 'DPNT'
           ,p_validate                    => p_validate
           ,p_no_choice_flag              => p_no_choice_flag
           ,p_imp_cvg_strt_dt             => l_imp_cvg_strt_dt
           );
    end if;
  end loop;

  hr_utility.set_location(' Leaving ' || l_proc , 11);
close c_enrt_subj_to_imp;

end redo_imp_inc;

--
procedure p_comp_imputed_income
   (p_person_id                      in  number
   ,p_enrt_mthd_cd                   in  varchar2
   ,p_business_group_id              in  number
   ,p_per_in_ler_id                  in  number
   ,p_effective_date                 in  date
   -- Always supply this parameter as its a FIDO only param. Set to false.
   ,p_ctrlm_fido_call                in  boolean  default true
   ,p_validate                       in  boolean  default false
   ,p_no_choice_flag                 in  boolean  default false
   ) is
   --
  l_proc varchar2(80) := 'ben_det_imputed_income.p_comp_imputed_income';
  l_commit number;
  l_SES_DATE date;
  l_SES_YESTERDAY_DATE date;
  l_START_OF_TIME date;
  l_END_OF_TIME date;
  l_SYS_DATE date;
  --
/*
  cursor c_imp_plan_exists is
    select 'Y'
    from   ben_pl_f pln
    where  pln.imptd_incm_calc_cd is not null
    and    pln.pl_stat_cd = 'A'
    and    pln.business_group_id = p_business_group_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
*/
  --
  -- Bug 1950602 : If no electable choices which are subject to imputed income
  -- exist for the per_in_ler do not do the imputed income computation.
  --
  cursor c_imp_plan_exists is
    select 'Y'
    from   ben_pl_f pln,
           ben_elig_per_elctbl_chc epe
    where  pln.subj_to_imptd_incm_typ_cd is not null
    and    pln.pl_id = epe.pl_id
    and    epe.per_in_ler_id  = p_per_in_ler_id
    and    pln.pl_stat_cd = 'A'
    and    pln.business_group_id = p_business_group_id
    and    p_effective_date
           between pln.effective_start_date
           and     pln.effective_end_date;
  --
  cursor c_imp_shell  is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen
    where  pen.person_id = p_person_id
    and    pen.comp_lvl_cd = 'PLANIMP'
    and    pen.effective_end_date = to_date('31-12-4712','dd-mm-yyyy')
    and    pen.prtt_enrt_rslt_stat_cd is null
    and    pen.enrt_cvg_thru_dt = to_date('31-12-4712','dd-mm-yyyy')
    and    exists (select null from ben_elig_per_elctbl_chc epe
                   where pen.pl_id = epe.pl_id
                   and   epe.per_in_ler_id = p_per_in_ler_id);
  --
  l_exists    varchar2(30) := 'N';
  --
  /* 8716870 begins*/

  l_no_choice_flag boolean := FALSE;

  function get_no_choice_flag(p_per_in_ler_id number, p_imptd_incm_calc_cd varchar2)
  return boolean
    is

    cursor c_imp_inc_no_chc(p_per_in_ler_id number, p_imptd_incm_calc_cd varchar2)
    is
    select 'Y'
    from   ben_prtt_enrt_rslt_f pen, ben_pl_f pl
    where  pen.person_id = p_person_id
      and  pen.comp_lvl_cd = 'PLANIMP'
      and  pen.effective_end_date = hr_api.g_eot
      and  pen.prtt_enrt_rslt_stat_cd is null
      and  pen.enrt_cvg_thru_dt = hr_api.g_eot
      and  pen.pl_id = pl.pl_id
      and  pl.imptd_incm_calc_cd = p_imptd_incm_calc_cd
      and  pl.pl_stat_cd = 'A'
      and  pen.enrt_cvg_strt_dt between pl.effective_start_date and pl.effective_end_date
      and  not exists (select 1
                         from ben_elig_per_elctbl_chc epe
                        where epe.pl_id  = pen.pl_id
                          and epe.pgm_id = pen.pgm_id
                          and epe.per_in_ler_id = p_per_in_ler_id);

    l_imp_inc_chc_exists c_imp_inc_no_chc%rowtype;
    l_no_chc_flg boolean := FALSE;
begin
    open c_imp_inc_no_chc(p_per_in_ler_id, p_imptd_incm_calc_cd);
    fetch c_imp_inc_no_chc into l_imp_inc_chc_exists;

    if c_imp_inc_no_chc%found then
      l_no_chc_flg := TRUE;
    end if;

    close c_imp_inc_no_chc;
    return l_no_chc_flg;
end;
/* 8716870 ends*/
  --
begin
  --
  --
  hr_utility.set_location(' Entering ' || l_proc , 11);
  hr_utility.set_location('   Calculate participant imputed income ', 10);

  if p_ctrlm_fido_call then
    --
    dt_fndate.get_dates(
      P_SES_DATE           =>l_SES_DATE,
      P_SES_YESTERDAY_DATE =>l_SES_YESTERDAY_DATE,
      P_START_OF_TIME      =>l_START_OF_TIME,
      P_END_OF_TIME        =>l_END_OF_TIME,
      P_SYS_DATE           =>l_SYS_DATE,
      P_COMMIT             =>l_COMMIT
    );
    --
    -- Put row in fnd_sessions
    --
    dt_fndate.change_ses_date
      (p_ses_date => p_effective_date,
       p_commit   => l_commit);
    --
    --
    -- Fidelity calls this routine from CTRL M which runs it as a concurrent
    -- program. In this case they need the environment setup for them.
    --
    ben_env_object.init(p_business_group_id  => p_business_group_id,
                        p_effective_date     => p_effective_date,
                        p_thread_id          => 1,
                        p_chunk_size         => 1,
                        p_threads            => 1,
                        p_max_errors         => 1,
                        p_benefit_action_id  => null);
    --
  end if;
  --
  -- Check whether any imputed income plan or subject to income plan
  -- exist for the business group.
  -- If none, no processing is required.
  --
  open  c_imp_plan_exists;
  fetch c_imp_plan_exists into l_exists;
  close c_imp_plan_exists;
  --
  --bug#4435255 - check to see whether the imputed shell plan needs to be deenrolled
  if l_exists = 'N' then
    --
    open c_imp_shell;
    fetch c_imp_shell into l_exists;
    close c_imp_shell;
    --
  end if;
  -- bug  1950602 : Do not recompute imputed income if there
  -- are no electable choices which are subjected to imputed income
  -- for this per in ler.  or compute if it is denrollment indicated
  -- by p_no_choice_flag.
  --
  -- 8716870
  l_no_choice_flag := get_no_choice_flag(p_per_in_ler_id       => p_per_in_ler_id,
                                         p_imptd_incm_calc_cd  => 'PRTT');

/*

  if l_exists = 'Y' or p_no_choice_flag then
    --
    p_comp_imp_inc_internal
     (p_person_id                   => p_person_id
     ,p_enrt_mthd_cd                => p_enrt_mthd_cd
     ,p_business_group_id           => p_business_group_id
     ,p_per_in_ler_id               => p_per_in_ler_id
     ,p_effective_date              => p_effective_date
     ,p_subj_to_imptd_incm_typ_cd   => 'PRTT'
     ,p_imptd_incm_calc_cd          => 'PRTT'
     ,p_validate                    => p_validate
     ,p_no_choice_flag              => p_no_choice_flag
     );

     hr_utility.set_location('   Calculate spouse imputed income ', 10);

    p_comp_imp_inc_internal
      (p_person_id                   => p_person_id
      ,p_enrt_mthd_cd                => p_enrt_mthd_cd
      ,p_business_group_id           => p_business_group_id
      ,p_per_in_ler_id               => p_per_in_ler_id
      ,p_effective_date              => p_effective_date
      ,p_subj_to_imptd_incm_typ_cd   => 'SPS'
      ,p_imptd_incm_calc_cd          => 'SPS'
      ,p_validate                    => p_validate
      ,p_no_choice_flag              => p_no_choice_flag
      );

      hr_utility.set_location('   Calculate dependent imputed income ', 10);

    p_comp_imp_inc_internal
       (p_person_id                   => p_person_id
       ,p_enrt_mthd_cd                => p_enrt_mthd_cd
       ,p_business_group_id           => p_business_group_id
       ,p_per_in_ler_id               => p_per_in_ler_id
       ,p_effective_date              => p_effective_date
       ,p_subj_to_imptd_incm_typ_cd   => 'DPNT'
       ,p_imptd_incm_calc_cd          => 'DPNT'
       ,p_validate                    => p_validate
       ,p_no_choice_flag              => p_no_choice_flag
       );
    --
  end if;
*/

   redo_imp_inc(p_person_id          => p_person_id,
                p_enrt_mthd_cd       => p_enrt_mthd_cd,
                p_business_group_id  => p_business_group_id,
                p_per_in_ler_id      => p_per_in_ler_id,
                p_effective_date     => p_effective_date,
                p_validate           => p_validate,
                p_no_choice_flag     => FALSE);

  if p_ctrlm_fido_call then
    --
    -- Put back fnd_sessions
    --
    dt_fndate.change_ses_date
      (p_ses_date => l_ses_date,
       p_commit   => l_commit);
    --
  end if;
  --
  hr_utility.set_location(' Leaving ' || l_proc , 10);

  end p_comp_imputed_income;
--
END ben_det_imputed_income;

/
