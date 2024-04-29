--------------------------------------------------------
--  DDL for Package Body BEN_PRMRY_CARE_PRVDR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRMRY_CARE_PRVDR_API" as
/* $Header: bepprapi.pkb 120.2.12010000.2 2008/08/05 15:16:48 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PRMRY_CARE_PRVDR_api.';
-- ----------------------------------------------------------------------------
-- |--------------------< determine_datetrack_mode >---------------------------|
-- ----------------------------------------------------------------------------

procedure determine_datetrack_mode
                  (p_effective_date         in     date
                  ,p_base_key_value         in     number
                  ,p_desired_datetrack_mode in     varchar2
                  ,p_mini_mode              in     varchar2
                  ,p_datetrack_allow        in out nocopy varchar2
                  )is
  l_correction           boolean;
  l_update               boolean;
  l_update_override      boolean;
  l_update_change_insert boolean;
  l_zap                  boolean;
  l_delete               boolean;
  l_future_change        boolean;
  l_delete_next_change   boolean;
  l_step                 number(9);
  l_proc                 varchar2(80) := g_package||'determine_datetrack_mode';
begin
   hr_utility.set_location ('Entering '||l_proc,10);

   if p_mini_mode = 'U' then  -- update

      ben_ppr_shd.find_dt_upd_modes
       (p_effective_date   => p_effective_date
   ,p_base_key_value   => p_base_key_value
   ,p_correction         => l_correction
   ,p_update               => l_update
   ,p_update_override  => l_update_override
   ,p_update_change_insert => l_update_change_insert
       );

      if (p_desired_datetrack_mode = hr_api.g_update and l_update) then
          p_datetrack_allow := hr_api.g_update;
      elsif(p_desired_datetrack_mode = hr_api.g_correction and l_correction)then
          p_datetrack_allow := hr_api.g_correction;
      elsif(p_desired_datetrack_mode = hr_api.g_update_override
            and l_update_override) then
          p_datetrack_allow := hr_api.g_update_override;
      elsif(p_desired_datetrack_mode = hr_api.g_update_change_insert
            and l_update_change_insert) then
          p_datetrack_allow := hr_api.g_update_change_insert;
      elsif(l_update) then
          p_datetrack_allow := hr_api.g_update;
      elsif(l_correction) then
          p_datetrack_allow := hr_api.g_correction;
      else
          fnd_message.set_name('BEN', 'BEN_91700_DATETRACK_NOT_ALWD');
          fnd_message.set_token('MODE',p_desired_datetrack_mode);
          fnd_message.raise_error;
      end if;
   else  -- mini-mode = 'D' for delete
      ben_ppr_shd.find_dt_del_modes
       (p_effective_date   => p_effective_date
   ,p_base_key_value   => p_base_key_value
       ,p_zap                  => l_zap
       ,p_delete               => l_delete
       ,p_future_change        => l_future_change
       ,p_delete_next_change   => l_delete_next_change);

      if (p_desired_datetrack_mode = hr_api.g_delete and l_delete) then
          p_datetrack_allow := hr_api.g_delete;
      elsif(p_desired_datetrack_mode = hr_api.g_zap and l_zap)then
          p_datetrack_allow := hr_api.g_zap;
      elsif(p_desired_datetrack_mode = hr_api.g_future_change and l_future_change) then
          p_datetrack_allow := hr_api.g_future_change;
      elsif(p_desired_datetrack_mode = hr_api.g_delete_next_change
            and l_delete_next_change) then
          p_datetrack_allow := hr_api.g_delete_next_change;
      elsif (l_delete) then
          p_datetrack_allow := hr_api.g_delete;
      elsif (l_zap) then
          p_datetrack_allow := hr_api.g_zap;
      else
          fnd_message.set_name('BEN', 'BEN_91700_DATETRACK_NOT_ALWD');
          fnd_message.set_token('MODE',p_desired_datetrack_mode);
          fnd_message.raise_error;
      end if;

   end if;

   hr_utility.set_location ('Leaving '||l_proc,99);
Exception
   when others then
       raise;
end determine_datetrack_mode;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PRMRY_CARE_PRVDR >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PRMRY_CARE_PRVDR
  (p_validate                       in  boolean   default false
  ,p_prmry_care_prvdr_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_ext_ident                      in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ppr_attribute_category         in  varchar2  default null
  ,p_ppr_attribute1                 in  varchar2  default null
  ,p_ppr_attribute2                 in  varchar2  default null
  ,p_ppr_attribute3                 in  varchar2  default null
  ,p_ppr_attribute4                 in  varchar2  default null
  ,p_ppr_attribute5                 in  varchar2  default null
  ,p_ppr_attribute6                 in  varchar2  default null
  ,p_ppr_attribute7                 in  varchar2  default null
  ,p_ppr_attribute8                 in  varchar2  default null
  ,p_ppr_attribute9                 in  varchar2  default null
  ,p_ppr_attribute10                in  varchar2  default null
  ,p_ppr_attribute11                in  varchar2  default null
  ,p_ppr_attribute12                in  varchar2  default null
  ,p_ppr_attribute13                in  varchar2  default null
  ,p_ppr_attribute14                in  varchar2  default null
  ,p_ppr_attribute15                in  varchar2  default null
  ,p_ppr_attribute16                in  varchar2  default null
  ,p_ppr_attribute17                in  varchar2  default null
  ,p_ppr_attribute18                in  varchar2  default null
  ,p_ppr_attribute19                in  varchar2  default null
  ,p_ppr_attribute20                in  varchar2  default null
  ,p_ppr_attribute21                in  varchar2  default null
  ,p_ppr_attribute22                in  varchar2  default null
  ,p_ppr_attribute23                in  varchar2  default null
  ,p_ppr_attribute24                in  varchar2  default null
  ,p_ppr_attribute25                in  varchar2  default null
  ,p_ppr_attribute26                in  varchar2  default null
  ,p_ppr_attribute27                in  varchar2  default null
  ,p_ppr_attribute28                in  varchar2  default null
  ,p_ppr_attribute29                in  varchar2  default null
  ,p_ppr_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prmry_care_prvdr_id ben_prmry_care_prvdr_f.prmry_care_prvdr_id%TYPE;
  l_effective_start_date ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PRMRY_CARE_PRVDR';
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PRMRY_CARE_PRVDR;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk1.create_PRMRY_CARE_PRVDR_b
      (
       p_prmry_care_prvdr_typ_cd        =>  p_prmry_care_prvdr_typ_cd
      ,p_name                           =>  p_name
      ,p_ext_ident                      =>  p_ext_ident
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppr_attribute_category         =>  p_ppr_attribute_category
      ,p_ppr_attribute1                 =>  p_ppr_attribute1
      ,p_ppr_attribute2                 =>  p_ppr_attribute2
      ,p_ppr_attribute3                 =>  p_ppr_attribute3
      ,p_ppr_attribute4                 =>  p_ppr_attribute4
      ,p_ppr_attribute5                 =>  p_ppr_attribute5
      ,p_ppr_attribute6                 =>  p_ppr_attribute6
      ,p_ppr_attribute7                 =>  p_ppr_attribute7
      ,p_ppr_attribute8                 =>  p_ppr_attribute8
      ,p_ppr_attribute9                 =>  p_ppr_attribute9
      ,p_ppr_attribute10                =>  p_ppr_attribute10
      ,p_ppr_attribute11                =>  p_ppr_attribute11
      ,p_ppr_attribute12                =>  p_ppr_attribute12
      ,p_ppr_attribute13                =>  p_ppr_attribute13
      ,p_ppr_attribute14                =>  p_ppr_attribute14
      ,p_ppr_attribute15                =>  p_ppr_attribute15
      ,p_ppr_attribute16                =>  p_ppr_attribute16
      ,p_ppr_attribute17                =>  p_ppr_attribute17
      ,p_ppr_attribute18                =>  p_ppr_attribute18
      ,p_ppr_attribute19                =>  p_ppr_attribute19
      ,p_ppr_attribute20                =>  p_ppr_attribute20
      ,p_ppr_attribute21                =>  p_ppr_attribute21
      ,p_ppr_attribute22                =>  p_ppr_attribute22
      ,p_ppr_attribute23                =>  p_ppr_attribute23
      ,p_ppr_attribute24                =>  p_ppr_attribute24
      ,p_ppr_attribute25                =>  p_ppr_attribute25
      ,p_ppr_attribute26                =>  p_ppr_attribute26
      ,p_ppr_attribute27                =>  p_ppr_attribute27
      ,p_ppr_attribute28                =>  p_ppr_attribute28
      ,p_ppr_attribute29                =>  p_ppr_attribute29
      ,p_ppr_attribute30                =>  p_ppr_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PRMRY_CARE_PRVDR
    --
  end;
  --
  ben_ppr_ins.ins
    (
     p_prmry_care_prvdr_id           => l_prmry_care_prvdr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prmry_care_prvdr_typ_cd       => p_prmry_care_prvdr_typ_cd
    ,p_name                          => p_name
    ,p_ext_ident                     => p_ext_ident
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppr_attribute_category        => p_ppr_attribute_category
    ,p_ppr_attribute1                => p_ppr_attribute1
    ,p_ppr_attribute2                => p_ppr_attribute2
    ,p_ppr_attribute3                => p_ppr_attribute3
    ,p_ppr_attribute4                => p_ppr_attribute4
    ,p_ppr_attribute5                => p_ppr_attribute5
    ,p_ppr_attribute6                => p_ppr_attribute6
    ,p_ppr_attribute7                => p_ppr_attribute7
    ,p_ppr_attribute8                => p_ppr_attribute8
    ,p_ppr_attribute9                => p_ppr_attribute9
    ,p_ppr_attribute10               => p_ppr_attribute10
    ,p_ppr_attribute11               => p_ppr_attribute11
    ,p_ppr_attribute12               => p_ppr_attribute12
    ,p_ppr_attribute13               => p_ppr_attribute13
    ,p_ppr_attribute14               => p_ppr_attribute14
    ,p_ppr_attribute15               => p_ppr_attribute15
    ,p_ppr_attribute16               => p_ppr_attribute16
    ,p_ppr_attribute17               => p_ppr_attribute17
    ,p_ppr_attribute18               => p_ppr_attribute18
    ,p_ppr_attribute19               => p_ppr_attribute19
    ,p_ppr_attribute20               => p_ppr_attribute20
    ,p_ppr_attribute21               => p_ppr_attribute21
    ,p_ppr_attribute22               => p_ppr_attribute22
    ,p_ppr_attribute23               => p_ppr_attribute23
    ,p_ppr_attribute24               => p_ppr_attribute24
    ,p_ppr_attribute25               => p_ppr_attribute25
    ,p_ppr_attribute26               => p_ppr_attribute26
    ,p_ppr_attribute27               => p_ppr_attribute27
    ,p_ppr_attribute28               => p_ppr_attribute28
    ,p_ppr_attribute29               => p_ppr_attribute29
    ,p_ppr_attribute30               => p_ppr_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  -- record an extract change event
  --
  ben_ext_chlg.log_pcp_chg
       (p_action               => 'CREATE',
        p_ext_ident            => p_ext_ident,
        p_name                 => p_name,
        p_prmry_care_prvdr_typ_cd => p_prmry_care_prvdr_typ_cd,
        p_prmry_care_prvdr_id  => l_prmry_care_prvdr_id,
        p_elig_cvrd_dpnt_id    => p_elig_cvrd_dpnt_id,
        p_prtt_enrt_rslt_id    => p_prtt_enrt_rslt_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);

  --  check for action items
      pcp_actn_items(
           p_prtt_enrt_rslt_id  => p_prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id  => p_elig_cvrd_dpnt_id
          ,p_effective_date     => p_effective_date
          ,p_business_group_id  => p_business_group_id
          ,p_validate           => p_validate
          ,p_datetrack_mode     => null
          );
  begin
    --
    -- Start of API User Hook for the after hook of create_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk1.create_PRMRY_CARE_PRVDR_a
      (
       p_prmry_care_prvdr_id            =>  l_prmry_care_prvdr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prmry_care_prvdr_typ_cd        =>  p_prmry_care_prvdr_typ_cd
      ,p_name                           =>  p_name
      ,p_ext_ident                      =>  p_ext_ident
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppr_attribute_category         =>  p_ppr_attribute_category
      ,p_ppr_attribute1                 =>  p_ppr_attribute1
      ,p_ppr_attribute2                 =>  p_ppr_attribute2
      ,p_ppr_attribute3                 =>  p_ppr_attribute3
      ,p_ppr_attribute4                 =>  p_ppr_attribute4
      ,p_ppr_attribute5                 =>  p_ppr_attribute5
      ,p_ppr_attribute6                 =>  p_ppr_attribute6
      ,p_ppr_attribute7                 =>  p_ppr_attribute7
      ,p_ppr_attribute8                 =>  p_ppr_attribute8
      ,p_ppr_attribute9                 =>  p_ppr_attribute9
      ,p_ppr_attribute10                =>  p_ppr_attribute10
      ,p_ppr_attribute11                =>  p_ppr_attribute11
      ,p_ppr_attribute12                =>  p_ppr_attribute12
      ,p_ppr_attribute13                =>  p_ppr_attribute13
      ,p_ppr_attribute14                =>  p_ppr_attribute14
      ,p_ppr_attribute15                =>  p_ppr_attribute15
      ,p_ppr_attribute16                =>  p_ppr_attribute16
      ,p_ppr_attribute17                =>  p_ppr_attribute17
      ,p_ppr_attribute18                =>  p_ppr_attribute18
      ,p_ppr_attribute19                =>  p_ppr_attribute19
      ,p_ppr_attribute20                =>  p_ppr_attribute20
      ,p_ppr_attribute21                =>  p_ppr_attribute21
      ,p_ppr_attribute22                =>  p_ppr_attribute22
      ,p_ppr_attribute23                =>  p_ppr_attribute23
      ,p_ppr_attribute24                =>  p_ppr_attribute24
      ,p_ppr_attribute25                =>  p_ppr_attribute25
      ,p_ppr_attribute26                =>  p_ppr_attribute26
      ,p_ppr_attribute27                =>  p_ppr_attribute27
      ,p_ppr_attribute28                =>  p_ppr_attribute28
      ,p_ppr_attribute29                =>  p_ppr_attribute29
      ,p_ppr_attribute30                =>  p_ppr_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PRMRY_CARE_PRVDR
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
  p_prmry_care_prvdr_id := l_prmry_care_prvdr_id;
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
    ROLLBACK TO create_PRMRY_CARE_PRVDR;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prmry_care_prvdr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PRMRY_CARE_PRVDR;
    raise;
    --
end create_PRMRY_CARE_PRVDR;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_prmry_care_prvdr_w >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_prmry_care_prvdr_w
(
   p_prmry_care_prvdr_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_ext_ident                      in  varchar2  default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_return_status                  out nocopy    varchar2
)
is

--
  l_proc varchar2(72) := g_package||'create_prmry_care_prvdr_w';

  l_prmry_care_prvdr_id ben_prmry_care_prvdr_f.prmry_care_prvdr_id%TYPE;
  l_effective_start_date ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  fnd_msg_pub.initialize;

  create_prmry_care_prvdr
  (
     p_prmry_care_prvdr_id      => l_prmry_care_prvdr_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_prmry_care_prvdr_typ_cd  => p_prmry_care_prvdr_typ_cd
    ,p_name                     => p_name
    ,p_ext_ident                => p_ext_ident
    ,p_prtt_enrt_rslt_id        => p_prtt_enrt_rslt_id
    ,p_elig_cvrd_dpnt_id        => p_elig_cvrd_dpnt_id
    ,p_business_group_id        => p_business_group_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => p_effective_date
  );
  --
  --
  -- Set all output arguments
  --
  p_prmry_care_prvdr_id   := l_prmry_care_prvdr_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  p_return_status	  := 'S';

  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location('Exception:'|| l_proc, 100);
    p_prmry_care_prvdr_id    := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := null;
    p_return_status	     := 'E';
    fnd_msg_pub.add;
    --
End create_prmry_care_prvdr_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_PRMRY_CARE_PRVDR >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRMRY_CARE_PRVDR
  (p_validate                       in  boolean   default false
  ,p_prmry_care_prvdr_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prmry_care_prvdr_typ_cd        in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_ext_ident                      in  varchar2  default hr_api.g_varchar2
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ppr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ppr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PRMRY_CARE_PRVDR';
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l_effective_start_date  ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  --
  cursor c_old_pcp_values
  is
  select pcp.prmry_care_prvdr_typ_cd,
         pcp.name,
         pcp.ext_ident,
         pcp.prtt_enrt_rslt_id,
         pcp.elig_cvrd_dpnt_id
  from ben_prmry_care_prvdr_f pcp
  where pcp.prmry_care_prvdr_id = p_prmry_care_prvdr_id
  and p_effective_date between pcp.effective_start_date and pcp.effective_end_date;

  l_old_pcp_values     c_old_pcp_values%rowtype;
  l_datetrack_mode     varchar2(80);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PRMRY_CARE_PRVDR;
  hr_utility.set_location(l_proc, 20);

  -- added for logging change events for extract
  open c_old_pcp_values;
  fetch c_old_pcp_values into l_old_pcp_values;
  close c_old_pcp_values;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;

  determine_datetrack_mode
                  (p_effective_date         => p_effective_date
                  ,p_base_key_value         => p_prmry_care_prvdr_id
                  ,p_desired_datetrack_mode => p_datetrack_mode
                  ,p_mini_mode              => 'U'
                  ,p_datetrack_allow        => l_datetrack_mode);


  begin
    --
    -- Start of API User Hook for the before hook of update_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk2.update_PRMRY_CARE_PRVDR_b
      (
       p_prmry_care_prvdr_id            =>  p_prmry_care_prvdr_id
      ,p_prmry_care_prvdr_typ_cd        =>  p_prmry_care_prvdr_typ_cd
      ,p_name                           =>  p_name
      ,p_ext_ident                      =>  p_ext_ident
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppr_attribute_category         =>  p_ppr_attribute_category
      ,p_ppr_attribute1                 =>  p_ppr_attribute1
      ,p_ppr_attribute2                 =>  p_ppr_attribute2
      ,p_ppr_attribute3                 =>  p_ppr_attribute3
      ,p_ppr_attribute4                 =>  p_ppr_attribute4
      ,p_ppr_attribute5                 =>  p_ppr_attribute5
      ,p_ppr_attribute6                 =>  p_ppr_attribute6
      ,p_ppr_attribute7                 =>  p_ppr_attribute7
      ,p_ppr_attribute8                 =>  p_ppr_attribute8
      ,p_ppr_attribute9                 =>  p_ppr_attribute9
      ,p_ppr_attribute10                =>  p_ppr_attribute10
      ,p_ppr_attribute11                =>  p_ppr_attribute11
      ,p_ppr_attribute12                =>  p_ppr_attribute12
      ,p_ppr_attribute13                =>  p_ppr_attribute13
      ,p_ppr_attribute14                =>  p_ppr_attribute14
      ,p_ppr_attribute15                =>  p_ppr_attribute15
      ,p_ppr_attribute16                =>  p_ppr_attribute16
      ,p_ppr_attribute17                =>  p_ppr_attribute17
      ,p_ppr_attribute18                =>  p_ppr_attribute18
      ,p_ppr_attribute19                =>  p_ppr_attribute19
      ,p_ppr_attribute20                =>  p_ppr_attribute20
      ,p_ppr_attribute21                =>  p_ppr_attribute21
      ,p_ppr_attribute22                =>  p_ppr_attribute22
      ,p_ppr_attribute23                =>  p_ppr_attribute23
      ,p_ppr_attribute24                =>  p_ppr_attribute24
      ,p_ppr_attribute25                =>  p_ppr_attribute25
      ,p_ppr_attribute26                =>  p_ppr_attribute26
      ,p_ppr_attribute27                =>  p_ppr_attribute27
      ,p_ppr_attribute28                =>  p_ppr_attribute28
      ,p_ppr_attribute29                =>  p_ppr_attribute29
      ,p_ppr_attribute30                =>  p_ppr_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PRMRY_CARE_PRVDR
    --
  end;
  --
  ben_ppr_upd.upd
    (
     p_prmry_care_prvdr_id           => p_prmry_care_prvdr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prmry_care_prvdr_typ_cd       => p_prmry_care_prvdr_typ_cd
    ,p_name                          => p_name
    ,p_ext_ident                     => p_ext_ident
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_business_group_id             => p_business_group_id
    ,p_ppr_attribute_category        => p_ppr_attribute_category
    ,p_ppr_attribute1                => p_ppr_attribute1
    ,p_ppr_attribute2                => p_ppr_attribute2
    ,p_ppr_attribute3                => p_ppr_attribute3
    ,p_ppr_attribute4                => p_ppr_attribute4
    ,p_ppr_attribute5                => p_ppr_attribute5
    ,p_ppr_attribute6                => p_ppr_attribute6
    ,p_ppr_attribute7                => p_ppr_attribute7
    ,p_ppr_attribute8                => p_ppr_attribute8
    ,p_ppr_attribute9                => p_ppr_attribute9
    ,p_ppr_attribute10               => p_ppr_attribute10
    ,p_ppr_attribute11               => p_ppr_attribute11
    ,p_ppr_attribute12               => p_ppr_attribute12
    ,p_ppr_attribute13               => p_ppr_attribute13
    ,p_ppr_attribute14               => p_ppr_attribute14
    ,p_ppr_attribute15               => p_ppr_attribute15
    ,p_ppr_attribute16               => p_ppr_attribute16
    ,p_ppr_attribute17               => p_ppr_attribute17
    ,p_ppr_attribute18               => p_ppr_attribute18
    ,p_ppr_attribute19               => p_ppr_attribute19
    ,p_ppr_attribute20               => p_ppr_attribute20
    ,p_ppr_attribute21               => p_ppr_attribute21
    ,p_ppr_attribute22               => p_ppr_attribute22
    ,p_ppr_attribute23               => p_ppr_attribute23
    ,p_ppr_attribute24               => p_ppr_attribute24
    ,p_ppr_attribute25               => p_ppr_attribute25
    ,p_ppr_attribute26               => p_ppr_attribute26
    ,p_ppr_attribute27               => p_ppr_attribute27
    ,p_ppr_attribute28               => p_ppr_attribute28
    ,p_ppr_attribute29               => p_ppr_attribute29
    ,p_ppr_attribute30               => p_ppr_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => l_datetrack_mode
    );
    --
    ben_ext_chlg.log_pcp_chg
       (p_action               => 'UPDATE',
        p_ext_ident            => p_ext_ident,
        p_old_ext_ident        => l_old_pcp_values.ext_ident,
        p_name                 => p_name,
        p_old_name             => l_old_pcp_values.name,
        p_prmry_care_prvdr_typ_cd => p_prmry_care_prvdr_typ_cd,
        p_old_prmry_care_prvdr_typ_cd => l_old_pcp_values.prmry_care_prvdr_typ_cd,
        p_prmry_care_prvdr_id  => p_prmry_care_prvdr_id,
        p_elig_cvrd_dpnt_id    => l_old_pcp_values.elig_cvrd_dpnt_id,
        p_prtt_enrt_rslt_id    => l_old_pcp_values.prtt_enrt_rslt_id,
        p_business_group_id    => p_business_group_id,
        p_effective_date       => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk2.update_PRMRY_CARE_PRVDR_a
      (
       p_prmry_care_prvdr_id            =>  p_prmry_care_prvdr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prmry_care_prvdr_typ_cd        =>  p_prmry_care_prvdr_typ_cd
      ,p_name                           =>  p_name
      ,p_ext_ident                      =>  p_ext_ident
      ,p_prtt_enrt_rslt_id              =>  p_prtt_enrt_rslt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ppr_attribute_category         =>  p_ppr_attribute_category
      ,p_ppr_attribute1                 =>  p_ppr_attribute1
      ,p_ppr_attribute2                 =>  p_ppr_attribute2
      ,p_ppr_attribute3                 =>  p_ppr_attribute3
      ,p_ppr_attribute4                 =>  p_ppr_attribute4
      ,p_ppr_attribute5                 =>  p_ppr_attribute5
      ,p_ppr_attribute6                 =>  p_ppr_attribute6
      ,p_ppr_attribute7                 =>  p_ppr_attribute7
      ,p_ppr_attribute8                 =>  p_ppr_attribute8
      ,p_ppr_attribute9                 =>  p_ppr_attribute9
      ,p_ppr_attribute10                =>  p_ppr_attribute10
      ,p_ppr_attribute11                =>  p_ppr_attribute11
      ,p_ppr_attribute12                =>  p_ppr_attribute12
      ,p_ppr_attribute13                =>  p_ppr_attribute13
      ,p_ppr_attribute14                =>  p_ppr_attribute14
      ,p_ppr_attribute15                =>  p_ppr_attribute15
      ,p_ppr_attribute16                =>  p_ppr_attribute16
      ,p_ppr_attribute17                =>  p_ppr_attribute17
      ,p_ppr_attribute18                =>  p_ppr_attribute18
      ,p_ppr_attribute19                =>  p_ppr_attribute19
      ,p_ppr_attribute20                =>  p_ppr_attribute20
      ,p_ppr_attribute21                =>  p_ppr_attribute21
      ,p_ppr_attribute22                =>  p_ppr_attribute22
      ,p_ppr_attribute23                =>  p_ppr_attribute23
      ,p_ppr_attribute24                =>  p_ppr_attribute24
      ,p_ppr_attribute25                =>  p_ppr_attribute25
      ,p_ppr_attribute26                =>  p_ppr_attribute26
      ,p_ppr_attribute27                =>  p_ppr_attribute27
      ,p_ppr_attribute28                =>  p_ppr_attribute28
      ,p_ppr_attribute29                =>  p_ppr_attribute29
      ,p_ppr_attribute30                =>  p_ppr_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'AP' );
    --
    -- End of API User Hook for the after hook of update_PRMRY_CARE_PRVDR
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
    ROLLBACK TO update_PRMRY_CARE_PRVDR;
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
    ROLLBACK TO update_PRMRY_CARE_PRVDR;
    raise;
    --
end update_PRMRY_CARE_PRVDR;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_prmry_care_prvdr_w >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_prmry_care_prvdr_w
(
    p_prmry_care_prvdr_id            in  number
   ,p_effective_start_date           out nocopy date
   ,p_effective_end_date             out nocopy date
   ,p_prmry_care_prvdr_typ_cd        in  varchar2  default hr_api.g_varchar2
   ,p_name                           in  varchar2  default hr_api.g_varchar2
   ,p_ext_ident                      in  varchar2  default hr_api.g_varchar2
   ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
   ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
   ,p_business_group_id              in  number    default hr_api.g_number
   ,p_object_version_number          in out nocopy number
   ,p_effective_date                 in  date
   ,p_datetrack_mode                 in  varchar2
   ,p_return_status                  out nocopy    varchar2
)
is
  --
  l_proc varchar2(72) := g_package||'update_prmry_care_prvdr_w';
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l_effective_start_date  ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  fnd_msg_pub.initialize;

  l_object_version_number := p_object_version_number;
  update_prmry_care_prvdr
  (
     p_prmry_care_prvdr_id      => p_prmry_care_prvdr_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_prmry_care_prvdr_typ_cd  => p_prmry_care_prvdr_typ_cd
    ,p_name                     => p_name
    ,p_ext_ident                => p_ext_ident
    ,p_business_group_id        => p_business_group_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
  );
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_return_status	  := 'S';
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location('Exception:'||l_proc, 100);
    p_effective_start_date := null;
    p_effective_end_date   := null;
    p_return_status	   := 'E';
    fnd_msg_pub.add;
    --
end update_prmry_care_prvdr_w;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PRMRY_CARE_PRVDR >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRMRY_CARE_PRVDR
  (p_validate                       in  boolean  default false
  ,p_prmry_care_prvdr_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_called_from                    in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_PRMRY_CARE_PRVDR';
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l_effective_start_date  ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  l_effective_date        date;

  cursor c_old_pcp_values
  is
  select pcp.prmry_care_prvdr_typ_cd,
         pcp.name,
         pcp.ext_ident,
         pcp.prtt_enrt_rslt_id,
         pcp.elig_cvrd_dpnt_id,
         pcp.business_group_id,
         pcp.effective_start_date
  from ben_prmry_care_prvdr_f pcp
  where pcp.prmry_care_prvdr_id = p_prmry_care_prvdr_id
  and p_effective_date between pcp.effective_start_date and pcp.effective_end_date;

  l_old_pcp_values     c_old_pcp_values%rowtype;
  l_datetrack_mode     varchar2(80);
  l_desired_dt_mode    varchar2(80);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PRMRY_CARE_PRVDR;
  hr_utility.set_location(l_proc, 20);

  -- added for logging change events for extract
  open c_old_pcp_values;
  fetch c_old_pcp_values into l_old_pcp_values;
  close c_old_pcp_values;

  -- we want to delete as of yesterday so the pcp doesn't show up on the web page
  -- after it's deleted.  But can only change the date if the record didn't
  -- start on the eff-date passed in.
  if l_old_pcp_values.effective_start_date <> p_effective_date then
     l_effective_date := p_effective_date -1;
     l_desired_dt_mode := p_datetrack_mode;
  else
     -- to make the functionality similar when the dates are the same,
     -- zap the record.  This is needed for web functionality. Felt that
     -- functionality should be same from web and back-office form.
     l_effective_date := p_effective_date ;
     l_desired_dt_mode := 'ZAP';
  end if;

  -- Process Logic
  l_object_version_number := p_object_version_number;

  determine_datetrack_mode
                  (p_effective_date         => l_effective_date
                  ,p_base_key_value         => p_prmry_care_prvdr_id
                  ,p_desired_datetrack_mode => l_desired_dt_mode
                  ,p_mini_mode              => 'D'
                  ,p_datetrack_allow        => l_datetrack_mode);


  begin
    --
    -- Start of API User Hook for the before hook of delete_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk3.delete_PRMRY_CARE_PRVDR_b
      (
       p_prmry_care_prvdr_id            => p_prmry_care_prvdr_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(l_effective_date)
      ,p_datetrack_mode                 => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'BP' );
    --
    -- End of API User Hook for the before hook of delete_PRMRY_CARE_PRVDR
    --
  end;
  --
  ben_ppr_del.del
    (
     p_prmry_care_prvdr_id           => p_prmry_care_prvdr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => l_effective_date
    ,p_datetrack_mode                => l_datetrack_mode
    );
  --
    -- write to the extract change log
    --
     ben_ext_chlg.log_pcp_chg
       (p_action               => 'DELETE',
        p_old_ext_ident        => l_old_pcp_values.ext_ident,
        p_old_name             => l_old_pcp_values.name,
        p_old_prmry_care_prvdr_typ_cd => l_old_pcp_values.prmry_care_prvdr_typ_cd,
        p_prmry_care_prvdr_id  => p_prmry_care_prvdr_id,
        p_elig_cvrd_dpnt_id    => l_old_pcp_values.elig_cvrd_dpnt_id,
        p_prtt_enrt_rslt_id    => l_old_pcp_values.prtt_enrt_rslt_id,
        p_business_group_id    => l_old_pcp_values.business_group_id,
        p_effective_date       => l_effective_date);
-- 4879576
/*hr_utility.set_location('SSARKAR l_old_pcp_values.prtt_enrt_rslt_id '|| l_old_pcp_values.prtt_enrt_rslt_id,99099);
hr_utility.set_location('SSARKAR l_old_pcp_values.elig_cvrd_dpnt_id '|| l_old_pcp_values.elig_cvrd_dpnt_id,99099);
hr_utility.set_location('SSARKAR l_effective_date '|| l_effective_date,99099);
hr_utility.set_location('SSARKAR l_old_pcp_values.business_group_id '|| l_old_pcp_values.business_group_id,99099);
hr_utility.set_location('SSARKAR l_datetrack_mode '|| l_datetrack_mode,99099);
*/
 if p_called_from is null then
   pcp_actn_items(
           p_prtt_enrt_rslt_id  => l_old_pcp_values.prtt_enrt_rslt_id
          ,p_elig_cvrd_dpnt_id  => l_old_pcp_values.elig_cvrd_dpnt_id
          ,p_effective_date     => l_effective_date
          ,p_business_group_id  => l_old_pcp_values.business_group_id
          ,p_validate           => p_validate
          ,p_datetrack_mode     => l_datetrack_mode
          );
  end if;
