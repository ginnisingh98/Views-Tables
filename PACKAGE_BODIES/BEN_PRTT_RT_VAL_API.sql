--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_RT_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_RT_VAL_API" as
/* $Header: beprvapi.pkb 120.3.12010000.3 2010/01/04 04:29:18 krupani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_prtt_rt_val_api.';
g_debug boolean := hr_utility.debug_enabled;
g_abr_name           varchar2(255);
--
-- ---------------------------------------------------------------------------
-- |------------------------< result_is_suspended >--------------------------|
-- ---------------------------------------------------------------------------
--
function result_is_suspended
(  p_prtt_enrt_rslt_id              number
  ,p_person_id                      number
  ,p_business_group_id              number
  ,p_effective_date                 date
 ) return varchar2 is
  --
  -- Declare cursors and local variables
  --
  l_result varchar2(30);
  l_proc varchar2(72); -- := g_package||'result_is_suspended';
  --
  cursor c_result is
    select nvl(sspndd_flag,'N')
    from   ben_prtt_enrt_rslt_f pen
    where  prtt_enrt_rslt_id=p_prtt_enrt_rslt_id and
           pen.prtt_enrt_rslt_stat_cd is null and
           business_group_id=p_business_group_id and
           p_effective_date <= effective_end_date
  order by effective_Start_Date;
  /* Bug 4949280 - Commented - Following clause fails when PEN.EFFECTIVE_START_DATE is later
                               than PRV.EFFECTIVE_START_DATE
           p_effective_date between
             effective_start_date and effective_end_date
   */
  --
begin
  --
  if g_debug then
    l_proc := g_package||'result_is_suspended';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- open cursor and fetch result
  --
  open c_result;
  fetch c_result into l_result;
  if c_result%notfound then
    fnd_message.set_name('BEN','BEN_91711_ENRT_RSLT_NOT_FND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('ID', to_char(p_prtt_enrt_rslt_id));
    fnd_message.set_token('PERSON_ID', to_char(p_person_id));
    fnd_message.set_token('LER_ID', null);
    fnd_message.set_token('EFFECTIVE_DATE',to_char(p_effective_date));
    fnd_message.raise_error;
  end if;
  close c_result;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 1000);
  end if;
  --
  return(l_result);
end;
--
-- ---------------------------------------------------------------------------
-- |------------------------< get_non_recurring_end_dt >---------------------|
-- ---------------------------------------------------------------------------
--
procedure get_non_recurring_end_dt
(  p_rt_strt_dt              date
  ,p_acty_base_rt_id         number
  ,p_business_group_id       number
  ,p_rt_end_dt               in out nocopy date
  ,p_recurring_rt            out nocopy boolean
  ,p_effective_date          date
 ) is

 l_proc varchar2(72); --  := g_package||'get_non_recurring_end_dt';
 l_abr_name           varchar2(255);
 l_rcrrg_cd           varchar2(30);
 l_element_type_id    number;
 l_ele_rqd_flag       varchar2(1);

 cursor c_ety is
 select processing_type
   from pay_element_types_f
  where element_type_id = l_element_type_id
    and p_effective_date between effective_start_date
    and effective_end_date ;

 cursor c_abr is
 select name,
        rcrrg_cd,
        ele_rqd_flag,
        element_type_id
   from ben_acty_base_rt_f
  where business_group_id = p_business_group_id
    and p_acty_base_rt_id = acty_base_rt_id
    and p_rt_strt_dt  between effective_start_date
    and effective_end_date ;


Begin

 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;

 p_recurring_rt := true;

 open c_abr ;
 fetch c_abr into
   l_abr_name,
   l_rcrrg_cd,
   l_ele_rqd_flag,
   l_element_type_id ;
 close c_abr ;

 if nvl(l_rcrrg_cd,'R') = 'ONCE' then

    p_rt_end_dt    := p_rt_strt_dt ;
    p_recurring_rt := false;

 elsif  l_element_type_id is not null and
        l_ele_rqd_flag = 'Y' then
        open c_ety;
        fetch c_ety into l_rcrrg_cd ;
        if  c_ety%found then
          if nvl(l_rcrrg_cd,'R') = 'N' then
             p_rt_end_dt    := p_rt_strt_dt ;
             p_recurring_rt := false;
          end if ;
        end if;
        close c_ety ;
 end if ;

 g_abr_name := l_abr_name;
 if g_debug then
    hr_utility.set_location('return date '|| p_rt_end_dt, 20);
    hr_utility.set_location('Leaving:'|| l_proc, 20);
 end if;

end get_non_recurring_end_dt;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_overlapping_dates >---------------------|
-- ---------------------------------------------------------------------------
--
procedure chk_overlapping_dates
  (p_acty_base_rt_id                in  number
  ,p_prtt_rt_val_id                 in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_new_rt_strt_dt                 in  date
  ,p_new_rt_end_dt                  in  date
  ) is

cursor c_overlap_rt is
select rt_strt_dt,
       rt_end_dt
  from ben_prtt_rt_val
 where prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
   and acty_base_rt_id = p_acty_base_rt_id
   and prtt_rt_val_id <> nvl(p_prtt_rt_val_id,-1)
   and prtt_rt_val_stat_cd is null
   and ((p_new_rt_strt_dt between rt_strt_dt and rt_end_dt) or
        (rt_strt_dt between p_new_rt_strt_dt and p_new_rt_end_dt));

l_rt_strt_dt   date;
l_rt_end_dt    date;
l_proc         varchar2(72);

begin

  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'chk_overlapping_dates';
    hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;

  open c_overlap_rt;
  fetch c_overlap_rt into
    l_rt_strt_dt,
    l_rt_end_dt;
  close c_overlap_rt;

  if l_rt_strt_dt is not null then
     fnd_message.set_name('BEN','BEN_93811_OVERLAPPING_RATES');
     fnd_message.set_token('PROC',l_proc);
     fnd_message.set_token('ABR', g_abr_name);
     fnd_message.set_token('RSLT_ID', to_char(p_prtt_enrt_rslt_id));
     fnd_message.set_token('EFFECTIVE_DATE',to_char(p_new_rt_strt_dt));
     fnd_message.raise_error;
  end if;

  if g_debug then
     hr_utility.set_location('Leaving:'|| l_proc, 10);
  end if;

