--------------------------------------------------------
--  DDL for Package Body BEN_BENEFIT_PRVDD_LEDGER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFIT_PRVDD_LEDGER_API" as
/* $Header: bebplapi.pkb 120.1.12010000.2 2008/08/05 14:08:59 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Benefit_Prvdd_Ledger_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdd_Ledger >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Benefit_Prvdd_Ledger
  (p_validate                       in  boolean   default false
  ,p_bnft_prvdd_ldgr_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default null
  ,p_frftd_val                      in  number    default null
  ,p_prvdd_val                      in  number    default null
  ,p_used_val                       in  number    default null
  ,p_person_id                      in  number    default null
  ,p_enrt_mthd_cd           in  varchar2  default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_per_in_ler_id                in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bpl_attribute_category         in  varchar2  default null
  ,p_bpl_attribute1                 in  varchar2  default null
  ,p_bpl_attribute2                 in  varchar2  default null
  ,p_bpl_attribute3                 in  varchar2  default null
  ,p_bpl_attribute4                 in  varchar2  default null
  ,p_bpl_attribute5                 in  varchar2  default null
  ,p_bpl_attribute6                 in  varchar2  default null
  ,p_bpl_attribute7                 in  varchar2  default null
  ,p_bpl_attribute8                 in  varchar2  default null
  ,p_bpl_attribute9                 in  varchar2  default null
  ,p_bpl_attribute10                in  varchar2  default null
  ,p_bpl_attribute11                in  varchar2  default null
  ,p_bpl_attribute12                in  varchar2  default null
  ,p_bpl_attribute13                in  varchar2  default null
  ,p_bpl_attribute14                in  varchar2  default null
  ,p_bpl_attribute15                in  varchar2  default null
  ,p_bpl_attribute16                in  varchar2  default null
  ,p_bpl_attribute17                in  varchar2  default null
  ,p_bpl_attribute18                in  varchar2  default null
  ,p_bpl_attribute19                in  varchar2  default null
  ,p_bpl_attribute20                in  varchar2  default null
  ,p_bpl_attribute21                in  varchar2  default null
  ,p_bpl_attribute22                in  varchar2  default null
  ,p_bpl_attribute23                in  varchar2  default null
  ,p_bpl_attribute24                in  varchar2  default null
  ,p_bpl_attribute25                in  varchar2  default null
  ,p_bpl_attribute26                in  varchar2  default null
  ,p_bpl_attribute27                in  varchar2  default null
  ,p_bpl_attribute28                in  varchar2  default null
  ,p_bpl_attribute29                in  varchar2  default null
  ,p_bpl_attribute30                in  varchar2  default null
  ,p_cash_recd_val                  in  number    default null
  ,p_rld_up_val                     in  number    default null
  ,p_effective_date                 in  date
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default null,
  p_cmcd_frftd_val               in   number           default null,
  p_cmcd_prvdd_val               in   number           default null,
  p_cmcd_rld_up_val              in   number           default null,
  p_cmcd_used_val                in   number           default null,
  p_cmcd_cash_recd_val           in   number           default null,
  p_cmcd_ref_perd_cd             in   varchar2         default null,
  p_ann_frftd_val                in   number           default null,
  p_ann_prvdd_val                in   number           default null,
  p_ann_rld_up_val               in   number           default null,
  p_ann_used_val                 in   number           default null,
  p_ann_cash_recd_val            in   number           default null,
  p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_enrt_rslt_id     ben_bnft_prvdd_ldgr_f.prtt_enrt_rslt_id%TYPE;
  l_bnft_prvdd_ldgr_id    ben_bnft_prvdd_ldgr_f.bnft_prvdd_ldgr_id%TYPE;
  l_effective_start_date  ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_proc varchar2(72)     := g_package||'create_Benefit_Prvdd_Ledger';
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_prtt_rt_val_id        number;

  l_cmcd_frftd_val     number := null;
  l_cmcd_prvdd_val     number := null;
  l_cmcd_rld_up_val    number := null;
  l_cmcd_used_val      number := null;
  l_cmcd_cash_recd_val number := null;
  l_ann_frftd_val      number := null;
  l_ann_prvdd_val      number := null;
  l_ann_rld_up_val     number := null;
  l_ann_used_val       number := null;
  l_ann_cash_recd_val  number := null;
  l_acty_ref_perd_cd   varchar2(30) := null;
  l_cmcd_ref_perd_cd   varchar2(30) := null;
  cursor c1 is
    select object_version_number
    from ben_bnft_prvdd_ldgr_f bpl
    where bnft_prvdd_ldgr_id = l_bnft_prvdd_ldgr_id
    and p_effective_date between bpl.effective_start_date
         and bpl.effective_end_date;
  --
  cursor c_bnft_pool is
    select bpp.pgm_id
    from   ben_bnft_prvdr_pool_f bpp
    where  bpp.bnft_prvdr_pool_id = p_bnft_prvdr_pool_id
    and    p_effective_date between bpp.effective_start_date
           and bpp.effective_end_date;
  --
  l_pgm_id        number;


  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_acty_base_rt_id:'||to_char(p_acty_base_rt_id), 11);
  hr_utility.set_location('p_person_id:'||to_char(p_person_id), 11);
  hr_utility.set_location('p_business_group_id:'||to_char(p_business_group_id), 11);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Benefit_Prvdd_Ledger;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  -- if dummy flex credit result id is passed as null then go get it.
  if p_prtt_enrt_rslt_id is null and p_process_enrt_flag = 'Y' then
     --
     open c_bnft_pool;
     fetch c_bnft_pool into l_pgm_id;
     close c_bnft_pool;
     --
     ben_provider_pools.create_flex_credit_enrolment(
      p_person_id          => p_person_id,
      p_enrt_mthd_cd       => p_enrt_mthd_cd,
      p_business_group_id  => p_business_group_id,
      p_effective_date     => p_effective_date,
      p_prtt_enrt_rslt_id  => l_prtt_enrt_rslt_id,
      p_prtt_rt_val_id     => l_prtt_rt_val_id,
      p_per_in_ler_id      => p_per_in_ler_id,
      p_rt_val             => null,
      p_pgm_id             => l_pgm_id );
  else
    l_prtt_enrt_rslt_id:=p_prtt_enrt_rslt_id;
  end if;

  --
  -- Bug#2278267 - for rollover plans the communicated values calculated after the result is
  -- created
  if p_prtt_ro_of_unusd_amt_flag = 'Y' and p_process_enrt_flag = 'Y'
     and p_from_reinstate_enrt_flag = 'N' then
    --
    l_acty_ref_perd_cd   := p_acty_ref_perd_cd;
    l_cmcd_ref_perd_cd   := p_cmcd_ref_perd_cd;
    l_cmcd_frftd_val     := p_cmcd_frftd_val;
    l_cmcd_prvdd_val     := p_cmcd_prvdd_val ;
    l_cmcd_rld_up_val    := p_cmcd_rld_up_val;
    l_cmcd_used_val      := p_cmcd_used_val;
    l_cmcd_cash_recd_val := p_cmcd_cash_recd_val;
    l_ann_frftd_val      := p_ann_frftd_val;
    l_ann_prvdd_val      := p_ann_prvdd_val;
    l_ann_rld_up_val     := p_ann_rld_up_val;
    l_ann_used_val       := p_ann_used_val;
    l_ann_cash_recd_val  := p_ann_cash_recd_val;

  else
    --
    if (p_frftd_val is not null and p_cmcd_frftd_val is null) or
       (p_used_val is not null and p_cmcd_used_val is null) or
       (p_prvdd_val is not null and p_cmcd_prvdd_val is null) or
       (p_cash_recd_val is not null and p_cmcd_cash_recd_val is null) or
       (p_rld_up_val is not null and p_cmcd_rld_up_val is null) then

      -- get the communicated and annual values
      ben_update_ledgers.get_cmcd_ann_values
             (p_bnft_prvdd_ldgr_id   => null,
             p_acty_base_rt_id       => p_acty_base_rt_id,
             p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id,
             p_business_group_id     => p_business_group_id,
             p_effective_start_date  => p_effective_date,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_frftd_val             => p_frftd_val,
             p_used_val              => p_used_val,
             p_prvdd_val             => p_prvdd_val,
             p_cash_recd_val         => p_cash_recd_val,
             p_rld_up_val            => p_rld_up_val,
             p_acty_ref_perd_cd      => l_acty_ref_perd_cd,
             p_cmcd_ref_perd_cd      => l_cmcd_ref_perd_cd,
             p_cmcd_frftd_val        => l_cmcd_frftd_val,
             p_cmcd_prvdd_val        => l_cmcd_prvdd_val,
             p_cmcd_rld_up_val       => l_cmcd_rld_up_val,
             p_cmcd_used_val         => l_cmcd_used_val,
             p_cmcd_cash_recd_val    => l_cmcd_cash_recd_val,
             p_ann_frftd_val         => l_ann_frftd_val,
             p_ann_prvdd_val         => l_ann_prvdd_val,
             p_ann_rld_up_val        => l_ann_rld_up_val,
             p_ann_used_val          => l_ann_used_val,
             p_ann_cash_recd_val     => l_ann_cash_recd_val);
    else
       l_acty_ref_perd_cd   := p_acty_ref_perd_cd;
       l_cmcd_ref_perd_cd   := p_cmcd_ref_perd_cd;
       l_cmcd_frftd_val     := p_cmcd_frftd_val;
       l_cmcd_prvdd_val     := p_cmcd_prvdd_val ;
       l_cmcd_rld_up_val    := p_cmcd_rld_up_val;
       l_cmcd_used_val      := p_cmcd_used_val;
       l_cmcd_cash_recd_val := p_cmcd_cash_recd_val;
       l_ann_frftd_val      := p_ann_frftd_val;
       l_ann_prvdd_val      := p_ann_prvdd_val;
       l_ann_rld_up_val     := p_ann_rld_up_val;
       l_ann_used_val       := p_ann_used_val;
       l_ann_cash_recd_val  := p_ann_cash_recd_val;
    end if;
    --
  end if;


  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk1.create_Benefit_Prvdd_Ledger_b
      (
       p_prtt_ro_of_unusd_amt_flag      =>  p_prtt_ro_of_unusd_amt_flag
      ,p_frftd_val                      =>  p_frftd_val
      ,p_prvdd_val                      =>  p_prvdd_val
      ,p_used_val                       =>  p_used_val
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpl_attribute_category         =>  p_bpl_attribute_category
      ,p_bpl_attribute1                 =>  p_bpl_attribute1
      ,p_bpl_attribute2                 =>  p_bpl_attribute2
      ,p_bpl_attribute3                 =>  p_bpl_attribute3
      ,p_bpl_attribute4                 =>  p_bpl_attribute4
      ,p_bpl_attribute5                 =>  p_bpl_attribute5
      ,p_bpl_attribute6                 =>  p_bpl_attribute6
      ,p_bpl_attribute7                 =>  p_bpl_attribute7
      ,p_bpl_attribute8                 =>  p_bpl_attribute8
      ,p_bpl_attribute9                 =>  p_bpl_attribute9
      ,p_bpl_attribute10                =>  p_bpl_attribute10
      ,p_bpl_attribute11                =>  p_bpl_attribute11
      ,p_bpl_attribute12                =>  p_bpl_attribute12
      ,p_bpl_attribute13                =>  p_bpl_attribute13
      ,p_bpl_attribute14                =>  p_bpl_attribute14
      ,p_bpl_attribute15                =>  p_bpl_attribute15
      ,p_bpl_attribute16                =>  p_bpl_attribute16
      ,p_bpl_attribute17                =>  p_bpl_attribute17
      ,p_bpl_attribute18                =>  p_bpl_attribute18
      ,p_bpl_attribute19                =>  p_bpl_attribute19
      ,p_bpl_attribute20                =>  p_bpl_attribute20
      ,p_bpl_attribute21                =>  p_bpl_attribute21
      ,p_bpl_attribute22                =>  p_bpl_attribute22
      ,p_bpl_attribute23                =>  p_bpl_attribute23
      ,p_bpl_attribute24                =>  p_bpl_attribute24
      ,p_bpl_attribute25                =>  p_bpl_attribute25
      ,p_bpl_attribute26                =>  p_bpl_attribute26
      ,p_bpl_attribute27                =>  p_bpl_attribute27
      ,p_bpl_attribute28                =>  p_bpl_attribute28
      ,p_bpl_attribute29                =>  p_bpl_attribute29
      ,p_bpl_attribute30                =>  p_bpl_attribute30
      ,p_cash_recd_val                  =>  p_cash_recd_val
      ,p_rld_up_val                     =>  p_rld_up_val
      ,p_effective_date                 => trunc(p_effective_date),
	p_acty_ref_perd_cd              =>   l_acty_ref_perd_cd,
	p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
	p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
	p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
	p_cmcd_used_val                 =>   l_cmcd_used_val,
	p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
	p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
	p_ann_frftd_val                 =>   l_ann_frftd_val,
	p_ann_prvdd_val                 =>   l_ann_prvdd_val,
	p_ann_rld_up_val                =>   l_ann_rld_up_val,
	p_ann_used_val                  =>   l_ann_used_val,
	p_ann_cash_recd_val             =>   l_ann_cash_recd_val
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Benefit_Prvdd_Ledger
    --
  end;
  --
  ben_bpl_ins.ins
    (
     p_bnft_prvdd_ldgr_id            => l_bnft_prvdd_ldgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtt_ro_of_unusd_amt_flag     => p_prtt_ro_of_unusd_amt_flag
    ,p_frftd_val                     => p_frftd_val
    ,p_prvdd_val                     => p_prvdd_val
    ,p_used_val                      => p_used_val
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_prtt_enrt_rslt_id             => l_prtt_enrt_rslt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpl_attribute_category        => p_bpl_attribute_category
    ,p_bpl_attribute1                => p_bpl_attribute1
    ,p_bpl_attribute2                => p_bpl_attribute2
    ,p_bpl_attribute3                => p_bpl_attribute3
    ,p_bpl_attribute4                => p_bpl_attribute4
    ,p_bpl_attribute5                => p_bpl_attribute5
    ,p_bpl_attribute6                => p_bpl_attribute6
    ,p_bpl_attribute7                => p_bpl_attribute7
    ,p_bpl_attribute8                => p_bpl_attribute8
    ,p_bpl_attribute9                => p_bpl_attribute9
    ,p_bpl_attribute10               => p_bpl_attribute10
    ,p_bpl_attribute11               => p_bpl_attribute11
    ,p_bpl_attribute12               => p_bpl_attribute12
    ,p_bpl_attribute13               => p_bpl_attribute13
    ,p_bpl_attribute14               => p_bpl_attribute14
    ,p_bpl_attribute15               => p_bpl_attribute15
    ,p_bpl_attribute16               => p_bpl_attribute16
    ,p_bpl_attribute17               => p_bpl_attribute17
    ,p_bpl_attribute18               => p_bpl_attribute18
    ,p_bpl_attribute19               => p_bpl_attribute19
    ,p_bpl_attribute20               => p_bpl_attribute20
    ,p_bpl_attribute21               => p_bpl_attribute21
    ,p_bpl_attribute22               => p_bpl_attribute22
    ,p_bpl_attribute23               => p_bpl_attribute23
    ,p_bpl_attribute24               => p_bpl_attribute24
    ,p_bpl_attribute25               => p_bpl_attribute25
    ,p_bpl_attribute26               => p_bpl_attribute26
    ,p_bpl_attribute27               => p_bpl_attribute27
    ,p_bpl_attribute28               => p_bpl_attribute28
    ,p_bpl_attribute29               => p_bpl_attribute29
    ,p_bpl_attribute30               => p_bpl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_cash_recd_val                 => p_cash_recd_val
    ,p_rld_up_val                    =>  p_rld_up_val
    ,p_effective_date                => trunc(p_effective_date),
	p_acty_ref_perd_cd              =>   l_acty_ref_perd_cd,
	p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
	p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
	p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
	p_cmcd_used_val                 =>   l_cmcd_used_val,
	p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
	p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
	p_ann_frftd_val                 =>   l_ann_frftd_val,
	p_ann_prvdd_val                 =>   l_ann_prvdd_val,
	p_ann_rld_up_val                =>   l_ann_rld_up_val,
	p_ann_used_val                  =>   l_ann_used_val,
	p_ann_cash_recd_val             =>   l_ann_cash_recd_val
    );
  --
   -- Create/update the enrollment to include the rollover amount.
  --
  if p_prtt_ro_of_unusd_amt_flag='Y' and p_process_enrt_flag = 'Y'
     and p_from_reinstate_enrt_flag = 'N'
  then
    ben_provider_pools.create_rollover_enrollment(
    p_bnft_prvdr_pool_id    => p_bnft_prvdr_pool_id,
    p_person_id             => p_person_id,
    p_per_in_ler_id         => p_per_in_ler_id,
    p_effective_date        => p_effective_date,
    p_datetrack_mode        => hr_api.g_update,
    p_acty_base_rt_id       => p_acty_base_rt_id,
    p_rlovr_amt             => p_used_val,
    p_old_rlovr_amt         => 0,               -- Creation so old value is 0.
    p_business_group_id     => p_business_group_id,
    p_enrt_mthd_cd          => p_enrt_mthd_cd
    );
    --
     ben_update_ledgers.get_cmcd_ann_values
             (p_bnft_prvdd_ldgr_id   => null,
             p_acty_base_rt_id       => p_acty_base_rt_id,
             p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id,
             p_business_group_id     => p_business_group_id,
             p_effective_start_date  => p_effective_date,
             p_per_in_ler_id         => p_per_in_ler_id,
             p_frftd_val             => p_frftd_val,
             p_used_val              => p_used_val,
             p_prvdd_val             => p_prvdd_val,
             p_cash_recd_val         => p_cash_recd_val,
             p_rld_up_val            => p_rld_up_val,
             p_acty_ref_perd_cd      => l_acty_ref_perd_cd,
             p_cmcd_ref_perd_cd      => l_cmcd_ref_perd_cd,
             p_cmcd_frftd_val        => l_cmcd_frftd_val,
             p_cmcd_prvdd_val        => l_cmcd_prvdd_val,
             p_cmcd_rld_up_val       => l_cmcd_rld_up_val,
             p_cmcd_used_val         => l_cmcd_used_val,
             p_cmcd_cash_recd_val    => l_cmcd_cash_recd_val,
             p_ann_frftd_val         => l_ann_frftd_val,
             p_ann_prvdd_val         => l_ann_prvdd_val,
             p_ann_rld_up_val        => l_ann_rld_up_val,
             p_ann_used_val          => l_ann_used_val,
             p_ann_cash_recd_val     => l_ann_cash_recd_val);
     --
        open c1;
        fetch c1 into l_object_version_number;
        close c1;
        --
        ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger (
           p_bnft_prvdd_ldgr_id           => l_bnft_prvdd_ldgr_id
          ,p_effective_start_date         => l_effective_start_date
          ,p_effective_end_date           => l_effective_end_date
          ,p_acty_ref_perd_cd             => l_acty_ref_perd_cd
          ,p_cmcd_frftd_val               => l_cmcd_frftd_val
          ,p_cmcd_prvdd_val               => l_cmcd_prvdd_val
          ,p_cmcd_rld_up_val              => l_cmcd_rld_up_val
          ,p_cmcd_used_val                => l_cmcd_used_val
          ,p_cmcd_cash_recd_val           => l_cmcd_cash_recd_val
          ,p_cmcd_ref_perd_cd             => l_cmcd_ref_perd_cd
          ,p_ann_frftd_val                => l_ann_frftd_val
          ,p_ann_prvdd_val                => l_ann_prvdd_val
          ,p_ann_rld_up_val               => l_ann_rld_up_val
          ,p_ann_used_val                 => l_ann_used_val
          ,p_ann_cash_recd_val            => l_ann_cash_recd_val
          ,p_object_version_number        => l_object_version_number
          ,p_effective_date               => trunc(p_effective_date)
          ,p_datetrack_mode               => 'CORRECTION');
          --
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk1.create_Benefit_Prvdd_Ledger_a
      (
       p_bnft_prvdd_ldgr_id             =>  l_bnft_prvdd_ldgr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prtt_ro_of_unusd_amt_flag      =>  p_prtt_ro_of_unusd_amt_flag
      ,p_frftd_val                      =>  p_frftd_val
      ,p_prvdd_val                      =>  p_prvdd_val
      ,p_used_val                       =>  p_used_val
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_rslt_id              =>  l_prtt_enrt_rslt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpl_attribute_category         =>  p_bpl_attribute_category
      ,p_bpl_attribute1                 =>  p_bpl_attribute1
      ,p_bpl_attribute2                 =>  p_bpl_attribute2
      ,p_bpl_attribute3                 =>  p_bpl_attribute3
      ,p_bpl_attribute4                 =>  p_bpl_attribute4
      ,p_bpl_attribute5                 =>  p_bpl_attribute5
      ,p_bpl_attribute6                 =>  p_bpl_attribute6
      ,p_bpl_attribute7                 =>  p_bpl_attribute7
      ,p_bpl_attribute8                 =>  p_bpl_attribute8
      ,p_bpl_attribute9                 =>  p_bpl_attribute9
      ,p_bpl_attribute10                =>  p_bpl_attribute10
      ,p_bpl_attribute11                =>  p_bpl_attribute11
      ,p_bpl_attribute12                =>  p_bpl_attribute12
      ,p_bpl_attribute13                =>  p_bpl_attribute13
      ,p_bpl_attribute14                =>  p_bpl_attribute14
      ,p_bpl_attribute15                =>  p_bpl_attribute15
      ,p_bpl_attribute16                =>  p_bpl_attribute16
      ,p_bpl_attribute17                =>  p_bpl_attribute17
      ,p_bpl_attribute18                =>  p_bpl_attribute18
      ,p_bpl_attribute19                =>  p_bpl_attribute19
      ,p_bpl_attribute20                =>  p_bpl_attribute20
      ,p_bpl_attribute21                =>  p_bpl_attribute21
      ,p_bpl_attribute22                =>  p_bpl_attribute22
      ,p_bpl_attribute23                =>  p_bpl_attribute23
      ,p_bpl_attribute24                =>  p_bpl_attribute24
      ,p_bpl_attribute25                =>  p_bpl_attribute25
      ,p_bpl_attribute26                =>  p_bpl_attribute26
      ,p_bpl_attribute27                =>  p_bpl_attribute27
      ,p_bpl_attribute28                =>  p_bpl_attribute28
      ,p_bpl_attribute29                =>  p_bpl_attribute29
      ,p_bpl_attribute30                =>  p_bpl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_cash_recd_val                  =>  p_cash_recd_val
      ,p_rld_up_val                     =>  p_rld_up_val
      ,p_effective_date                 => trunc(p_effective_date),
	p_acty_ref_perd_cd              =>   l_acty_ref_perd_cd,
	p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
	p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
	p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
	p_cmcd_used_val                 =>   l_cmcd_used_val,
	p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
	p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
	p_ann_frftd_val                 =>   l_ann_frftd_val,
	p_ann_prvdd_val                 =>   l_ann_prvdd_val,
	p_ann_rld_up_val                =>   l_ann_rld_up_val,
	p_ann_used_val                  =>   l_ann_used_val,
	p_ann_cash_recd_val             =>   l_ann_cash_recd_val
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Benefit_Prvdd_Ledger
    --
  end;
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
  p_bnft_prvdd_ldgr_id := l_bnft_prvdd_ldgr_id;
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
    ROLLBACK TO create_Benefit_Prvdd_Ledger;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_prvdd_ldgr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Benefit_Prvdd_Ledger;
    p_bnft_prvdd_ldgr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_Benefit_Prvdd_Ledger;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdd_Ledger_w >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Benefit_Prvdd_Ledger_w
  (p_validate                       in  varchar2  default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default null
  ,p_frftd_val                      in  number    default null
  ,p_prvdd_val                      in  number    default null
  ,p_used_val                       in  number    default null
  ,p_person_id                      in  number    default null
  ,p_enrt_mthd_cd                   in  varchar2  default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cash_recd_val                  in  number    default null
  ,p_rld_up_val                     in  number    default null
  ,p_effective_date                 in  date
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default null,
  p_cmcd_frftd_val               in   number           default null,
  p_cmcd_prvdd_val               in   number           default null,
  p_cmcd_rld_up_val              in   number           default null,
  p_cmcd_used_val                in   number           default null,
  p_cmcd_cash_recd_val           in   number           default null,
  p_cmcd_ref_perd_cd             in   varchar2         default null,
  p_ann_frftd_val                in   number           default null,
  p_ann_prvdd_val                in   number           default null,
  p_ann_rld_up_val               in   number           default null,
  p_ann_used_val                 in   number           default null,
  p_ann_cash_recd_val            in   number           default null,
  p_object_version_number          out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_bnft_prvdd_ldgr_id    ben_bnft_prvdd_ldgr_f.bnft_prvdd_ldgr_id%TYPE;
  l_effective_start_date  ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_validate              BOOLEAN;

  l_proc varchar2(72)     := g_package||'create_Benefit_Prvdd_Ledger_w';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_acty_base_rt_id:'||to_char(p_acty_base_rt_id), 11);
  hr_utility.set_location('p_person_id:'||to_char(p_person_id), 11);
  hr_utility.set_location('p_business_group_id:'||to_char(p_business_group_id), 11);
  --
  hr_utility.set_location(l_proc, 20);
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger
      (
       p_validate                      => l_validate
      ,p_bnft_prvdd_ldgr_id            => l_bnft_prvdd_ldgr_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_prtt_ro_of_unusd_amt_flag     => p_prtt_ro_of_unusd_amt_flag
      ,p_frftd_val                     => p_frftd_val
      ,p_prvdd_val                     => p_prvdd_val
      ,p_used_val                      => p_used_val
      ,p_person_id                     => p_person_id
      ,p_enrt_mthd_cd                  => p_enrt_mthd_cd
      ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id               => p_acty_base_rt_id
      ,p_per_in_ler_id                 => p_per_in_ler_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_cash_recd_val                 => p_cash_recd_val
      ,p_rld_up_val                    => p_rld_up_val
      ,p_effective_date                => trunc(p_effective_date)
      ,p_process_enrt_flag             => p_process_enrt_flag
      ,p_from_reinstate_enrt_flag      => p_from_reinstate_enrt_flag,
	p_acty_ref_perd_cd              =>   p_acty_ref_perd_cd,
	p_cmcd_frftd_val                =>   p_cmcd_frftd_val,
	p_cmcd_prvdd_val                =>   p_cmcd_prvdd_val,
	p_cmcd_rld_up_val               =>   p_cmcd_rld_up_val,
	p_cmcd_used_val                 =>   p_cmcd_used_val,
	p_cmcd_cash_recd_val            =>   p_cmcd_cash_recd_val,
	p_cmcd_ref_perd_cd              =>   p_cmcd_ref_perd_cd,
	p_ann_frftd_val                 =>   p_ann_frftd_val,
	p_ann_prvdd_val                 =>   p_ann_prvdd_val,
	p_ann_rld_up_val                =>   p_ann_rld_up_val,
	p_ann_used_val                  =>   p_ann_used_val,
	p_ann_cash_recd_val             =>   p_ann_cash_recd_val
      );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Set all output arguments
  --
  p_bnft_prvdd_ldgr_id    := l_bnft_prvdd_ldgr_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
exception
  --
  when others then
    p_bnft_prvdd_ldgr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    fnd_msg_pub.add;
  --
end create_Benefit_Prvdd_Ledger_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdd_Ledger >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Benefit_Prvdd_Ledger
  (p_validate                       in  boolean   default false
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_frftd_val                      in  number    default hr_api.g_number
  ,p_prvdd_val                      in  number    default hr_api.g_number
  ,p_used_val                       in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_per_in_ler_id                in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bpl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bpl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_cash_recd_val                  in  number    default hr_api.g_number
  ,p_rld_up_val                     in number     default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_cmcd_frftd_val               in   number           default hr_api.g_number,
  p_cmcd_prvdd_val               in   number           default hr_api.g_number,
  p_cmcd_rld_up_val              in   number           default hr_api.g_number,
  p_cmcd_used_val                in   number           default hr_api.g_number,
  p_cmcd_cash_recd_val           in   number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_ann_frftd_val                in   number           default hr_api.g_number,
  p_ann_prvdd_val                in   number           default hr_api.g_number,
  p_ann_rld_up_val               in   number           default hr_api.g_number,
  p_ann_used_val                 in   number           default hr_api.g_number,
  p_ann_cash_recd_val            in   number           default hr_api.g_number,
  p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Benefit_Prvdd_Ledger';
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_dup_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_bnft_prvdr_pool_id number;
  l_person_id number;
  l_acty_base_rt_id number;
  l_per_in_ler_id number;
  l_enrt_mthd_cd varchar2(30);
  l_old_used_val number;
  --
  -- cursor to get the ledger info
  --
  cursor c_ledger_info is
    select bpl.bnft_prvdr_pool_id,
           pen.person_id,
           bpl.acty_base_rt_id,
           bpl.per_in_ler_id,
           bpl.used_val,
           pen.enrt_mthd_cd
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_prtt_enrt_rslt_f pen,
    -- Bug : 1634870 : UK changes
           ben_per_in_ler pil
    where  bpl.bnft_prvdd_ldgr_id=p_bnft_prvdd_ldgr_id and
           bpl.object_version_number=p_object_version_number and
           bpl.business_group_id=p_business_group_id and
           pen.prtt_enrt_rslt_id=bpl.prtt_enrt_rslt_id and
           pen.business_group_id=p_business_group_id and
	   pen.prtt_enrt_rslt_stat_cd is null and
    -- Bug : 1634870 : UK changes
           pil.per_in_ler_id=bpl.per_in_ler_id and
           pil.business_group_id=bpl.business_group_id and
           pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') and
           p_effective_date between
             pen.effective_start_date and pen.effective_end_date;
    --
    -- Bug: 3611160/4169180: Added this cursor.
    cursor c1 is
    select object_version_number
      from ben_bnft_prvdd_ldgr_f bpl
     where bnft_prvdd_ldgr_id = p_bnft_prvdd_ldgr_id
       and p_effective_date between bpl.effective_start_date
       and bpl.effective_end_date;
    --

  l_cmcd_frftd_val     number := null;
  l_cmcd_prvdd_val     number := null;
  l_cmcd_rld_up_val    number := null;
  l_cmcd_used_val      number := null;
  l_cmcd_cash_recd_val number := null;
  l_ann_frftd_val      number := null;
  l_ann_prvdd_val      number := null;
  l_ann_rld_up_val     number := null;
  l_ann_used_val       number := null;
  l_ann_cash_recd_val  number := null;
  l_acty_ref_perd_cd   varchar2(30) := null;
  l_cmcd_ref_perd_cd   varchar2(30) := null;
  l_hr_api_g_number    number := hr_api.g_number;
  l_bnft_prvdd_ldgr_updated boolean := FALSE;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Issue a savepoint if operating in validation only mode
  savepoint update_Benefit_Prvdd_Ledger;

  hr_utility.set_location(l_proc, 20);

  -- Process Logic
  l_object_version_number := p_object_version_number;

  --
  -- Get the info to do the result adjustment
  --   have to get it before the delete takes place
  --
  if p_prtt_ro_of_unusd_amt_flag='Y' and p_process_enrt_flag = 'Y' then
    open c_ledger_info;
    fetch c_ledger_info into
      l_bnft_prvdr_pool_id,
      l_person_id,
      l_acty_base_rt_id,
      l_per_in_ler_id,
      l_old_used_val,
      l_enrt_mthd_cd
    ;
    if c_ledger_info%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    close c_ledger_info;
  end if;

  --
  -- Create/update the enrollment to include the rollover amount.
  --  (lmcdonal 20-Feb-02:  moved this to here from after the update of the ldgr
  --   because we need the prtt-rt to have been created to go get the cmcd and annual
  --   values to put onto the ldgr)
  if p_prtt_ro_of_unusd_amt_flag='Y' and p_process_enrt_flag = 'Y'
     and p_from_reinstate_enrt_flag = 'N'
  then
    ben_provider_pools.create_rollover_enrollment(
    p_bnft_prvdr_pool_id    => p_bnft_prvdr_pool_id,
    p_person_id             => l_person_id,
    p_per_in_ler_id         => p_per_in_ler_id,
    p_effective_date        => p_effective_date,
    p_datetrack_mode        => p_datetrack_mode,
    p_acty_base_rt_id       => p_acty_base_rt_id,
    p_rlovr_amt             => p_used_val,
    p_old_rlovr_amt         => l_old_used_val,
    p_business_group_id     => p_business_group_id,
    p_enrt_mthd_cd          => l_enrt_mthd_cd);
    --
    -- Bug: 3611160/4169180:
    -- If create_rollover_enrollment calls update_Benefit_Prvdd_Ledger internally,
    -- then fetch the new object_version_number.
    -- If the bnft_prvdd_ldgr row is updated, then avoid calling the ben_bpl_upd.upd.
    --
    open c1;
    fetch c1 into l_dup_object_version_number;
    close c1;
    --
    if (l_dup_object_version_number IS NOT NULL
         AND l_object_version_number <> l_dup_object_version_number) then
        l_bnft_prvdd_ldgr_updated := TRUE;
        l_object_version_number := l_dup_object_version_number;
    end if;
    --  Bug: 3611160/4169180 Changes end...
  end if;

   if (p_frftd_val is not null and  p_frftd_val <> l_hr_api_g_number and
         (p_cmcd_frftd_val is null or p_cmcd_frftd_val = l_hr_api_g_number)) or
     (p_used_val is not null and  p_used_val <> l_hr_api_g_number and
         (p_cmcd_used_val is null or p_cmcd_used_val = l_hr_api_g_number)) or
     (p_prvdd_val is not null and  p_prvdd_val <> l_hr_api_g_number and
         (p_cmcd_prvdd_val is null or p_cmcd_prvdd_val = l_hr_api_g_number)) or
     (p_cash_recd_val is not null and   p_cash_recd_val <> l_hr_api_g_number and
        (p_cmcd_cash_recd_val is null or p_cmcd_cash_recd_val = l_hr_api_g_number)) or
     (p_rld_up_val is not null and   p_rld_up_val <> l_hr_api_g_number and
         (p_cmcd_rld_up_val is null or p_cmcd_rld_up_val = l_hr_api_g_number)) then
    -- get the communicated and annual values
    ben_update_ledgers.get_cmcd_ann_values
           (p_bnft_prvdd_ldgr_id   => p_bnft_prvdd_ldgr_id,
           p_acty_base_rt_id       => p_acty_base_rt_id,
           p_prtt_enrt_rslt_id     => p_prtt_enrt_rslt_id,
           p_business_group_id     => p_business_group_id,
           p_effective_start_date  => p_effective_date,
           p_per_in_ler_id         => p_per_in_ler_id,
           p_frftd_val             => p_frftd_val,
           p_used_val              => p_used_val,
           p_prvdd_val             => p_prvdd_val,
           p_cash_recd_val         => p_cash_recd_val,
           p_rld_up_val            => p_rld_up_val,
           p_acty_ref_perd_cd      => l_acty_ref_perd_cd,
           p_cmcd_ref_perd_cd      => l_cmcd_ref_perd_cd,
           p_cmcd_frftd_val        => l_cmcd_frftd_val,
           p_cmcd_prvdd_val        => l_cmcd_prvdd_val,
           p_cmcd_rld_up_val       => l_cmcd_rld_up_val,
           p_cmcd_used_val         => l_cmcd_used_val,
           p_cmcd_cash_recd_val    => l_cmcd_cash_recd_val,
           p_ann_frftd_val         => l_ann_frftd_val,
           p_ann_prvdd_val         => l_ann_prvdd_val,
           p_ann_rld_up_val        => l_ann_rld_up_val,
           p_ann_used_val          => l_ann_used_val,
           p_ann_cash_recd_val     => l_ann_cash_recd_val);
  else
     l_acty_ref_perd_cd   := p_acty_ref_perd_cd;
     l_cmcd_ref_perd_cd   := p_cmcd_ref_perd_cd;
     l_cmcd_frftd_val     := p_cmcd_frftd_val;
     l_cmcd_prvdd_val     := p_cmcd_prvdd_val ;
     l_cmcd_rld_up_val    := p_cmcd_rld_up_val;
     l_cmcd_used_val      := p_cmcd_used_val;
     l_cmcd_cash_recd_val := p_cmcd_cash_recd_val;
     l_ann_frftd_val      := p_ann_frftd_val;
     l_ann_prvdd_val      := p_ann_prvdd_val;
     l_ann_rld_up_val     := p_ann_rld_up_val;
     l_ann_used_val       := p_ann_used_val;
     l_ann_cash_recd_val  := p_ann_cash_recd_val;
  end if;
--
if (NOT l_bnft_prvdd_ldgr_updated) then --  Bug: 3611160/4169180 Added this condition
  --
  begin
    -- Start of API User Hook for the before hook of update_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk2.update_Benefit_Prvdd_Ledger_b
      (
       p_bnft_prvdd_ldgr_id             =>  p_bnft_prvdd_ldgr_id
      ,p_prtt_ro_of_unusd_amt_flag      =>  p_prtt_ro_of_unusd_amt_flag
      ,p_frftd_val                      =>  p_frftd_val
      ,p_prvdd_val                      =>  p_prvdd_val
      ,p_used_val                       =>  p_used_val
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpl_attribute_category         =>  p_bpl_attribute_category
      ,p_bpl_attribute1                 =>  p_bpl_attribute1
      ,p_bpl_attribute2                 =>  p_bpl_attribute2
      ,p_bpl_attribute3                 =>  p_bpl_attribute3
      ,p_bpl_attribute4                 =>  p_bpl_attribute4
      ,p_bpl_attribute5                 =>  p_bpl_attribute5
      ,p_bpl_attribute6                 =>  p_bpl_attribute6
      ,p_bpl_attribute7                 =>  p_bpl_attribute7
      ,p_bpl_attribute8                 =>  p_bpl_attribute8
      ,p_bpl_attribute9                 =>  p_bpl_attribute9
      ,p_bpl_attribute10                =>  p_bpl_attribute10
      ,p_bpl_attribute11                =>  p_bpl_attribute11
      ,p_bpl_attribute12                =>  p_bpl_attribute12
      ,p_bpl_attribute13                =>  p_bpl_attribute13
      ,p_bpl_attribute14                =>  p_bpl_attribute14
      ,p_bpl_attribute15                =>  p_bpl_attribute15
      ,p_bpl_attribute16                =>  p_bpl_attribute16
      ,p_bpl_attribute17                =>  p_bpl_attribute17
      ,p_bpl_attribute18                =>  p_bpl_attribute18
      ,p_bpl_attribute19                =>  p_bpl_attribute19
      ,p_bpl_attribute20                =>  p_bpl_attribute20
      ,p_bpl_attribute21                =>  p_bpl_attribute21
      ,p_bpl_attribute22                =>  p_bpl_attribute22
      ,p_bpl_attribute23                =>  p_bpl_attribute23
      ,p_bpl_attribute24                =>  p_bpl_attribute24
      ,p_bpl_attribute25                =>  p_bpl_attribute25
      ,p_bpl_attribute26                =>  p_bpl_attribute26
      ,p_bpl_attribute27                =>  p_bpl_attribute27
      ,p_bpl_attribute28                =>  p_bpl_attribute28
      ,p_bpl_attribute29                =>  p_bpl_attribute29
      ,p_bpl_attribute30                =>  p_bpl_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_cash_recd_val                  =>  p_cash_recd_val
      ,p_rld_up_val                     =>  p_rld_up_val
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode,
    p_acty_ref_perd_cd              =>   l_acty_ref_perd_cd,
    p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
    p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
    p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
    p_cmcd_used_val                 =>   l_cmcd_used_val,
    p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
    p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
    p_ann_frftd_val                 =>   l_ann_frftd_val,
    p_ann_prvdd_val                 =>   l_ann_prvdd_val,
    p_ann_rld_up_val                =>   l_ann_rld_up_val,
    p_ann_used_val                  =>   l_ann_used_val,
    p_ann_cash_recd_val             =>   l_ann_cash_recd_val
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Benefit_Prvdd_Ledger
    --
  end;
  --
  ben_bpl_upd.upd
    (
     p_bnft_prvdd_ldgr_id            => p_bnft_prvdd_ldgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtt_ro_of_unusd_amt_flag     => p_prtt_ro_of_unusd_amt_flag
    ,p_frftd_val                     => p_frftd_val
    ,p_prvdd_val                     => p_prvdd_val
    ,p_used_val                      => p_used_val
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpl_attribute_category        => p_bpl_attribute_category
    ,p_bpl_attribute1                => p_bpl_attribute1
    ,p_bpl_attribute2                => p_bpl_attribute2
    ,p_bpl_attribute3                => p_bpl_attribute3
    ,p_bpl_attribute4                => p_bpl_attribute4
    ,p_bpl_attribute5                => p_bpl_attribute5
    ,p_bpl_attribute6                => p_bpl_attribute6
    ,p_bpl_attribute7                => p_bpl_attribute7
    ,p_bpl_attribute8                => p_bpl_attribute8
    ,p_bpl_attribute9                => p_bpl_attribute9
    ,p_bpl_attribute10               => p_bpl_attribute10
    ,p_bpl_attribute11               => p_bpl_attribute11
    ,p_bpl_attribute12               => p_bpl_attribute12
    ,p_bpl_attribute13               => p_bpl_attribute13
    ,p_bpl_attribute14               => p_bpl_attribute14
    ,p_bpl_attribute15               => p_bpl_attribute15
    ,p_bpl_attribute16               => p_bpl_attribute16
    ,p_bpl_attribute17               => p_bpl_attribute17
    ,p_bpl_attribute18               => p_bpl_attribute18
    ,p_bpl_attribute19               => p_bpl_attribute19
    ,p_bpl_attribute20               => p_bpl_attribute20
    ,p_bpl_attribute21               => p_bpl_attribute21
    ,p_bpl_attribute22               => p_bpl_attribute22
    ,p_bpl_attribute23               => p_bpl_attribute23
    ,p_bpl_attribute24               => p_bpl_attribute24
    ,p_bpl_attribute25               => p_bpl_attribute25
    ,p_bpl_attribute26               => p_bpl_attribute26
    ,p_bpl_attribute27               => p_bpl_attribute27
    ,p_bpl_attribute28               => p_bpl_attribute28
    ,p_bpl_attribute29               => p_bpl_attribute29
    ,p_bpl_attribute30               => p_bpl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_cash_recd_val                 => p_cash_recd_val
    ,p_rld_up_val                    =>  p_rld_up_val
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode,
    p_acty_ref_perd_cd              =>   l_acty_ref_perd_cd,
    p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
    p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
    p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
    p_cmcd_used_val                 =>   l_cmcd_used_val,
    p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
    p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
    p_ann_frftd_val                 =>   l_ann_frftd_val,
    p_ann_prvdd_val                 =>   l_ann_prvdd_val,
    p_ann_rld_up_val                =>   l_ann_rld_up_val,
    p_ann_used_val                  =>   l_ann_used_val,
    p_ann_cash_recd_val             =>   l_ann_cash_recd_val
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk2.update_Benefit_Prvdd_Ledger_a
      (
       p_bnft_prvdd_ldgr_id             =>  p_bnft_prvdd_ldgr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prtt_ro_of_unusd_amt_flag      =>  p_prtt_ro_of_unusd_amt_flag
      ,p_frftd_val                      =>  p_frftd_val
      ,p_prvdd_val                      =>  p_prvdd_val
      ,p_used_val                       =>  p_used_val
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpl_attribute_category         =>  p_bpl_attribute_category
      ,p_bpl_attribute1                 =>  p_bpl_attribute1
      ,p_bpl_attribute2                 =>  p_bpl_attribute2
      ,p_bpl_attribute3                 =>  p_bpl_attribute3
      ,p_bpl_attribute4                 =>  p_bpl_attribute4
      ,p_bpl_attribute5                 =>  p_bpl_attribute5
      ,p_bpl_attribute6                 =>  p_bpl_attribute6
      ,p_bpl_attribute7                 =>  p_bpl_attribute7
      ,p_bpl_attribute8                 =>  p_bpl_attribute8
      ,p_bpl_attribute9                 =>  p_bpl_attribute9
      ,p_bpl_attribute10                =>  p_bpl_attribute10
      ,p_bpl_attribute11                =>  p_bpl_attribute11
      ,p_bpl_attribute12                =>  p_bpl_attribute12
      ,p_bpl_attribute13                =>  p_bpl_attribute13
      ,p_bpl_attribute14                =>  p_bpl_attribute14
      ,p_bpl_attribute15                =>  p_bpl_attribute15
      ,p_bpl_attribute16                =>  p_bpl_attribute16
      ,p_bpl_attribute17                =>  p_bpl_attribute17
      ,p_bpl_attribute18                =>  p_bpl_attribute18
      ,p_bpl_attribute19                =>  p_bpl_attribute19
      ,p_bpl_attribute20                =>  p_bpl_attribute20
      ,p_bpl_attribute21                =>  p_bpl_attribute21
      ,p_bpl_attribute22                =>  p_bpl_attribute22
      ,p_bpl_attribute23                =>  p_bpl_attribute23
      ,p_bpl_attribute24                =>  p_bpl_attribute24
      ,p_bpl_attribute25                =>  p_bpl_attribute25
      ,p_bpl_attribute26                =>  p_bpl_attribute26
      ,p_bpl_attribute27                =>  p_bpl_attribute27
      ,p_bpl_attribute28                =>  p_bpl_attribute28
      ,p_bpl_attribute29                =>  p_bpl_attribute29
      ,p_bpl_attribute30                =>  p_bpl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_cash_recd_val                  =>  p_cash_recd_val
      ,p_rld_up_val                     =>  p_rld_up_val
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode,
    p_acty_ref_perd_cd              =>   p_acty_ref_perd_cd,
    p_cmcd_frftd_val                =>   l_cmcd_frftd_val,
    p_cmcd_prvdd_val                =>   l_cmcd_prvdd_val,
    p_cmcd_rld_up_val               =>   l_cmcd_rld_up_val,
    p_cmcd_used_val                 =>   l_cmcd_used_val,
    p_cmcd_cash_recd_val            =>   l_cmcd_cash_recd_val,
    p_cmcd_ref_perd_cd              =>   l_cmcd_ref_perd_cd,
    p_ann_frftd_val                 =>   l_ann_frftd_val,
    p_ann_prvdd_val                 =>   l_ann_prvdd_val,
    p_ann_rld_up_val                =>   l_ann_rld_up_val,
    p_ann_used_val                  =>   l_ann_used_val,
    p_ann_cash_recd_val             =>   l_ann_cash_recd_val
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Benefit_Prvdd_Ledger
    --
  end;
--
end if; --  Bug: 3611160/4169180.
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
    ROLLBACK TO update_Benefit_Prvdd_Ledger;
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
    ROLLBACK TO update_Benefit_Prvdd_Ledger;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_Benefit_Prvdd_Ledger;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdd_Ledger_w > ----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Benefit_Prvdd_Ledger_w
  (p_validate                       in  varchar2  default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtt_ro_of_unusd_amt_flag      in  varchar2  default hr_api.g_varchar2
  ,p_frftd_val                      in  number    default hr_api.g_number
  ,p_prvdd_val                      in  number    default hr_api.g_number
  ,p_used_val                       in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cash_recd_val                  in  number    default hr_api.g_number
  ,p_rld_up_val                     in number     default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_process_enrt_flag              in  varchar2  default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2  default 'N',
  p_acty_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_cmcd_frftd_val               in   number           default hr_api.g_number,
  p_cmcd_prvdd_val               in   number           default hr_api.g_number,
  p_cmcd_rld_up_val              in   number           default hr_api.g_number,
  p_cmcd_used_val                in   number           default hr_api.g_number,
  p_cmcd_cash_recd_val           in   number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in   varchar2         default hr_api.g_varchar2,
  p_ann_frftd_val                in   number           default hr_api.g_number,
  p_ann_prvdd_val                in   number           default hr_api.g_number,
  p_ann_rld_up_val               in   number           default hr_api.g_number,
  p_ann_used_val                 in   number           default hr_api.g_number,
  p_ann_cash_recd_val            in   number           default hr_api.g_number,
  p_object_version_number          in  out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_validate BOOLEAN;
  --
  l_proc varchar2(72) := g_package||'update_Benefit_Prvdd_Ledger_w';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_object_version_number := p_object_version_number;
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  ben_Benefit_Prvdd_Ledger_api.update_Benefit_Prvdd_Ledger
  (
     p_validate                      => l_validate
    ,p_bnft_prvdd_ldgr_id            => p_bnft_prvdd_ldgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtt_ro_of_unusd_amt_flag     => p_prtt_ro_of_unusd_amt_flag
    ,p_frftd_val                     => p_frftd_val
    ,p_prvdd_val                     => p_prvdd_val
    ,p_used_val                      => p_used_val
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_cash_recd_val                 => p_cash_recd_val
    ,p_rld_up_val                    =>  p_rld_up_val
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_process_enrt_flag             => p_process_enrt_flag
    ,p_from_reinstate_enrt_flag      => p_from_reinstate_enrt_flag,
	p_acty_ref_perd_cd              =>   p_acty_ref_perd_cd,
	p_cmcd_frftd_val                =>   p_cmcd_frftd_val,
	p_cmcd_prvdd_val                =>   p_cmcd_prvdd_val,
	p_cmcd_rld_up_val               =>   p_cmcd_rld_up_val,
	p_cmcd_used_val                 =>   p_cmcd_used_val,
	p_cmcd_cash_recd_val            =>   p_cmcd_cash_recd_val,
	p_cmcd_ref_perd_cd              =>   p_cmcd_ref_perd_cd,
	p_ann_frftd_val                 =>   p_ann_frftd_val,
	p_ann_prvdd_val                 =>   p_ann_prvdd_val,
	p_ann_rld_up_val                =>   p_ann_rld_up_val,
	p_ann_used_val                  =>   p_ann_used_val,
	p_ann_cash_recd_val             =>   p_ann_cash_recd_val
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  --
  when others then
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    fnd_msg_pub.add;
  --
end update_Benefit_Prvdd_Ledger_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdd_Ledger >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdd_Ledger
  (p_validate                       in  boolean  default false
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_business_group_id              in number
  ,p_process_enrt_flag              in varchar2 default 'Y'
  ,p_from_reinstate_enrt_flag       in varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_Benefit_Prvdd_Ledger';
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_bnft_prvdr_pool_id number;
  l_person_id number;
  l_acty_base_rt_id number;
  l_per_in_ler_id number;
  l_enrt_mthd_cd varchar2(30);
  l_prtt_ro_of_unusd_amt_flag varchar2(30);
  l_old_used_val number;
  --
  -- cursor to get the ledger info
  --
  cursor c_ledger_info is
    select bpl.bnft_prvdr_pool_id,
           pen.person_id,
           bpl.acty_base_rt_id,
           bpl.per_in_ler_id,
           bpl.used_val,
           pen.enrt_mthd_cd,
           bpl.prtt_ro_of_unusd_amt_flag
    from   ben_bnft_prvdd_ldgr_f bpl,
           ben_prtt_enrt_rslt_f pen,
           -- UK Changes.
           ben_per_in_ler pil
    where  bpl.bnft_prvdd_ldgr_id=p_bnft_prvdd_ldgr_id and
           bpl.object_version_number=p_object_version_number and
           pen.prtt_enrt_rslt_id=bpl.prtt_enrt_rslt_id and
           pen.business_group_id=bpl.business_group_id and
	   pen.prtt_enrt_rslt_stat_cd is null and
           -- UK Changes.
           pil.per_in_ler_id=bpl.per_in_ler_id and
           pil.business_group_id=bpl.business_group_id and
           pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT') and
           p_effective_date between pen.effective_start_date and pen.effective_end_date
    ;

-- 5612091 - This is used to fetch current pil, if any.
-- Unable to use a parameter as this procedure is called from lot of places. hence queried again.
--
    cursor c_cur_pil IS
     SELECT pil.per_in_ler_id
       FROM ben_per_in_ler pil, ben_ler_f ler
      WHERE pil.person_id = l_person_id
        and pil.ler_id = ler.ler_id
        AND pil.per_in_ler_stat_cd = 'STRTD'
        and p_effective_date between ler.effective_start_date
                                 and ler.effective_end_date
        and ler.typ_cd not in ('GSP','COMP','ABS','IREC', 'CHECKLIST');
    --
     l_curr_pil_id NUMBER;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Benefit_Prvdd_Ledger;
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
    -- Start of API User Hook for the before hook of delete_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk3.delete_Benefit_Prvdd_Ledger_b
      (
       p_bnft_prvdd_ldgr_id             =>  p_bnft_prvdd_ldgr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Benefit_Prvdd_Ledger
    --
  end;
  --
  -- Get the info to do the result adjustment
  --   have to get it before the delete takes place
  --
  if p_process_enrt_flag = 'Y' then
     --
     open c_ledger_info;
     fetch c_ledger_info into
         l_bnft_prvdr_pool_id,
         l_person_id,
         l_acty_base_rt_id,
         l_per_in_ler_id,
         l_old_used_val,
         l_enrt_mthd_cd,
         l_prtt_ro_of_unusd_amt_flag
     ;
     if c_ledger_info%notfound then
       --
       -- The primary key is invalid therefore we must error
       --
       fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
       fnd_message.raise_error;
     end if;
     close c_ledger_info;
     --
  end if;
  --
  -- do the real delete
  --
  hr_utility.set_location('Delete Ledger Row ' || p_bnft_prvdd_ldgr_id, 10);
  hr_utility.set_location('Ledger created in PIL_ID ' || l_per_in_ler_id, 10);
  --
  ben_bpl_del.del
    (
     p_bnft_prvdd_ldgr_id            => p_bnft_prvdd_ldgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  --
  -- Create/update the enrollment to include the rollover amount.
  --
 -- 5612091 Use latest pil, if avlb
 hr_utility.set_location('Previous l_per_in_ler_id' || l_per_in_ler_id, 10);

   l_curr_pil_id := null;
   open c_cur_pil;
   fetch c_cur_pil into l_curr_pil_id;
   close c_cur_pil;
   l_per_in_ler_id := NVL(l_curr_pil_id, l_per_in_ler_id);
   --

  hr_utility.set_location('Create Rollover PIL_ID' || l_per_in_ler_id, 10);

  /*
    Bug 5645366 : Commeneted the following ben_provider_pools.create_rollover_enrollment.

    This call seems to be un-necessary. This call is made also through
    ben_Benefit_Prvdd_Ledger_api.create_Benefit_Prvdd_Ledger
    which would take care of creating the rollover enrollment.

  */

  /*
   if l_prtt_ro_of_unusd_amt_flag='Y' and p_process_enrt_flag = 'Y'
     and p_from_reinstate_enrt_flag = 'N'
     and nvl(ben_newly_ineligible.g_denroling_from_pgm, 'N') <> 'Y'   --Bug 5642702
  then
    ben_provider_pools.create_rollover_enrollment(
    p_bnft_prvdr_pool_id    => l_bnft_prvdr_pool_id,
    p_person_id             => l_person_id,
    p_per_in_ler_id         => l_per_in_ler_id,
    p_effective_date        => p_effective_date,
    p_datetrack_mode        => p_datetrack_mode,
    p_acty_base_rt_id       => l_acty_base_rt_id,
    p_rlovr_amt             => 0,
    p_old_rlovr_amt         => l_old_used_val,
    p_business_group_id     => p_business_group_id,
    p_enrt_mthd_cd          => l_enrt_mthd_cd
    );
  end if;
  */

  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Benefit_Prvdd_Ledger
    --
    ben_Benefit_Prvdd_Ledger_bk3.delete_Benefit_Prvdd_Ledger_a
      (
       p_bnft_prvdd_ldgr_id             => p_bnft_prvdd_ldgr_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefit_Prvdd_Ledger'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Benefit_Prvdd_Ledger
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
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
    ROLLBACK TO delete_Benefit_Prvdd_Ledger;
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
    ROLLBACK TO delete_Benefit_Prvdd_Ledger;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
    --
end delete_Benefit_Prvdd_Ledger;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdd_Ledger_w >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdd_Ledger_w
  (p_validate                       in  varchar2 default 'FALSE'
  ,p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_business_group_id              in  number
  ,p_process_enrt_flag              in  varchar2 default 'Y'
  ,p_from_reinstate_enrt_flag       in  varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number ben_bnft_prvdd_ldgr_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdd_ldgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdd_ldgr_f.effective_end_date%TYPE;
  l_validate BOOLEAN;
  --
  l_proc varchar2(72) := g_package||'delete_Benefit_Prvdd_Ledger';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_object_version_number := p_object_version_number;
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  ben_Benefit_Prvdd_Ledger_api.delete_Benefit_Prvdd_Ledger
    (
     p_validate                      => l_validate
    ,p_bnft_prvdd_ldgr_id            => p_bnft_prvdd_ldgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_business_group_id             => p_business_group_id
    ,p_process_enrt_flag             => p_process_enrt_flag
    ,p_from_reinstate_enrt_flag      => p_from_reinstate_enrt_flag
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  --
  when others then
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    fnd_msg_pub.add;
  --
end delete_Benefit_Prvdd_Ledger_w;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_prvdd_ldgr_id                   in     number
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
  ben_bpl_shd.lck
    (
      p_bnft_prvdd_ldgr_id                 => p_bnft_prvdd_ldgr_id
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
end ben_Benefit_Prvdd_Ledger_api;

/
