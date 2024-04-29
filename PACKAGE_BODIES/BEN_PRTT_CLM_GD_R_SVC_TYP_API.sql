--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_CLM_GD_R_SVC_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_CLM_GD_R_SVC_TYP_API" as
/* $Header: bepcgapi.pkb 115.4 2002/12/16 11:57:55 vsethi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRTT_CLM_GD_R_SVC_TYP_api.';

-- ----------------------------------------------------------------------------
-- |------------------------< check_remb_rqst_ctfn_rqs >----------------------|
-- ----------------------------------------------------------------------------
--


Procedure check_remb_rqst_ctfn_rqs(
    p_prtt_reimbmt_rqst_id in number    default null
    ,p_pl_gd_or_svc_id      in number    default null
    ,p_effective_date       in date
    ,p_ctfn_rqd_flag        out nocopy varchar2 ) is

l_proc varchar2(72) := g_package||'check_remb_rqst_ctfn_rqs';

cursor c_pct_gdsvc is
  select 'x' from
  ben_pl_gd_r_svc_ctfn_f
  where pl_gd_or_svc_id = p_pl_gd_or_svc_id
    and p_effective_date  between
        effective_start_date and
        effective_end_date ;

cursor c_pct_remb is
  select 'x' from
  ben_pl_gd_r_svc_ctfn_f pct,
  ben_prtt_clm_gd_or_svc_typ pcg
  where pcg.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and pct.pl_gd_or_svc_id      = pcg.pl_gd_or_svc_id
    and p_effective_date  between
        pct.effective_start_date and
        pct.effective_end_date ;

l_dummy_var varchar2(1) ;

begin
hr_utility.set_location('Entering:'|| l_proc, 10);
p_ctfn_rqd_flag := 'N' ;
if  p_prtt_reimbmt_rqst_id is not null then
    open  c_pct_remb ;
    fetch c_pct_remb into l_dummy_var ;
    if  c_pct_remb%found then
        p_ctfn_rqd_flag := 'Y' ;
    end if ;
    close c_pct_remb ;
else
  open  c_pct_gdsvc ;
    fetch c_pct_gdsvc into l_dummy_var ;
    if  c_pct_gdsvc%found then
        p_ctfn_rqd_flag := 'Y' ;
    end if ;
    close c_pct_gdsvc ;

end if;

hr_utility.set_location('Result:'||  p_ctfn_rqd_flag, 15);
hr_utility.set_location('Exiting:'|| l_proc, 10);
end check_remb_rqst_ctfn_rqs ;


-- ----------------------------------------------------------------------------
-- |------------------------< check_remb_rqst_ctfn_prvdd >----------------------|
-- ----------------------------------------------------------------------------
Procedure check_remb_rqst_ctfn_prvdd(
    p_prtt_reimbmt_rqst_id         in number    default null
     ,p_prtt_clm_gd_or_svc_typ_id   in number    default null
     ,p_effective_date              in date
     ,p_ctfn_pending_flag           out nocopy varchar2 ) is

l_proc varchar2(72) := g_package||'check_remb_rqst_ctfn_prvdd';

cursor c_pqc_gdsvc is
  select 'x' from
  ben_prtt_rmt_rqst_ctfn_prvdd_f
  where prtt_clm_gd_or_svc_typ_id  = p_prtt_clm_gd_or_svc_typ_id
    and reimbmt_ctfn_recd_dt is null
    and p_effective_date  between
        effective_start_date and
        effective_end_date ;

cursor c_pqc_prc  is
  select 'x' from
  ben_prtt_rmt_rqst_ctfn_prvdd_f pqc,
  ben_prtt_clm_gd_or_svc_typ pcg
  where pcg.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and pqc.prtt_clm_gd_or_svc_typ_id  = pcg.prtt_clm_gd_or_svc_typ_id
    and pqc.reimbmt_ctfn_recd_dt is null
    and p_effective_date  between
        pqc.effective_start_date and
        pqc.effective_end_date ;

l_dummy_var varchar2(1) ;

begin
hr_utility.set_location('Entering:'|| l_proc, 10);
p_ctfn_pending_flag := 'N' ;
if  p_prtt_reimbmt_rqst_id is not null then
    open  c_pqc_prc ;
    fetch c_pqc_prc into l_dummy_var ;
    if  c_pqc_prc%found then
        p_ctfn_pending_flag := 'Y' ;
    end if ;
    close c_pqc_prc ;
else
  open  c_pqc_gdsvc ;
    fetch c_pqc_gdsvc into l_dummy_var ;
    if  c_pqc_gdsvc%found then
        p_ctfn_pending_flag := 'Y' ;
    end if ;
    close c_pqc_gdsvc ;

end if;

hr_utility.set_location('Result:'||  p_ctfn_pending_flag , 15);
hr_utility.set_location('Exiting:'|| l_proc, 10);
end check_remb_rqst_ctfn_prvdd ;


-- ----------------------------------------------------------------------------
-- |------------------------< write_remb_rqst_ctfn >----------------------|
-- ----------------------------------------------------------------------------
procedure write_remb_rqst_ctfn (
           p_prtt_clm_gd_or_svc_typ_id    in number
          ,p_pl_gd_r_svc_ctfn_id          in number
          ,p_reimbmt_ctfn_rqd_flag        in varchar2
          ,p_reimbmt_ctfn_typ_cd          in varchar2
          ,p_prtt_enrt_actn_id            in Number default null
          ,p_business_group_id            in number
          ,p_ctfn_rqd_when_rl             in number
          ,p_prtt_reimbmt_rqst_id         in number
          ,p_effective_date               in Date  ) is


   l_proc varchar2(72) := g_package||'write_remb_rqst_ctfn';
   l_write_ctfn     boolean := TRUE;
   l_outputs        ff_exec.outputs_t;
   l_dummy_var      varchar2(1) ;
   ---Cursor for formula
  cursor c_asg is
  select prc.pl_id,asg.assignment_id
  from  ben_prtt_reimbmt_rqst_f prc ,
        per_all_assignments_f  asg
  where prc.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
    and p_effective_date between
        prc.effective_start_date and prc.effective_end_date
    and asg.person_id = prc.submitter_person_id
    and asg.assignment_type <> 'C'
    and asg.primary_flag = 'Y'
    and  p_effective_date between
        asg.effective_start_date and asg.effective_end_date ;

  l_asg  c_asg%Rowtype ;

   --cursor to check the certifcate already exist
   cursor c_pqc is
   select 'x'
   from  ben_prtt_rmt_rqst_ctfn_prvdd_f
   where prtt_clm_gd_or_svc_typ_id   = p_prtt_clm_gd_or_svc_typ_id
     and p_pl_gd_r_svc_ctfn_id       = p_pl_gd_r_svc_ctfn_id
     and nvl(reimbmt_ctfn_typ_cd,-1) = nvl(p_reimbmt_ctfn_typ_cd ,-1)
     and p_effective_date between effective_start_date
     and effective_end_Date ;

   l_prtt_rmt_rqst_ctfn_prvdd_id number(15) ;
   l_effective_start_date  date ;
   l_effective_end_date   date ;
   l_object_version_number number(9);
Begin
   hr_utility.set_location ('Entering '||l_proc,10);
   open c_pqc ;
   fetch c_pqc into l_dummy_var ;
   if c_pqc%found then
      l_write_ctfn := FALSE ;
      hr_utility.set_location('certifacte eixist '   , 11);
   end if ;
   close c_pqc ;
   ---validate rule
      hr_utility.set_location('formula'|| p_ctfn_rqd_when_rl  , 11);

   if l_write_ctfn and p_ctfn_rqd_when_rl is not null then
      --pl id and assg id
      open c_Asg ;
      fetch c_asg into l_asg ;
      close c_asg ;
      hr_utility.set_location('calling formula' , 11);
      --
      l_outputs := benutils.formula
                   (p_formula_id           => p_ctfn_rqd_when_rl
                   ,p_pl_id                => l_asg.pl_id
                   ,p_business_group_id    => p_business_group_id
                   ,p_assignment_id        => l_asg.assignment_id
                   ,p_enrt_ctfn_typ_cd     => p_reimbmt_ctfn_typ_cd
                   ,p_effective_date       => p_effective_date);
       --
       if l_outputs(l_outputs.first).value = 'N' then
          l_write_ctfn := FALSE;
       end if;
      null ;
   end if ;
  if l_write_ctfn then

      ben_reimbmt_ctfn_prvdd_api.create_reimbmt_ctfn_prvdd
        (p_validate                         => false
          ,p_prtt_rmt_rqst_ctfn_prvdd_id    => l_prtt_rmt_rqst_ctfn_prvdd_id
          ,p_prtt_clm_gd_or_svc_typ_id      => p_prtt_clm_gd_or_svc_typ_id
          ,p_pl_gd_r_svc_ctfn_id            => p_pl_gd_r_svc_ctfn_id
          ,p_effective_start_date           => l_effective_start_date
          ,p_effective_end_date             => l_effective_end_date
          ,p_reimbmt_ctfn_rqd_flag          => p_reimbmt_ctfn_rqd_flag
          ,p_business_group_id              => p_business_group_id
          ,p_reimbmt_ctfn_typ_cd            => p_reimbmt_ctfn_typ_cd
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => p_effective_date
        );


  end if ;
  hr_utility.set_location ('Leaving ' ||l_proc,10);

End write_remb_rqst_ctfn ;



-- ----------------------------------------------------------------------------
-- |------------------------< create_PRTT_CLM_GD_R_SVC_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRTT_CLM_GD_R_SVC_TYP
  (p_validate                       in  boolean   default false
  ,p_prtt_clm_gd_or_svc_typ_id      out nocopy number
  ,p_prtt_reimbmt_rqst_id           in  number    default null
  ,p_gd_or_svc_typ_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcg_attribute_category         in  varchar2  default null
  ,p_pcg_attribute1                 in  varchar2  default null
  ,p_pcg_attribute2                 in  varchar2  default null
  ,p_pcg_attribute3                 in  varchar2  default null
  ,p_pcg_attribute4                 in  varchar2  default null
  ,p_pcg_attribute5                 in  varchar2  default null
  ,p_pcg_attribute6                 in  varchar2  default null
  ,p_pcg_attribute7                 in  varchar2  default null
  ,p_pcg_attribute8                 in  varchar2  default null
  ,p_pcg_attribute9                 in  varchar2  default null
  ,p_pcg_attribute10                in  varchar2  default null
  ,p_pcg_attribute11                in  varchar2  default null
  ,p_pcg_attribute12                in  varchar2  default null
  ,p_pcg_attribute13                in  varchar2  default null
  ,p_pcg_attribute14                in  varchar2  default null
  ,p_pcg_attribute15                in  varchar2  default null
  ,p_pcg_attribute16                in  varchar2  default null
  ,p_pcg_attribute17                in  varchar2  default null
  ,p_pcg_attribute18                in  varchar2  default null
  ,p_pcg_attribute19                in  varchar2  default null
  ,p_pcg_attribute20                in  varchar2  default null
  ,p_pcg_attribute21                in  varchar2  default null
  ,p_pcg_attribute22                in  varchar2  default null
  ,p_pcg_attribute23                in  varchar2  default null
  ,p_pcg_attribute24                in  varchar2  default null
  ,p_pcg_attribute25                in  varchar2  default null
  ,p_pcg_attribute26                in  varchar2  default null
  ,p_pcg_attribute27                in  varchar2  default null
  ,p_pcg_attribute28                in  varchar2  default null
  ,p_pcg_attribute29                in  varchar2  default null
  ,p_pcg_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_pl_gd_or_svc_id                in  number    default null
  ,p_effective_date                 in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_clm_gd_or_svc_typ_id ben_prtt_clm_gd_or_svc_typ.prtt_clm_gd_or_svc_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_PRTT_CLM_GD_R_SVC_TYP';
  l_object_version_number ben_prtt_clm_gd_or_svc_typ.object_version_number%TYPE;
  --#### Tilak ####
  l_ctfn_rqd_flag varchar2(30) ;

  cursor c_pct_gdsvc is
  select *  from
  ben_pl_gd_r_svc_ctfn_f
  where pl_gd_or_svc_id = p_pl_gd_or_svc_id
    and p_effective_date  between
        effective_start_date and
        effective_end_date ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRTT_CLM_GD_R_SVC_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk1.create_PRTT_CLM_GD_R_SVC_TYP_b
      (
       p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcg_attribute_category         =>  p_pcg_attribute_category
      ,p_pcg_attribute1                 =>  p_pcg_attribute1
      ,p_pcg_attribute2                 =>  p_pcg_attribute2
      ,p_pcg_attribute3                 =>  p_pcg_attribute3
      ,p_pcg_attribute4                 =>  p_pcg_attribute4
      ,p_pcg_attribute5                 =>  p_pcg_attribute5
      ,p_pcg_attribute6                 =>  p_pcg_attribute6
      ,p_pcg_attribute7                 =>  p_pcg_attribute7
      ,p_pcg_attribute8                 =>  p_pcg_attribute8
      ,p_pcg_attribute9                 =>  p_pcg_attribute9
      ,p_pcg_attribute10                =>  p_pcg_attribute10
      ,p_pcg_attribute11                =>  p_pcg_attribute11
      ,p_pcg_attribute12                =>  p_pcg_attribute12
      ,p_pcg_attribute13                =>  p_pcg_attribute13
      ,p_pcg_attribute14                =>  p_pcg_attribute14
      ,p_pcg_attribute15                =>  p_pcg_attribute15
      ,p_pcg_attribute16                =>  p_pcg_attribute16
      ,p_pcg_attribute17                =>  p_pcg_attribute17
      ,p_pcg_attribute18                =>  p_pcg_attribute18
      ,p_pcg_attribute19                =>  p_pcg_attribute19
      ,p_pcg_attribute20                =>  p_pcg_attribute20
      ,p_pcg_attribute21                =>  p_pcg_attribute21
      ,p_pcg_attribute22                =>  p_pcg_attribute22
      ,p_pcg_attribute23                =>  p_pcg_attribute23
      ,p_pcg_attribute24                =>  p_pcg_attribute24
      ,p_pcg_attribute25                =>  p_pcg_attribute25
      ,p_pcg_attribute26                =>  p_pcg_attribute26
      ,p_pcg_attribute27                =>  p_pcg_attribute27
      ,p_pcg_attribute28                =>  p_pcg_attribute28
      ,p_pcg_attribute29                =>  p_pcg_attribute29
      ,p_pcg_attribute30                =>  p_pcg_attribute30
      ,p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRTT_CLM_GD_R_SVC_TYP
    --
  end;
  --
  ben_pcg_ins.ins
    (
     p_prtt_clm_gd_or_svc_typ_id     => l_prtt_clm_gd_or_svc_typ_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcg_attribute_category        => p_pcg_attribute_category
    ,p_pcg_attribute1                => p_pcg_attribute1
    ,p_pcg_attribute2                => p_pcg_attribute2
    ,p_pcg_attribute3                => p_pcg_attribute3
    ,p_pcg_attribute4                => p_pcg_attribute4
    ,p_pcg_attribute5                => p_pcg_attribute5
    ,p_pcg_attribute6                => p_pcg_attribute6
    ,p_pcg_attribute7                => p_pcg_attribute7
    ,p_pcg_attribute8                => p_pcg_attribute8
    ,p_pcg_attribute9                => p_pcg_attribute9
    ,p_pcg_attribute10               => p_pcg_attribute10
    ,p_pcg_attribute11               => p_pcg_attribute11
    ,p_pcg_attribute12               => p_pcg_attribute12
    ,p_pcg_attribute13               => p_pcg_attribute13
    ,p_pcg_attribute14               => p_pcg_attribute14
    ,p_pcg_attribute15               => p_pcg_attribute15
    ,p_pcg_attribute16               => p_pcg_attribute16
    ,p_pcg_attribute17               => p_pcg_attribute17
    ,p_pcg_attribute18               => p_pcg_attribute18
    ,p_pcg_attribute19               => p_pcg_attribute19
    ,p_pcg_attribute20               => p_pcg_attribute20
    ,p_pcg_attribute21               => p_pcg_attribute21
    ,p_pcg_attribute22               => p_pcg_attribute22
    ,p_pcg_attribute23               => p_pcg_attribute23
    ,p_pcg_attribute24               => p_pcg_attribute24
    ,p_pcg_attribute25               => p_pcg_attribute25
    ,p_pcg_attribute26               => p_pcg_attribute26
    ,p_pcg_attribute27               => p_pcg_attribute27
    ,p_pcg_attribute28               => p_pcg_attribute28
    ,p_pcg_attribute29               => p_pcg_attribute29
    ,p_pcg_attribute30               => p_pcg_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_pl_gd_or_svc_id               => p_pl_gd_or_svc_id
    );
  --
  --#### Tilak ####
  ---Check Cretification is required
  check_remb_rqst_ctfn_rqs
    (p_pl_gd_or_svc_id     => p_pl_gd_or_svc_id
    ,p_effective_date      => p_effective_date
    ,p_ctfn_rqd_flag       => l_ctfn_rqd_flag );


  if l_ctfn_rqd_flag = 'Y' then
     ----Create Certification
     for  l_pct_gdsvc   in  c_pct_gdsvc loop
          write_remb_rqst_ctfn (
           p_prtt_clm_gd_or_svc_typ_id    => l_prtt_clm_gd_or_svc_typ_id
          ,p_pl_gd_r_svc_ctfn_id          => l_pct_gdsvc.pl_gd_r_svc_ctfn_id
          ,p_reimbmt_ctfn_rqd_flag        => l_pct_gdsvc.rqd_flag
          ,p_reimbmt_ctfn_typ_cd          => l_pct_gdsvc.rmbmt_ctfn_typ_cd
          ,p_prtt_enrt_actn_id            => null
          ,p_business_group_id            => p_business_group_id
          ,p_ctfn_rqd_when_rl             => l_pct_gdsvc.ctfn_rqd_when_rl
          ,p_prtt_reimbmt_rqst_id         => p_prtt_reimbmt_rqst_id
          ,p_effective_date               => p_effective_date );

     end loop ;
  end if ;



  begin
    --
    -- Start of API User Hook for the after hook of create_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk1.create_PRTT_CLM_GD_R_SVC_TYP_a
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  l_prtt_clm_gd_or_svc_typ_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcg_attribute_category         =>  p_pcg_attribute_category
      ,p_pcg_attribute1                 =>  p_pcg_attribute1
      ,p_pcg_attribute2                 =>  p_pcg_attribute2
      ,p_pcg_attribute3                 =>  p_pcg_attribute3
      ,p_pcg_attribute4                 =>  p_pcg_attribute4
      ,p_pcg_attribute5                 =>  p_pcg_attribute5
      ,p_pcg_attribute6                 =>  p_pcg_attribute6
      ,p_pcg_attribute7                 =>  p_pcg_attribute7
      ,p_pcg_attribute8                 =>  p_pcg_attribute8
      ,p_pcg_attribute9                 =>  p_pcg_attribute9
      ,p_pcg_attribute10                =>  p_pcg_attribute10
      ,p_pcg_attribute11                =>  p_pcg_attribute11
      ,p_pcg_attribute12                =>  p_pcg_attribute12
      ,p_pcg_attribute13                =>  p_pcg_attribute13
      ,p_pcg_attribute14                =>  p_pcg_attribute14
      ,p_pcg_attribute15                =>  p_pcg_attribute15
      ,p_pcg_attribute16                =>  p_pcg_attribute16
      ,p_pcg_attribute17                =>  p_pcg_attribute17
      ,p_pcg_attribute18                =>  p_pcg_attribute18
      ,p_pcg_attribute19                =>  p_pcg_attribute19
      ,p_pcg_attribute20                =>  p_pcg_attribute20
      ,p_pcg_attribute21                =>  p_pcg_attribute21
      ,p_pcg_attribute22                =>  p_pcg_attribute22
      ,p_pcg_attribute23                =>  p_pcg_attribute23
      ,p_pcg_attribute24                =>  p_pcg_attribute24
      ,p_pcg_attribute25                =>  p_pcg_attribute25
      ,p_pcg_attribute26                =>  p_pcg_attribute26
      ,p_pcg_attribute27                =>  p_pcg_attribute27
      ,p_pcg_attribute28                =>  p_pcg_attribute28
      ,p_pcg_attribute29                =>  p_pcg_attribute29
      ,p_pcg_attribute30                =>  p_pcg_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRTT_CLM_GD_R_SVC_TYP
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
  p_prtt_clm_gd_or_svc_typ_id := l_prtt_clm_gd_or_svc_typ_id;
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
    ROLLBACK TO create_PRTT_CLM_GD_R_SVC_TYP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_clm_gd_or_svc_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRTT_CLM_GD_R_SVC_TYP;
    p_prtt_clm_gd_or_svc_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_PRTT_CLM_GD_R_SVC_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRTT_CLM_GD_R_SVC_TYP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_CLM_GD_R_SVC_TYP
  (p_validate                       in  boolean   default false
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_prtt_reimbmt_rqst_id           in  number    default hr_api.g_number
  ,p_gd_or_svc_typ_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcg_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pcg_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_pl_gd_or_svc_id                in number    default hr_api.g_number
  ,p_effective_date                 in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_CLM_GD_R_SVC_TYP';
  l_object_version_number ben_prtt_clm_gd_or_svc_typ.object_version_number%TYPE;

   --#### Tilak ####
  l_ctfn_rqd_flag varchar2(30) ;

  cursor c_pct_gdsvc is
  select *  from
  ben_pl_gd_r_svc_ctfn_f
  where pl_gd_or_svc_id = p_pl_gd_or_svc_id
    and p_effective_date  between
        effective_start_date and
        effective_end_date ;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRTT_CLM_GD_R_SVC_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk2.update_PRTT_CLM_GD_R_SVC_TYP_b
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcg_attribute_category         =>  p_pcg_attribute_category
      ,p_pcg_attribute1                 =>  p_pcg_attribute1
      ,p_pcg_attribute2                 =>  p_pcg_attribute2
      ,p_pcg_attribute3                 =>  p_pcg_attribute3
      ,p_pcg_attribute4                 =>  p_pcg_attribute4
      ,p_pcg_attribute5                 =>  p_pcg_attribute5
      ,p_pcg_attribute6                 =>  p_pcg_attribute6
      ,p_pcg_attribute7                 =>  p_pcg_attribute7
      ,p_pcg_attribute8                 =>  p_pcg_attribute8
      ,p_pcg_attribute9                 =>  p_pcg_attribute9
      ,p_pcg_attribute10                =>  p_pcg_attribute10
      ,p_pcg_attribute11                =>  p_pcg_attribute11
      ,p_pcg_attribute12                =>  p_pcg_attribute12
      ,p_pcg_attribute13                =>  p_pcg_attribute13
      ,p_pcg_attribute14                =>  p_pcg_attribute14
      ,p_pcg_attribute15                =>  p_pcg_attribute15
      ,p_pcg_attribute16                =>  p_pcg_attribute16
      ,p_pcg_attribute17                =>  p_pcg_attribute17
      ,p_pcg_attribute18                =>  p_pcg_attribute18
      ,p_pcg_attribute19                =>  p_pcg_attribute19
      ,p_pcg_attribute20                =>  p_pcg_attribute20
      ,p_pcg_attribute21                =>  p_pcg_attribute21
      ,p_pcg_attribute22                =>  p_pcg_attribute22
      ,p_pcg_attribute23                =>  p_pcg_attribute23
      ,p_pcg_attribute24                =>  p_pcg_attribute24
      ,p_pcg_attribute25                =>  p_pcg_attribute25
      ,p_pcg_attribute26                =>  p_pcg_attribute26
      ,p_pcg_attribute27                =>  p_pcg_attribute27
      ,p_pcg_attribute28                =>  p_pcg_attribute28
      ,p_pcg_attribute29                =>  p_pcg_attribute29
      ,p_pcg_attribute30                =>  p_pcg_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRTT_CLM_GD_R_SVC_TYP
    --
  end;
  --
  ben_pcg_upd.upd
    (
     p_prtt_clm_gd_or_svc_typ_id     => p_prtt_clm_gd_or_svc_typ_id
    ,p_prtt_reimbmt_rqst_id          => p_prtt_reimbmt_rqst_id
    ,p_gd_or_svc_typ_id              => p_gd_or_svc_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcg_attribute_category        => p_pcg_attribute_category
    ,p_pcg_attribute1                => p_pcg_attribute1
    ,p_pcg_attribute2                => p_pcg_attribute2
    ,p_pcg_attribute3                => p_pcg_attribute3
    ,p_pcg_attribute4                => p_pcg_attribute4
    ,p_pcg_attribute5                => p_pcg_attribute5
    ,p_pcg_attribute6                => p_pcg_attribute6
    ,p_pcg_attribute7                => p_pcg_attribute7
    ,p_pcg_attribute8                => p_pcg_attribute8
    ,p_pcg_attribute9                => p_pcg_attribute9
    ,p_pcg_attribute10               => p_pcg_attribute10
    ,p_pcg_attribute11               => p_pcg_attribute11
    ,p_pcg_attribute12               => p_pcg_attribute12
    ,p_pcg_attribute13               => p_pcg_attribute13
    ,p_pcg_attribute14               => p_pcg_attribute14
    ,p_pcg_attribute15               => p_pcg_attribute15
    ,p_pcg_attribute16               => p_pcg_attribute16
    ,p_pcg_attribute17               => p_pcg_attribute17
    ,p_pcg_attribute18               => p_pcg_attribute18
    ,p_pcg_attribute19               => p_pcg_attribute19
    ,p_pcg_attribute20               => p_pcg_attribute20
    ,p_pcg_attribute21               => p_pcg_attribute21
    ,p_pcg_attribute22               => p_pcg_attribute22
    ,p_pcg_attribute23               => p_pcg_attribute23
    ,p_pcg_attribute24               => p_pcg_attribute24
    ,p_pcg_attribute25               => p_pcg_attribute25
    ,p_pcg_attribute26               => p_pcg_attribute26
    ,p_pcg_attribute27               => p_pcg_attribute27
    ,p_pcg_attribute28               => p_pcg_attribute28
    ,p_pcg_attribute29               => p_pcg_attribute29
    ,p_pcg_attribute30               => p_pcg_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_pl_gd_or_svc_id               => p_pl_gd_or_svc_id
    );



  --#### Tilak ####
  ---Check Cretification is required
  check_remb_rqst_ctfn_rqs
    (p_pl_gd_or_svc_id     => p_pl_gd_or_svc_id
    ,p_effective_date      => p_effective_date
    ,p_ctfn_rqd_flag       => l_ctfn_rqd_flag );


  if l_ctfn_rqd_flag = 'Y' then
     ----Create Certification
     for l_pct_gdsvc   in  c_pct_gdsvc loop
         write_remb_rqst_ctfn (
           p_prtt_clm_gd_or_svc_typ_id    => p_prtt_clm_gd_or_svc_typ_id
          ,p_pl_gd_r_svc_ctfn_id          => l_pct_gdsvc.pl_gd_r_svc_ctfn_id
          ,p_reimbmt_ctfn_rqd_flag        => l_pct_gdsvc.rqd_flag
          ,p_reimbmt_ctfn_typ_cd          => l_pct_gdsvc.rmbmt_ctfn_typ_cd
          ,p_prtt_enrt_actn_id            => null
          ,p_business_group_id            => p_business_group_id
          ,p_ctfn_rqd_when_rl             => l_pct_gdsvc.ctfn_rqd_when_rl
          ,p_prtt_reimbmt_rqst_id         => p_prtt_reimbmt_rqst_id
          ,p_effective_date               => p_effective_date );
     end loop ;
  end if ;


  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk2.update_PRTT_CLM_GD_R_SVC_TYP_a
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_prtt_reimbmt_rqst_id           =>  p_prtt_reimbmt_rqst_id
      ,p_gd_or_svc_typ_id               =>  p_gd_or_svc_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcg_attribute_category         =>  p_pcg_attribute_category
      ,p_pcg_attribute1                 =>  p_pcg_attribute1
      ,p_pcg_attribute2                 =>  p_pcg_attribute2
      ,p_pcg_attribute3                 =>  p_pcg_attribute3
      ,p_pcg_attribute4                 =>  p_pcg_attribute4
      ,p_pcg_attribute5                 =>  p_pcg_attribute5
      ,p_pcg_attribute6                 =>  p_pcg_attribute6
      ,p_pcg_attribute7                 =>  p_pcg_attribute7
      ,p_pcg_attribute8                 =>  p_pcg_attribute8
      ,p_pcg_attribute9                 =>  p_pcg_attribute9
      ,p_pcg_attribute10                =>  p_pcg_attribute10
      ,p_pcg_attribute11                =>  p_pcg_attribute11
      ,p_pcg_attribute12                =>  p_pcg_attribute12
      ,p_pcg_attribute13                =>  p_pcg_attribute13
      ,p_pcg_attribute14                =>  p_pcg_attribute14
      ,p_pcg_attribute15                =>  p_pcg_attribute15
      ,p_pcg_attribute16                =>  p_pcg_attribute16
      ,p_pcg_attribute17                =>  p_pcg_attribute17
      ,p_pcg_attribute18                =>  p_pcg_attribute18
      ,p_pcg_attribute19                =>  p_pcg_attribute19
      ,p_pcg_attribute20                =>  p_pcg_attribute20
      ,p_pcg_attribute21                =>  p_pcg_attribute21
      ,p_pcg_attribute22                =>  p_pcg_attribute22
      ,p_pcg_attribute23                =>  p_pcg_attribute23
      ,p_pcg_attribute24                =>  p_pcg_attribute24
      ,p_pcg_attribute25                =>  p_pcg_attribute25
      ,p_pcg_attribute26                =>  p_pcg_attribute26
      ,p_pcg_attribute27                =>  p_pcg_attribute27
      ,p_pcg_attribute28                =>  p_pcg_attribute28
      ,p_pcg_attribute29                =>  p_pcg_attribute29
      ,p_pcg_attribute30                =>  p_pcg_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_pl_gd_or_svc_id                =>  p_pl_gd_or_svc_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PRTT_CLM_GD_R_SVC_TYP
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
    ROLLBACK TO update_PRTT_CLM_GD_R_SVC_TYP;
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
    ROLLBACK TO update_PRTT_CLM_GD_R_SVC_TYP;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_PRTT_CLM_GD_R_SVC_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRTT_CLM_GD_R_SVC_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTT_CLM_GD_R_SVC_TYP
  (p_validate                       in  boolean  default false
  ,p_prtt_clm_gd_or_svc_typ_id      in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRTT_CLM_GD_R_SVC_TYP';
  l_object_version_number ben_prtt_clm_gd_or_svc_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRTT_CLM_GD_R_SVC_TYP;
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
    -- Start of API User Hook for the before hook of delete_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk3.delete_PRTT_CLM_GD_R_SVC_TYP_b
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PRTT_CLM_GD_R_SVC_TYP
    --
  end;
  --
  ben_pcg_del.del
    (
     p_prtt_clm_gd_or_svc_typ_id     => p_prtt_clm_gd_or_svc_typ_id
    ,p_object_version_number         => l_object_version_number
    );

  --
  --#### tilak call for deleteing ####
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRTT_CLM_GD_R_SVC_TYP
    --
    ben_PRTT_CLM_GD_R_SVC_TYP_bk3.delete_PRTT_CLM_GD_R_SVC_TYP_a
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRTT_CLM_GD_R_SVC_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRTT_CLM_GD_R_SVC_TYP
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
    ROLLBACK TO delete_PRTT_CLM_GD_R_SVC_TYP;
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
    ROLLBACK TO delete_PRTT_CLM_GD_R_SVC_TYP;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_PRTT_CLM_GD_R_SVC_TYP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_clm_gd_or_svc_typ_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_pcg_shd.lck
    (
      p_prtt_clm_gd_or_svc_typ_id                 => p_prtt_clm_gd_or_svc_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_PRTT_CLM_GD_R_SVC_TYP_api;

/
