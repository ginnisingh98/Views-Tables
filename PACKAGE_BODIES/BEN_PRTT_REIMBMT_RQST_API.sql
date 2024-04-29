--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_REIMBMT_RQST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_REIMBMT_RQST_API" as
/* $Header: beprcapi.pkb 120.4 2008/01/14 12:17:29 sallumwa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ben_PRTT_REIMBMT_RQST_api.';
--
procedure generate_communications
   ( p_submitter_person_id           in number,
     p_pl_id                         in number,
     p_prtt_reimbmt_rqst_stat_cd     in varchar2,
     p_business_group_id             in number,
     p_effective_date                in date) is
   --
   cursor  c_pen is
      select pen.pgm_id,
             pen.pl_typ_id,
             pen.ler_id,
             pen.per_in_ler_id
      from   ben_prtt_enrt_rslt_f pen
      where  pen.person_id = p_submitter_person_id
      and    pen.pl_id     = p_pl_id
      and    pen.business_group_id = p_business_group_id
      and    pen.prtt_enrt_rslt_stat_cd is null
      and    p_effective_date between
             pen.effective_start_date and pen.effective_end_date
      and    pen.enrt_cvg_thru_dt = hr_api.g_eot;
   --
   l_pen       c_pen%rowtype;
   l_proc_cd   varchar2(30) := null;
   l_proc      varchar2(72) := g_package||'generate_communications';
   --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   if p_prtt_reimbmt_rqst_stat_cd = 'PNDGPYMT' then   --- Pending Payment
      l_proc_cd := 'RMBRQST';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'PDINFL' then  --- Paid in Full
      l_proc_cd := 'RMBPYMT';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'PRTLYPD' then ---  Partilly paid
      l_proc_cd := 'RMBPRPY';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'DND' then     --- Denied
      l_proc_cd := 'RMBDND';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'APPRVD' then   --- approved
      l_proc_cd := 'RMBAPRVD';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'PDINFL' then   --- approved for fully paid
      l_proc_cd := 'RMBAPRVD';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'PRTLYPD' then   --- approved for partial payment
      l_proc_cd := 'RMBAPRVD';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'PNDNG' then   --- Pending
      l_proc_cd := 'RMBPNDG';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'INAPEL' then   --- in appeal
      l_proc_cd := 'RMBNAPEL';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'VOIDED' then   --- Voided
      l_proc_cd := 'RMBVOID';
   elsif p_prtt_reimbmt_rqst_stat_cd = 'DPLICT' then   --- duplicate
      l_proc_cd := 'RMBDPLCT';
   else
      hr_utility.set_location('Leaving:'|| l_proc, 15);
      return;
   end if;
   --
   hr_utility.set_location( l_proc, 20);
   --
   open  c_pen;
   fetch c_pen into l_pen;
   --
   if c_pen%found then
      --
      -- Add environment init procedure
      --
      -- Work out if we are being called from a concurrent program
      -- otherwise we need to initialize the environment
      --
      if fnd_global.conc_request_id = -1 then
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
      ben_generate_communications.main
          (p_person_id             => p_submitter_person_id,
           -- CWB Changes.
           p_per_in_ler_id         => l_pen.per_in_ler_id,
           p_pl_id                 => p_pl_id,
           p_pl_typ_id             => l_pen.pl_typ_id,
           p_pgm_id                => l_pen.pgm_id,
           p_ler_id                => l_pen.ler_id,
           p_business_group_id     => p_business_group_id,
           p_proc_cd1              => l_proc_cd,
           p_effective_date        => p_effective_date);
      --
   end if;
   --
   close c_pen;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);
   --
end generate_communications;
--
procedure find_pymt_amt (p_effective_date date,
                         p_prtt_reimbmt_rqst_id number,
                         p_business_group_id number,
                         p_pymt_amt in out nocopy number) is
  --

  l_proc   varchar2(72) := g_package || 'find_pymt_amt';

  cursor c_prc is
     select nvl(prc.aprvd_for_pymt_amt,prc.rqst_amt),
            prc.popl_yr_perd_id_1,
            prc.popl_yr_perd_id_2,
            prc.amt_year1,
            prc.amt_year2
     from ben_prtt_reimbmt_rqst_f prc
     where  p_prtt_reimbmt_rqst_id  = prc.prtt_reimbmt_rqst_id
       and   p_business_group_id    = prc.business_group_id
       and   p_effective_Date between prc.effective_start_date
             and prc.effective_end_date ;

   l_rqst_amt       number ;
   l_total_pymt_amt number ;
   l_popl_yr_perd_id_1  number;
   l_popl_yr_perd_id_2  number;
--

  cursor c_pl_info is
  select pl.pl_id
        ,pl.cmpr_clms_to_cvg_or_bal_cd
        ,prc.SUBMITTER_PERSON_ID
        ,prc.PRTT_ENRT_RSLT_ID
        ,prc.EXP_INCURD_DT
  from  ben_prtt_reimbmt_rqst_f prc,
        ben_pl_f pl
  where prc.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and pl.pl_id  = prc.pl_id
    and prc.EXP_INCURD_DT   between  pl.effective_start_date
        and pl.effective_end_date ;


  cursor c_yr_amount (p_pl_id  number ,
                      p_person_id  number,
                      p_popl_yr_perd number ) is
   select sum(nvl(pry.APRVD_FR_PYMT_AMT,0))
                from   ben_prtt_reimbmt_rqst_f prc,
                       ben_prtt_rmt_aprvd_fr_pymt_f pry
                where  prc.submitter_person_id = p_person_id
                and    prc.prtt_reimbmt_rqst_stat_cd not in ('DND','VOIDED','DPLICT')
                and    p_pl_id                = prc.pl_id
                and    ((prc.popl_yr_perd_id_1 = p_popl_yr_perd and
                       prc.amt_year2 is null) or
                       (prc.popl_yr_perd_id_2 = p_popl_yr_perd
                       and prc.amt_year1 is null))
                and    prc.effective_end_date  = hr_api.g_eot
                and    prc.prtt_reimbmt_rqst_id = pry.prtt_reimbmt_rqst_id
                ;
  cursor c_prc_overlap(p_pl_id  number ,
                      p_person_id  number,
                      p_popl_yr_perd number ) is
    select prtt_reimbmt_rqst_id,
           popl_yr_perd_id_1,
           popl_yr_perd_id_2,
           amt_year1,
           amt_year2
    from ben_prtt_reimbmt_rqst_f prc
    where prc.submitter_person_id = p_person_id
    and  prc.prtt_reimbmt_rqst_stat_cd not in ('DND','VOIDED','DPLICT')
    and  p_pl_id                = prc.pl_id
    and (( prc.popl_yr_perd_id_1 = p_popl_yr_perd and prc.amt_year2 is not null)
        or (prc.popl_yr_perd_id_2 = p_popl_yr_perd and prc.amt_year1 is not null))
   ;
  l_prc_overlap   c_prc_overlap%rowtype;
  --
  cursor c_paid_amt (p_prtt_reimbmt_rqst_id number) is
    select sum(nvl(pry.APRVD_FR_PYMT_AMT,0))
    from ben_prtt_rmt_aprvd_fr_pymt_f pry
    where pry.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id;
  --
   l_paid_amt  number;
   l_pl_info  c_pl_info%rowtype ;
   --
   cursor c_yr_perd(p_popl_yr_perd_id number) is
     select END_DATE
     from ben_yr_perd yrp,
          ben_popl_yr_perd cpy
     where cpy.popl_yr_perd_id = p_popl_yr_perd_id
     and   cpy.yr_perd_id = yrp.yr_perd_id;
   --
   l_yr_end   date;
   l_amt_year1  number;
   l_amt_year2  number;
   l_rqst_amt_1  number;

begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
   open c_prc ;
   fetch c_prc into l_rqst_amt,l_popl_yr_perd_id_1,l_popl_yr_perd_id_2,
                    l_amt_year1,l_amt_year2 ;
   close c_prc ;

   hr_utility.set_location( 'reimbursement id' || p_prtt_reimbmt_rqst_id  , 11);
  open c_pl_info ;
  fetch c_pl_info into l_pl_info ;
  close c_pl_info ;
  hr_utility.set_location(' bal type '|| l_pl_info.cmpr_clms_to_cvg_or_bal_cd ,20);
  if l_pl_info.cmpr_clms_to_cvg_or_bal_cd = 'BAL' then
     -- not in grace period or claim is in only for current year
    if l_popl_yr_perd_id_2 is null or (l_popl_yr_perd_id_2 is not null and
               l_amt_year1 is null) then
      --
      l_total_pymt_amt :=  ben_prc_bus.get_year_balance (
              p_person_id            =>   l_pl_info.submitter_person_id
             ,p_pgm_id               =>   null
             ,p_pl_id                =>   l_pl_info.pl_id
             ,p_business_group_id    =>   p_business_group_id
             ,p_per_in_ler_id        =>   null
             ,p_prtt_enrt_rslt_id    =>   l_pl_info.prtt_enrt_rslt_id
             ,p_effective_date       =>   p_effective_date
             ,p_exp_incurd_dt        =>   l_pl_info.exp_incurd_dt
              ) ;
        hr_utility.set_location(' balance  '|| l_total_pymt_amt  ,20);
        --
        if l_popl_yr_perd_id_2 is null then
          open c_yr_amount(l_pl_info.pl_id  ,
                           l_pl_info.submitter_person_id ,
                           l_popl_yr_perd_id_1 )  ;
          fetch  c_yr_amount into  l_rqst_amt ;
          close c_yr_amount ;
          --
          open c_prc_overlap(l_pl_info.pl_id  ,
                           l_pl_info.submitter_person_id ,
                           l_popl_yr_perd_id_1 )  ;
          fetch c_prc_overlap into l_prc_overlap;
          close c_prc_overlap;
          --
          --
          if l_prc_overlap.prtt_reimbmt_rqst_id is not null then
            open c_paid_amt(l_prc_overlap.prtt_reimbmt_rqst_id);
            fetch c_paid_amt into l_paid_amt;
            close c_paid_amt;
          end if;
          if l_paid_amt > 0 then
            hr_utility.set_location ('Paid Amount '||l_paid_amt,10);
            if l_prc_overlap.popl_yr_perd_id_1 = l_popl_yr_perd_id_1 then
              --
              l_rqst_amt := l_rqst_amt + least(l_paid_amt,l_prc_overlap.amt_year1);
            elsif
              --
              l_prc_overlap.popl_yr_perd_id_2 = l_popl_yr_perd_id_1 then
              --
              l_rqst_amt := l_rqst_amt + least((l_paid_amt - l_prc_overlap.amt_year1),l_prc_overlap.amt_year2);
            end if;
            --
          end if;
        else
          --
          open c_yr_amount(l_pl_info.pl_id  ,
                           l_pl_info.submitter_person_id ,
                           l_popl_yr_perd_id_2 )  ;
          fetch  c_yr_amount into  l_rqst_amt ;
          close c_yr_amount ;
          --
          open c_prc_overlap(l_pl_info.pl_id  ,
                           l_pl_info.submitter_person_id ,
                           l_popl_yr_perd_id_2 )  ;
          fetch c_prc_overlap into l_prc_overlap;
          close c_prc_overlap;
          --
          if l_prc_overlap.prtt_reimbmt_rqst_id is not null then
            open c_paid_amt(l_prc_overlap.prtt_reimbmt_rqst_id);
            fetch c_paid_amt into l_paid_amt;
            close c_paid_amt;
          end if;
          --
          if l_paid_amt > 0 then
            --
            hr_utility.set_location ('Paid Amount '||l_paid_amt,11);
            if l_prc_overlap.popl_yr_perd_id_1 = l_popl_yr_perd_id_2 then
              --
              l_rqst_amt := l_rqst_amt + least(l_paid_amt,l_prc_overlap.amt_year1);
            elsif
              --
              l_prc_overlap.popl_yr_perd_id_2 = l_popl_yr_perd_id_1 then
              --
              l_rqst_amt := l_rqst_amt + least((l_paid_amt - l_prc_overlap.amt_year1),l_prc_overlap.amt_year2);
            end if;
            --
          end if;
        end if;

        hr_utility.set_location(' total for the yr   '|| l_rqst_amt   ,20);

     else
       --
       open c_yr_perd (l_popl_yr_perd_id_1);
       fetch c_yr_perd into l_yr_end;
       close c_yr_perd;
       --
        --
       l_total_pymt_amt :=  ben_prc_bus.get_year_balance (
              p_person_id            =>   l_pl_info.submitter_person_id
             ,p_pgm_id               =>   null
             ,p_pl_id                =>   l_pl_info.pl_id
             ,p_business_group_id    =>   p_business_group_id
             ,p_per_in_ler_id        =>   null
             ,p_prtt_enrt_rslt_id    =>   l_pl_info.prtt_enrt_rslt_id
             ,p_effective_date       =>   l_yr_end
             ,p_exp_incurd_dt        =>   l_yr_end
              ) ;
       hr_utility.set_location(' prevbalance  '|| l_total_pymt_amt  ,21);
       open c_yr_amount(l_pl_info.pl_id  ,
                        l_pl_info.submitter_person_id ,
                        l_popl_yr_perd_id_1)  ;
       fetch  c_yr_amount into  l_rqst_amt ;
       close c_yr_amount ;
       --
       open c_prc_overlap(l_pl_info.pl_id  ,
                           l_pl_info.submitter_person_id ,
                           l_popl_yr_perd_id_1 )  ;
       fetch c_prc_overlap into l_prc_overlap;
       close c_prc_overlap;
       --
       if l_prc_overlap.prtt_reimbmt_rqst_id is not null then
         open c_paid_amt(l_prc_overlap.prtt_reimbmt_rqst_id);
         fetch c_paid_amt into l_paid_amt;
         close c_paid_amt;
       end if;
       --
       if l_paid_amt > 0 then
            hr_utility.set_location ('Paid Amount '||l_paid_amt,12);
         if l_prc_overlap.popl_yr_perd_id_1 = l_popl_yr_perd_id_1 then
           --
           l_rqst_amt := l_rqst_amt + least(l_paid_amt,l_prc_overlap.amt_year1);
         elsif
           --
           l_prc_overlap.popl_yr_perd_id_2 = l_popl_yr_perd_id_1 then
           --
           l_rqst_amt := l_rqst_amt + least((l_paid_amt - l_prc_overlap.amt_year1),l_prc_overlap.amt_year2);
         end if;
        --
       end if;
       hr_utility.set_location(' total for the yr   '|| l_rqst_amt   ,21);
     --
     if l_amt_year2 is not null then
       --
       l_total_pymt_amt := l_total_pymt_amt +
                            ben_prc_bus.get_year_balance (
                            p_person_id            => l_pl_info.submitter_person_id
                           ,p_pgm_id               =>   null
                           ,p_pl_id                =>   l_pl_info.pl_id
                           ,p_business_group_id    =>   p_business_group_id
                           ,p_per_in_ler_id        =>   null
                           ,p_prtt_enrt_rslt_id    =>   l_pl_info.prtt_enrt_rslt_id
                           ,p_effective_date       =>   p_effective_date
                           ,p_exp_incurd_dt        =>   l_pl_info.exp_incurd_dt
                            ) ;
       open c_yr_amount(l_pl_info.pl_id  ,
                         l_pl_info.submitter_person_id ,
                         l_popl_yr_perd_id_2)  ;
       fetch c_yr_amount into  l_rqst_amt ;
       close c_yr_amount ;
       --
       open c_prc_overlap(l_pl_info.pl_id  ,
                          l_pl_info.submitter_person_id ,
                          l_popl_yr_perd_id_1 )  ;
       fetch c_prc_overlap into l_prc_overlap;
       close c_prc_overlap;
       --
       if l_prc_overlap.prtt_reimbmt_rqst_id is not null then
         open c_paid_amt(l_prc_overlap.prtt_reimbmt_rqst_id);
         fetch c_paid_amt into l_paid_amt;
         close c_paid_amt;
       end if;
       --
       if l_paid_amt > 0 then
            hr_utility.set_location ('Paid Amount '||l_paid_amt,13);
         if l_prc_overlap.popl_yr_perd_id_1 = l_popl_yr_perd_id_1 then
           --
           l_rqst_amt := l_rqst_amt + least(l_paid_amt,l_prc_overlap.amt_year1);
         elsif
             --
             l_prc_overlap.popl_yr_perd_id_2 = l_popl_yr_perd_id_1 then
           --
           l_rqst_amt := l_rqst_amt + least((l_paid_amt - l_prc_overlap.amt_year1),l_prc_overlap.amt_year2);
         end if;
         --
       end if;
       --
     end if;


     end if;
     --

      if   nvl(l_rqst_amt,0) + nvl(p_pymt_amt,0)
           > l_total_pymt_amt  then
        -- adjust the payment to total contribution - already paid amount
        p_pymt_amt := l_total_pymt_amt - nvl(l_rqst_amt,0);

      end if ;


  end if ;

  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end find_pymt_amt;
--
procedure find_popl_yr_perd
   (p_pl_id  number,
    p_exp_incurd_dt date,
    p_effective_date date,
    p_business_group_id number,
    p_popl_yr_perd_id_1 out nocopy  number,
    p_popl_yr_perd_id_2  out nocopy number) is
 --
  cursor c1 is
    select popl_yr_perd_id
    from ben_popl_yr_perd cpy,
         ben_yr_perd yrp
    where p_exp_incurd_dt between yrp.start_date
          and nvl(cpy.PY_CLMS_THRU_DT,yrp.end_date)
    and   p_effective_date between yrp.start_date
          and nvl(cpy.ACPT_CLM_RQSTS_THRU_DT,yrp.end_date)
    and   cpy.yr_perd_id = yrp.yr_perd_id
    and   cpy.pl_id = p_pl_id
    and   cpy.business_group_id = p_business_group_id
    and   yrp.business_group_id = p_business_group_id
    order by yrp.start_date;
  --
  cnt number;
  l_popl_yr_perd_id number;
  --
begin
  --
  cnt := 1;
  open c1;
  loop
    fetch c1 into l_popl_yr_perd_id;
    if c1%found then
      if cnt = 1 then
         p_popl_yr_perd_id_1 := l_popl_yr_perd_id;
      elsif cnt = 2 then
         p_popl_yr_perd_id_2 := l_popl_yr_perd_id;
      end if;
    else
     exit;
   end if;
   cnt := cnt + 1;
   if cnt >= 3 then
     exit;
   end if;
  end loop;
  close c1;
  --
end;



-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_REIMBMT_RQST >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_REIMBMT_RQST
  (p_validate                       in  boolean   default false
  ,p_prtt_reimbmt_rqst_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_incrd_from_dt                  in  date      default null
  ,p_incrd_to_dt                    in  date      default null
  ,p_rqst_num                       in out nocopy number
  ,p_rqst_amt                       in  number    default null
  ,p_rqst_amt_uom                   in  varchar2  default null
  ,p_rqst_btch_num                  in  number    default null
  ,p_prtt_reimbmt_rqst_stat_cd      in  out nocopy varchar2
  ,p_reimbmt_ctfn_typ_prvdd_cd      in  varchar2  default null
  ,p_rcrrg_cd                       in  varchar2  default null
  ,p_submitter_person_id            in  number    default null
  ,p_recipient_person_id            in  number    default null
  ,p_provider_person_id             in  number    default null
  ,p_provider_ssn_person_id         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_gd_or_svc_typ_id               in  number    default null
  ,p_contact_relationship_id        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_popl_yr_perd_id_1              in  number    default null
  ,p_popl_yr_perd_id_2              in  number    default null
  ,p_amt_year1                      in  number    default null
  ,p_amt_year2                      in  number    default null
  ,p_prc_attribute_category         in  varchar2  default null
  ,p_prc_attribute1                 in  varchar2  default null
  ,p_prc_attribute2                 in  varchar2  default null
  ,p_prc_attribute3                 in  varchar2  default null
  ,p_prc_attribute4                 in  varchar2  default null
  ,p_prc_attribute5                 in  varchar2  default null
  ,p_prc_attribute6                 in  varchar2  default null
  ,p_prc_attribute7                 in  varchar2  default null
  ,p_prc_attribute8                 in  varchar2  default null
  ,p_prc_attribute9                 in  varchar2  default null
  ,p_prc_attribute10                in  varchar2  default null
  ,p_prc_attribute11                in  varchar2  default null
  ,p_prc_attribute12                in  varchar2  default null
  ,p_prc_attribute13                in  varchar2  default null
  ,p_prc_attribute14                in  varchar2  default null
  ,p_prc_attribute15                in  varchar2  default null
  ,p_prc_attribute16                in  varchar2  default null
  ,p_prc_attribute17                in  varchar2  default null
  ,p_prc_attribute18                in  varchar2  default null
  ,p_prc_attribute19                in  varchar2  default null
  ,p_prc_attribute20                in  varchar2  default null
  ,p_prc_attribute21                in  varchar2  default null
  ,p_prc_attribute22                in  varchar2  default null
  ,p_prc_attribute23                in  varchar2  default null
  ,p_prc_attribute24                in  varchar2  default null
  ,p_prc_attribute25                in  varchar2  default null
  ,p_prc_attribute26                in  varchar2  default null
  ,p_prc_attribute27                in  varchar2  default null
  ,p_prc_attribute28                in  varchar2  default null
  ,p_prc_attribute29                in  varchar2  default null
  ,p_prc_attribute30                in  varchar2  default null
  ,p_prtt_enrt_rslt_id              out nocopy number
  ,p_comment_id                     in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_stat_rsn_cd                    in  out nocopy varchar2
  ,p_pymt_stat_cd                   in  out nocopy varchar2
  ,p_pymt_stat_rsn_cd               in  out nocopy varchar2
  ,p_stat_ovrdn_flag                in  varchar2  default null
  ,p_stat_ovrdn_rsn_cd              in  varchar2  default null
  ,p_stat_prr_to_ovrd               in  varchar2  default null
  ,p_pymt_stat_ovrdn_flag           in  varchar2  default null
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default null
  ,p_pymt_stat_prr_to_ovrd          in  varchar2  default null
  ,p_adjmt_flag                     in  varchar2  default null
  ,p_submtd_dt                      in  date      default null
  ,p_ttl_rqst_amt                   in  number    default null
  ,p_aprvd_for_pymt_amt             in  out nocopy  number
  ,p_exp_incurd_dt		    in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor c_rslt_rec is
               select  pen.prtt_enrt_rslt_id,
                       pen.pgm_id,
                       pen.per_in_ler_id
                from   ben_prtt_enrt_rslt_f pen
                where  pen.pl_id = p_pl_id
                and    pen.prtt_enrt_rslt_stat_cd is null
                and    pen.person_id = p_submitter_person_id
                and    pen.business_group_id = p_business_group_id
                and    p_effective_date between
                       pen.effective_start_date and pen.effective_end_date
                and    p_incrd_from_dt <=  pen.enrt_cvg_thru_dt
                and    p_incrd_to_dt   >=   pen.enrt_cvg_strt_dt ;
                --and    p_effective_date between
                --       pen.enrt_cvg_strt_dt  and pen.enrt_cvg_thru_dt;
  --
   l_rslt_rec   c_rslt_rec%rowtype;
  --
   cursor c_abr_pl
   is
   select abr.acty_base_rt_id,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr
   where pl_id = p_pl_id
   and   acty_typ_cd like 'PRD%'
   and   acty_base_rt_stat_cd = 'A'
 -- and   p_effective_date between
  and     p_exp_incurd_dt  between
         abr.effective_start_date and
         abr.effective_end_date;

--- reimbursement rate can be fixed whether plan level or plan in program level
cursor c_abr_plip (p_pl_id number, p_pgm_id  number)
   is
   select abr.acty_base_rt_id,
          abr.rt_typ_cd,
          abr.tx_typ_cd,
          abr.acty_typ_cd,
          abr.rt_mlt_cd,
          abr.bnft_rt_typ_cd,
          abr.dsply_on_enrt_flag,
          abr.comp_lvl_fctr_id,
          abr.actl_prem_id,
          abr.input_value_id,
          abr.element_type_id
   from ben_acty_base_rt_f abr,
        ben_plip_f plp
   where plp.pl_id   = p_pl_id
   and   plp.pgm_id   = p_pgm_id
   and   abr.acty_base_rt_stat_cd = 'A'
   --and   p_effective_date between
   and   p_exp_incurd_dt  between
         plp.effective_start_date and
         plp.effective_end_date
   and   plp.plip_id = abr.plip_id
   and   abr.acty_typ_cd like 'PRD%'
   --and   p_effective_date between
   and   p_exp_incurd_dt  between
         abr.effective_start_date and
         abr.effective_end_date;
   --
   l_acty_base_rt      c_abr_pl%rowtype;

  l_cvg_amt_calc_mthd_id   number;
  l_prtt_rmt_aprvd_fr_pymt_id number ;
  l_prtt_reimbmt_rqst_id ben_prtt_reimbmt_rqst_f.prtt_reimbmt_rqst_id%TYPE;
  l_effective_start_date ben_prtt_reimbmt_rqst_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_reimbmt_rqst_f.effective_end_date%TYPE;
  l_effective_start_date_pymt ben_prtt_reimbmt_rqst_f.effective_start_date%TYPE;
  l_effective_end_date_pymt ben_prtt_reimbmt_rqst_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_REIMBMT_RQST';
  l_object_version_number ben_prtt_reimbmt_rqst_f.object_version_number%TYPE;
  l_object_version_number_pymt ben_prtt_reimbmt_rqst_f.object_version_number%TYPE;
  --
  l_pymt_amount   number ;
  l_popl_yr_perd_id_1  number;
  l_popl_yr_perd_id_2  number;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_REIMBMT_RQST;
  --
  hr_utility.set_location(l_proc, 20);
  --this cursor is for gettin value for resutlt id and to create prtt_rt_val
  open c_rslt_rec;
  fetch c_rslt_rec into l_rslt_rec;
  close c_rslt_rec;
  p_prtt_enrt_rslt_id := l_rslt_rec.prtt_enrt_rslt_id ;

  ---- chek for reimbursement rate
  open c_abr_plip(p_pl_id,l_rslt_rec.pgm_id);
  fetch c_abr_plip into l_acty_base_rt;
  if c_abr_plip%notfound then
     open c_abr_pl ;
     fetch c_abr_pl into l_acty_base_rt ;
     if c_abr_pl%notfound then
        close c_abr_pl;
        close c_abr_plip ;
        fnd_message.set_name('BEN','BEN_92697_NO_REMBMT_RATE');
        fnd_message.raise_error;
     end if ;
     close c_abr_pl;
  end if;
  close c_abr_plip;
  --
  --populate year period ids based on exp incurred date
  find_popl_yr_perd (p_pl_id => p_pl_id,
                     p_business_group_id => p_business_group_id,
                     p_effective_date   => p_effective_date,
                     p_exp_incurd_dt => p_exp_incurd_dt,
                     p_popl_yr_perd_id_1 => l_popl_yr_perd_id_1,
                     p_popl_yr_perd_id_2 => l_popl_yr_perd_id_2);
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk1.create_PRTT_REIMBMT_RQST_b
      (
       p_incrd_from_dt                  =>  p_incrd_from_dt
      ,p_incrd_to_dt                    =>  p_incrd_to_dt
      ,p_rqst_num                       =>  p_rqst_num
      ,p_rqst_amt                       =>  p_rqst_amt
      ,p_rqst_amt_uom                   =>  p_rqst_amt_uom
      ,p_rqst_btch_num                  =>  p_rqst_btch_num
      ,p_prtt_reimbmt_rqst_stat_cd      =>  p_prtt_reimbmt_rqst_stat_cd
      ,p_reimbmt_ctfn_typ_prvdd_cd      =>  p_reimbmt_ctfn_typ_prvdd_cd
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_submitter_person_id            =>  p_submitter_person_id
      ,p_recipient_person_id            =>  p_recipient_person_id
      ,p_provider_person_id             =>  p_provider_person_id
      ,p_provider_ssn_person_id         =>  p_provider_ssn_person_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_contact_relationship_id        =>  p_contact_relationship_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  p_opt_id
      ,p_popl_yr_perd_id_1              =>  l_popl_yr_perd_id_1
      ,p_popl_yr_perd_id_2              =>  l_popl_yr_perd_id_2
      ,p_amt_year1                      =>  p_amt_year1
      ,p_amt_year2                      =>  p_amt_year2
      ,p_prc_attribute_category         =>  p_prc_attribute_category
      ,p_prc_attribute1                 =>  p_prc_attribute1
      ,p_prc_attribute2                 =>  p_prc_attribute2
      ,p_prc_attribute3                 =>  p_prc_attribute3
      ,p_prc_attribute4                 =>  p_prc_attribute4
      ,p_prc_attribute5                 =>  p_prc_attribute5
      ,p_prc_attribute6                 =>  p_prc_attribute6
      ,p_prc_attribute7                 =>  p_prc_attribute7
      ,p_prc_attribute8                 =>  p_prc_attribute8
      ,p_prc_attribute9                 =>  p_prc_attribute9
      ,p_prc_attribute10                =>  p_prc_attribute10
      ,p_prc_attribute11                =>  p_prc_attribute11
      ,p_prc_attribute12                =>  p_prc_attribute12
      ,p_prc_attribute13                =>  p_prc_attribute13
      ,p_prc_attribute14                =>  p_prc_attribute14
      ,p_prc_attribute15                =>  p_prc_attribute15
      ,p_prc_attribute16                =>  p_prc_attribute16
      ,p_prc_attribute17                =>  p_prc_attribute17
      ,p_prc_attribute18                =>  p_prc_attribute18
      ,p_prc_attribute19                =>  p_prc_attribute19
      ,p_prc_attribute20                =>  p_prc_attribute20
      ,p_prc_attribute21                =>  p_prc_attribute21
      ,p_prc_attribute22                =>  p_prc_attribute22
      ,p_prc_attribute23                =>  p_prc_attribute23
      ,p_prc_attribute24                =>  p_prc_attribute24
      ,p_prc_attribute25                =>  p_prc_attribute25
      ,p_prc_attribute26                =>  p_prc_attribute26
      ,p_prc_attribute27                =>  p_prc_attribute27
      ,p_prc_attribute28                =>  p_prc_attribute28
      ,p_prc_attribute29                =>  p_prc_attribute29
      ,p_prc_attribute30                =>  p_prc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,P_STAT_RSN_CD                    =>  P_STAT_RSN_CD
      ,p_Pymt_stat_cd                   =>  p_Pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_stat_ovrdn_flag                =>  p_stat_ovrdn_flag
      ,p_stat_ovrdn_rsn_cd              =>  p_stat_ovrdn_rsn_cd
      ,p_stat_prr_to_ovrd               =>  p_stat_prr_to_ovrd
      ,p_pymt_stat_ovrdn_flag           =>  p_pymt_stat_ovrdn_flag
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd          =>  p_pymt_stat_prr_to_ovrd
      ,p_Adjmt_flag                     =>  p_Adjmt_flag
      ,p_Submtd_dt                      =>  trunc(p_Submtd_dt)
      ,p_Ttl_rqst_amt                   =>  p_Ttl_rqst_amt
      ,p_Aprvd_for_pymt_amt             =>  p_Aprvd_for_pymt_amt
      ,p_exp_incurd_dt			=>  p_exp_incurd_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_REIMBMT_RQST
    --
  end;
  --
  ben_prc_ins.ins
    (
     p_prtt_reimbmt_rqst_id          => l_prtt_reimbmt_rqst_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_incrd_from_dt                 => p_incrd_from_dt
    ,p_incrd_to_dt                   => p_incrd_to_dt
    ,p_rqst_num                      => p_rqst_num
    ,p_rqst_amt                      => p_rqst_amt
    ,p_rqst_amt_uom                  => p_rqst_amt_uom
    ,p_rqst_btch_num                 => p_rqst_btch_num
    ,p_prtt_reimbmt_rqst_stat_cd     => p_prtt_reimbmt_rqst_stat_cd
    ,p_reimbmt_ctfn_typ_prvdd_cd     => p_reimbmt_ctfn_typ_prvdd_cd
    ,p_rcrrg_cd                      => p_rcrrg_cd
    ,p_submitter_person_id           => p_submitter_person_id
    ,p_recipient_person_id           => p_recipient_person_id
    ,p_provider_person_id            => p_provider_person_id
    ,p_provider_ssn_person_id        => p_provider_ssn_person_id
    ,p_pl_id                         => p_pl_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_contact_relationship_id       => p_contact_relationship_id
    ,p_business_group_id             => p_business_group_id
    ,p_opt_id                        =>  p_opt_id
    ,p_popl_yr_perd_id_1             =>  l_popl_yr_perd_id_1
    ,p_popl_yr_perd_id_2             =>  l_popl_yr_perd_id_2
    ,p_amt_year1                     =>  p_amt_year1
    ,p_amt_year2                     =>  p_amt_year2
    ,p_prc_attribute_category        => p_prc_attribute_category
    ,p_prc_attribute1                => p_prc_attribute1
    ,p_prc_attribute2                => p_prc_attribute2
    ,p_prc_attribute3                => p_prc_attribute3
    ,p_prc_attribute4                => p_prc_attribute4
    ,p_prc_attribute5                => p_prc_attribute5
    ,p_prc_attribute6                => p_prc_attribute6
    ,p_prc_attribute7                => p_prc_attribute7
    ,p_prc_attribute8                => p_prc_attribute8
    ,p_prc_attribute9                => p_prc_attribute9
    ,p_prc_attribute10               => p_prc_attribute10
    ,p_prc_attribute11               => p_prc_attribute11
    ,p_prc_attribute12               => p_prc_attribute12
    ,p_prc_attribute13               => p_prc_attribute13
    ,p_prc_attribute14               => p_prc_attribute14
    ,p_prc_attribute15               => p_prc_attribute15
    ,p_prc_attribute16               => p_prc_attribute16
    ,p_prc_attribute17               => p_prc_attribute17
    ,p_prc_attribute18               => p_prc_attribute18
    ,p_prc_attribute19               => p_prc_attribute19
    ,p_prc_attribute20               => p_prc_attribute20
    ,p_prc_attribute21               => p_prc_attribute21
    ,p_prc_attribute22               => p_prc_attribute22
    ,p_prc_attribute23               => p_prc_attribute23
    ,p_prc_attribute24               => p_prc_attribute24
    ,p_prc_attribute25               => p_prc_attribute25
    ,p_prc_attribute26               => p_prc_attribute26
    ,p_prc_attribute27               => p_prc_attribute27
    ,p_prc_attribute28               => p_prc_attribute28
    ,p_prc_attribute29               => p_prc_attribute29
    ,p_prc_attribute30               => p_prc_attribute30
    ,p_prtt_enrt_rslt_id             => l_rslt_rec.prtt_enrt_rslt_id
    ,p_comment_id                    => p_comment_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,P_STAT_RSN_CD                   => P_STAT_RSN_CD
    ,p_Pymt_stat_cd                  => p_Pymt_stat_cd
    ,p_pymt_stat_rsn_cd              => p_pymt_stat_rsn_cd
    ,p_stat_ovrdn_flag               => p_stat_ovrdn_flag
    ,p_stat_ovrdn_rsn_cd             => p_stat_ovrdn_rsn_cd
    ,p_stat_prr_to_ovrd              => p_stat_prr_to_ovrd
    ,p_pymt_stat_ovrdn_flag          => p_pymt_stat_ovrdn_flag
    ,p_pymt_stat_ovrdn_rsn_cd        => p_pymt_stat_ovrdn_rsn_cd
    ,p_pymt_stat_prr_to_ovrd         => p_pymt_stat_prr_to_ovrd
    ,p_Adjmt_flag                    => p_Adjmt_flag
    ,p_Submtd_dt                     => trunc(p_Submtd_dt)
    ,p_Ttl_rqst_amt                  => p_Ttl_rqst_amt
    ,p_Aprvd_for_pymt_amt            => p_Aprvd_for_pymt_amt
    ,p_pymt_amount                   => l_pymt_amount
    ,p_exp_incurd_dt		     => p_exp_incurd_dt
    );
   --hr_utility.set_location('after ins in api  ' || p_prtt_reimbmt_rqst_stat_cd, 110);
   --hr_utility.set_location('after ins status  ' || P_STAT_RSN_CD, 110);
   --hr_utility.set_location('after ins in api  ' || p_Pymt_stat_cd, 110);
   --hr_utility.set_location('after ins status  ' || p_pymt_stat_rsn_cd, 110);


  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk1.create_PRTT_REIMBMT_RQST_a
      (
       p_prtt_reimbmt_rqst_id           =>  l_prtt_reimbmt_rqst_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_incrd_from_dt                  =>  p_incrd_from_dt
      ,p_incrd_to_dt                    =>  p_incrd_to_dt
      ,p_rqst_num                       =>  p_rqst_num
      ,p_rqst_amt                       =>  p_rqst_amt
      ,p_rqst_amt_uom                   =>  p_rqst_amt_uom
      ,p_rqst_btch_num                  =>  p_rqst_btch_num
      ,p_prtt_reimbmt_rqst_stat_cd      =>  p_prtt_reimbmt_rqst_stat_cd
      ,p_reimbmt_ctfn_typ_prvdd_cd      =>  p_reimbmt_ctfn_typ_prvdd_cd
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_submitter_person_id            =>  p_submitter_person_id
      ,p_recipient_person_id            =>  p_recipient_person_id
      ,p_provider_person_id             =>  p_provider_person_id
      ,p_provider_ssn_person_id         =>  p_provider_ssn_person_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_contact_relationship_id        =>  p_contact_relationship_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  p_opt_id
      ,p_popl_yr_perd_id_1              =>  l_popl_yr_perd_id_1
      ,p_popl_yr_perd_id_2              =>  l_popl_yr_perd_id_2
      ,p_amt_year1                      =>  p_amt_year1
      ,p_amt_year2                      =>  p_amt_year2
      ,p_prc_attribute_category         =>  p_prc_attribute_category
      ,p_prc_attribute1                 =>  p_prc_attribute1
      ,p_prc_attribute2                 =>  p_prc_attribute2
      ,p_prc_attribute3                 =>  p_prc_attribute3
      ,p_prc_attribute4                 =>  p_prc_attribute4
      ,p_prc_attribute5                 =>  p_prc_attribute5
      ,p_prc_attribute6                 =>  p_prc_attribute6
      ,p_prc_attribute7                 =>  p_prc_attribute7
      ,p_prc_attribute8                 =>  p_prc_attribute8
      ,p_prc_attribute9                 =>  p_prc_attribute9
      ,p_prc_attribute10                =>  p_prc_attribute10
      ,p_prc_attribute11                =>  p_prc_attribute11
      ,p_prc_attribute12                =>  p_prc_attribute12
      ,p_prc_attribute13                =>  p_prc_attribute13
      ,p_prc_attribute14                =>  p_prc_attribute14
      ,p_prc_attribute15                =>  p_prc_attribute15
      ,p_prc_attribute16                =>  p_prc_attribute16
      ,p_prc_attribute17                =>  p_prc_attribute17
      ,p_prc_attribute18                =>  p_prc_attribute18
      ,p_prc_attribute19                =>  p_prc_attribute19
      ,p_prc_attribute20                =>  p_prc_attribute20
      ,p_prc_attribute21                =>  p_prc_attribute21
      ,p_prc_attribute22                =>  p_prc_attribute22
      ,p_prc_attribute23                =>  p_prc_attribute23
      ,p_prc_attribute24                =>  p_prc_attribute24
      ,p_prc_attribute25                =>  p_prc_attribute25
      ,p_prc_attribute26                =>  p_prc_attribute26
      ,p_prc_attribute27                =>  p_prc_attribute27
      ,p_prc_attribute28                =>  p_prc_attribute28
      ,p_prc_attribute29                =>  p_prc_attribute29
      ,p_prc_attribute30                =>  p_prc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,P_STAT_RSN_CD                    =>  P_STAT_RSN_CD
      ,p_Pymt_stat_cd                   =>  p_Pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_stat_ovrdn_flag                =>  p_stat_ovrdn_flag
      ,p_stat_ovrdn_rsn_cd              =>  p_stat_ovrdn_rsn_cd
      ,p_stat_prr_to_ovrd               =>  p_stat_prr_to_ovrd
      ,p_pymt_stat_ovrdn_flag           =>  p_pymt_stat_ovrdn_flag
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd          =>  p_pymt_stat_prr_to_ovrd
      ,p_Adjmt_flag                     =>  p_Adjmt_flag
      ,p_Submtd_dt                      =>  trunc(p_Submtd_dt)
      ,p_Ttl_rqst_amt                   =>  p_Ttl_rqst_amt
      ,p_Aprvd_for_pymt_amt             =>  p_Aprvd_for_pymt_amt
      ,p_exp_incurd_dt			=>  p_exp_incurd_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_REIMBMT_RQST
    --
  end;
  --
  --- Create payment entry only when  approved
  hr_utility.set_location(' Payable Amount in api '|| l_pymt_amount, 110);
  if  p_prtt_reimbmt_rqst_stat_cd in ('APPRVD','PDINFL','PRTLYPD')  then
        --bug#5527088
        find_pymt_amt (  p_effective_date => p_effective_date,
                         p_prtt_reimbmt_rqst_id => p_prtt_reimbmt_rqst_id,
                         p_business_group_id => p_business_group_id,
                         p_pymt_amt => l_pymt_amount);
        --
        if nvl(l_pymt_amount,0) <> 0 then
            ben_prtt_rmt_aprvd_pymt_api.create_prtt_rmt_aprvd_pymt
              (p_validate                       => p_validate
              ,p_prtt_rmt_aprvd_fr_pymt_id      => l_prtt_rmt_aprvd_fr_pymt_id
              ,p_prtt_reimbmt_rqst_id           => p_prtt_reimbmt_rqst_id
              ,p_effective_start_date           => l_effective_start_date_pymt
              ,p_effective_end_date             => l_effective_end_date_pymt
              ,p_adjmt_flag                     => 'N'
              ,p_aprvd_fr_pymt_amt              => l_pymt_amount
              ,p_business_group_id              => p_business_group_id
              ,p_object_version_number          => l_object_version_number_pymt
              ,p_effective_date                  => p_effective_date
            );
         end if ;

   end if ;

   hr_utility.set_location(l_proc, 135);
   if p_prtt_reimbmt_rqst_stat_cd is not null then
      generate_communications(
        p_submitter_person_id        => p_submitter_person_id,
        p_pl_id                      => p_pl_id,
        p_prtt_reimbmt_rqst_stat_cd  => p_prtt_reimbmt_rqst_stat_cd,
        p_business_group_id          => p_business_group_id,
        p_effective_date             => p_effective_date);
  end if ;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_prtt_reimbmt_rqst_id := l_prtt_reimbmt_rqst_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_PRTT_REIMBMT_RQST;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_reimbmt_rqst_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_REIMBMT_RQST;
    raise;
    --
end create_PRTT_REIMBMT_RQST;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_REIMBMT_RQST >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_REIMBMT_RQST
  (p_validate                       in  boolean   default false
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_incrd_from_dt                  in  date      default hr_api.g_date
  ,p_incrd_to_dt                    in  date      default hr_api.g_date
  ,p_rqst_num                       in  number    default hr_api.g_number
  ,p_rqst_amt                       in  number    default hr_api.g_number
  ,p_rqst_amt_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_rqst_btch_num                  in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_stat_cd      in  out nocopy varchar2
  ,p_reimbmt_ctfn_typ_prvdd_cd      in  varchar2  default hr_api.g_varchar2
  ,p_rcrrg_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_submitter_person_id            in  number    default hr_api.g_number
  ,p_recipient_person_id            in  number    default hr_api.g_number
  ,p_provider_person_id             in  number    default hr_api.g_number
  ,p_provider_ssn_person_id         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_gd_or_svc_typ_id               in  number    default hr_api.g_number
  ,p_contact_relationship_id        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_popl_yr_perd_id_1              in  number    default hr_api.g_number
  ,p_popl_yr_perd_id_2              in  number    default hr_api.g_number
  ,p_amt_year1                      in  number    default hr_api.g_number
  ,p_amt_year2                      in  number    default hr_api.g_number
  ,p_prc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_comment_id                     in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_stat_rsn_cd                    in  out nocopy varchar2
  ,p_pymt_stat_cd                   in  out nocopy varchar2
  ,p_pymt_stat_rsn_cd               in  out nocopy varchar2
  ,p_stat_ovrdn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_stat_ovrdn_rsn_cd              in  varchar2  default hr_api.g_varchar2
  ,p_stat_prr_to_ovrd               in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_ovrdn_flag           in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2  default hr_api.g_varchar2
  ,p_pymt_stat_prr_to_ovrd          in  varchar2  default hr_api.g_varchar2
  ,p_Adjmt_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_Submtd_dt                      in  date      default hr_api.g_date
  ,p_Ttl_rqst_amt                   in  number    default hr_api.g_number
  ,p_Aprvd_for_pymt_amt             in  out nocopy number
  ,p_exp_incurd_dt		    in  date      default hr_api.g_date
  ) is
  -- DECLARE CURSORS
  --- Select old information to find the status
  Cursor c_prcold is
  select prc.*
  From  ben_prtt_reimbmt_rqst_f  prc
  where prc.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and  p_effective_date between
         prc.effective_start_date and
         prc.effective_end_date;
  l_prc_old c_prcold%rowtype ;
  --
  -- bug fix 2223214
  --
  l_prtt_rmt_aprvd_pymt_id number;
  l_pry_ovn number;
  l_pry_eff_strt_dt date;
  l_pry_eff_end_dt date;
  --
  cursor c_pry is
    select pry.prtt_rmt_aprvd_fr_pymt_id
         , pry.object_version_number
    from ben_prtt_rmt_aprvd_fr_pymt_f pry
    where pry.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id;
  --
  -- end fix 2223214
  --

  -- Declare cursors and local variables

  l_prtt_rmt_aprvd_fr_pymt_id number ;
  l_proc varchar2(72) := g_package||'update_PRTT_REIMBMT_RQST';
  l_object_version_number ben_prtt_reimbmt_rqst_f.object_version_number%TYPE;
  l_object_version_number_pymt  ben_prtt_reimbmt_rqst_f.object_version_number%TYPE;
  l_effective_start_date  ben_prtt_reimbmt_rqst_f.effective_start_date%TYPE;
  l_effective_end_date    ben_prtt_reimbmt_rqst_f.effective_end_date%TYPE;
  l_effective_start_date_pymt  ben_prtt_reimbmt_rqst_f.effective_start_date%TYPE;
  l_effective_end_date_pymt    ben_prtt_reimbmt_rqst_f.effective_end_date%TYPE;
  --
  l_dummy_number          number;
  l_pymt_amount           number ;
  l_popl_yr_perd_id_1     number := p_popl_yr_perd_id_1;
  l_popl_yr_perd_id_2     number := p_popl_yr_perd_id_2;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_REIMBMT_RQST;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  ----Get all before update data of reimbursement
  open c_prcold ;
  fetch c_prcold into l_prc_old ;
  close c_prcold ;
  --
  l_object_version_number := p_object_version_number;
  --
  if p_exp_incurd_dt <> hr_api.g_date then
    find_popl_yr_perd (p_pl_id => p_pl_id,
                     p_business_group_id => p_business_group_id,
                     p_effective_date => l_prc_old.SUBMTD_DT,
                     p_exp_incurd_dt => p_exp_incurd_dt,
                     p_popl_yr_perd_id_1 => l_popl_yr_perd_id_1,
                     p_popl_yr_perd_id_2 => l_popl_yr_perd_id_2);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk2.update_PRTT_REIMBMT_RQST_b
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_incrd_from_dt                  =>  p_incrd_from_dt
      ,p_incrd_to_dt                    =>  p_incrd_to_dt
      ,p_rqst_num                       =>  p_rqst_num
      ,p_rqst_amt                       =>  p_rqst_amt
      ,p_rqst_amt_uom                   =>  p_rqst_amt_uom
      ,p_rqst_btch_num                  =>  p_rqst_btch_num
      ,p_prtt_reimbmt_rqst_stat_cd      =>  p_prtt_reimbmt_rqst_stat_cd
      ,p_reimbmt_ctfn_typ_prvdd_cd      =>  p_reimbmt_ctfn_typ_prvdd_cd
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_submitter_person_id            =>  p_submitter_person_id
      ,p_recipient_person_id            =>  p_recipient_person_id
      ,p_provider_person_id             =>  p_provider_person_id
      ,p_provider_ssn_person_id         =>  p_provider_ssn_person_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_contact_relationship_id        =>  p_contact_relationship_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  p_opt_id
      ,p_popl_yr_perd_id_1              =>  l_popl_yr_perd_id_1
      ,p_popl_yr_perd_id_2              =>  l_popl_yr_perd_id_2
      ,p_amt_year1                      =>  p_amt_year1
      ,p_amt_year2                      =>  p_amt_year2
      ,p_prc_attribute_category         =>  p_prc_attribute_category
      ,p_prc_attribute1                 =>  p_prc_attribute1
      ,p_prc_attribute2                 =>  p_prc_attribute2
      ,p_prc_attribute3                 =>  p_prc_attribute3
      ,p_prc_attribute4                 =>  p_prc_attribute4
      ,p_prc_attribute5                 =>  p_prc_attribute5
      ,p_prc_attribute6                 =>  p_prc_attribute6
      ,p_prc_attribute7                 =>  p_prc_attribute7
      ,p_prc_attribute8                 =>  p_prc_attribute8
      ,p_prc_attribute9                 =>  p_prc_attribute9
      ,p_prc_attribute10                =>  p_prc_attribute10
      ,p_prc_attribute11                =>  p_prc_attribute11
      ,p_prc_attribute12                =>  p_prc_attribute12
      ,p_prc_attribute13                =>  p_prc_attribute13
      ,p_prc_attribute14                =>  p_prc_attribute14
      ,p_prc_attribute15                =>  p_prc_attribute15
      ,p_prc_attribute16                =>  p_prc_attribute16
      ,p_prc_attribute17                =>  p_prc_attribute17
      ,p_prc_attribute18                =>  p_prc_attribute18
      ,p_prc_attribute19                =>  p_prc_attribute19
      ,p_prc_attribute20                =>  p_prc_attribute20
      ,p_prc_attribute21                =>  p_prc_attribute21
      ,p_prc_attribute22                =>  p_prc_attribute22
      ,p_prc_attribute23                =>  p_prc_attribute23
      ,p_prc_attribute24                =>  p_prc_attribute24
      ,p_prc_attribute25                =>  p_prc_attribute25
      ,p_prc_attribute26                =>  p_prc_attribute26
      ,p_prc_attribute27                =>  p_prc_attribute27
      ,p_prc_attribute28                =>  p_prc_attribute28
      ,p_prc_attribute29                =>  p_prc_attribute29
      ,p_prc_attribute30                =>  p_prc_attribute30
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_comment_id                     =>  p_comment_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,P_STAT_RSN_CD                    =>  P_STAT_RSN_CD
      ,p_Pymt_stat_cd                   =>  p_Pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_stat_ovrdn_flag                =>  p_stat_ovrdn_flag
      ,p_stat_ovrdn_rsn_cd              =>  p_stat_ovrdn_rsn_cd
      ,p_stat_prr_to_ovrd               =>  p_stat_prr_to_ovrd
      ,p_pymt_stat_ovrdn_flag           =>  p_pymt_stat_ovrdn_flag
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd          =>  p_pymt_stat_prr_to_ovrd
      ,p_Adjmt_flag                     =>  p_Adjmt_flag
      ,p_Submtd_dt                      =>  trunc(p_Submtd_dt)
      ,p_Ttl_rqst_amt                   =>  p_Ttl_rqst_amt
      ,p_Aprvd_for_pymt_amt             =>  p_Aprvd_for_pymt_amt
      ,p_exp_incurd_dt			=>  p_exp_incurd_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_REIMBMT_RQST
    --
  end;
  --
  ben_prc_upd.upd
    (
     p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_incrd_from_dt                 => p_incrd_from_dt
    ,p_incrd_to_dt                   => p_incrd_to_dt
    ,p_rqst_num                      => p_rqst_num
    ,p_rqst_amt                      => p_rqst_amt
    ,p_rqst_amt_uom                  => p_rqst_amt_uom
    ,p_rqst_btch_num                 => p_rqst_btch_num
    ,p_prtt_reimbmt_rqst_stat_cd     => p_prtt_reimbmt_rqst_stat_cd
    ,p_reimbmt_ctfn_typ_prvdd_cd     => p_reimbmt_ctfn_typ_prvdd_cd
    ,p_rcrrg_cd                      => p_rcrrg_cd
    ,p_submitter_person_id           => p_submitter_person_id
    ,p_recipient_person_id           => p_recipient_person_id
    ,p_provider_person_id            => p_provider_person_id
    ,p_provider_ssn_person_id        => p_provider_ssn_person_id
    ,p_pl_id                         => p_pl_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_contact_relationship_id       => p_contact_relationship_id
    ,p_business_group_id             => p_business_group_id
    ,p_opt_id                        => p_opt_id
    ,p_popl_yr_perd_id_1             => l_popl_yr_perd_id_1
    ,p_popl_yr_perd_id_2             => l_popl_yr_perd_id_2
    ,p_amt_year1                     => p_amt_year1
    ,p_amt_year2                     => p_amt_year2
    ,p_prc_attribute_category        => p_prc_attribute_category
    ,p_prc_attribute1                => p_prc_attribute1
    ,p_prc_attribute2                => p_prc_attribute2
    ,p_prc_attribute3                => p_prc_attribute3
    ,p_prc_attribute4                => p_prc_attribute4
    ,p_prc_attribute5                => p_prc_attribute5
    ,p_prc_attribute6                => p_prc_attribute6
    ,p_prc_attribute7                => p_prc_attribute7
    ,p_prc_attribute8                => p_prc_attribute8
    ,p_prc_attribute9                => p_prc_attribute9
    ,p_prc_attribute10               => p_prc_attribute10
    ,p_prc_attribute11               => p_prc_attribute11
    ,p_prc_attribute12               => p_prc_attribute12
    ,p_prc_attribute13               => p_prc_attribute13
    ,p_prc_attribute14               => p_prc_attribute14
    ,p_prc_attribute15               => p_prc_attribute15
    ,p_prc_attribute16               => p_prc_attribute16
    ,p_prc_attribute17               => p_prc_attribute17
    ,p_prc_attribute18               => p_prc_attribute18
    ,p_prc_attribute19               => p_prc_attribute19
    ,p_prc_attribute20               => p_prc_attribute20
    ,p_prc_attribute21               => p_prc_attribute21
    ,p_prc_attribute22               => p_prc_attribute22
    ,p_prc_attribute23               => p_prc_attribute23
    ,p_prc_attribute24               => p_prc_attribute24
    ,p_prc_attribute25               => p_prc_attribute25
    ,p_prc_attribute26               => p_prc_attribute26
    ,p_prc_attribute27               => p_prc_attribute27
    ,p_prc_attribute28               => p_prc_attribute28
    ,p_prc_attribute29               => p_prc_attribute29
    ,p_prc_attribute30               => p_prc_attribute30
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_comment_id                    => p_comment_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,P_STAT_RSN_CD                   =>  P_STAT_RSN_CD
    ,p_Pymt_stat_cd                  =>  p_Pymt_stat_cd
    ,p_pymt_stat_rsn_cd              =>  p_pymt_stat_rsn_cd
    ,p_stat_ovrdn_flag               =>  p_stat_ovrdn_flag
    ,p_stat_ovrdn_rsn_cd             =>  p_stat_ovrdn_rsn_cd
    ,p_stat_prr_to_ovrd              =>  p_stat_prr_to_ovrd
    ,p_pymt_stat_ovrdn_flag          =>  p_pymt_stat_ovrdn_flag
    ,p_pymt_stat_ovrdn_rsn_cd        =>  p_pymt_stat_ovrdn_rsn_cd
    ,p_pymt_stat_prr_to_ovrd         =>  p_pymt_stat_prr_to_ovrd
    ,p_Adjmt_flag                    =>  p_Adjmt_flag
    ,p_Submtd_dt                     =>  trunc(p_Submtd_dt)
    ,p_Ttl_rqst_amt                  =>  p_Ttl_rqst_amt
    ,p_Aprvd_for_pymt_amt            =>  p_Aprvd_for_pymt_amt
    ,p_pymt_amount                   =>  l_pymt_amount
    ,p_exp_incurd_dt		     =>  p_exp_incurd_dt
    );
  --
   --hr_utility.set_location('after upd  in api  ' || p_prtt_reimbmt_rqst_stat_cd, 110);
   --hr_utility.set_location('after ins in api  ' || P_STAT_RSN_CD, 110);
   --hr_utility.set_location('after ins in api  ' || p_Pymt_stat_cd, 110);
   --hr_utility.set_location('after ins status  ' || p_pymt_stat_rsn_cd, 110);

  --
  -- bug fix 2223214
  -- when the user tries to move from an approved status to any of the unapproved
  -- status (taking into consideration that run result values are already checked for
  -- in the PLD), we have to delete the reimbursement payment records, rate value records,
  -- and element entry and their corresponding value records for this
  -- participant reimbursement request which had been earlier approved.
  --

  if nvl(p_prtt_reimbmt_rqst_stat_cd,'-1')  not in ('APPRVD','PDINFL','PRTLYPD')  and
        nvl(l_prc_old.prtt_reimbmt_rqst_stat_cd,'-1') in  ('APPRVD','PDINFL','PRTLYPD')  then
    --
    hr_utility.set_location(l_proc, 30);
    --
    open c_pry;
    loop
      --
      fetch c_pry into l_prtt_rmt_aprvd_pymt_id
    		   , l_pry_ovn;
      --
      hr_utility.set_location(l_proc, 40);
      hr_utility.set_location(' l_prtt_rmt_aprvd_pymt_id is ' || l_prtt_rmt_aprvd_pymt_id , 999);
      --
      if c_pry%found then
        --
        -- delete reimbursement payment records
        --
        ben_prtt_rmt_aprvd_pymt_api.delete_prtt_rmt_aprvd_pymt
        (p_prtt_rmt_aprvd_fr_pymt_id  => l_prtt_rmt_aprvd_pymt_id,
         p_effective_start_date       => l_pry_eff_strt_dt,
         p_effective_end_date         => l_pry_eff_end_dt,
         p_object_version_number      => l_pry_ovn,
         p_effective_date             => p_effective_date,
         p_datetrack_mode             => 'ZAP'
        );
        --
      else
        --
        exit;
        --
      end if;
      --
    end loop;
    close c_pry;
    --
    hr_utility.set_location(l_proc, 50);
    --
  end if;

  --
  -- end fix 2223214
  --

  hr_utility.set_location(' Payable Amount in api '|| l_pymt_amount, 110);
  if nvl(p_prtt_reimbmt_rqst_stat_cd,'-1')  in ('APPRVD','PDINFL','PRTLYPD')  and
        nvl(l_prc_old.prtt_reimbmt_rqst_stat_cd,'-1') not in  ('APPRVD','PDINFL','PRTLYPD')  then
      --bug#5527088
        find_pymt_amt (  p_effective_date => p_effective_date,
                         p_prtt_reimbmt_rqst_id => p_prtt_reimbmt_rqst_id,
                         p_business_group_id => p_business_group_id,
                         p_pymt_amt => l_pymt_amount);

      if nvl(l_pymt_amount,0) <> 0 then
         -- Once the Amount is approved create the Payment
         ben_prtt_rmt_aprvd_pymt_api.create_prtt_rmt_aprvd_pymt
           (p_validate                       => false
           ,p_prtt_rmt_aprvd_fr_pymt_id      => l_prtt_rmt_aprvd_fr_pymt_id
           ,p_prtt_reimbmt_rqst_id           => p_prtt_reimbmt_rqst_id
           ,p_effective_start_date           => l_effective_start_date_pymt
           ,p_effective_end_date             => l_effective_end_date_pymt
           ,p_adjmt_flag                     => 'N'
           ,p_aprvd_fr_pymt_amt              => l_pymt_amount
           ,p_business_group_id              => p_business_group_id
           ,p_object_version_number          => l_object_version_number_pymt
           ,p_effective_date                 => p_effective_date
           );
       end if ;
       --
  end if;

  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk2.update_PRTT_REIMBMT_RQST_a
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_incrd_from_dt                  =>  p_incrd_from_dt
      ,p_incrd_to_dt                    =>  p_incrd_to_dt
      ,p_rqst_num                       =>  p_rqst_num
      ,p_rqst_amt                       =>  p_rqst_amt
      ,p_rqst_amt_uom                   =>  p_rqst_amt_uom
      ,p_rqst_btch_num                  =>  p_rqst_btch_num
      ,p_prtt_reimbmt_rqst_stat_cd      =>  p_prtt_reimbmt_rqst_stat_cd
      ,p_reimbmt_ctfn_typ_prvdd_cd      =>  p_reimbmt_ctfn_typ_prvdd_cd
      ,p_rcrrg_cd                       =>  p_rcrrg_cd
      ,p_submitter_person_id            =>  p_submitter_person_id
      ,p_recipient_person_id            =>  p_recipient_person_id
      ,p_provider_person_id             =>  p_provider_person_id
      ,p_provider_ssn_person_id         =>  p_provider_ssn_person_id
      ,p_pl_id                          =>  p_pl_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_contact_relationship_id        =>  p_contact_relationship_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  p_opt_id
      ,p_popl_yr_perd_id_1              =>  l_popl_yr_perd_id_1
      ,p_popl_yr_perd_id_2              =>  l_popl_yr_perd_id_2
      ,p_amt_year1                      =>  p_amt_year1
      ,p_amt_year2                      =>  p_amt_year2
      ,p_prc_attribute_category         =>  p_prc_attribute_category
      ,p_prc_attribute1                 =>  p_prc_attribute1
      ,p_prc_attribute2                 =>  p_prc_attribute2
      ,p_prc_attribute3                 =>  p_prc_attribute3
      ,p_prc_attribute4                 =>  p_prc_attribute4
      ,p_prc_attribute5                 =>  p_prc_attribute5
      ,p_prc_attribute6                 =>  p_prc_attribute6
      ,p_prc_attribute7                 =>  p_prc_attribute7
      ,p_prc_attribute8                 =>  p_prc_attribute8
      ,p_prc_attribute9                 =>  p_prc_attribute9
      ,p_prc_attribute10                =>  p_prc_attribute10
      ,p_prc_attribute11                =>  p_prc_attribute11
      ,p_prc_attribute12                =>  p_prc_attribute12
      ,p_prc_attribute13                =>  p_prc_attribute13
      ,p_prc_attribute14                =>  p_prc_attribute14
      ,p_prc_attribute15                =>  p_prc_attribute15
      ,p_prc_attribute16                =>  p_prc_attribute16
      ,p_prc_attribute17                =>  p_prc_attribute17
      ,p_prc_attribute18                =>  p_prc_attribute18
      ,p_prc_attribute19                =>  p_prc_attribute19
      ,p_prc_attribute20                =>  p_prc_attribute20
      ,p_prc_attribute21                =>  p_prc_attribute21
      ,p_prc_attribute22                =>  p_prc_attribute22
      ,p_prc_attribute23                =>  p_prc_attribute23
      ,p_prc_attribute24                =>  p_prc_attribute24
      ,p_prc_attribute25                =>  p_prc_attribute25
      ,p_prc_attribute26                =>  p_prc_attribute26
      ,p_prc_attribute27                =>  p_prc_attribute27
      ,p_prc_attribute28                =>  p_prc_attribute28
      ,p_prc_attribute29                =>  p_prc_attribute29
      ,p_prc_attribute30                =>  p_prc_attribute30
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_comment_id                     =>  p_comment_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      ,P_STAT_RSN_CD                    =>  P_STAT_RSN_CD
      ,p_Pymt_stat_cd                   =>  p_Pymt_stat_cd
      ,p_pymt_stat_rsn_cd               =>  p_pymt_stat_rsn_cd
      ,p_stat_ovrdn_flag                =>  p_stat_ovrdn_flag
      ,p_stat_ovrdn_rsn_cd              =>  p_stat_ovrdn_rsn_cd
      ,p_stat_prr_to_ovrd               =>  p_stat_prr_to_ovrd
      ,p_pymt_stat_ovrdn_flag           =>  p_pymt_stat_ovrdn_flag
      ,p_pymt_stat_ovrdn_rsn_cd         =>  p_pymt_stat_ovrdn_rsn_cd
      ,p_pymt_stat_prr_to_ovrd          =>  p_pymt_stat_prr_to_ovrd
      ,p_Adjmt_flag                     =>  p_Adjmt_flag
      ,p_Submtd_dt                      =>  trunc(p_Submtd_dt)
      ,p_Ttl_rqst_amt                   =>  p_Ttl_rqst_amt
      ,p_Aprvd_for_pymt_amt             =>  p_Aprvd_for_pymt_amt
      ,p_exp_incurd_dt			=>  p_exp_incurd_dt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_REIMBMT_RQST
    --
  end;
  --
  ---Call The communication when the status us changed
  --if  p_prtt_reimbmt_rqst_stat_cd is not null and
  --    nvl(l_prc_old.prtt_reimbmt_rqst_stat_cd,'-1') <> p_prtt_reimbmt_rqst_stat_cd
  --    then

     generate_communications(
        p_submitter_person_id        => p_submitter_person_id,
        p_pl_id                      => p_pl_id,
        p_prtt_reimbmt_rqst_stat_cd  => p_prtt_reimbmt_rqst_stat_cd,
        p_business_group_id          => p_business_group_id,
        p_effective_date             => p_effective_date);
  --end if ;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_PRTT_REIMBMT_RQST;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PRTT_REIMBMT_RQST;
    raise;
    --
end update_PRTT_REIMBMT_RQST;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_REIMBMT_RQST >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_REIMBMT_RQST
  (p_validate                       in  boolean  default false
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_submitter_person_id            in  number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc varchar2(72) := g_package||'delete_PRTT_REIMBMT_RQST';
  l_object_version_number ben_prtt_reimbmt_rqst_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_reimbmt_rqst_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_reimbmt_rqst_f.effective_end_date%TYPE;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_REIMBMT_RQST;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk3.delete_PRTT_REIMBMT_RQST_b
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTT_REIMBMT_RQST
    --
  end;
  --

  ben_prc_del.del
    (
     p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_REIMBMT_RQST
    --
    ben_PRTT_REIMBMT_RQST_bk3.delete_PRTT_REIMBMT_RQST_a
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_REIMBMT_RQST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTT_REIMBMT_RQST
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_PRTT_REIMBMT_RQST;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_PRTT_REIMBMT_RQST;
    raise;
    --
end delete_PRTT_REIMBMT_RQST;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_reimbmt_rqst_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_prc_shd.lck
    (
      p_prtt_reimbmt_rqst_id                 => p_prtt_reimbmt_rqst_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_PRTT_REIMBMT_RQST_api;

/