-- END 4879576
  begin
    --
    -- Start of API User Hook for the after hook of delete_PRMRY_CARE_PRVDR
    --
    ben_PRMRY_CARE_PRVDR_bk3.delete_PRMRY_CARE_PRVDR_a
      (
       p_prmry_care_prvdr_id            => p_prmry_care_prvdr_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(l_effective_date)
      ,p_datetrack_mode                 => l_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PRMRY_CARE_PRVDR'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PRMRY_CARE_PRVDR
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
    ROLLBACK TO delete_PRMRY_CARE_PRVDR;
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
    ROLLBACK TO delete_PRMRY_CARE_PRVDR;
    raise;
    --
end delete_PRMRY_CARE_PRVDR;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_prmry_care_prvdr_w >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_prmry_care_prvdr_w
(
     p_prmry_care_prvdr_id            in  number
    ,p_effective_start_date           out nocopy date
    ,p_effective_end_date             out nocopy date
    ,p_object_version_number          in out nocopy number
    ,p_effective_date                 in date
    ,p_datetrack_mode                 in varchar2
    ,p_return_status                  out nocopy    varchar2
)
is

  l_proc varchar2(72) := g_package||'delete_prmry_care_prvdr_w';
  l_object_version_number ben_prmry_care_prvdr_f.object_version_number%TYPE;
  l_effective_start_date  ben_prmry_care_prvdr_f.effective_start_date%TYPE;
  l_effective_end_date    ben_prmry_care_prvdr_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  fnd_msg_pub.initialize;
  --
  l_object_version_number := p_object_version_number;

  delete_prmry_care_prvdr
  (
     p_prmry_care_prvdr_id      => p_prmry_care_prvdr_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_object_version_number    => l_object_version_number
    ,p_effective_date           => p_effective_date
    ,p_datetrack_mode           => p_datetrack_mode
  );
  --
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  p_return_status	  := 'S';
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  exception
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location('Exception:'||l_proc, 100);
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    p_return_status	    := 'E';
    fnd_msg_pub.add;
    --
end delete_prmry_care_prvdr_w;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prmry_care_prvdr_id                   in     number
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
  ben_ppr_shd.lck
    (
      p_prmry_care_prvdr_id                 => p_prmry_care_prvdr_id
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
-- ----------------------------------------------------------------------------
-- |-------------------------------< pcp_actn_items >--------------------------
-- ----------------------------------------------------------------------------
--
procedure pcp_actn_items
  (
   p_prtt_enrt_rslt_id              in     number
  ,p_elig_cvrd_dpnt_id              in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_validate                       in     boolean default false
  ,p_datetrack_mode                 in     varchar2
  ) is
--
l_proc varchar2(72) := g_package||'dpnt_actn_items';
l_prtt_enrt_rslt_id   number(15);
l_business_group_id   number(15);
l_rslt_object_version_number number(9);
l_suspend_flag        varchar2(30);
l_pcp_actn_warning   boolean;
l_pcp_dpnt_actn_warning   boolean;
--
cursor get_rslt_id_c is
   select ecd.prtt_enrt_rslt_id,
          ecd.business_group_id
    from ben_elig_cvrd_dpnt_f ecd
    where ecd.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
      and p_effective_date between ecd.effective_start_date
                               and ecd.effective_end_date;
--
cursor get_rslt_ovn_c is
   select pen.object_version_number,
          pen.sspndd_flag
   from   ben_prtt_enrt_rslt_f pen
   where  pen.prtt_enrt_rslt_id = l_prtt_enrt_rslt_id
   and    pen.prtt_enrt_rslt_stat_cd is null
   and    pen.business_group_id = l_business_group_id
   and    p_effective_date
          between pen.effective_start_date and pen.effective_end_date;
--
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   if p_prtt_enrt_rslt_id is null or
      p_business_group_id is null then
      open get_rslt_id_c;
      fetch get_rslt_id_c into l_prtt_enrt_rslt_id,
                               l_business_group_id;
      close get_rslt_id_c;
      if l_prtt_enrt_rslt_id is not null then
         open get_rslt_ovn_c;
         fetch get_rslt_ovn_c into l_rslt_object_version_number,
                               l_suspend_flag;
         close get_rslt_ovn_c;
      end if;
     ben_enrollment_action_items.process_pcp_dpnt_actn_items(
                    p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
                   ,p_rslt_object_version_number => l_rslt_object_version_number
                   ,p_effective_date    => trunc(p_effective_date)
                   ,p_business_group_id => l_business_group_id
                   ,p_validate          => FALSE
                   ,p_datetrack_mode    => p_datetrack_mode
                   ,p_suspend_flag      => l_suspend_flag
                   ,p_pcp_dpnt_actn_warning => l_pcp_dpnt_actn_warning
                   );
   else
      l_prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
      l_business_group_id := p_business_group_id;
      if l_prtt_enrt_rslt_id is not null then
         open get_rslt_ovn_c;
         fetch get_rslt_ovn_c into l_rslt_object_version_number,
                               l_suspend_flag;
         close get_rslt_ovn_c;
      end if;
     ben_enrollment_action_items.process_pcp_actn_items(
                    p_prtt_enrt_rslt_id => l_prtt_enrt_rslt_id
                   ,p_rslt_object_version_number => l_rslt_object_version_number
                   ,p_effective_date    => trunc(p_effective_date)
                   ,p_business_group_id => l_business_group_id
                   ,p_validate          => FALSE
                   ,p_datetrack_mode    => p_datetrack_mode
                   ,p_suspend_flag      => l_suspend_flag
                   ,p_pcp_actn_warning => l_pcp_actn_warning
                   );
   end if;
   --
   --
   hr_utility.set_location('Exiting:'|| l_proc, 40);
   --
  --
end pcp_actn_items;
--
end ben_PRMRY_CARE_PRVDR_api;

/