end chk_overlapping_dates;
--
-- ---------------------------------------------------------------------------
-- |------------------------< create_prtt_rt_val >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_prtt_rt_val
  (p_validate                       in  boolean   default false
  ,p_prtt_rt_val_id                 out nocopy number
  ,p_enrt_rt_id                     in  number default null
  ,p_person_id                      in  number
  ,p_input_value_id                 in  number
  ,p_element_type_id                in  number
  ,p_rt_strt_dt                     in  date      default null
  ,p_rt_end_dt                      in  date      default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_ordr_num               in number     default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_mlt_cd                         in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_rt_val                         in  number    default null
  ,p_ann_rt_val                     in  number    default null
  ,p_cmcd_rt_val                    in  number    default null
  ,p_cmcd_ref_perd_cd               in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_dsply_on_enrt_flag             in  varchar2  default 'N'
  ,p_rt_ovridn_flag                 in  varchar2  default 'N'
  ,p_rt_ovridn_thru_dt              in  date      default null
  ,p_elctns_made_dt                 in  date      default null
  ,p_prtt_rt_val_stat_cd            in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_element_entry_value_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_ended_per_in_ler_id            in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_prtt_reimbmt_rqst_id           in  number    default null
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default null
  ,p_pp_in_yr_used_num              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_prv_attribute_category         in  varchar2  default null
  ,p_prv_attribute1                 in  varchar2  default null
  ,p_prv_attribute2                 in  varchar2  default null
  ,p_prv_attribute3                 in  varchar2  default null
  ,p_prv_attribute4                 in  varchar2  default null
  ,p_prv_attribute5                 in  varchar2  default null
  ,p_prv_attribute6                 in  varchar2  default null
  ,p_prv_attribute7                 in  varchar2  default null
  ,p_prv_attribute8                 in  varchar2  default null
  ,p_prv_attribute9                 in  varchar2  default null
  ,p_prv_attribute10                in  varchar2  default null
  ,p_prv_attribute11                in  varchar2  default null
  ,p_prv_attribute12                in  varchar2  default null
  ,p_prv_attribute13                in  varchar2  default null
  ,p_prv_attribute14                in  varchar2  default null
  ,p_prv_attribute15                in  varchar2  default null
  ,p_prv_attribute16                in  varchar2  default null
  ,p_prv_attribute17                in  varchar2  default null
  ,p_prv_attribute18                in  varchar2  default null
  ,p_prv_attribute19                in  varchar2  default null
  ,p_prv_attribute20                in  varchar2  default null
  ,p_prv_attribute21                in  varchar2  default null
  ,p_prv_attribute22                in  varchar2  default null
  ,p_prv_attribute23                in  varchar2  default null
  ,p_prv_attribute24                in  varchar2  default null
  ,p_prv_attribute25                in  varchar2  default null
  ,p_prv_attribute26                in  varchar2  default null
  ,p_prv_attribute27                in  varchar2  default null
  ,p_prv_attribute28                in  varchar2  default null
  ,p_prv_attribute29                in  varchar2  default null
  ,p_prv_attribute30                in  varchar2  default null
  ,p_pk_id_table_name               in  varchar2  default null
  ,p_pk_id                          in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- LGE : Rate certification.
  --
  cursor c_enrt_ctfn(p_enrt_rt_id in number) is
    select erc.*
    from ben_enrt_rt_ctfn erc
    where enrt_rt_id  = p_enrt_rt_id
      and business_group_id = p_business_group_id;
  --
  -- LGE : Check whether the rate is non recurring and attached to
  -- plan not in program.
  --
  cursor c_pl_nip is
    select null
      from ben_pl_f pln,
           ben_prtt_enrt_rslt_f pen
     where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and pen.prtt_enrt_rslt_stat_cd is null
       and pen.pl_id = pln.pl_id
       and pln.pl_cd = 'MYNTBPGM'
       and p_effective_date between pln.effective_start_date and
                                    pln.effective_end_date ;

  --Bug 4141719: Retrieve the rate name which will be used to show
  --in the note 93120(if the note is applicable)
  cursor c_abr is
    select name
    from ben_acty_base_rt_f
    where business_group_id = p_business_group_id
      and p_acty_base_rt_id = acty_base_rt_id
      and p_rt_strt_dt  between effective_start_date
      and effective_end_date ;

  --
  l_dummy      varchar2(30);
  l_rcrrg_cd   varchar2(100);
  l_recurring_rt   boolean;
  l_abr_name   varchar2(300);
  --
  l_prtt_rt_val_id ben_prtt_rt_val.prtt_rt_val_id%TYPE;
  l_enrt_rt_ovn number;
  l_proc varchar2(72) ; -- := g_package||'create_prtt_rt_val';
  l_object_version_number ben_prtt_rt_val.object_version_number%TYPE;
  --
  l_dummy_number number;
  l_rt_end_dt   date ;
  l_prtt_rt_val_ctfn_prvdd_id number;
  l_ovn                       number;
  l_pl_nip      boolean;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'create_prtt_rt_val';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_prtt_rt_val;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;

  l_rt_end_dt := p_rt_end_dt;

  --Bug 4141719: Retrieve the rate name which will be used to show
  --in the note 93120(if the note is applicable)
  open c_abr ;
  fetch c_abr into g_abr_name;
  close c_abr ;

  -- get the end date and the rate/element type
  get_non_recurring_end_dt
  (p_rt_end_dt         => l_rt_end_dt
  ,p_rt_strt_dt        => p_rt_strt_dt
  ,p_acty_base_rt_id   => p_acty_base_rt_id
  ,p_business_group_id => p_business_group_id
  ,p_recurring_rt      => l_recurring_rt
  ,p_effective_date    => p_effective_date
  ) ;

  if l_recurring_rt then

     chk_overlapping_dates
     (p_acty_base_rt_id        => p_acty_base_rt_id
     ,p_prtt_rt_val_id         => null
     ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
     ,p_new_rt_strt_dt         => p_rt_strt_dt
     ,p_new_rt_end_dt          => hr_api.g_eot);

  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_prtt_rt_val
    --
    ben_prtt_rt_val_bk1.create_prtt_rt_val_b
      (
       p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_rt_end_dt                      =>  l_rt_end_dt
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_ordr_num                    =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_rt_val                         =>  p_rt_val
      ,p_ann_rt_val                     =>  p_ann_rt_val
      ,p_cmcd_rt_val                    =>  p_cmcd_rt_val
      ,p_cmcd_ref_perd_cd               =>  p_cmcd_ref_perd_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_rt_ovridn_flag                 =>  p_rt_ovridn_flag
      ,p_rt_ovridn_thru_dt              =>  p_rt_ovridn_thru_dt
      ,p_elctns_made_dt                 =>  p_elctns_made_dt
      ,p_prtt_rt_val_stat_cd            =>  p_prtt_rt_val_stat_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ended_per_in_ler_id            =>  p_ended_per_in_ler_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_pp_in_yr_used_num              =>  p_pp_in_yr_used_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_prv_attribute_category         =>  p_prv_attribute_category
      ,p_prv_attribute1                 =>  p_prv_attribute1
      ,p_prv_attribute2                 =>  p_prv_attribute2
      ,p_prv_attribute3                 =>  p_prv_attribute3
      ,p_prv_attribute4                 =>  p_prv_attribute4
      ,p_prv_attribute5                 =>  p_prv_attribute5
      ,p_prv_attribute6                 =>  p_prv_attribute6
      ,p_prv_attribute7                 =>  p_prv_attribute7
      ,p_prv_attribute8                 =>  p_prv_attribute8
      ,p_prv_attribute9                 =>  p_prv_attribute9
      ,p_prv_attribute10                =>  p_prv_attribute10
      ,p_prv_attribute11                =>  p_prv_attribute11
      ,p_prv_attribute12                =>  p_prv_attribute12
      ,p_prv_attribute13                =>  p_prv_attribute13
      ,p_prv_attribute14                =>  p_prv_attribute14
      ,p_prv_attribute15                =>  p_prv_attribute15
      ,p_prv_attribute16                =>  p_prv_attribute16
      ,p_prv_attribute17                =>  p_prv_attribute17
      ,p_prv_attribute18                =>  p_prv_attribute18
      ,p_prv_attribute19                =>  p_prv_attribute19
      ,p_prv_attribute20                =>  p_prv_attribute20
      ,p_prv_attribute21                =>  p_prv_attribute21
      ,p_prv_attribute22                =>  p_prv_attribute22
      ,p_prv_attribute23                =>  p_prv_attribute23
      ,p_prv_attribute24                =>  p_prv_attribute24
      ,p_prv_attribute25                =>  p_prv_attribute25
      ,p_prv_attribute26                =>  p_prv_attribute26
      ,p_prv_attribute27                =>  p_prv_attribute27
      ,p_prv_attribute28                =>  p_prv_attribute28
      ,p_prv_attribute29                =>  p_prv_attribute29
      ,p_prv_attribute30                =>  p_prv_attribute30
      ,p_pk_id_table_name               =>  p_pk_id_table_name
      ,p_pk_id                          =>  p_pk_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_prtt_rt_val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_prtt_rt_val
    --
  end;
  --
  ben_prv_ins.ins
    (
     p_prtt_rt_val_id                => l_prtt_rt_val_id
    ,p_enrt_rt_id                    => p_enrt_rt_id
    ,p_rt_strt_dt                    => p_rt_strt_dt
    ,p_rt_end_dt                     => l_rt_end_dt
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_ordr_num                      => p_ordr_num
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_mlt_cd                        => p_mlt_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_rt_val                        => p_rt_val
    ,p_ann_rt_val                    => p_ann_rt_val
    ,p_cmcd_rt_val                   => p_cmcd_rt_val
    ,p_cmcd_ref_perd_cd              => p_cmcd_ref_perd_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_dsply_on_enrt_flag            => p_dsply_on_enrt_flag
    ,p_rt_ovridn_flag                => p_rt_ovridn_flag
    ,p_rt_ovridn_thru_dt             => p_rt_ovridn_thru_dt
    ,p_elctns_made_dt                => p_elctns_made_dt
    ,p_prtt_rt_val_stat_cd           => p_prtt_rt_val_stat_cd
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_element_entry_value_id        => p_element_entry_value_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_ended_per_in_ler_id           => p_ended_per_in_ler_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_prtt_rmt_aprvd_fr_pymt_id     => p_prtt_rmt_aprvd_fr_pymt_id
    ,p_pp_in_yr_used_num             => p_pp_in_yr_used_num
    ,p_business_group_id             => p_business_group_id
    ,p_prv_attribute_category        => p_prv_attribute_category
    ,p_prv_attribute1                => p_prv_attribute1
    ,p_prv_attribute2                => p_prv_attribute2
    ,p_prv_attribute3                => p_prv_attribute3
    ,p_prv_attribute4                => p_prv_attribute4
    ,p_prv_attribute5                => p_prv_attribute5
    ,p_prv_attribute6                => p_prv_attribute6
    ,p_prv_attribute7                => p_prv_attribute7
    ,p_prv_attribute8                => p_prv_attribute8
    ,p_prv_attribute9                => p_prv_attribute9
    ,p_prv_attribute10               => p_prv_attribute10
    ,p_prv_attribute11               => p_prv_attribute11
    ,p_prv_attribute12               => p_prv_attribute12
    ,p_prv_attribute13               => p_prv_attribute13
    ,p_prv_attribute14               => p_prv_attribute14
    ,p_prv_attribute15               => p_prv_attribute15
    ,p_prv_attribute16               => p_prv_attribute16
    ,p_prv_attribute17               => p_prv_attribute17
    ,p_prv_attribute18               => p_prv_attribute18
    ,p_prv_attribute19               => p_prv_attribute19
    ,p_prv_attribute20               => p_prv_attribute20
    ,p_prv_attribute21               => p_prv_attribute21
    ,p_prv_attribute22               => p_prv_attribute22
    ,p_prv_attribute23               => p_prv_attribute23
    ,p_prv_attribute24               => p_prv_attribute24
    ,p_prv_attribute25               => p_prv_attribute25
    ,p_prv_attribute26               => p_prv_attribute26
    ,p_prv_attribute27               => p_prv_attribute27
    ,p_prv_attribute28               => p_prv_attribute28
    ,p_prv_attribute29               => p_prv_attribute29
    ,p_prv_attribute30               => p_prv_attribute30
    ,p_pk_id_table_name              => p_pk_id_table_name
    ,p_pk_id                         => p_pk_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
     );
  --
  if p_enrt_rt_id is not null then
     --
     -- only update the ben_enrt_rt table to point to the inserted prtt_rt_val
     -- row if the rate val row is not being inserted as a void or backed out
     -- row. if the rate end date is less than the rate start date, the row
     -- will be voided in the pre-insert and pre-update in the rhi.
     --
     if p_rt_strt_dt > nvl(l_rt_end_dt,p_rt_strt_dt)
        or p_prtt_rt_val_stat_cd = 'BCKDT' then
       null;
     else
       --
       -- Get the object version number for the update
       --
       l_enrt_rt_ovn:=
           dt_api.get_object_version_number
           (p_base_table_name => 'ben_enrt_rt',
            p_base_key_column => 'enrt_rt_id',
            p_base_key_value  => p_enrt_rt_id)-1;

       ben_enrollment_rate_api.update_enrollment_rate(
        p_enrt_rt_id            => p_enrt_rt_id,
        p_prtt_rt_val_id        => l_prtt_rt_val_id,
        p_object_version_number => l_enrt_rt_ovn,
        p_effective_date        => p_effective_date
         );
    end if;
    --
    -- Option Level Rates enhancements
    --
    --
    -- LGE : Create the rate certifications.
    --
    if not l_recurring_rt then
      --
      -- check if Plan not in Program
      --
      open c_pl_nip ;
      fetch c_pl_nip into l_dummy ;
      l_pl_nip := c_pl_nip%found;
      close c_pl_nip ;

      if l_pl_nip then
         --
         for l_rt_ctfn_rec in c_enrt_ctfn(p_enrt_rt_id) loop
           --
           ben_prv_ctfn_prvdd_api.create_PRV_CTFN_PRVDD
           (
             p_prtt_rt_val_ctfn_prvdd_id      => l_prtt_rt_val_ctfn_prvdd_id
             ,p_enrt_ctfn_rqd_flag             => l_rt_ctfn_rec.rqd_flag
             ,p_enrt_ctfn_typ_cd               => l_rt_ctfn_rec.enrt_ctfn_typ_cd
             ,p_enrt_ctfn_recd_dt              => null
             ,p_enrt_ctfn_dnd_dt               => null
             ,p_prtt_rt_val_id                 => l_prtt_rt_val_id
             ,p_business_group_id              => l_rt_ctfn_rec.business_group_id
             ,p_object_version_number          => l_ovn
             ,p_effective_date                 => p_effective_date
            );
           --
         end loop;
--Bug 3108779
l_abr_name :=g_abr_name;
--
         if l_prtt_rt_val_ctfn_prvdd_id is not null then
            ben_warnings.load_warning
            (p_application_short_name  => 'BEN',
             p_message_name            => 'BEN_93120_RQD_RT_CTFN_MISSING',
             p_parma     => l_abr_name,
             p_person_id => p_person_id);
         end if;

      end if; --pl nip
    end if; -- rate certification
  end if; --enrt rt
  --
  -- Create the element entry if the result is not suspended
  --
  -- Bug 9242703: passing p_rt_strt_dt below. We need to check whether the
  -- enrollment is suspended on the rate start date, not the effective date.
  if result_is_suspended(
     p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
     p_person_id         => p_person_id,
     p_business_group_id => p_business_group_id,
     p_effective_date    => nvl(p_rt_strt_dt,p_effective_date)) ='N' and
     l_prtt_rt_val_ctfn_prvdd_id is null then

     ben_element_entry.create_enrollment_element
     (p_business_group_id        => p_business_group_id
     ,p_prtt_rt_val_id           => l_prtt_rt_val_id
     ,p_person_id                => p_person_id
     ,p_acty_ref_perd            => p_acty_ref_perd_cd
     ,p_acty_base_rt_id          => p_acty_base_rt_id
     ,p_enrt_rslt_id             => p_prtt_enrt_rslt_id
     ,p_rt_start_date            => p_rt_strt_dt
     ,p_rt                       => p_rt_val
     ,p_cmncd_rt                 => p_cmcd_rt_val
     ,p_ann_rt                   => p_ann_rt_val
     ,p_input_value_id           => p_input_value_id
     ,p_element_type_id          => p_element_type_id
     ,p_prv_object_version_number=> l_object_version_number
     ,p_effective_date           => p_effective_date
     ,p_eev_screen_entry_value   => l_dummy_number
     ,p_element_entry_value_id   => l_dummy_number
      );
    --
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_prtt_rt_val
    --
    ben_prtt_rt_val_bk1.create_prtt_rt_val_a
      (
       p_prtt_rt_val_id                 =>  l_prtt_rt_val_id
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_rt_end_dt                      =>  l_rt_end_dt
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_rt_val                         =>  p_rt_val
      ,p_ann_rt_val                     =>  p_ann_rt_val
      ,p_cmcd_rt_val                    =>  p_cmcd_rt_val
      ,p_cmcd_ref_perd_cd               =>  p_cmcd_ref_perd_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_rt_ovridn_flag                 =>  p_rt_ovridn_flag
      ,p_rt_ovridn_thru_dt              =>  p_rt_ovridn_thru_dt
      ,p_elctns_made_dt                 =>  p_elctns_made_dt
      ,p_prtt_rt_val_stat_cd            =>  p_prtt_rt_val_stat_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ended_per_in_ler_id            =>  p_ended_per_in_ler_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_pp_in_yr_used_num              =>  p_pp_in_yr_used_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_prv_attribute_category         =>  p_prv_attribute_category
      ,p_prv_attribute1                 =>  p_prv_attribute1
      ,p_prv_attribute2                 =>  p_prv_attribute2
      ,p_prv_attribute3                 =>  p_prv_attribute3
      ,p_prv_attribute4                 =>  p_prv_attribute4
      ,p_prv_attribute5                 =>  p_prv_attribute5
      ,p_prv_attribute6                 =>  p_prv_attribute6
      ,p_prv_attribute7                 =>  p_prv_attribute7
      ,p_prv_attribute8                 =>  p_prv_attribute8
      ,p_prv_attribute9                 =>  p_prv_attribute9
      ,p_prv_attribute10                =>  p_prv_attribute10
      ,p_prv_attribute11                =>  p_prv_attribute11
      ,p_prv_attribute12                =>  p_prv_attribute12
      ,p_prv_attribute13                =>  p_prv_attribute13
      ,p_prv_attribute14                =>  p_prv_attribute14
      ,p_prv_attribute15                =>  p_prv_attribute15
      ,p_prv_attribute16                =>  p_prv_attribute16
      ,p_prv_attribute17                =>  p_prv_attribute17
      ,p_prv_attribute18                =>  p_prv_attribute18
      ,p_prv_attribute19                =>  p_prv_attribute19
      ,p_prv_attribute20                =>  p_prv_attribute20
      ,p_prv_attribute21                =>  p_prv_attribute21
      ,p_prv_attribute22                =>  p_prv_attribute22
      ,p_prv_attribute23                =>  p_prv_attribute23
      ,p_prv_attribute24                =>  p_prv_attribute24
      ,p_prv_attribute25                =>  p_prv_attribute25
      ,p_prv_attribute26                =>  p_prv_attribute26
      ,p_prv_attribute27                =>  p_prv_attribute27
      ,p_prv_attribute28                =>  p_prv_attribute28
      ,p_prv_attribute29                =>  p_prv_attribute29
      ,p_prv_attribute30                =>  p_prv_attribute30
      ,p_pk_id_table_name               =>  p_pk_id_table_name
      ,p_pk_id                          =>  p_pk_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_prtt_rt_val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_prtt_rt_val
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_prtt_rt_val_id := l_prtt_rt_val_id;
  p_object_version_number := l_object_version_number;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_prtt_rt_val;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_rt_val_id := null;
    p_object_version_number  := null;
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_prtt_rt_val;
    p_prtt_rt_val_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_prtt_rt_val;
-- ---------------------------------------------------------------------------
-- |------------------------< update_prtt_rt_val >--- -----------------------|
-- ---------------------------------------------------------------------------
--
procedure update_prtt_rt_val
  (p_validate                       in  boolean   default false
  ,p_prtt_rt_val_id                 in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_enrt_rt_id                     in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_rt_end_dt                      in  date      default hr_api.g_date
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num               in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_rt_val                         in  number    default hr_api.g_number
  ,p_ann_rt_val                     in  number    default hr_api.g_number
  ,p_cmcd_rt_val                    in  number    default hr_api.g_number
  ,p_cmcd_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_rt_ovridn_thru_dt              in  date      default hr_api.g_date
  ,p_elctns_made_dt                 in  date      default hr_api.g_date
  ,p_prtt_rt_val_stat_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_element_entry_value_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_ended_per_in_ler_id            in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number    default hr_api.g_number
  ,p_pp_in_yr_used_num              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_pk_id_table_name               in  varchar2  default hr_api.g_varchar2
  ,p_pk_id                          in  number    default hr_api.g_number
  ,p_no_end_element                 in  boolean   default false
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  cursor c_old_prv is
    select prv.rt_end_dt,
           prv.rt_strt_dt,
           prv.prtt_enrt_rslt_id,
           prv.element_entry_value_id,
           prv.acty_base_rt_id,
           prv.rt_val,
           prv.cmcd_rt_val,
           prv.ann_rt_val,
           prv.acty_ref_perd_cd,
           prv.per_in_ler_id,
           prv.prtt_rt_val_stat_cd
    from   ben_prtt_rt_val prv
    where  prv.prtt_rt_val_id=p_prtt_rt_val_id and
           prv.business_group_id=p_business_group_id;
  --
   cursor c_ele_entry (p_element_entry_value_id number,
                       p_effective_date date) is
   select ele.element_entry_id,
          ele.entry_type,
          ele.original_entry_id,
          elt.processing_type,
          elk.element_type_id,
          elk.effective_end_date
     from pay_element_entry_values_f elv,
          pay_element_entries_f ele,
          pay_element_links_f elk,
          pay_element_types_f elt
    where elv.element_entry_value_id  = p_element_entry_value_id
      and elv.element_entry_id = ele.element_entry_id
      and elv.effective_start_date between ele.effective_start_date
      and ele.effective_end_date
      and ele.element_link_id   = elk.element_link_id
      and ele.effective_start_date between elk.effective_start_date
      and elk.effective_end_date
      and elk.element_type_id = elt.element_type_id
      and elk.effective_start_date between elt.effective_start_date
      and elt.effective_end_date ;
  --
  l_ele_rec                c_ele_entry%rowtype;
  --
  cursor c_prv_ovn is
    select prv.object_version_number
    from   ben_prtt_rt_val prv
    where  prv.prtt_rt_val_id=p_prtt_rt_val_id;

  --
  l_proc varchar2(72) := g_package||'update_prtt_rt_val';
  l_object_version_number ben_prtt_rt_val.object_version_number%TYPE;
  l_enrt_rt_ovn number;
  l_old_enrt_rslt_id number;
  l_old_rt_end_dt date;
  l_rt_end_dt date;
  l_old_rt_strt_dt date;
  l_old_element_link_id number;
  l_ee_effective_end_date date;
  l_old_element_entry_value_id number;
  l_old_abr_id number;
  l_old_rt_val number;
  l_old_cmcd_rt_val    number;
  l_old_ann_rt_val     number;
  l_old_per_in_ler_id number;
  l_old_acty_ref_perd_cd varchar2(30);
  l_old_prtt_rt_val_stat_cd varchar2(30);
  l_element_type_id      number;
  l_rt_strt_dt   date;
  l_assignment_id        number;
  l_organization_id      number;
  l_payroll_id           number;
  l_max_end_date         date;
  l_rt_dt                date;
  l_abs_ler              boolean := false;
  l_per_in_ler_id        number;
  l_dummy                varchar2(30);
  l_effective_date       date;
  l_processed_flag       varchar2(30) := 'N';
  l_element_end_date date;
  l_element_start_date date;
  l_recurring_rt   boolean;
  l_cmcd_rt_val    number;
  l_ann_rt_val     number;
  l_rt_val         number;
  l_recreated      boolean := false;
  l_rslt_suspended varchar2(30);
  l_dummy_number   number;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_prtt_rt_val;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Get the old values before any changes or calls
  --
  open c_old_prv;
  fetch c_old_prv into
    l_old_rt_end_dt,
    l_old_rt_strt_dt,
    l_old_enrt_rslt_id,
    l_old_element_entry_value_id,
    l_old_abr_id,
    l_old_rt_val,
    l_old_cmcd_rt_val,
    l_old_ann_rt_val,
    l_old_acty_ref_perd_cd,
    l_old_per_in_ler_id,
    l_old_prtt_rt_val_stat_cd
  ;
  if c_old_prv%notfound then
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close c_old_prv;
  --
  if nvl(p_rt_strt_dt,hr_api.g_date) = hr_api.g_date  then
     l_rt_strt_dt := l_old_rt_strt_dt;
  else
     l_rt_strt_dt := p_rt_strt_dt;
  end if;

  l_rt_end_dt  :=  p_rt_end_dt;

  if nvl(p_prtt_rt_val_stat_cd,'XXX') <> 'BCKDT' then
     get_non_recurring_end_dt
     (p_rt_end_dt         => l_rt_end_dt
     ,p_rt_strt_dt        => l_rt_strt_dt
     ,p_acty_base_rt_id   => p_acty_base_rt_id
     ,p_business_group_id => p_business_group_id
     ,p_recurring_rt      => l_recurring_rt
     ,p_effective_date    => p_effective_date) ;
  end if;
  --
  if  l_rt_end_dt = hr_api.g_date then
      l_rt_end_dt := l_old_rt_end_dt;
  end if;
  --
  if  p_rt_val = hr_api.g_number then
      l_rt_val := l_old_rt_val;
  else
      l_rt_val := p_rt_val;
  end if;
  --
  if  p_cmcd_rt_val = hr_api.g_number then
      l_cmcd_rt_val := l_old_cmcd_rt_val;
  else
      l_cmcd_rt_val := p_cmcd_rt_val;
  end if;
  --
  if  p_ann_rt_val = hr_api.g_number then
      l_ann_rt_val := l_old_ann_rt_val;
  else
      l_ann_rt_val := p_ann_rt_val;
  end if;
  --
  if not l_recurring_rt and
     l_old_element_entry_value_id is not null then
     --
     open c_ele_entry(l_old_element_entry_value_id,
                      l_rt_strt_dt);
     fetch c_ele_entry into l_ele_rec ;
     close c_ele_entry;
     --
     -- For Non recurring rates if the processed_flag is Y raise an error and
     -- dont allow the user to modify the rates
     --
     --BUG 3476699 fixes. We shoould allow to change the rate from the
     --Override forms.
     --
     --if l_ele_rec.element_entry_id is not null then
     if ( (NVL(p_rt_ovridn_flag,'N') = 'N' OR
            (NVL(p_rt_ovridn_flag,'N') ='Y' AND
              NVL(p_rt_ovridn_thru_dt,hr_api.g_eot ) < l_rt_strt_dt
            )
          )
        AND l_ele_rec.element_entry_id is not null ) then
        --
        l_processed_flag := substr(pay_paywsmee_pkg.processed(
                                   l_ele_rec.element_entry_id,
                                   l_ele_rec.original_entry_id,
                                   l_ele_rec.processing_type,
                                   l_ele_rec.entry_type,
                                   l_rt_strt_dt), 1,1) ;
        --
        if l_processed_flag = 'Y' then
           --
           fnd_message.set_name ('BEN','BEN_93341_PRCCSD_IN_PAYROLL');
           fnd_message.raise_error;
           --
        end if;
        --
     end if;
     --
  end if;
  --
  -- check if the new rate start and end dates result in overlap
  --
  if (l_recurring_rt and
      (p_rt_strt_dt <> l_rt_strt_dt or
       p_rt_end_dt <> l_rt_end_dt )) then

     chk_overlapping_dates
     (p_acty_base_rt_id        => p_acty_base_rt_id
     ,p_prtt_rt_val_id         => p_prtt_rt_val_id
     ,p_prtt_enrt_rslt_id      => p_prtt_enrt_rslt_id
     ,p_new_rt_strt_dt         => l_rt_strt_dt
     ,p_new_rt_end_dt          => l_rt_end_dt);

  end if;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_prtt_rt_val
    --
    ben_prtt_rt_val_bk2.update_prtt_rt_val_b
      (
       p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_rt_end_dt                      =>  l_rt_end_dt
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_rt_val                         =>  p_rt_val
      ,p_ann_rt_val                     =>  p_ann_rt_val
      ,p_cmcd_rt_val                    =>  p_cmcd_rt_val
      ,p_cmcd_ref_perd_cd               =>  p_cmcd_ref_perd_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_rt_ovridn_flag                 =>  p_rt_ovridn_flag
      ,p_rt_ovridn_thru_dt              =>  p_rt_ovridn_thru_dt
      ,p_elctns_made_dt                 =>  p_elctns_made_dt
      ,p_prtt_rt_val_stat_cd            =>  p_prtt_rt_val_stat_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ended_per_in_ler_id            =>  p_ended_per_in_ler_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_pp_in_yr_used_num              =>  p_pp_in_yr_used_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_prv_attribute_category         =>  p_prv_attribute_category
      ,p_prv_attribute1                 =>  p_prv_attribute1
      ,p_prv_attribute2                 =>  p_prv_attribute2
      ,p_prv_attribute3                 =>  p_prv_attribute3
      ,p_prv_attribute4                 =>  p_prv_attribute4
      ,p_prv_attribute5                 =>  p_prv_attribute5
      ,p_prv_attribute6                 =>  p_prv_attribute6
      ,p_prv_attribute7                 =>  p_prv_attribute7
      ,p_prv_attribute8                 =>  p_prv_attribute8
      ,p_prv_attribute9                 =>  p_prv_attribute9
      ,p_prv_attribute10                =>  p_prv_attribute10
      ,p_prv_attribute11                =>  p_prv_attribute11
      ,p_prv_attribute12                =>  p_prv_attribute12
      ,p_prv_attribute13                =>  p_prv_attribute13
      ,p_prv_attribute14                =>  p_prv_attribute14
      ,p_prv_attribute15                =>  p_prv_attribute15
      ,p_prv_attribute16                =>  p_prv_attribute16
      ,p_prv_attribute17                =>  p_prv_attribute17
      ,p_prv_attribute18                =>  p_prv_attribute18
      ,p_prv_attribute19                =>  p_prv_attribute19
      ,p_prv_attribute20                =>  p_prv_attribute20
      ,p_prv_attribute21                =>  p_prv_attribute21
      ,p_prv_attribute22                =>  p_prv_attribute22
      ,p_prv_attribute23                =>  p_prv_attribute23
      ,p_prv_attribute24                =>  p_prv_attribute24
      ,p_prv_attribute25                =>  p_prv_attribute25
      ,p_prv_attribute26                =>  p_prv_attribute26
      ,p_prv_attribute27                =>  p_prv_attribute27
      ,p_prv_attribute28                =>  p_prv_attribute28
      ,p_prv_attribute29                =>  p_prv_attribute29
      ,p_prv_attribute30                =>  p_prv_attribute30
      ,p_pk_id_table_name               =>  p_pk_id_table_name
      ,p_pk_id                          =>  p_pk_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prtt_rt_val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_prtt_rt_val
    --
  end;
  --
  ben_prv_upd.upd
    (
     p_prtt_rt_val_id                => p_prtt_rt_val_id
    ,p_enrt_rt_id                    => p_enrt_rt_id
    ,p_rt_strt_dt                    => p_rt_strt_dt
    ,p_rt_end_dt                     => l_rt_end_dt
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_ordr_num                       =>  p_ordr_num
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_mlt_cd                        => p_mlt_cd
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_rt_val                        => p_rt_val
    ,p_ann_rt_val                    => p_ann_rt_val
    ,p_cmcd_rt_val                   => p_cmcd_rt_val
    ,p_cmcd_ref_perd_cd              => p_cmcd_ref_perd_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_dsply_on_enrt_flag            => p_dsply_on_enrt_flag
    ,p_rt_ovridn_flag                => p_rt_ovridn_flag
    ,p_rt_ovridn_thru_dt             => p_rt_ovridn_thru_dt
    ,p_elctns_made_dt                => p_elctns_made_dt
    ,p_prtt_rt_val_stat_cd           => p_prtt_rt_val_stat_cd
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_element_entry_value_id        => p_element_entry_value_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_ended_per_in_ler_id           => p_ended_per_in_ler_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_prtt_rmt_aprvd_fr_pymt_id     => p_prtt_rmt_aprvd_fr_pymt_id
    ,p_pp_in_yr_used_num             =>  p_pp_in_yr_used_num
    ,p_business_group_id             => p_business_group_id
    ,p_prv_attribute_category        => p_prv_attribute_category
    ,p_prv_attribute1                => p_prv_attribute1
    ,p_prv_attribute2                => p_prv_attribute2
    ,p_prv_attribute3                => p_prv_attribute3
    ,p_prv_attribute4                => p_prv_attribute4
    ,p_prv_attribute5                => p_prv_attribute5
    ,p_prv_attribute6                => p_prv_attribute6
    ,p_prv_attribute7                => p_prv_attribute7
    ,p_prv_attribute8                => p_prv_attribute8
    ,p_prv_attribute9                => p_prv_attribute9
    ,p_prv_attribute10               => p_prv_attribute10
    ,p_prv_attribute11               => p_prv_attribute11
    ,p_prv_attribute12               => p_prv_attribute12
    ,p_prv_attribute13               => p_prv_attribute13
    ,p_prv_attribute14               => p_prv_attribute14
    ,p_prv_attribute15               => p_prv_attribute15
    ,p_prv_attribute16               => p_prv_attribute16
    ,p_prv_attribute17               => p_prv_attribute17
    ,p_prv_attribute18               => p_prv_attribute18
    ,p_prv_attribute19               => p_prv_attribute19
    ,p_prv_attribute20               => p_prv_attribute20
    ,p_prv_attribute21               => p_prv_attribute21
    ,p_prv_attribute22               => p_prv_attribute22
    ,p_prv_attribute23               => p_prv_attribute23
    ,p_prv_attribute24               => p_prv_attribute24
    ,p_prv_attribute25               => p_prv_attribute25
    ,p_prv_attribute26               => p_prv_attribute26
    ,p_prv_attribute27               => p_prv_attribute27
    ,p_prv_attribute28               => p_prv_attribute28
    ,p_prv_attribute29               => p_prv_attribute29
    ,p_prv_attribute30               => p_prv_attribute30
    ,p_pk_id_table_name              => p_pk_id_table_name
    ,p_pk_id                         => p_pk_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
     );
  --
  if g_debug then
    hr_utility.set_location('old entry value'||l_old_element_entry_value_id,11);
    hr_utility.set_location('prtt rt val id '||p_prtt_rt_val_id,11);
    hr_utility.set_location('rate start date '||l_rt_strt_dt,11);
    hr_utility.set_location('old rt strt date '||l_old_rt_strt_dt,12);
    hr_utility.set_location('rate end date '||l_rt_end_dt,12);
    hr_utility.set_location('old rt end date '||l_old_rt_end_dt,12);
  end if;
  --
  --BUG 3559005 We need to compate three values or
  --may bedependeding on the value passed to payroll code we need to
  --consider checking cmcd_rt_val and ann_rt_val
  --
  if l_rt_strt_dt <> l_old_rt_strt_dt or
     l_rt_end_dt <> l_old_rt_end_dt or
     nvl(l_rt_val,0) <> nvl(l_old_rt_val,0) or
     nvl(l_cmcd_rt_val,0) <> nvl(l_old_cmcd_rt_val,0) or
     nvl(l_ann_rt_val,0) <> nvl(l_old_ann_rt_val,0)  then
     l_rslt_suspended :=
     result_is_suspended(p_prtt_enrt_rslt_id => l_old_enrt_rslt_id,
                         p_person_id         => p_person_id,
                         p_business_group_id => p_business_group_id,
                         p_effective_date    => p_effective_date) ;
  end if;
  --
  -- Rate Start Date updates handled below
  --
  --BUG 3559005 We need to compate three values or
  --may bedependeding on the value passed to payroll code we need to
  --consider checking cmcd_rt_val and ann_rt_val
  --
  if l_rt_strt_dt <> l_old_rt_strt_dt or
     nvl(l_rt_val,0) <> nvl(l_old_rt_val,0) or
     nvl(l_cmcd_rt_val,0) <> nvl(l_old_cmcd_rt_val,0) or
     nvl(l_ann_rt_val,0) <> nvl(l_old_ann_rt_val,0)   then
     --
     -- end entry one day before. Will not use rate end code here
     -- as the prv is not the one getting end dated
     --
     if g_debug then
        hr_utility.set_location('Inside re-create',13);
     end if;

     ben_element_entry.end_enrollment_element
     (p_business_group_id        => p_business_group_id
     ,p_person_id                => p_person_id
     ,p_enrt_rslt_id             => l_old_enrt_rslt_id
     ,p_acty_ref_perd            => l_old_acty_ref_perd_cd
     ,p_element_link_id          => null
     ,p_prtt_rt_val_id           => p_prtt_rt_val_id
     ,p_rt_end_date              => l_old_rt_strt_dt -1
     ,p_effective_date           => p_effective_date
     ,p_dt_delete_mode           => null
     ,p_acty_base_rt_id          => l_old_abr_id
     ,p_amt                      => l_old_rt_val
     );
     --
     if l_rslt_suspended = 'N' then
        ben_element_entry.create_enrollment_element
        (p_business_group_id        => p_business_group_id
        ,p_prtt_rt_val_id           => p_prtt_rt_val_id
        ,p_person_id                => p_person_id
        ,p_acty_ref_perd            => l_old_acty_ref_perd_cd
        ,p_acty_base_rt_id          => l_old_abr_id
        ,p_enrt_rslt_id             => l_old_enrt_rslt_id
        ,p_rt_start_date            => l_rt_strt_dt
        ,p_rt                       => l_rt_val
        ,p_cmncd_rt                 => l_cmcd_rt_val
        ,p_ann_rt                   => l_ann_rt_val
        ,p_prv_object_version_number=> l_object_version_number
        ,p_effective_date           => p_effective_date
        ,p_eev_screen_entry_value   => l_dummy_number
        ,p_element_entry_value_id   => l_dummy_number
         );
         l_recreated := l_recurring_rt;
        ben_prv_shd.lck
        (
        p_prtt_rt_val_id                 => p_prtt_rt_val_id
       ,p_object_version_number          => l_object_version_number
        );
     end if;
  end if;
  --
  -- Rate End Date updates handled below
  --
  if not l_recreated and
     l_rt_end_dt > l_old_rt_end_dt and
     l_rslt_suspended = 'N' then
     --
     -- Bug 5012222. Special case here. Backed out prv re-opened. Do not reopen
     -- the previous entry. Rate may have changed.
     -- Call create_enrollment_element in this case.
     --
     if p_prtt_rt_val_stat_cd  is null and
        l_old_prtt_rt_val_stat_cd = 'BCKDT' then

        ben_element_entry.create_enrollment_element
        (p_business_group_id        => p_business_group_id
        ,p_prtt_rt_val_id           => p_prtt_rt_val_id
        ,p_person_id                => p_person_id
        ,p_acty_ref_perd            => l_old_acty_ref_perd_cd
        ,p_acty_base_rt_id          => l_old_abr_id
        ,p_enrt_rslt_id             => l_old_enrt_rslt_id
        ,p_rt_start_date            => l_rt_strt_dt
        ,p_rt                       => l_rt_val
        ,p_cmncd_rt                 => l_cmcd_rt_val
        ,p_ann_rt                   => l_ann_rt_val
        ,p_prv_object_version_number=> l_object_version_number
        ,p_effective_date           => p_effective_date
        ,p_eev_screen_entry_value   => l_dummy_number
        ,p_element_entry_value_id   => l_dummy_number
         );
        ben_prv_shd.lck
        (
        p_prtt_rt_val_id                 => p_prtt_rt_val_id
       ,p_object_version_number          => l_object_version_number
        );
     else
        --
        -- Rate reopened. If rslt is suspended, Element entry will be reopened
        -- when it gets unsuspended
        --
        ben_element_entry.reopen_closed_enrollment
        (p_business_group_id        => p_business_group_id
        ,p_person_id                => p_person_id
        ,p_prtt_rt_val_id           => p_prtt_rt_val_id
        ,p_acty_base_rt_id          => l_old_abr_id
        ,p_element_type_id          => null
        ,p_input_value_id           => null
        ,p_rt                       => null
        ,p_rt_start_date            => l_old_rt_strt_dt
        ,p_effective_date           => p_effective_date
        );
        --
        -- This is temporary. Need to add ovn param to
        -- reopen_closed_enrollment
        --
        open c_prv_ovn;
        fetch c_prv_ovn into l_object_version_number;
        close c_prv_ovn;

     end if;
  end if;

  if not p_no_end_element and
     (l_rt_end_dt < l_rt_strt_dt or
      (
       (l_recurring_rt and l_rt_end_dt <> hr_api.g_eot) and
       (l_rt_end_dt <> l_old_rt_end_dt or l_recreated)
      )
     ) then

       ben_element_entry.end_enrollment_element
       (p_business_group_id        => p_business_group_id
       ,p_person_id                => p_person_id
       ,p_enrt_rslt_id             => l_old_enrt_rslt_id
       ,p_acty_ref_perd            => l_old_acty_ref_perd_cd
       ,p_element_link_id          => null
       ,p_prtt_rt_val_id           => p_prtt_rt_val_id
       ,p_rt_end_date              => l_rt_end_dt
       ,p_effective_date           => p_effective_date
       ,p_dt_delete_mode           => null
       ,p_acty_base_rt_id          => l_old_abr_id
       ,p_amt                      => l_rt_val
       );
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_prtt_rt_val
    --
    ben_prtt_rt_val_bk2.update_prtt_rt_val_a
      (
       p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_rt_end_dt                      =>  l_rt_end_dt
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_rt_val                         =>  p_rt_val
      ,p_ann_rt_val                     =>  p_ann_rt_val
      ,p_cmcd_rt_val                    =>  p_cmcd_rt_val
      ,p_cmcd_ref_perd_cd               =>  p_cmcd_ref_perd_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dsply_on_enrt_flag             =>  p_dsply_on_enrt_flag
      ,p_rt_ovridn_flag                 =>  p_rt_ovridn_flag
      ,p_rt_ovridn_thru_dt              =>  p_rt_ovridn_thru_dt
      ,p_elctns_made_dt                 =>  p_elctns_made_dt
      ,p_prtt_rt_val_stat_cd            =>  p_prtt_rt_val_stat_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_element_entry_value_id         =>  p_element_entry_value_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_ended_per_in_ler_id            =>  p_ended_per_in_ler_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_prtt_rmt_aprvd_fr_pymt_id      =>  p_prtt_rmt_aprvd_fr_pymt_id
      ,p_pp_in_yr_used_num              =>  p_pp_in_yr_used_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_prv_attribute_category         =>  p_prv_attribute_category
      ,p_prv_attribute1                 =>  p_prv_attribute1
      ,p_prv_attribute2                 =>  p_prv_attribute2
      ,p_prv_attribute3                 =>  p_prv_attribute3
      ,p_prv_attribute4                 =>  p_prv_attribute4
      ,p_prv_attribute5                 =>  p_prv_attribute5
      ,p_prv_attribute6                 =>  p_prv_attribute6
      ,p_prv_attribute7                 =>  p_prv_attribute7
      ,p_prv_attribute8                 =>  p_prv_attribute8
      ,p_prv_attribute9                 =>  p_prv_attribute9
      ,p_prv_attribute10                =>  p_prv_attribute10
      ,p_prv_attribute11                =>  p_prv_attribute11
      ,p_prv_attribute12                =>  p_prv_attribute12
      ,p_prv_attribute13                =>  p_prv_attribute13
      ,p_prv_attribute14                =>  p_prv_attribute14
      ,p_prv_attribute15                =>  p_prv_attribute15
      ,p_prv_attribute16                =>  p_prv_attribute16
      ,p_prv_attribute17                =>  p_prv_attribute17
      ,p_prv_attribute18                =>  p_prv_attribute18
      ,p_prv_attribute19                =>  p_prv_attribute19
      ,p_prv_attribute20                =>  p_prv_attribute20
      ,p_prv_attribute21                =>  p_prv_attribute21
      ,p_prv_attribute22                =>  p_prv_attribute22
      ,p_prv_attribute23                =>  p_prv_attribute23
      ,p_prv_attribute24                =>  p_prv_attribute24
      ,p_prv_attribute25                =>  p_prv_attribute25
      ,p_prv_attribute26                =>  p_prv_attribute26
      ,p_prv_attribute27                =>  p_prv_attribute27
      ,p_prv_attribute28                =>  p_prv_attribute28
      ,p_prv_attribute29                =>  p_prv_attribute29
      ,p_prv_attribute30                =>  p_prv_attribute30
      ,p_pk_id_table_name               =>  p_pk_id_table_name
      ,p_pk_id                          =>  p_pk_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_prtt_rt_val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_prtt_rt_val
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
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
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_prtt_rt_val;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_prtt_rt_val;
    raise;
    --
end update_prtt_rt_val;
-- ---------------------------------------------------------------------------
-- |------------------------< delete_prtt_rt_val >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_prtt_rt_val
  (p_validate                       in  boolean  default false
  ,p_prtt_rt_val_id                 in  number
  ,p_enrt_rt_id                     in  number default null
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor c_old_prv is
    select prv.rt_end_dt,
           prv.rt_strt_dt,
           prv.prtt_enrt_rslt_id,
           prv.element_entry_value_id,
           prv.acty_base_rt_id,
           prv.rt_val,
           prv.acty_ref_perd_cd
    from   ben_prtt_rt_val prv
    where  prv.prtt_rt_val_id=p_prtt_rt_val_id and
           prv.business_group_id=p_business_group_id;
  --
  cursor c_enrt_rt (p_prtt_rt_val_id number) is
    select enrt_rt_id,
           object_version_number
    from ben_enrt_rt
    where prtt_rt_val_id = p_prtt_rt_val_id;
  --
  l_proc varchar2(72); -- := g_package||'delete_prtt_rt_val';
  l_object_version_number ben_prtt_rt_val.object_version_number%TYPE;
  l_enrt_rt_ovn number;
  l_old_rt_end_dt date;
  l_old_rt_strt_dt date;
  l_old_enrt_rslt_id number;
  l_old_element_link_id number;
  l_old_element_entry_value_id number;
  l_old_abr_id number;
  l_old_rt_val number;
  l_old_acty_ref_perd_cd varchar2(30);
  l_enrt_rt_id  number;

begin
  --
  g_debug := hr_utility.debug_enabled;

  if g_debug then
    l_proc := g_package||'delete_prtt_rt_val';
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_prtt_rt_val;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Get the old values before any changes or calls
  --
  open c_old_prv;
  fetch c_old_prv into
    l_old_rt_end_dt,
    l_old_rt_strt_dt,
    l_old_enrt_rslt_id,
    l_old_element_entry_value_id,
    l_old_abr_id,
    l_old_rt_val,
    l_old_acty_ref_perd_cd ;
  if c_old_prv%notfound then
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close c_old_prv;
  if g_debug then
    hr_utility.set_location(l_proc, 22);
  end if;

  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_prtt_rt_val
    --
    ben_prtt_rt_val_bk3.delete_prtt_rt_val_b
      (
       p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prtt_rt_val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_prtt_rt_val
    --
  end;
  --
  -- Get the object version number for the update
  -- Do it only if null is not passed.
  --
  if p_enrt_rt_id is not null then
    -- bug#5378504
    open c_enrt_rt (p_prtt_rt_val_id);
    loop
      fetch c_enrt_rt into l_enrt_rt_id, l_enrt_rt_ovn;
      if c_enrt_rt%notfound then
        exit;
      end if;
    /*
    l_enrt_rt_ovn:=
      dt_api.get_object_version_number
        (p_base_table_name => 'ben_enrt_rt',
         p_base_key_column => 'enrt_rt_id',
         p_base_key_value  => p_enrt_rt_id)-1;
    --
     */

       ben_enrollment_rate_api.update_enrollment_rate(
        p_enrt_rt_id                    => l_enrt_rt_id,
        p_prtt_rt_val_id                => null,
        p_object_version_number         => l_enrt_rt_ovn,
        p_effective_date                => p_effective_date
         );
     end loop;
     close c_enrt_rt;
  end if;
  --
  if l_old_element_entry_value_id is not null then

     l_old_rt_end_dt := l_old_rt_strt_dt - 1;

     ben_element_entry.end_enrollment_element
     (p_business_group_id        => p_business_group_id
     ,p_person_id                => p_person_id
     ,p_enrt_rslt_id             => l_old_enrt_rslt_id
     ,p_acty_ref_perd            => l_old_acty_ref_perd_cd
     ,p_element_link_id          => null
     ,p_prtt_rt_val_id           => p_prtt_rt_val_id
     ,p_rt_end_date              => l_old_rt_end_dt
     ,p_effective_date           => l_old_rt_strt_dt
     ,p_dt_delete_mode           => null
     ,p_acty_base_rt_id          => l_old_abr_id
     ,p_amt                      => l_old_rt_val);

  end if;
  --

  ben_prv_del.del
    (
     p_prtt_rt_val_id                => p_prtt_rt_val_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_prtt_rt_val
    --
    ben_prtt_rt_val_bk3.delete_prtt_rt_val_a
      (
       p_prtt_rt_val_id                 =>  p_prtt_rt_val_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_prtt_rt_val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_prtt_rt_val
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_prtt_rt_val;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_prtt_rt_val;
    raise;
    --
end delete_prtt_rt_val;
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< lck >-----------------------------------|
-- ---------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_rt_val_id                   in     number
  ,p_object_version_number            in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  ben_prv_shd.lck
    (
      p_prtt_rt_val_id                 => p_prtt_rt_val_id
     ,p_object_version_number          => p_object_version_number
    );
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
end lck;
--
end ben_prtt_rt_val_api;

/
