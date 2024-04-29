--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_ENRT_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_ENRT_CTFN_PRVDD_API" as
/* $Header: bepcsapi.pkb 120.1.12010000.2 2008/08/05 15:06:09 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRTT_ENRT_CTFN_PRVDD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_prtt_ctfn> ----------------------|
-- ----------------------------------------------------------------------------
--
procedure check_prtt_ctfn
  (p_prtt_enrt_actn_id        in number,
   p_datetrack_mode           in varchar2,
   p_business_group_id        in number,
   p_effective_date           in date) is
  --
  l_all_prvdd boolean := FALSE;
  --
  cursor prtt_c is
  select pen.prtt_enrt_rslt_id,
         pen.person_id,
         pea.prtt_enrt_actn_id,
         pea.actn_typ_id,
         pea.cmpltd_dt,
         pea.rqd_flag,
         pen.object_version_number rslt_ovn,
         pea.object_version_number
    from ben_prtt_enrt_rslt_f pen,
         ben_prtt_enrt_actn_f pea
   where pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
     and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and pea.business_group_id  = p_business_group_id
     and pen.prtt_enrt_rslt_stat_cd is null
     and p_effective_date between pea.effective_start_date
                              and pea.effective_end_date
     and pen.business_group_id  = p_business_group_id
     and p_effective_date between pen.effective_start_date
                              and pen.effective_end_date;
  --
  l_prtt      prtt_c%rowtype;
  --
  l_proc       varchar2(80) := g_package||'check_prtt_ctfn';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open prtt_c;
  fetch prtt_c into l_prtt;
  close prtt_c;
  --
  if l_prtt.prtt_enrt_rslt_id is not null and
     l_prtt.person_id is not null then
    --
    --
    l_all_prvdd := ben_enrollment_action_items.check_enrt_ctfn
                       (p_prtt_enrt_actn_id => l_prtt.prtt_enrt_actn_id
                       ,p_prtt_enrt_rslt_id => l_prtt.prtt_enrt_rslt_id
                       ,p_effective_date    => p_effective_date);
    --
    ben_enrollment_action_items.process_action_item
          (p_prtt_enrt_actn_id         => l_prtt.prtt_enrt_actn_id
          ,p_actn_typ_id               => l_prtt.actn_typ_id
          ,p_cmpltd_dt                 => l_prtt.cmpltd_dt
          ,p_object_version_number     => l_prtt.object_version_number
          ,p_effective_date            => p_effective_date
          ,p_rqd_data_found            => l_all_prvdd
          ,p_prtt_enrt_rslt_id         => l_prtt.prtt_enrt_rslt_id
          ,p_rqd_flag                  => l_prtt.rqd_flag
          ,p_post_rslt_flag            => 'Y'  -- 3626176
          ,p_business_group_id         => p_business_group_id
          ,p_datetrack_mode            => p_datetrack_mode
          ,p_rslt_object_version_number => l_prtt.rslt_ovn);
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
end check_prtt_ctfn;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_dnd_ctfns> ----------------------|
-- ----------------------------------------------------------------------------
--
procedure check_dnd_ctfns
  (p_prtt_enrt_rslt_id  in number,
   p_effective_date     in date,
   p_business_group_id  in number,
   p_validate           in boolean,
   p_datetrack_mode     in varchar2
   )
is
  -- this procedure will determine if suspended enrollment should be deleted
  -- due to a certification being denied.
  -- The person will still have the interm coverage that was assigned to them.
  --
  l_proc varchar2(72) :=  g_package||'.check_dnd_ctfns';
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_object_version_number number;
  l_datetrack_mode        varchar2(30) := hr_api.g_delete;
  l_del_enrt              varchar2(1) := 'N';
  l_per_in_ler_id         number;
  --
  -- Check if any required is denied.
  --
  cursor c_rqd_ctfn_prvdd is
    select 'Y'
    from ben_prtt_enrt_ctfn_prvdd_f pcs
    where pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and pcs.business_group_id  = p_business_group_id
    and pcs.enrt_ctfn_rqd_flag = 'Y'
    and p_effective_date
    between pcs.effective_start_date and pcs.effective_end_date
    and pcs.enrt_ctfn_dnd_dt is not null;
  --
  -- Check if all optionals are denied.
  -- If there are any optional ctfns available and yet to be denied,
  -- it will be the first record because of "order by" clause.
  --
  cursor c_opt_ctfn_prvdd is
    select decode(pcs.enrt_ctfn_dnd_dt,null,'N','Y')
    from ben_prtt_enrt_ctfn_prvdd_f pcs
    where pcs.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    and pcs.business_group_id  = p_business_group_id
    and pcs.enrt_ctfn_rqd_flag = 'N'
    and p_effective_date
    between pcs.effective_start_date and pcs.effective_end_date
    order by pcs.enrt_ctfn_dnd_dt desc;
  --
  -- mmogel - fixed bug 1146777 (this cursor's where clause used to say
  -- where p_prtt_enrt_rslt_id = p_prtt_enrt_rslt_id)
  --
  cursor c_sspndd_rslt is
    select pen.object_version_number,
           pen.effective_start_date,pen.per_in_ler_id  -- 2386000
      from ben_prtt_enrt_rslt_f pen
      where p_prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
        and pen.business_group_id  = p_business_group_id
        and pen.prtt_enrt_rslt_stat_cd is null
        and p_effective_date
           between pen.effective_start_date and pen.effective_end_date
        and pen.sspndd_flag = 'Y';
   --
   l_sspndd_rslt varchar2(1) := null;
   --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check whether any required certification denied. If it is, then
  -- the l_del_enrt flag is turned to 'Y'
  --
  open  c_rqd_ctfn_prvdd;
  fetch c_rqd_ctfn_prvdd into l_del_enrt;
  close c_rqd_ctfn_prvdd;
  --
  -- If no required cert. has been denied, look whether all the optionals
  -- have been denied. Here we need to look for all, as even if one optional
  -- is completed then the optional conditions are satisfied.
  --
  if l_del_enrt = 'N' then
    --
    -- If no optional certs. available, then the flag remains intact.
    -- If optional certs are availbe, then the 'order by' clause helps us
    -- determine whether any optional cert. is still available.
    --
    open c_opt_ctfn_prvdd;
    fetch c_opt_ctfn_prvdd into l_del_enrt;
    close c_opt_ctfn_prvdd;
    --
  end if;
  --
  --  If the result is suspended, and the either one required cert. is denied
  --  or all the optionals are denied, there is no way, the action item can
  --  be completed, so delete the result.
  --
  if l_del_enrt = 'Y' then
     --
     open c_sspndd_rslt;
     fetch c_sspndd_rslt into l_object_version_number,
                              l_effective_start_date,
                              l_per_in_ler_id ;
     --
     if c_sspndd_rslt%notfound then
        null;  -- result is not suspended, do nothing
     else
       --
       if l_effective_start_date = p_effective_date then
          l_datetrack_mode := hr_api.g_zap;
       end if;
       -- this will end date the enrollment, it's action items and it's
       -- certifications (all the children).
       hr_utility.set_location('Leaving:'|| l_proc, 40);
       ben_prtt_enrt_result_api.delete_enrollment
           (P_VALIDATE              => p_validate
           ,P_PRTT_ENRT_RSLT_ID     => p_prtt_enrt_rslt_id
           ,p_per_in_ler_id         => l_per_in_ler_id      -- 2386000
           ,P_BUSINESS_GROUP_ID     => p_business_group_id
           ,P_EFFECTIVE_START_DATE  => l_effective_start_date
           ,P_EFFECTIVE_END_DATE    => l_effective_end_date
           ,P_OBJECT_VERSION_NUMBER => l_object_version_number
           ,P_EFFECTIVE_DATE        => p_effective_date
           ,P_DATETRACK_MODE        => l_datetrack_mode
           ,P_MULTI_ROW_VALIDATE    => TRUE
           ,p_source                => 'bepcsapi'
           );
       hr_utility.set_location('Leaving:'|| l_proc, 45);
     end if;
     close c_sspndd_rslt;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
end check_dnd_ctfns;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_prtt_futur_lf_evnt> ----------------------|
-- ----------------------------------------------------------------------------
--
procedure check_prtt_futur_lf_evnt
  (p_prtt_enrt_actn_id        in number,
   p_effective_date           in date) is
--
 --
  cursor c_future_pils( p_person_id number,
                         p_business_group_id number,
                        p_lf_evt_ocrd_dt date ) is
    select 1
    from   ben_per_in_ler pil,
           ben_ler_f      ler
    where  pil.business_group_id = p_business_group_id
    and    pil.person_id = p_person_id
    and    pil.lf_evt_ocrd_dt > p_lf_evt_ocrd_dt
    and    pil.ler_id = ler.ler_id
    and    p_effective_date
           between ler.effective_start_date
           and     ler.effective_end_date
    and    ler.typ_cd not in ('IREC', 'SCHDU','ABS', 'COMP', 'GSP')
    and    pil.per_in_ler_stat_cd in ('STRTD','PROCD');

  l_future_pils c_future_pils%rowtype;
  --
  cursor c_pil(p_PRTT_ENRT_ACTN_ID number) is
   select pil1.lf_evt_ocrd_dt lf_evt_ocrd_dt,
           pil1.person_id person_id,
           pil1.business_group_id business_group_id
    from ben_per_in_ler pil1, ben_prtt_enrt_actn_f actn
    where pil1.per_in_ler_id = actn.per_in_ler_id
      and actn.PRTT_ENRT_ACTN_ID = p_PRTT_ENRT_ACTN_ID
      and p_effective_date
           between actn.effective_start_date
           and     actn.effective_end_date;
  l_pil c_pil%rowtype;
  --
  l_proc varchar2(72) :=  g_package||'.check_prtt_futur_lf_evnt';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  open c_pil(p_PRTT_ENRT_ACTN_ID);
  fetch c_pil into l_pil;
  close c_pil;
  --
  open c_future_pils( l_pil.person_id,l_pil.business_group_id,l_pil.lf_evt_ocrd_dt);
  fetch c_future_pils into l_future_pils;
  --
  if(c_future_pils%found) then

    close c_future_pils;
    fnd_message.set_name('BEN', 'BEN_94037_FUTUR_EVT_EXISTS');
    fnd_message.raise_error;

  end if;
  --
  close c_future_pils;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
end  check_prtt_futur_lf_evnt;

-- ----------------------------------------------------------------------------
-- |---------------------< create_PRTT_ENRT_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_ENRT_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_ctfn_prvdd_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default 'N'
  ,p_enrt_ctfn_typ_cd               in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_enrt_ctfn_dnd_dt               in  date      default null
  ,p_enrt_r_bnft_ctfn_cd            in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcs_attribute_category         in  varchar2  default null
  ,p_pcs_attribute1                 in  varchar2  default null
  ,p_pcs_attribute2                 in  varchar2  default null
  ,p_pcs_attribute3                 in  varchar2  default null
  ,p_pcs_attribute4                 in  varchar2  default null
  ,p_pcs_attribute5                 in  varchar2  default null
  ,p_pcs_attribute6                 in  varchar2  default null
  ,p_pcs_attribute7                 in  varchar2  default null
  ,p_pcs_attribute8                 in  varchar2  default null
  ,p_pcs_attribute9                 in  varchar2  default null
  ,p_pcs_attribute10                in  varchar2  default null
  ,p_pcs_attribute11                in  varchar2  default null
  ,p_pcs_attribute12                in  varchar2  default null
  ,p_pcs_attribute13                in  varchar2  default null
  ,p_pcs_attribute14                in  varchar2  default null
  ,p_pcs_attribute15                in  varchar2  default null
  ,p_pcs_attribute16                in  varchar2  default null
  ,p_pcs_attribute17                in  varchar2  default null
  ,p_pcs_attribute18                in  varchar2  default null
  ,p_pcs_attribute19                in  varchar2  default null
  ,p_pcs_attribute20                in  varchar2  default null
  ,p_pcs_attribute21                in  varchar2  default null
  ,p_pcs_attribute22                in  varchar2  default null
  ,p_pcs_attribute23                in  varchar2  default null
  ,p_pcs_attribute24                in  varchar2  default null
  ,p_pcs_attribute25                in  varchar2  default null
  ,p_pcs_attribute26                in  varchar2  default null
  ,p_pcs_attribute27                in  varchar2  default null
  ,p_pcs_attribute28                in  varchar2  default null
  ,p_pcs_attribute29                in  varchar2  default null
  ,p_pcs_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_enrt_ctfn_prvdd_id ben_prtt_enrt_ctfn_prvdd_f.prtt_enrt_ctfn_prvdd_id%TYPE;
  l_effective_start_date ben_prtt_enrt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_ctfn_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_ENRT_CTFN_PRVDD';
  l_object_version_number ben_prtt_enrt_ctfn_prvdd_f.object_version_number%TYPE;
  l_prtt_enrt_actn_id     ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init
      (p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_ENRT_CTFN_PRVDD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if p_prtt_enrt_actn_id is null then
     --
     ben_enrollment_action_items.process_new_ctfn_action
          (p_prtt_enrt_rslt_id   => p_prtt_enrt_rslt_id
          ,p_actn_typ_cd         => 'ENRTCTFN'
          ,p_ctfn_rqd_flag       => p_enrt_ctfn_rqd_flag
          ,p_ctfn_recd_dt        => p_enrt_ctfn_recd_dt
          ,p_business_group_id   => p_business_group_id
          ,p_effective_date      => p_effective_date
          ,p_prtt_enrt_actn_id   => l_prtt_enrt_actn_id);
     --
  else
     --
     l_prtt_enrt_actn_id := p_prtt_enrt_actn_id;
     --
  end if;
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk1.create_PRTT_ENRT_CTFN_PRVDD_b
      (
       p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_enrt_r_bnft_ctfn_cd            =>  p_enrt_r_bnft_ctfn_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcs_attribute_category         =>  p_pcs_attribute_category
      ,p_pcs_attribute1                 =>  p_pcs_attribute1
      ,p_pcs_attribute2                 =>  p_pcs_attribute2
      ,p_pcs_attribute3                 =>  p_pcs_attribute3
      ,p_pcs_attribute4                 =>  p_pcs_attribute4
      ,p_pcs_attribute5                 =>  p_pcs_attribute5
      ,p_pcs_attribute6                 =>  p_pcs_attribute6
      ,p_pcs_attribute7                 =>  p_pcs_attribute7
      ,p_pcs_attribute8                 =>  p_pcs_attribute8
      ,p_pcs_attribute9                 =>  p_pcs_attribute9
      ,p_pcs_attribute10                =>  p_pcs_attribute10
      ,p_pcs_attribute11                =>  p_pcs_attribute11
      ,p_pcs_attribute12                =>  p_pcs_attribute12
      ,p_pcs_attribute13                =>  p_pcs_attribute13
      ,p_pcs_attribute14                =>  p_pcs_attribute14
      ,p_pcs_attribute15                =>  p_pcs_attribute15
      ,p_pcs_attribute16                =>  p_pcs_attribute16
      ,p_pcs_attribute17                =>  p_pcs_attribute17
      ,p_pcs_attribute18                =>  p_pcs_attribute18
      ,p_pcs_attribute19                =>  p_pcs_attribute19
      ,p_pcs_attribute20                =>  p_pcs_attribute20
      ,p_pcs_attribute21                =>  p_pcs_attribute21
      ,p_pcs_attribute22                =>  p_pcs_attribute22
      ,p_pcs_attribute23                =>  p_pcs_attribute23
      ,p_pcs_attribute24                =>  p_pcs_attribute24
      ,p_pcs_attribute25                =>  p_pcs_attribute25
      ,p_pcs_attribute26                =>  p_pcs_attribute26
      ,p_pcs_attribute27                =>  p_pcs_attribute27
      ,p_pcs_attribute28                =>  p_pcs_attribute28
      ,p_pcs_attribute29                =>  p_pcs_attribute29
      ,p_pcs_attribute30                =>  p_pcs_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_ENRT_CTFN_PRVDD
    --
  end;
  --
  ben_pcs_ins.ins
    (
     p_prtt_enrt_ctfn_prvdd_id       => l_prtt_enrt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_ctfn_rqd_flag            => p_enrt_ctfn_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_enrt_ctfn_dnd_dt              => p_enrt_ctfn_dnd_dt
    ,p_enrt_r_bnft_ctfn_cd           => p_enrt_r_bnft_ctfn_cd
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_prtt_enrt_actn_id             => l_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcs_attribute_category        => p_pcs_attribute_category
    ,p_pcs_attribute1                => p_pcs_attribute1
    ,p_pcs_attribute2                => p_pcs_attribute2
    ,p_pcs_attribute3                => p_pcs_attribute3
    ,p_pcs_attribute4                => p_pcs_attribute4
    ,p_pcs_attribute5                => p_pcs_attribute5
    ,p_pcs_attribute6                => p_pcs_attribute6
    ,p_pcs_attribute7                => p_pcs_attribute7
    ,p_pcs_attribute8                => p_pcs_attribute8
    ,p_pcs_attribute9                => p_pcs_attribute9
    ,p_pcs_attribute10               => p_pcs_attribute10
    ,p_pcs_attribute11               => p_pcs_attribute11
    ,p_pcs_attribute12               => p_pcs_attribute12
    ,p_pcs_attribute13               => p_pcs_attribute13
    ,p_pcs_attribute14               => p_pcs_attribute14
    ,p_pcs_attribute15               => p_pcs_attribute15
    ,p_pcs_attribute16               => p_pcs_attribute16
    ,p_pcs_attribute17               => p_pcs_attribute17
    ,p_pcs_attribute18               => p_pcs_attribute18
    ,p_pcs_attribute19               => p_pcs_attribute19
    ,p_pcs_attribute20               => p_pcs_attribute20
    ,p_pcs_attribute21               => p_pcs_attribute21
    ,p_pcs_attribute22               => p_pcs_attribute22
    ,p_pcs_attribute23               => p_pcs_attribute23
    ,p_pcs_attribute24               => p_pcs_attribute24
    ,p_pcs_attribute25               => p_pcs_attribute25
    ,p_pcs_attribute26               => p_pcs_attribute26
    ,p_pcs_attribute27               => p_pcs_attribute27
    ,p_pcs_attribute28               => p_pcs_attribute28
    ,p_pcs_attribute29               => p_pcs_attribute29
    ,p_pcs_attribute30               => p_pcs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk1.create_PRTT_ENRT_CTFN_PRVDD_a
      (
       p_prtt_enrt_ctfn_prvdd_id        =>  l_prtt_enrt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_enrt_r_bnft_ctfn_cd            =>  p_enrt_r_bnft_ctfn_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_prtt_enrt_actn_id              =>  l_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcs_attribute_category         =>  p_pcs_attribute_category
      ,p_pcs_attribute1                 =>  p_pcs_attribute1
      ,p_pcs_attribute2                 =>  p_pcs_attribute2
      ,p_pcs_attribute3                 =>  p_pcs_attribute3
      ,p_pcs_attribute4                 =>  p_pcs_attribute4
      ,p_pcs_attribute5                 =>  p_pcs_attribute5
      ,p_pcs_attribute6                 =>  p_pcs_attribute6
      ,p_pcs_attribute7                 =>  p_pcs_attribute7
      ,p_pcs_attribute8                 =>  p_pcs_attribute8
      ,p_pcs_attribute9                 =>  p_pcs_attribute9
      ,p_pcs_attribute10                =>  p_pcs_attribute10
      ,p_pcs_attribute11                =>  p_pcs_attribute11
      ,p_pcs_attribute12                =>  p_pcs_attribute12
      ,p_pcs_attribute13                =>  p_pcs_attribute13
      ,p_pcs_attribute14                =>  p_pcs_attribute14
      ,p_pcs_attribute15                =>  p_pcs_attribute15
      ,p_pcs_attribute16                =>  p_pcs_attribute16
      ,p_pcs_attribute17                =>  p_pcs_attribute17
      ,p_pcs_attribute18                =>  p_pcs_attribute18
      ,p_pcs_attribute19                =>  p_pcs_attribute19
      ,p_pcs_attribute20                =>  p_pcs_attribute20
      ,p_pcs_attribute21                =>  p_pcs_attribute21
      ,p_pcs_attribute22                =>  p_pcs_attribute22
      ,p_pcs_attribute23                =>  p_pcs_attribute23
      ,p_pcs_attribute24                =>  p_pcs_attribute24
      ,p_pcs_attribute25                =>  p_pcs_attribute25
      ,p_pcs_attribute26                =>  p_pcs_attribute26
      ,p_pcs_attribute27                =>  p_pcs_attribute27
      ,p_pcs_attribute28                =>  p_pcs_attribute28
      ,p_pcs_attribute29                =>  p_pcs_attribute29
      ,p_pcs_attribute30                =>  p_pcs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_ENRT_CTFN_PRVDD
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
  p_prtt_enrt_ctfn_prvdd_id := l_prtt_enrt_ctfn_prvdd_id;
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
    ROLLBACK TO create_PRTT_ENRT_CTFN_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_enrt_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_ENRT_CTFN_PRVDD;
    --
    p_prtt_enrt_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_PRTT_ENRT_CTFN_PRVDD;
-- ----------------------------------------------------------------------------
-- |---------------------< update_PRTT_ENRT_CTFN_PRVDD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_ENRT_CTFN_PRVDD
  (p_validate                       in  boolean   default false
  ,p_prtt_enrt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_enrt_ctfn_rqd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_enrt_ctfn_dnd_dt               in  date      default hr_api.g_date
  ,p_enrt_r_bnft_ctfn_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcs_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcs_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_ENRT_CTFN_PRVDD';
  l_object_version_number ben_prtt_enrt_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_ctfn_prvdd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --
    ben_env_object.init
      (p_business_group_id => p_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
    --
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_ENRT_CTFN_PRVDD;

  /* code moved to PLD
  --
  -- Before completing Enrollment certification should check for the future pil records
  -- if they exist raise error else contine
  --
  check_prtt_futur_lf_evnt
  (p_prtt_enrt_actn_id,
   p_effective_date);
  */
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk2.update_PRTT_ENRT_CTFN_PRVDD_b
      (
       p_prtt_enrt_ctfn_prvdd_id        =>  p_prtt_enrt_ctfn_prvdd_id
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_enrt_r_bnft_ctfn_cd            =>  p_enrt_r_bnft_ctfn_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcs_attribute_category         =>  p_pcs_attribute_category
      ,p_pcs_attribute1                 =>  p_pcs_attribute1
      ,p_pcs_attribute2                 =>  p_pcs_attribute2
      ,p_pcs_attribute3                 =>  p_pcs_attribute3
      ,p_pcs_attribute4                 =>  p_pcs_attribute4
      ,p_pcs_attribute5                 =>  p_pcs_attribute5
      ,p_pcs_attribute6                 =>  p_pcs_attribute6
      ,p_pcs_attribute7                 =>  p_pcs_attribute7
      ,p_pcs_attribute8                 =>  p_pcs_attribute8
      ,p_pcs_attribute9                 =>  p_pcs_attribute9
      ,p_pcs_attribute10                =>  p_pcs_attribute10
      ,p_pcs_attribute11                =>  p_pcs_attribute11
      ,p_pcs_attribute12                =>  p_pcs_attribute12
      ,p_pcs_attribute13                =>  p_pcs_attribute13
      ,p_pcs_attribute14                =>  p_pcs_attribute14
      ,p_pcs_attribute15                =>  p_pcs_attribute15
      ,p_pcs_attribute16                =>  p_pcs_attribute16
      ,p_pcs_attribute17                =>  p_pcs_attribute17
      ,p_pcs_attribute18                =>  p_pcs_attribute18
      ,p_pcs_attribute19                =>  p_pcs_attribute19
      ,p_pcs_attribute20                =>  p_pcs_attribute20
      ,p_pcs_attribute21                =>  p_pcs_attribute21
      ,p_pcs_attribute22                =>  p_pcs_attribute22
      ,p_pcs_attribute23                =>  p_pcs_attribute23
      ,p_pcs_attribute24                =>  p_pcs_attribute24
      ,p_pcs_attribute25                =>  p_pcs_attribute25
      ,p_pcs_attribute26                =>  p_pcs_attribute26
      ,p_pcs_attribute27                =>  p_pcs_attribute27
      ,p_pcs_attribute28                =>  p_pcs_attribute28
      ,p_pcs_attribute29                =>  p_pcs_attribute29
      ,p_pcs_attribute30                =>  p_pcs_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_ENRT_CTFN_PRVDD
    --
  end;
  --
  ben_pcs_upd.upd
    (
     p_prtt_enrt_ctfn_prvdd_id       => p_prtt_enrt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_enrt_ctfn_rqd_flag            => p_enrt_ctfn_rqd_flag
    ,p_enrt_ctfn_typ_cd              => p_enrt_ctfn_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_enrt_ctfn_dnd_dt              => p_enrt_ctfn_dnd_dt
    ,p_enrt_r_bnft_ctfn_cd           => p_enrt_r_bnft_ctfn_cd
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcs_attribute_category        => p_pcs_attribute_category
    ,p_pcs_attribute1                => p_pcs_attribute1
    ,p_pcs_attribute2                => p_pcs_attribute2
    ,p_pcs_attribute3                => p_pcs_attribute3
    ,p_pcs_attribute4                => p_pcs_attribute4
    ,p_pcs_attribute5                => p_pcs_attribute5
    ,p_pcs_attribute6                => p_pcs_attribute6
    ,p_pcs_attribute7                => p_pcs_attribute7
    ,p_pcs_attribute8                => p_pcs_attribute8
    ,p_pcs_attribute9                => p_pcs_attribute9
    ,p_pcs_attribute10               => p_pcs_attribute10
    ,p_pcs_attribute11               => p_pcs_attribute11
    ,p_pcs_attribute12               => p_pcs_attribute12
    ,p_pcs_attribute13               => p_pcs_attribute13
    ,p_pcs_attribute14               => p_pcs_attribute14
    ,p_pcs_attribute15               => p_pcs_attribute15
    ,p_pcs_attribute16               => p_pcs_attribute16
    ,p_pcs_attribute17               => p_pcs_attribute17
    ,p_pcs_attribute18               => p_pcs_attribute18
    ,p_pcs_attribute19               => p_pcs_attribute19
    ,p_pcs_attribute20               => p_pcs_attribute20
    ,p_pcs_attribute21               => p_pcs_attribute21
    ,p_pcs_attribute22               => p_pcs_attribute22
    ,p_pcs_attribute23               => p_pcs_attribute23
    ,p_pcs_attribute24               => p_pcs_attribute24
    ,p_pcs_attribute25               => p_pcs_attribute25
    ,p_pcs_attribute26               => p_pcs_attribute26
    ,p_pcs_attribute27               => p_pcs_attribute27
    ,p_pcs_attribute28               => p_pcs_attribute28
    ,p_pcs_attribute29               => p_pcs_attribute29
    ,p_pcs_attribute30               => p_pcs_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk2.update_PRTT_ENRT_CTFN_PRVDD_a
      (
       p_prtt_enrt_ctfn_prvdd_id        =>  p_prtt_enrt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_enrt_ctfn_rqd_flag             =>  p_enrt_ctfn_rqd_flag
      ,p_enrt_ctfn_typ_cd               =>  p_enrt_ctfn_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_enrt_ctfn_dnd_dt               =>  p_enrt_ctfn_dnd_dt
      ,p_enrt_r_bnft_ctfn_cd            =>  p_enrt_r_bnft_ctfn_cd
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcs_attribute_category         =>  p_pcs_attribute_category
      ,p_pcs_attribute1                 =>  p_pcs_attribute1
      ,p_pcs_attribute2                 =>  p_pcs_attribute2
      ,p_pcs_attribute3                 =>  p_pcs_attribute3
      ,p_pcs_attribute4                 =>  p_pcs_attribute4
      ,p_pcs_attribute5                 =>  p_pcs_attribute5
      ,p_pcs_attribute6                 =>  p_pcs_attribute6
      ,p_pcs_attribute7                 =>  p_pcs_attribute7
      ,p_pcs_attribute8                 =>  p_pcs_attribute8
      ,p_pcs_attribute9                 =>  p_pcs_attribute9
      ,p_pcs_attribute10                =>  p_pcs_attribute10
      ,p_pcs_attribute11                =>  p_pcs_attribute11
      ,p_pcs_attribute12                =>  p_pcs_attribute12
      ,p_pcs_attribute13                =>  p_pcs_attribute13
      ,p_pcs_attribute14                =>  p_pcs_attribute14
      ,p_pcs_attribute15                =>  p_pcs_attribute15
      ,p_pcs_attribute16                =>  p_pcs_attribute16
      ,p_pcs_attribute17                =>  p_pcs_attribute17
      ,p_pcs_attribute18                =>  p_pcs_attribute18
      ,p_pcs_attribute19                =>  p_pcs_attribute19
      ,p_pcs_attribute20                =>  p_pcs_attribute20
      ,p_pcs_attribute21                =>  p_pcs_attribute21
      ,p_pcs_attribute22                =>  p_pcs_attribute22
      ,p_pcs_attribute23                =>  p_pcs_attribute23
      ,p_pcs_attribute24                =>  p_pcs_attribute24
      ,p_pcs_attribute25                =>  p_pcs_attribute25
      ,p_pcs_attribute26                =>  p_pcs_attribute26
      ,p_pcs_attribute27                =>  p_pcs_attribute27
      ,p_pcs_attribute28                =>  p_pcs_attribute28
      ,p_pcs_attribute29                =>  p_pcs_attribute29
      ,p_pcs_attribute30                =>  p_pcs_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_ENRT_CTFN_PRVDD
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  check_prtt_ctfn(p_prtt_enrt_actn_id       => p_prtt_enrt_actn_id,
                  p_effective_date          => p_effective_date,
                  p_business_group_id       => p_business_group_id,
                  p_datetrack_mode          => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 62);
  --
  if p_enrt_ctfn_dnd_dt IS NOT NULL   then
    check_dnd_ctfns(p_prtt_enrt_rslt_id => p_prtt_enrt_rslt_id,
                    p_effective_date    => p_effective_date,
                    p_business_group_id => p_business_group_id,
                    p_validate          => p_validate,
                    p_datetrack_mode    => p_datetrack_mode);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 64);
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
    ROLLBACK TO update_PRTT_ENRT_CTFN_PRVDD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_PRTT_ENRT_CTFN_PRVDD;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end update_PRTT_ENRT_CTFN_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_PRTT_ENRT_CTFN_PRVDD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_ENRT_CTFN_PRVDD
  (p_validate                       in  boolean  default false
  ,p_prtt_enrt_ctfn_prvdd_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_check_actions                  in varchar2 default 'Y'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_PRTT_ENRT_CTFN_PRVDD';
  l_object_version_number ben_prtt_enrt_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_enrt_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_enrt_ctfn_prvdd_f.effective_end_date%TYPE;
  --
  l_prtt_enrt_actn_id      ben_prtt_enrt_actn_f.prtt_enrt_actn_id%type := null;
  l_prtt_enrt_rslt_id      number(15);
  l_rslt_object_version_number number(15);
  l_business_group_id      number(15);
  l_exist                  varchar2(1) := 'N';
  l1_object_version_number ben_prtt_enrt_actn_f.object_version_number%TYPE;
  l1_effective_start_date  ben_prtt_enrt_actn_f.effective_start_date%TYPE;
  l1_effective_end_date    ben_prtt_enrt_actn_f.effective_end_date%TYPE;
  l_env_rec     ben_env_object.g_global_env_rec_type;
  --
  cursor get_actn_c is
      select prtt_enrt_actn_id,
             business_group_id
        from ben_prtt_enrt_ctfn_prvdd_f
      where prtt_enrt_ctfn_prvdd_id = p_prtt_enrt_ctfn_prvdd_id
        and p_effective_date between effective_start_date
                                 and effective_end_date;
  --
  cursor more_ctfn_c is
     select 'Y'
       from ben_prtt_enrt_ctfn_prvdd_f
     where prtt_enrt_actn_id = l_prtt_enrt_actn_id
       and p_effective_date between effective_start_date
                                   and effective_end_date;
  --
  cursor actn_info_c is
     select pea.object_version_number,
	    pea.prtt_enrt_rslt_id,
	    pen.object_version_number
       from ben_prtt_enrt_actn_f pea,
	    ben_prtt_enrt_rslt_f pen
      where pea.prtt_enrt_actn_id = l_prtt_enrt_actn_id
	and pea.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
        and pen.prtt_enrt_rslt_stat_cd is null
        and p_effective_date between pea.effective_start_date
                                 and pea.effective_end_date
        and p_effective_date between pen.effective_start_date
				 and pen.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get action item id and the business group id.
  --
  open  get_actn_c;
  fetch get_actn_c into l_prtt_enrt_actn_id,
                        l_business_group_id;
  close get_actn_c;
  --
  -- Initialize environment
  --
  if fnd_global.conc_request_id = -1 then
    --5460912
    ben_env_object.get(p_rec => l_env_rec);
    if l_env_rec.business_group_id is null then
      --
      ben_env_object.init
      (p_business_group_id => l_business_group_id,
       p_effective_date    => p_effective_date,
       p_thread_id         => null,
       p_chunk_size        => null,
       p_threads           => null,
       p_max_errors        => null,
       p_benefit_action_id => null);
      --
    end if;
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_ENRT_CTFN_PRVDD;
  /* code moved to PLD
  --
  -- Before completing Enrollment certification should check for the future pil records
  -- if they exist raise error else contine
  --
  check_prtt_futur_lf_evnt
  (l_prtt_enrt_actn_id,
   p_effective_date);
  */
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk3.delete_PRTT_ENRT_CTFN_PRVDD_b
      (p_prtt_enrt_ctfn_prvdd_id        =>  p_prtt_enrt_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTT_ENRT_CTFN_PRVDD
    --
  end;
  --
  ben_pcs_del.del
    (
     p_prtt_enrt_ctfn_prvdd_id       => p_prtt_enrt_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  --
  --
  -- If there are no remaining certifications,
  -- delete corresponding action item.
  --
  if p_check_actions = 'Y' then
    --
    open  more_ctfn_c;
    fetch more_ctfn_c into l_exist;
    close more_ctfn_c;
    --
    if l_exist = 'N' then
      --
      open  actn_info_c;
      fetch actn_info_c into l1_object_version_number,
                             l_prtt_enrt_rslt_id,
                             l_rslt_object_version_number;
      --
      if actn_info_c%FOUND then
        --
        ben_prtt_enrt_actn_api.delete_prtt_enrt_actn
         (p_validate              => p_validate
         ,p_prtt_enrt_actn_id     => l_prtt_enrt_actn_id
         ,p_business_group_id     => l_business_group_id
         ,p_effective_date        => p_effective_date
         ,p_datetrack_mode        => p_datetrack_mode
         ,p_object_version_number => l1_object_version_number
         ,p_prtt_enrt_rslt_id     => l_prtt_enrt_rslt_id
         ,p_rslt_object_version_number => l_rslt_object_version_number
         ,p_effective_start_date  => l1_effective_start_date
         ,p_effective_end_date    => l1_effective_end_date
         );
        --
      end if;
      --
      close actn_info_c;
      --
    else
      --
      -- Since a certification was deleted, we may be able to complete
      -- action item.
      --
      check_prtt_ctfn(p_prtt_enrt_actn_id       => l_prtt_enrt_actn_id,
                      p_effective_date          => p_effective_date,
                      p_business_group_id       => l_business_group_id,
                      p_datetrack_mode          => p_datetrack_mode);
      --
    end if;  -- l_exist
    --
  end if;  -- check_actions

  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_ENRT_CTFN_PRVDD
    --
    ben_PRTT_ENRT_CTFN_PRVDD_bk3.delete_PRTT_ENRT_CTFN_PRVDD_a
      (
       p_prtt_enrt_ctfn_prvdd_id        =>  p_prtt_enrt_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_ENRT_CTFN_PRVDD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTT_ENRT_CTFN_PRVDD
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
    ROLLBACK TO delete_PRTT_ENRT_CTFN_PRVDD;
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
    ROLLBACK TO delete_PRTT_ENRT_CTFN_PRVDD;
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
    --
end delete_PRTT_ENRT_CTFN_PRVDD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_enrt_ctfn_prvdd_id                   in     number
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
  ben_pcs_shd.lck
    (
      p_prtt_enrt_ctfn_prvdd_id    => p_prtt_enrt_ctfn_prvdd_id
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
end ben_PRTT_ENRT_CTFN_PRVDD_api;

/
