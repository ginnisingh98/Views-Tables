--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_DPNT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_DPNT_API" as
/* $Header: beegdapi.pkb 120.11.12010000.5 2009/11/03 09:51:23 sallumwa ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_DPNT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_DPNT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DPNT
  (p_validate                       in  boolean   default false
  ,p_elig_dpnt_id                   out nocopy number
  ,p_create_dt                      in  date      default null
  ,p_elig_strt_dt                   in  date      default null
  ,p_elig_thru_dt                   in  date      default null
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_dpnt_inelig_flag               in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_elig_per_id                    in  number    default null
  ,p_elig_per_opt_id                in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_egd_attribute_category         in  varchar2  default null
  ,p_egd_attribute1                 in  varchar2  default null
  ,p_egd_attribute2                 in  varchar2  default null
  ,p_egd_attribute3                 in  varchar2  default null
  ,p_egd_attribute4                 in  varchar2  default null
  ,p_egd_attribute5                 in  varchar2  default null
  ,p_egd_attribute6                 in  varchar2  default null
  ,p_egd_attribute7                 in  varchar2  default null
  ,p_egd_attribute8                 in  varchar2  default null
  ,p_egd_attribute9                 in  varchar2  default null
  ,p_egd_attribute10                in  varchar2  default null
  ,p_egd_attribute11                in  varchar2  default null
  ,p_egd_attribute12                in  varchar2  default null
  ,p_egd_attribute13                in  varchar2  default null
  ,p_egd_attribute14                in  varchar2  default null
  ,p_egd_attribute15                in  varchar2  default null
  ,p_egd_attribute16                in  varchar2  default null
  ,p_egd_attribute17                in  varchar2  default null
  ,p_egd_attribute18                in  varchar2  default null
  ,p_egd_attribute19                in  varchar2  default null
  ,p_egd_attribute20                in  varchar2  default null
  ,p_egd_attribute21                in  varchar2  default null
  ,p_egd_attribute22                in  varchar2  default null
  ,p_egd_attribute23                in  varchar2  default null
  ,p_egd_attribute24                in  varchar2  default null
  ,p_egd_attribute25                in  varchar2  default null
  ,p_egd_attribute26                in  varchar2  default null
  ,p_egd_attribute27                in  varchar2  default null
  ,p_egd_attribute28                in  varchar2  default null
  ,p_egd_attribute29                in  varchar2  default null
  ,p_egd_attribute30                in  varchar2  default null
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
  l_elig_dpnt_id ben_elig_dpnt.elig_dpnt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_DPNT';
  l_object_version_number ben_elig_dpnt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_DPNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk1.create_ELIG_DPNT_b
      (
       p_create_dt                      =>  p_create_dt
      ,p_elig_strt_dt                   =>  p_elig_strt_dt
      ,p_elig_thru_dt                   =>  p_elig_thru_dt
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_dpnt_inelig_flag               =>  p_dpnt_inelig_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_egd_attribute_category         =>  p_egd_attribute_category
      ,p_egd_attribute1                 =>  p_egd_attribute1
      ,p_egd_attribute2                 =>  p_egd_attribute2
      ,p_egd_attribute3                 =>  p_egd_attribute3
      ,p_egd_attribute4                 =>  p_egd_attribute4
      ,p_egd_attribute5                 =>  p_egd_attribute5
      ,p_egd_attribute6                 =>  p_egd_attribute6
      ,p_egd_attribute7                 =>  p_egd_attribute7
      ,p_egd_attribute8                 =>  p_egd_attribute8
      ,p_egd_attribute9                 =>  p_egd_attribute9
      ,p_egd_attribute10                =>  p_egd_attribute10
      ,p_egd_attribute11                =>  p_egd_attribute11
      ,p_egd_attribute12                =>  p_egd_attribute12
      ,p_egd_attribute13                =>  p_egd_attribute13
      ,p_egd_attribute14                =>  p_egd_attribute14
      ,p_egd_attribute15                =>  p_egd_attribute15
      ,p_egd_attribute16                =>  p_egd_attribute16
      ,p_egd_attribute17                =>  p_egd_attribute17
      ,p_egd_attribute18                =>  p_egd_attribute18
      ,p_egd_attribute19                =>  p_egd_attribute19
      ,p_egd_attribute20                =>  p_egd_attribute20
      ,p_egd_attribute21                =>  p_egd_attribute21
      ,p_egd_attribute22                =>  p_egd_attribute22
      ,p_egd_attribute23                =>  p_egd_attribute23
      ,p_egd_attribute24                =>  p_egd_attribute24
      ,p_egd_attribute25                =>  p_egd_attribute25
      ,p_egd_attribute26                =>  p_egd_attribute26
      ,p_egd_attribute27                =>  p_egd_attribute27
      ,p_egd_attribute28                =>  p_egd_attribute28
      ,p_egd_attribute29                =>  p_egd_attribute29
      ,p_egd_attribute30                =>  p_egd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_DPNT
    --
  end;
  --
  ben_egd_ins.ins
    (
     p_elig_dpnt_id                  => l_elig_dpnt_id
    ,p_create_dt                     => p_create_dt
    ,p_elig_strt_dt                  => p_elig_strt_dt
    ,p_elig_thru_dt                  => p_elig_thru_dt
    ,p_ovrdn_flag                    => p_ovrdn_flag
    ,p_ovrdn_thru_dt                 => p_ovrdn_thru_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_dpnt_inelig_flag              => p_dpnt_inelig_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_elig_per_opt_id               => p_elig_per_opt_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_egd_attribute_category        => p_egd_attribute_category
    ,p_egd_attribute1                => p_egd_attribute1
    ,p_egd_attribute2                => p_egd_attribute2
    ,p_egd_attribute3                => p_egd_attribute3
    ,p_egd_attribute4                => p_egd_attribute4
    ,p_egd_attribute5                => p_egd_attribute5
    ,p_egd_attribute6                => p_egd_attribute6
    ,p_egd_attribute7                => p_egd_attribute7
    ,p_egd_attribute8                => p_egd_attribute8
    ,p_egd_attribute9                => p_egd_attribute9
    ,p_egd_attribute10               => p_egd_attribute10
    ,p_egd_attribute11               => p_egd_attribute11
    ,p_egd_attribute12               => p_egd_attribute12
    ,p_egd_attribute13               => p_egd_attribute13
    ,p_egd_attribute14               => p_egd_attribute14
    ,p_egd_attribute15               => p_egd_attribute15
    ,p_egd_attribute16               => p_egd_attribute16
    ,p_egd_attribute17               => p_egd_attribute17
    ,p_egd_attribute18               => p_egd_attribute18
    ,p_egd_attribute19               => p_egd_attribute19
    ,p_egd_attribute20               => p_egd_attribute20
    ,p_egd_attribute21               => p_egd_attribute21
    ,p_egd_attribute22               => p_egd_attribute22
    ,p_egd_attribute23               => p_egd_attribute23
    ,p_egd_attribute24               => p_egd_attribute24
    ,p_egd_attribute25               => p_egd_attribute25
    ,p_egd_attribute26               => p_egd_attribute26
    ,p_egd_attribute27               => p_egd_attribute27
    ,p_egd_attribute28               => p_egd_attribute28
    ,p_egd_attribute29               => p_egd_attribute29
    ,p_egd_attribute30               => p_egd_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk1.create_ELIG_DPNT_a
      (
       p_elig_dpnt_id                   =>  l_elig_dpnt_id
      ,p_create_dt                      =>  p_create_dt
      ,p_elig_strt_dt                   =>  p_elig_strt_dt
      ,p_elig_thru_dt                   =>  p_elig_thru_dt
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_dpnt_inelig_flag               =>  p_dpnt_inelig_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_egd_attribute_category         =>  p_egd_attribute_category
      ,p_egd_attribute1                 =>  p_egd_attribute1
      ,p_egd_attribute2                 =>  p_egd_attribute2
      ,p_egd_attribute3                 =>  p_egd_attribute3
      ,p_egd_attribute4                 =>  p_egd_attribute4
      ,p_egd_attribute5                 =>  p_egd_attribute5
      ,p_egd_attribute6                 =>  p_egd_attribute6
      ,p_egd_attribute7                 =>  p_egd_attribute7
      ,p_egd_attribute8                 =>  p_egd_attribute8
      ,p_egd_attribute9                 =>  p_egd_attribute9
      ,p_egd_attribute10                =>  p_egd_attribute10
      ,p_egd_attribute11                =>  p_egd_attribute11
      ,p_egd_attribute12                =>  p_egd_attribute12
      ,p_egd_attribute13                =>  p_egd_attribute13
      ,p_egd_attribute14                =>  p_egd_attribute14
      ,p_egd_attribute15                =>  p_egd_attribute15
      ,p_egd_attribute16                =>  p_egd_attribute16
      ,p_egd_attribute17                =>  p_egd_attribute17
      ,p_egd_attribute18                =>  p_egd_attribute18
      ,p_egd_attribute19                =>  p_egd_attribute19
      ,p_egd_attribute20                =>  p_egd_attribute20
      ,p_egd_attribute21                =>  p_egd_attribute21
      ,p_egd_attribute22                =>  p_egd_attribute22
      ,p_egd_attribute23                =>  p_egd_attribute23
      ,p_egd_attribute24                =>  p_egd_attribute24
      ,p_egd_attribute25                =>  p_egd_attribute25
      ,p_egd_attribute26                =>  p_egd_attribute26
      ,p_egd_attribute27                =>  p_egd_attribute27
      ,p_egd_attribute28                =>  p_egd_attribute28
      ,p_egd_attribute29                =>  p_egd_attribute29
      ,p_egd_attribute30                =>  p_egd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_DPNT
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
  p_elig_dpnt_id := l_elig_dpnt_id;
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
    ROLLBACK TO create_ELIG_DPNT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_dpnt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIG_DPNT;
    raise;
    --
end create_ELIG_DPNT;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_perf_ELIG_DPNT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_ELIG_DPNT
  (p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   out nocopy number
  ,p_create_dt                      in  date      default null
  ,p_elig_strt_dt                   in  date      default null
  ,p_elig_thru_dt                   in  date      default null
  ,p_ovrdn_flag                     in  varchar2  default 'N'
  ,p_ovrdn_thru_dt                  in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_dpnt_inelig_flag               in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_elig_per_id                    in  number    default null
  ,p_elig_per_opt_id                in  number    default null
  ,p_elig_cvrd_dpnt_id              in  number    default null
  ,p_dpnt_person_id                 in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_egd_attribute_category         in  varchar2  default null
  ,p_egd_attribute1                 in  varchar2  default null
  ,p_egd_attribute2                 in  varchar2  default null
  ,p_egd_attribute3                 in  varchar2  default null
  ,p_egd_attribute4                 in  varchar2  default null
  ,p_egd_attribute5                 in  varchar2  default null
  ,p_egd_attribute6                 in  varchar2  default null
  ,p_egd_attribute7                 in  varchar2  default null
  ,p_egd_attribute8                 in  varchar2  default null
  ,p_egd_attribute9                 in  varchar2  default null
  ,p_egd_attribute10                in  varchar2  default null
  ,p_egd_attribute11                in  varchar2  default null
  ,p_egd_attribute12                in  varchar2  default null
  ,p_egd_attribute13                in  varchar2  default null
  ,p_egd_attribute14                in  varchar2  default null
  ,p_egd_attribute15                in  varchar2  default null
  ,p_egd_attribute16                in  varchar2  default null
  ,p_egd_attribute17                in  varchar2  default null
  ,p_egd_attribute18                in  varchar2  default null
  ,p_egd_attribute19                in  varchar2  default null
  ,p_egd_attribute20                in  varchar2  default null
  ,p_egd_attribute21                in  varchar2  default null
  ,p_egd_attribute22                in  varchar2  default null
  ,p_egd_attribute23                in  varchar2  default null
  ,p_egd_attribute24                in  varchar2  default null
  ,p_egd_attribute25                in  varchar2  default null
  ,p_egd_attribute26                in  varchar2  default null
  ,p_egd_attribute27                in  varchar2  default null
  ,p_egd_attribute28                in  varchar2  default null
  ,p_egd_attribute29                in  varchar2  default null
  ,p_egd_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  )
is
  --
  l_proc varchar2(72) := g_package||'create_perf_ELIG_DPNT';
  --
  l_old_rec               ben_egd_ler.g_egd_ler_rec;
  l_new_rec               ben_egd_ler.g_egd_ler_rec;
  --
  -- Declare cursors and local variables
  --
  l_elig_dpnt_id          ben_elig_dpnt.elig_dpnt_id%TYPE;
  l_object_version_number ben_elig_dpnt.object_version_number%TYPE;
  --
  l_created_by            ben_elig_dpnt.created_by%TYPE;
  l_creation_date         ben_elig_dpnt.creation_date%TYPE;
  l_last_update_date      ben_elig_dpnt.last_update_date%TYPE;
  l_last_updated_by       ben_elig_dpnt.last_updated_by%TYPE;
  l_last_update_login     ben_elig_dpnt.last_update_login%TYPE;
  --
  Cursor C_Sel1 is select ben_elig_dpnt_s.nextval from sys.dual;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_ELIG_DPNT;
  --
  -- Insert the row
  --
  --   Set the object version number for the insert
  --
  l_object_version_number := 1;
  --
  ben_egd_shd.g_api_dml := true;  -- Set the api dml status
  --
  hr_utility.set_location('Insert EGD: '||l_proc, 5);
  insert into ben_elig_dpnt
  ( elig_dpnt_id,
    create_dt,
    elig_strt_dt,
    elig_thru_dt,
    ovrdn_flag,
    ovrdn_thru_dt,
    inelg_rsn_cd,
    dpnt_inelig_flag,
    elig_per_elctbl_chc_id,
    per_in_ler_id,
    elig_per_id,
    elig_per_opt_id,
    elig_cvrd_dpnt_id,
    dpnt_person_id,
    business_group_id,
    egd_attribute_category,
    egd_attribute1,
    egd_attribute2,
    egd_attribute3,
    egd_attribute4,
    egd_attribute5,
    egd_attribute6,
    egd_attribute7,
    egd_attribute8,
    egd_attribute9,
    egd_attribute10,
    egd_attribute11,
    egd_attribute12,
    egd_attribute13,
    egd_attribute14,
    egd_attribute15,
    egd_attribute16,
    egd_attribute17,
    egd_attribute18,
    egd_attribute19,
    egd_attribute20,
    egd_attribute21,
    egd_attribute22,
    egd_attribute23,
    egd_attribute24,
    egd_attribute25,
    egd_attribute26,
    egd_attribute27,
    egd_attribute28,
    egd_attribute29,
    egd_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number
  )
  Values
  ( ben_elig_dpnt_s.nextval,
    p_create_dt,
    p_elig_strt_dt,
    p_elig_thru_dt,
    p_ovrdn_flag,
    p_ovrdn_thru_dt,
    p_inelg_rsn_cd,
    p_dpnt_inelig_flag,
    p_elig_per_elctbl_chc_id,
    p_per_in_ler_id,
    p_elig_per_id,
    p_elig_per_opt_id,
    p_elig_cvrd_dpnt_id,
    p_dpnt_person_id,
    p_business_group_id,
    p_egd_attribute_category,
    p_egd_attribute1,
    p_egd_attribute2,
    p_egd_attribute3,
    p_egd_attribute4,
    p_egd_attribute5,
    p_egd_attribute6,
    p_egd_attribute7,
    p_egd_attribute8,
    p_egd_attribute9,
    p_egd_attribute10,
    p_egd_attribute11,
    p_egd_attribute12,
    p_egd_attribute13,
    p_egd_attribute14,
    p_egd_attribute15,
    p_egd_attribute16,
    p_egd_attribute17,
    p_egd_attribute18,
    p_egd_attribute19,
    p_egd_attribute20,
    p_egd_attribute21,
    p_egd_attribute22,
    p_egd_attribute23,
    p_egd_attribute24,
    p_egd_attribute25,
    p_egd_attribute26,
    p_egd_attribute27,
    p_egd_attribute28,
    p_egd_attribute29,
    p_egd_attribute30,
    p_request_id,
    p_program_application_id,
    p_program_id,
    p_program_update_date,
    l_object_version_number
  ) RETURNING elig_dpnt_id into l_elig_dpnt_id;
  hr_utility.set_location('Dn Insert: '||l_proc, 5);
  --
  -- Call life event trigger
  --
  l_old_rec.business_group_id := null;
  l_old_rec.dpnt_person_id := null;
  l_old_rec.elig_strt_dt :=null;
  l_old_rec.elig_thru_dt := null;
  l_old_rec.dpnt_inelig_flag := null;
  l_old_rec.ovrdn_thru_dt := null;
  l_old_rec.ovrdn_flag := null;
  l_old_rec.create_dt := null;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.dpnt_person_id := p_dpnt_person_id;
  l_new_rec.elig_strt_dt := p_elig_strt_dt;
  l_new_rec.elig_thru_dt := p_elig_thru_dt;
  l_new_rec.dpnt_inelig_flag := p_dpnt_inelig_flag;
  l_new_rec.ovrdn_thru_dt := p_ovrdn_thru_dt;
  l_new_rec.ovrdn_flag := p_ovrdn_flag;
  l_new_rec.create_dt := p_create_dt;
  l_new_rec.per_in_ler_id := p_per_in_ler_id;  --Bug 5630251
  --
  ben_egd_ler.ler_chk(l_old_rec,l_new_rec,p_effective_date);
  --
  ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_dpnt_id          := l_elig_dpnt_id;
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
    ROLLBACK TO create_perf_ELIG_DPNT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_dpnt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK to create_perf_ELIG_DPNT;
    raise;
    --
end create_perf_ELIG_DPNT;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_DPNT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT
  (p_validate                       in  boolean   default false
  ,p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date      default hr_api.g_date
  ,p_elig_strt_dt                   in  date      default hr_api.g_date
  ,p_elig_thru_dt                   in  date      default hr_api.g_date
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_inelig_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_elig_per_opt_id                in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_egd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_DPNT';
  l_object_version_number ben_elig_dpnt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_DPNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk2.update_ELIG_DPNT_b
      (
       p_elig_dpnt_id                   =>  p_elig_dpnt_id
      ,p_create_dt                      =>  p_create_dt
      ,p_elig_strt_dt                   =>  p_elig_strt_dt
      ,p_elig_thru_dt                   =>  p_elig_thru_dt
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_dpnt_inelig_flag               =>  p_dpnt_inelig_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_egd_attribute_category         =>  p_egd_attribute_category
      ,p_egd_attribute1                 =>  p_egd_attribute1
      ,p_egd_attribute2                 =>  p_egd_attribute2
      ,p_egd_attribute3                 =>  p_egd_attribute3
      ,p_egd_attribute4                 =>  p_egd_attribute4
      ,p_egd_attribute5                 =>  p_egd_attribute5
      ,p_egd_attribute6                 =>  p_egd_attribute6
      ,p_egd_attribute7                 =>  p_egd_attribute7
      ,p_egd_attribute8                 =>  p_egd_attribute8
      ,p_egd_attribute9                 =>  p_egd_attribute9
      ,p_egd_attribute10                =>  p_egd_attribute10
      ,p_egd_attribute11                =>  p_egd_attribute11
      ,p_egd_attribute12                =>  p_egd_attribute12
      ,p_egd_attribute13                =>  p_egd_attribute13
      ,p_egd_attribute14                =>  p_egd_attribute14
      ,p_egd_attribute15                =>  p_egd_attribute15
      ,p_egd_attribute16                =>  p_egd_attribute16
      ,p_egd_attribute17                =>  p_egd_attribute17
      ,p_egd_attribute18                =>  p_egd_attribute18
      ,p_egd_attribute19                =>  p_egd_attribute19
      ,p_egd_attribute20                =>  p_egd_attribute20
      ,p_egd_attribute21                =>  p_egd_attribute21
      ,p_egd_attribute22                =>  p_egd_attribute22
      ,p_egd_attribute23                =>  p_egd_attribute23
      ,p_egd_attribute24                =>  p_egd_attribute24
      ,p_egd_attribute25                =>  p_egd_attribute25
      ,p_egd_attribute26                =>  p_egd_attribute26
      ,p_egd_attribute27                =>  p_egd_attribute27
      ,p_egd_attribute28                =>  p_egd_attribute28
      ,p_egd_attribute29                =>  p_egd_attribute29
      ,p_egd_attribute30                =>  p_egd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_DPNT
    --
  end;
  --
  ben_egd_upd.upd
    (
     p_elig_dpnt_id                  => p_elig_dpnt_id
    ,p_create_dt                     => p_create_dt
    ,p_elig_strt_dt                  => p_elig_strt_dt
    ,p_elig_thru_dt                  => p_elig_thru_dt
    ,p_ovrdn_flag                    => p_ovrdn_flag
    ,p_ovrdn_thru_dt                 => p_ovrdn_thru_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_dpnt_inelig_flag              => p_dpnt_inelig_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_elig_per_opt_id               => p_elig_per_opt_id
    ,p_elig_cvrd_dpnt_id             => p_elig_cvrd_dpnt_id
    ,p_dpnt_person_id                => p_dpnt_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_egd_attribute_category        => p_egd_attribute_category
    ,p_egd_attribute1                => p_egd_attribute1
    ,p_egd_attribute2                => p_egd_attribute2
    ,p_egd_attribute3                => p_egd_attribute3
    ,p_egd_attribute4                => p_egd_attribute4
    ,p_egd_attribute5                => p_egd_attribute5
    ,p_egd_attribute6                => p_egd_attribute6
    ,p_egd_attribute7                => p_egd_attribute7
    ,p_egd_attribute8                => p_egd_attribute8
    ,p_egd_attribute9                => p_egd_attribute9
    ,p_egd_attribute10               => p_egd_attribute10
    ,p_egd_attribute11               => p_egd_attribute11
    ,p_egd_attribute12               => p_egd_attribute12
    ,p_egd_attribute13               => p_egd_attribute13
    ,p_egd_attribute14               => p_egd_attribute14
    ,p_egd_attribute15               => p_egd_attribute15
    ,p_egd_attribute16               => p_egd_attribute16
    ,p_egd_attribute17               => p_egd_attribute17
    ,p_egd_attribute18               => p_egd_attribute18
    ,p_egd_attribute19               => p_egd_attribute19
    ,p_egd_attribute20               => p_egd_attribute20
    ,p_egd_attribute21               => p_egd_attribute21
    ,p_egd_attribute22               => p_egd_attribute22
    ,p_egd_attribute23               => p_egd_attribute23
    ,p_egd_attribute24               => p_egd_attribute24
    ,p_egd_attribute25               => p_egd_attribute25
    ,p_egd_attribute26               => p_egd_attribute26
    ,p_egd_attribute27               => p_egd_attribute27
    ,p_egd_attribute28               => p_egd_attribute28
    ,p_egd_attribute29               => p_egd_attribute29
    ,p_egd_attribute30               => p_egd_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk2.update_ELIG_DPNT_a
      (
       p_elig_dpnt_id                   =>  p_elig_dpnt_id
      ,p_create_dt                      =>  p_create_dt
      ,p_elig_strt_dt                   =>  p_elig_strt_dt
      ,p_elig_thru_dt                   =>  p_elig_thru_dt
      ,p_ovrdn_flag                     =>  p_ovrdn_flag
      ,p_ovrdn_thru_dt                  =>  p_ovrdn_thru_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_dpnt_inelig_flag               =>  p_dpnt_inelig_flag
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_cvrd_dpnt_id              =>  p_elig_cvrd_dpnt_id
      ,p_dpnt_person_id                 =>  p_dpnt_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_egd_attribute_category         =>  p_egd_attribute_category
      ,p_egd_attribute1                 =>  p_egd_attribute1
      ,p_egd_attribute2                 =>  p_egd_attribute2
      ,p_egd_attribute3                 =>  p_egd_attribute3
      ,p_egd_attribute4                 =>  p_egd_attribute4
      ,p_egd_attribute5                 =>  p_egd_attribute5
      ,p_egd_attribute6                 =>  p_egd_attribute6
      ,p_egd_attribute7                 =>  p_egd_attribute7
      ,p_egd_attribute8                 =>  p_egd_attribute8
      ,p_egd_attribute9                 =>  p_egd_attribute9
      ,p_egd_attribute10                =>  p_egd_attribute10
      ,p_egd_attribute11                =>  p_egd_attribute11
      ,p_egd_attribute12                =>  p_egd_attribute12
      ,p_egd_attribute13                =>  p_egd_attribute13
      ,p_egd_attribute14                =>  p_egd_attribute14
      ,p_egd_attribute15                =>  p_egd_attribute15
      ,p_egd_attribute16                =>  p_egd_attribute16
      ,p_egd_attribute17                =>  p_egd_attribute17
      ,p_egd_attribute18                =>  p_egd_attribute18
      ,p_egd_attribute19                =>  p_egd_attribute19
      ,p_egd_attribute20                =>  p_egd_attribute20
      ,p_egd_attribute21                =>  p_egd_attribute21
      ,p_egd_attribute22                =>  p_egd_attribute22
      ,p_egd_attribute23                =>  p_egd_attribute23
      ,p_egd_attribute24                =>  p_egd_attribute24
      ,p_egd_attribute25                =>  p_egd_attribute25
      ,p_egd_attribute26                =>  p_egd_attribute26
      ,p_egd_attribute27                =>  p_egd_attribute27
      ,p_egd_attribute28                =>  p_egd_attribute28
      ,p_egd_attribute29                =>  p_egd_attribute29
      ,p_egd_attribute30                =>  p_egd_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_DPNT
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
    ROLLBACK TO update_ELIG_DPNT;
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
    ROLLBACK TO update_ELIG_DPNT;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_ELIG_DPNT;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_perf_ELIG_DPNT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_ELIG_DPNT
  (
   p_validate                       in boolean    default false
  ,p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date      default hr_api.g_date
  ,p_elig_strt_dt                   in  date      default hr_api.g_date
  ,p_elig_thru_dt                   in  date      default hr_api.g_date
  ,p_ovrdn_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ovrdn_thru_dt                  in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_inelig_flag               in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_elig_per_opt_id                in  number    default hr_api.g_number
  ,p_elig_cvrd_dpnt_id              in  number    default hr_api.g_number
  ,p_dpnt_person_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_egd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_perf_ELIG_DPNT';
  --
  l_old_rec               ben_egd_ler.g_egd_ler_rec;
  l_new_rec               ben_egd_ler.g_egd_ler_rec;
  --
  l_rec                   ben_egd_shd.g_rec_type;
  l_object_version_number ben_elig_dpnt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_perf_ELIG_DPNT;
  --
  l_rec :=
  ben_egd_shd.convert_args
  (
  p_elig_dpnt_id,
  p_create_dt,
  p_elig_strt_dt,
  p_elig_thru_dt,
  p_ovrdn_flag,
  p_ovrdn_thru_dt,
  p_inelg_rsn_cd,
  p_dpnt_inelig_flag,
  p_elig_per_elctbl_chc_id,
  p_per_in_ler_id,
  p_elig_per_id,
  p_elig_per_opt_id,
  p_elig_cvrd_dpnt_id,
  p_dpnt_person_id,
  p_business_group_id,
  p_egd_attribute_category,
  p_egd_attribute1,
  p_egd_attribute2,
  p_egd_attribute3,
  p_egd_attribute4,
  p_egd_attribute5,
  p_egd_attribute6,
  p_egd_attribute7,
  p_egd_attribute8,
  p_egd_attribute9,
  p_egd_attribute10,
  p_egd_attribute11,
  p_egd_attribute12,
  p_egd_attribute13,
  p_egd_attribute14,
  p_egd_attribute15,
  p_egd_attribute16,
  p_egd_attribute17,
  p_egd_attribute18,
  p_egd_attribute19,
  p_egd_attribute20,
  p_egd_attribute21,
  p_egd_attribute22,
  p_egd_attribute23,
  p_egd_attribute24,
  p_egd_attribute25,
  p_egd_attribute26,
  p_egd_attribute27,
  p_egd_attribute28,
  p_egd_attribute29,
  p_egd_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number
  );
  --
  -- We must lock the row which we need to update.
  --
  ben_egd_shd.lck
    (p_elig_dpnt_id          => p_elig_dpnt_id
    ,p_object_version_number => p_object_version_number
    );
  --
  ben_egd_upd.convert_defs(p_rec => l_rec);
  --
  -- Increment object version number
  --
  l_object_version_number := p_object_version_number+1;
  ben_egd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_elig_dpnt Row
  --
  update ben_elig_dpnt
  set
  elig_dpnt_id                      = l_rec.elig_dpnt_id,
  create_dt                         = l_rec.create_dt,
  elig_strt_dt                      = l_rec.elig_strt_dt,
  elig_thru_dt                      = l_rec.elig_thru_dt,
  ovrdn_flag                        = l_rec.ovrdn_flag,
  ovrdn_thru_dt                     = l_rec.ovrdn_thru_dt,
  inelg_rsn_cd                      = l_rec.inelg_rsn_cd,
  dpnt_inelig_flag                  = l_rec.dpnt_inelig_flag,
  elig_per_elctbl_chc_id            = l_rec.elig_per_elctbl_chc_id,
  per_in_ler_id                     = l_rec.per_in_ler_id,
  elig_per_id                       = l_rec.elig_per_id,
  elig_per_opt_id                   = l_rec.elig_per_opt_id,
  elig_cvrd_dpnt_id                 = l_rec.elig_cvrd_dpnt_id,
  dpnt_person_id                    = l_rec.dpnt_person_id,
  business_group_id                 = l_rec.business_group_id,
  egd_attribute_category            = l_rec.egd_attribute_category,
  egd_attribute1                    = l_rec.egd_attribute1,
  egd_attribute2                    = l_rec.egd_attribute2,
  egd_attribute3                    = l_rec.egd_attribute3,
  egd_attribute4                    = l_rec.egd_attribute4,
  egd_attribute5                    = l_rec.egd_attribute5,
  egd_attribute6                    = l_rec.egd_attribute6,
  egd_attribute7                    = l_rec.egd_attribute7,
  egd_attribute8                    = l_rec.egd_attribute8,
  egd_attribute9                    = l_rec.egd_attribute9,
  egd_attribute10                   = l_rec.egd_attribute10,
  egd_attribute11                   = l_rec.egd_attribute11,
  egd_attribute12                   = l_rec.egd_attribute12,
  egd_attribute13                   = l_rec.egd_attribute13,
  egd_attribute14                   = l_rec.egd_attribute14,
  egd_attribute15                   = l_rec.egd_attribute15,
  egd_attribute16                   = l_rec.egd_attribute16,
  egd_attribute17                   = l_rec.egd_attribute17,
  egd_attribute18                   = l_rec.egd_attribute18,
  egd_attribute19                   = l_rec.egd_attribute19,
  egd_attribute20                   = l_rec.egd_attribute20,
  egd_attribute21                   = l_rec.egd_attribute21,
  egd_attribute22                   = l_rec.egd_attribute22,
  egd_attribute23                   = l_rec.egd_attribute23,
  egd_attribute24                   = l_rec.egd_attribute24,
  egd_attribute25                   = l_rec.egd_attribute25,
  egd_attribute26                   = l_rec.egd_attribute26,
  egd_attribute27                   = l_rec.egd_attribute27,
  egd_attribute28                   = l_rec.egd_attribute28,
  egd_attribute29                   = l_rec.egd_attribute29,
  egd_attribute30                   = l_rec.egd_attribute30,
  request_id                        = l_rec.request_id,
  program_application_id            = l_rec.program_application_id,
  program_id                        = l_rec.program_id,
  program_update_date               = l_rec.program_update_date,
  object_version_number             = l_rec.object_version_number
  where elig_dpnt_id = l_rec.elig_dpnt_id;
  --
  -- Call life event trigger
  --
  l_old_rec.business_group_id := ben_egd_shd.g_old_rec.business_group_id;
  l_old_rec.dpnt_person_id := ben_egd_shd.g_old_rec.dpnt_person_id;
  l_old_rec.elig_strt_dt := ben_egd_shd.g_old_rec.elig_strt_dt;
  l_old_rec.elig_thru_dt := ben_egd_shd.g_old_rec.elig_thru_dt;
  l_old_rec.dpnt_inelig_flag := ben_egd_shd.g_old_rec.dpnt_inelig_flag;
  l_old_rec.ovrdn_thru_dt := ben_egd_shd.g_old_rec.ovrdn_thru_dt;
  l_old_rec.ovrdn_flag := ben_egd_shd.g_old_rec.ovrdn_flag;
  l_old_rec.create_dt := ben_egd_shd.g_old_rec.create_dt;
  l_old_rec.per_in_ler_id := ben_egd_shd.g_old_rec.per_in_ler_id;


  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.dpnt_person_id := p_dpnt_person_id;
  l_new_rec.elig_strt_dt := p_elig_strt_dt;
  l_new_rec.elig_thru_dt := p_elig_thru_dt;
  l_new_rec.dpnt_inelig_flag := p_dpnt_inelig_flag;
  l_new_rec.ovrdn_thru_dt := p_ovrdn_thru_dt;
  l_new_rec.ovrdn_flag := p_ovrdn_flag;
  l_new_rec.create_dt := p_create_dt;
  l_new_rec.per_in_ler_id := p_per_in_ler_id; --Bug 5630251
  --
  hr_utility.set_location(' Old per_in_ler_id from api ' || l_old_rec.per_in_ler_id , 9876 );

  ben_egd_ler.ler_chk(l_old_rec,l_new_rec,p_effective_date);
  --
  ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
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
    ROLLBACK TO update_perf_ELIG_DPNT;
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
    ROLLBACK TO update_perf_ELIG_DPNT;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_perf_ELIG_DPNT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_DPNT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT
  (p_validate                       in  boolean  default false
  ,p_elig_dpnt_id                   in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_DPNT';
  l_object_version_number ben_elig_dpnt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_DPNT;
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
    -- Start of API User Hook for the before hook of delete_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk3.delete_ELIG_DPNT_b
      (
       p_elig_dpnt_id                   =>  p_elig_dpnt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_DPNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_DPNT
    --
  end;
  --
  ben_egd_del.del
    (
     p_elig_dpnt_id                  => p_elig_dpnt_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_DPNT
    --
    ben_ELIG_DPNT_bk3.delete_ELIG_DPNT_a
      (
       p_elig_dpnt_id                   =>  p_elig_dpnt_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_DPNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_DPNT
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
    ROLLBACK TO delete_ELIG_DPNT;
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
    ROLLBACK TO delete_ELIG_DPNT;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_ELIG_DPNT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_dpnt_id                   in     number
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
  ben_egd_shd.lck
    (
      p_elig_dpnt_id                 => p_elig_dpnt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_sspnd_if_interim >--------------------------|
-- ----------------------------------------------------------------------------
-- Bug 5486397
function return_sspnd_if_interim (p_interim_pen_id NUMBER,
                                  p_effective_date DATE)
return number
is
  --
  CURSOR c_is_pen_interim (cv_prtt_enrt_rslt_id NUMBER,
                           cv_effective_date    DATE   )
  IS
     SELECT sspndd.prtt_enrt_rslt_id
       FROM ben_prtt_enrt_rslt_f sspndd, ben_prtt_enrt_rslt_f inter
      WHERE inter.prtt_enrt_rslt_id = cv_prtt_enrt_rslt_id
        AND sspndd.rplcs_sspndd_rslt_id = inter.prtt_enrt_rslt_id
        AND sspndd.pl_id = inter.pl_id
        AND NVL (sspndd.pgm_id, -1) = NVL (inter.pgm_id, -1)
        AND sspndd.pl_id = inter.pl_id
        AND NVL (sspndd.oipl_id, -1) = NVL (inter.oipl_id, -1)
        AND sspndd.prtt_enrt_rslt_stat_cd IS NULL
        AND inter.prtt_enrt_rslt_stat_cd IS NULL
        AND inter.enrt_cvg_thru_dt = hr_api.g_eot
        AND sspndd.enrt_cvg_thru_dt = hr_api.g_eot
        and cv_effective_date between sspndd.effective_start_date
                                  and sspndd.effective_end_date
        and cv_effective_date between inter.effective_start_date
                                  and inter.effective_end_date;

  --
  l_sspndd_pen_id number(30);
  --
begin
  --
  -- Similar code exists in BENEDSGB.fmb >> EPE.POST-QUERY. Make changes
  -- at both the places
  hr_utility.set_location('Entering return_sspnd_if_interim', 5);
  open c_is_pen_interim (p_interim_pen_id, p_effective_date);
    --
    fetch c_is_pen_interim into l_sspndd_pen_id;
    --
    if c_is_pen_interim%found
    then
      --
      null;
      --
    else
      --
      l_sspndd_pen_id := p_interim_pen_id;
      --
    end if;
    --
  close c_is_pen_interim;
  --
  hr_utility.set_location('l_sspndd_pen_id = ' || l_sspndd_pen_id, 15);
  hr_utility.set_location('Leaving return_sspnd_if_interim', 10);
  return l_sspndd_pen_id;
  --
end return_sspnd_if_interim;
--
--   Procedure: process_dependent.
--   Purpose  : Used to create/update covered dependent (elig_cvrd_dpnt) record
--              based on eligible dependent record (elig_dpnt).
--   Called from: Called from Dependents form and manage dpnts.(8/25/99)
--
procedure process_dependent(p_validate in boolean default false,
                            p_elig_dpnt_id    in number,
                            p_business_group_id in number,
                            p_effective_date    in date,
                            p_cvg_strt_dt       in date,
                            p_cvg_thru_dt       in date,
                            p_datetrack_mode    in varchar2,
                            p_pdp_attribute_category  in varchar2 default null,
                            p_pdp_attribute1          in varchar2 default null,
                            p_pdp_attribute2          in varchar2 default null,
                            p_pdp_attribute3          in varchar2 default null,
                            p_pdp_attribute4          in varchar2 default null,
                            p_pdp_attribute5          in varchar2 default null,
                            p_pdp_attribute6          in varchar2 default null,
                            p_pdp_attribute7          in varchar2 default null,
                            p_pdp_attribute8          in varchar2 default null,
                            p_pdp_attribute9          in varchar2 default null,
                            p_pdp_attribute10         in varchar2 default null,
                            p_pdp_attribute11         in varchar2 default null,
                            p_pdp_attribute12         in varchar2 default null,
                            p_pdp_attribute13         in varchar2 default null,
                            p_pdp_attribute14         in varchar2 default null,
                            p_pdp_attribute15         in varchar2 default null,
                            p_pdp_attribute16         in varchar2 default null,
                            p_pdp_attribute17         in varchar2 default null,
                            p_pdp_attribute18         in varchar2 default null,
                            p_pdp_attribute19         in varchar2 default null,
                            p_pdp_attribute20         in varchar2 default null,
                            p_pdp_attribute21         in varchar2 default null,
                            p_pdp_attribute22         in varchar2 default null,
                            p_pdp_attribute23         in varchar2 default null,
                            p_pdp_attribute24         in varchar2 default null,
                            p_pdp_attribute25         in varchar2 default null,
                            p_pdp_attribute26         in varchar2 default null,
                            p_pdp_attribute27         in varchar2 default null,
                            p_pdp_attribute28         in varchar2 default null,
                            p_pdp_attribute29         in varchar2 default null,
                            p_pdp_attribute30         in varchar2 default null,
                            p_elig_cvrd_dpnt_id       out nocopy number,
                            p_effective_start_date    out nocopy date,
                            p_effective_end_date      out nocopy date,
                            p_object_version_number   in  out nocopy number
                           ,p_multi_row_actn          in  BOOLEAN default FALSE) is
   --
   cursor c_egd is
      select egd.elig_dpnt_id,
             egd.elig_cvrd_dpnt_id,
             egd.elig_per_elctbl_chc_id,
             egd.dpnt_person_id,
             egd.per_in_ler_id,
             epe.prtt_enrt_rslt_id,
             egd.object_version_number
      from   ben_elig_dpnt egd,
             ben_elig_per_elctbl_chc epe,
             ben_per_in_ler          pil
      where  egd.elig_dpnt_id = p_elig_dpnt_id
      and    egd.business_group_id = p_business_group_id
      and    egd.elig_per_elctbl_chc_id = epe.elig_per_elctbl_chc_id
      and    egd.per_in_ler_id = pil.per_in_ler_id
      and    pil.per_in_ler_stat_cd not in ('BCKDT','VOIDD');
   --
   l_egd_rec   c_egd%rowtype;
   --
   cursor c_pdp is
      select pdp.cvg_strt_dt,
             pdp.cvg_thru_dt,
             pdp.object_version_number,
	     pdp.effective_end_date,  -------Bug 9051021
             pdp.effective_start_date
      from   ben_elig_cvrd_dpnt_f pdp
      where  pdp.elig_cvrd_dpnt_id = l_egd_rec.elig_cvrd_dpnt_id
      and    pdp.prtt_enrt_rslt_id = l_egd_rec.prtt_enrt_rslt_id
      and    pdp.business_group_id = p_business_group_id
      and    p_effective_date between
             pdp.effective_start_date and pdp.effective_end_date;
   --
   l_pdp_rec    c_pdp%rowtype;
   l_egd_found  boolean := false;
   l_pdp_found  boolean := false;
   l_pdp_datetrack_mode varchar2(30);
   l_cvg_thru_dt date;
   l_effective_start_date date;
   l_effective_end_date   date;
   l_object_version_number number := p_object_version_number;
   l_proc varchar2(72) := g_package||'.process_dependent';
   --
begin
   --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint process_dependent;
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
  hr_utility.set_location(l_proc, 15);
  --
   open  c_egd;
   fetch c_egd into l_egd_rec;
   if c_egd%found then
      l_egd_found := true;
   end if;
   close c_egd;
  --
  -- Bug 5486397
  l_egd_rec.prtt_enrt_rslt_id := return_sspnd_if_interim (l_egd_rec.prtt_enrt_rslt_id, p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
   --
   if l_egd_rec.elig_cvrd_dpnt_id is not null then
      --
      hr_utility.set_location(l_proc, 25);
      --
      open  c_pdp;
      fetch c_pdp into l_pdp_rec;
      if c_pdp%found then
         --
         hr_utility.set_location(l_proc, 30);
         --
         l_pdp_found := true;
         --
         if l_pdp_rec.effective_start_date = p_effective_date then
            --
            l_pdp_datetrack_mode := hr_api.g_correction;
            --
         else
            --
            l_pdp_datetrack_mode := p_datetrack_mode;
            --
         end if;
         --
      end if;
      --
      close c_pdp;
      --
      hr_utility.set_location(l_proc, 35);
      --
   end if;
   --
   -- Note: We are making coverge through date as EOT, if it is null.
   --       Take note of this, when looking for cases.
   --
   if p_cvg_thru_dt is null then
      --
      l_cvg_thru_dt := hr_api.g_eot;
      --
   else
      --
      l_cvg_thru_dt := p_cvg_thru_dt;
      --
   end if;
   --
  hr_utility.set_location(l_proc, 40);
  --
  -- Cases start. Each case has their own if statement.
  --
   if not l_egd_found then
      --
      -- Eligible dependent record not found.
      -- ERROR out.
      --
      hr_utility.set_location(l_proc, 45);
      --
      fnd_message.set_name('BEN','BEN_92322_EGD_NOT_FOUND');
      fnd_message.raise_error;
      --
   elsif l_cvg_thru_dt <> hr_api.g_eot and not l_pdp_found then
      --
      -- The Coverage through date is not EOT, it means that the
      -- user is trying to end coverage. But here the covered dependent
      -- record is not found, so we cannot end coverage.
      -- ERROR out.
      --
      hr_utility.set_location(l_proc, 50);
      --
      fnd_message.set_name('BEN','BEN_92323_CVG_CANNOT_BE_ENDED');
      fnd_message.raise_error;
      --
   elsif l_pdp_found and (l_cvg_thru_dt <> hr_api.g_eot
                          or p_cvg_strt_dt is null) then
      --
      -- The coverage through date is not EOT or the coverage start date
      -- is null. In both the case, the user is trying to end the coverage
      -- for the dependent. As the covered dependent record is found,
      -- we continue with the processing.
      --
      hr_utility.set_location(l_proc, 55);
      --
      if p_effective_date > l_pdp_rec.cvg_strt_dt  then
         --
         -- Coverage has started, so we cannot delete it. Just update
         -- the record with the coverage through date and the per_in_ler_id.
         --
         hr_utility.set_location(l_proc, 60);
         --
         ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
           p_elig_cvrd_dpnt_id         => l_egd_rec.elig_cvrd_dpnt_id,
           p_effective_start_date      => p_effective_start_date,
           p_effective_end_date        => p_effective_end_date,
           p_per_in_ler_id             => l_egd_rec.per_in_ler_id,
           p_cvg_thru_dt               => l_cvg_thru_dt,
           p_object_version_number     => l_pdp_rec.object_version_number,
           p_datetrack_mode            => l_pdp_datetrack_mode,
           p_multi_row_actn            => p_multi_row_actn,
           p_pdp_attribute_category    =>  p_pdp_attribute_category,
           p_pdp_attribute1            =>  p_pdp_attribute1,
           p_pdp_attribute2            =>  p_pdp_attribute2,
           p_pdp_attribute3            =>  p_pdp_attribute3,
           p_pdp_attribute4            =>  p_pdp_attribute4,
           p_pdp_attribute5            =>  p_pdp_attribute5,
           p_pdp_attribute6            =>  p_pdp_attribute6,
           p_pdp_attribute7            =>  p_pdp_attribute7,
           p_pdp_attribute8            =>  p_pdp_attribute8,
           p_pdp_attribute9            =>  p_pdp_attribute9,
           p_pdp_attribute10           =>  p_pdp_attribute10,
           p_pdp_attribute11           =>  p_pdp_attribute11,
           p_pdp_attribute12           =>  p_pdp_attribute12,
           p_pdp_attribute13           =>  p_pdp_attribute13,
           p_pdp_attribute14           =>  p_pdp_attribute14,
           p_pdp_attribute15           =>  p_pdp_attribute15,
           p_pdp_attribute16           =>  p_pdp_attribute16,
           p_pdp_attribute17           =>  p_pdp_attribute17,
           p_pdp_attribute18           =>  p_pdp_attribute18,
           p_pdp_attribute19           =>  p_pdp_attribute19,
           p_pdp_attribute20           =>  p_pdp_attribute20,
           p_pdp_attribute21           =>  p_pdp_attribute21,
           p_pdp_attribute22           =>  p_pdp_attribute22,
           p_pdp_attribute23           =>  p_pdp_attribute23,
           p_pdp_attribute24           =>  p_pdp_attribute24,
           p_pdp_attribute25           =>  p_pdp_attribute25,
           p_pdp_attribute26           =>  p_pdp_attribute26,
           p_pdp_attribute27           =>  p_pdp_attribute27,
           p_pdp_attribute28           =>  p_pdp_attribute28,
           p_pdp_attribute29           =>  p_pdp_attribute29,
           p_pdp_attribute30           =>  p_pdp_attribute30,
           p_request_id                => fnd_global.conc_request_id,
           p_program_application_id    => fnd_global.prog_appl_id,
           p_program_id                => fnd_global.conc_program_id,
           p_program_update_date       => sysdate,
           p_business_group_id         => p_business_group_id,
           p_effective_date            => p_effective_date);
         --
         p_elig_cvrd_dpnt_id     := l_egd_rec.elig_cvrd_dpnt_id;
         p_object_version_number := l_pdp_rec.object_version_number;
         --
      else
         --
         -- Coverage has not started, so purge the record.
         -- Remove the link from eligible dependent record.
         --
         hr_utility.set_location(l_proc, 65);
         --
         ben_elig_cvrd_dpnt_api.delete_elig_cvrd_dpnt(
           p_elig_cvrd_dpnt_id     => l_egd_rec.elig_cvrd_dpnt_id,
           p_effective_start_date  => l_effective_start_date,
           p_effective_end_date    => l_effective_end_date,
           p_object_version_number => l_pdp_rec.object_version_number,
           p_business_group_id     => p_business_group_id,
           p_effective_date        => p_effective_date,
           p_datetrack_mode        => hr_api.g_zap,
           p_multi_row_actn        => true,
           p_called_from           => 'beegdapi' );
         --
         ben_elig_dpnt_api.update_elig_dpnt(
            p_elig_dpnt_id          => p_elig_dpnt_id,
            p_elig_cvrd_dpnt_id     => null,
            p_effective_date        => p_effective_date,
            p_business_group_id     => p_business_group_id,
            p_object_version_number => l_egd_rec.object_version_number,
            p_program_application_id => fnd_global.prog_appl_id,
            p_program_id             => fnd_global.conc_program_id,
            p_request_id             => fnd_global.conc_request_id,
            p_program_update_date    => sysdate);
         --
         p_elig_cvrd_dpnt_id     := null;
         p_object_version_number := null;
         p_effective_start_date  := null;
         p_effective_end_date    := null;
         --
      end if;
      --
   elsif /* l_pdp_found and
         p_effective_date between
         l_pdp_rec.cvg_strt_dt and l_pdp_rec.cvg_thru_dt then
         */
      --
      -- Bug 3138982 if we remove a dependent accidentally and the
      -- coverage end date code is in the past like one day before event
      -- we dont come into this clause with the above condition and we try
      -- to create a new pdp records which will result in 91651 error.
      -- We need to look at the new coverage start date also.
      --
      l_pdp_found and
      ((p_effective_date between
       l_pdp_rec.cvg_strt_dt and l_pdp_rec.cvg_thru_dt) OR
       ( p_effective_date >=l_pdp_rec.effective_start_date and
         p_cvg_strt_dt    = l_pdp_rec.cvg_strt_dt) or
       (p_effective_date between
       l_pdp_rec.effective_start_date and l_pdp_rec.effective_end_date and       -----Bug 9051021
        l_pdp_rec.effective_end_date = hr_api.g_eot and
	l_pdp_rec.cvg_strt_dt between
	l_pdp_rec.effective_start_date and l_pdp_rec.effective_end_date and
	l_pdp_rec.cvg_thru_dt = hr_api.g_eot)) then

      --
      -- As we have reached here, it means the coverge through date is EOT,
      -- and hence we are not trying to de-enroll the dependent.
      -- As coverage has started and we are within the coverage period,
      -- we can re-open the covered dependent record and use it.
      -- Update the record the coverage through date as EOT and the
      -- new per in ler id.
      --
      hr_utility.set_location(l_proc, 70);
      --
      ben_elig_cvrd_dpnt_api.update_elig_cvrd_dpnt(
           p_elig_cvrd_dpnt_id         => l_egd_rec.elig_cvrd_dpnt_id,
           p_effective_start_date      => p_effective_start_date,
           p_effective_end_date        => p_effective_end_date,
           p_per_in_ler_id             => l_egd_rec.per_in_ler_id,
           p_cvg_strt_dt               => p_cvg_strt_dt, -- 3453213
           p_cvg_thru_dt               => hr_api.g_eot,
           p_object_version_number     => l_pdp_rec.object_version_number,
           p_datetrack_mode            => l_pdp_datetrack_mode,
           p_multi_row_actn            => p_multi_row_actn,
           p_pdp_attribute_category    =>  p_pdp_attribute_category,
           p_pdp_attribute1            =>  p_pdp_attribute1,
           p_pdp_attribute2            =>  p_pdp_attribute2,
           p_pdp_attribute3            =>  p_pdp_attribute3,
           p_pdp_attribute4            =>  p_pdp_attribute4,
           p_pdp_attribute5            =>  p_pdp_attribute5,
           p_pdp_attribute6            =>  p_pdp_attribute6,
           p_pdp_attribute7            =>  p_pdp_attribute7,
           p_pdp_attribute8            =>  p_pdp_attribute8,
           p_pdp_attribute9            =>  p_pdp_attribute9,
           p_pdp_attribute10           =>  p_pdp_attribute10,
           p_pdp_attribute11           =>  p_pdp_attribute11,
           p_pdp_attribute12           =>  p_pdp_attribute12,
           p_pdp_attribute13           =>  p_pdp_attribute13,
           p_pdp_attribute14           =>  p_pdp_attribute14,
           p_pdp_attribute15           =>  p_pdp_attribute15,
           p_pdp_attribute16           =>  p_pdp_attribute16,
           p_pdp_attribute17           =>  p_pdp_attribute17,
           p_pdp_attribute18           =>  p_pdp_attribute18,
           p_pdp_attribute19           =>  p_pdp_attribute19,
           p_pdp_attribute20           =>  p_pdp_attribute20,
           p_pdp_attribute21           =>  p_pdp_attribute21,
           p_pdp_attribute22           =>  p_pdp_attribute22,
           p_pdp_attribute23           =>  p_pdp_attribute23,
           p_pdp_attribute24           =>  p_pdp_attribute24,
           p_pdp_attribute25           =>  p_pdp_attribute25,
           p_pdp_attribute26           =>  p_pdp_attribute26,
           p_pdp_attribute27           =>  p_pdp_attribute27,
           p_pdp_attribute28           =>  p_pdp_attribute28,
           p_pdp_attribute29           =>  p_pdp_attribute29,
           p_pdp_attribute30           =>  p_pdp_attribute30,
           p_request_id                => fnd_global.conc_request_id,
           p_program_application_id    => fnd_global.prog_appl_id,
           p_program_id                => fnd_global.conc_program_id,
           p_program_update_date       => sysdate,
           p_business_group_id         => p_business_group_id,
           p_effective_date            => p_effective_date);
      --
      p_elig_cvrd_dpnt_id     := l_egd_rec.elig_cvrd_dpnt_id;
      p_object_version_number := l_pdp_rec.object_version_number;
      --
   elsif p_cvg_strt_dt is not null then
      --
      -- Now the only left case, I could think of. But most important.
      -- Here we are trying to enroll the dependent for whom no covered
      -- dependent records were found and it needs to be created.
      -- Create the covered dependent record with the coverage start date
      -- and coverge through date.
      -- Update the eligible dependent record with the covered dependent id.
      --
      hr_utility.set_location(l_proc, 75);
      --
      ben_elig_cvrd_dpnt_api.create_elig_cvrd_dpnt
          (p_elig_cvrd_dpnt_id         => p_elig_cvrd_dpnt_id,
           p_effective_start_date      => p_effective_start_date,
           p_effective_end_date        => p_effective_end_date,
           p_business_group_id         => p_business_group_id,
           p_dpnt_person_id            => l_egd_rec.dpnt_person_id,
           p_per_in_ler_id             => l_egd_rec.per_in_ler_id,
           p_cvg_strt_dt               => p_cvg_strt_dt,
           p_cvg_thru_dt               => hr_api.g_eot,
           p_prtt_enrt_rslt_id         => l_egd_rec.prtt_enrt_rslt_id,
           p_object_version_number     => p_object_version_number,
           p_effective_date            => p_effective_date,
           p_multi_row_actn            => p_multi_row_actn,
           p_pdp_attribute_category    =>  p_pdp_attribute_category,
           p_pdp_attribute1            =>  p_pdp_attribute1,
           p_pdp_attribute2            =>  p_pdp_attribute2,
           p_pdp_attribute3            =>  p_pdp_attribute3,
           p_pdp_attribute4            =>  p_pdp_attribute4,
           p_pdp_attribute5            =>  p_pdp_attribute5,
           p_pdp_attribute6            =>  p_pdp_attribute6,
           p_pdp_attribute7            =>  p_pdp_attribute7,
           p_pdp_attribute8            =>  p_pdp_attribute8,
           p_pdp_attribute9            =>  p_pdp_attribute9,
           p_pdp_attribute10           =>  p_pdp_attribute10,
           p_pdp_attribute11           =>  p_pdp_attribute11,
           p_pdp_attribute12           =>  p_pdp_attribute12,
           p_pdp_attribute13           =>  p_pdp_attribute13,
           p_pdp_attribute14           =>  p_pdp_attribute14,
           p_pdp_attribute15           =>  p_pdp_attribute15,
           p_pdp_attribute16           =>  p_pdp_attribute16,
           p_pdp_attribute17           =>  p_pdp_attribute17,
           p_pdp_attribute18           =>  p_pdp_attribute18,
           p_pdp_attribute19           =>  p_pdp_attribute19,
           p_pdp_attribute20           =>  p_pdp_attribute20,
           p_pdp_attribute21           =>  p_pdp_attribute21,
           p_pdp_attribute22           =>  p_pdp_attribute22,
           p_pdp_attribute23           =>  p_pdp_attribute23,
           p_pdp_attribute24           =>  p_pdp_attribute24,
           p_pdp_attribute25           =>  p_pdp_attribute25,
           p_pdp_attribute26           =>  p_pdp_attribute26,
           p_pdp_attribute27           =>  p_pdp_attribute27,
           p_pdp_attribute28           =>  p_pdp_attribute28,
           p_pdp_attribute29           =>  p_pdp_attribute29,
           p_pdp_attribute30           =>  p_pdp_attribute30,
           p_program_application_id    => fnd_global.prog_appl_id,
           p_program_id                => fnd_global.conc_program_id,
           p_request_id                => fnd_global.conc_request_id,
           p_program_update_date       => sysdate);
      --
      ben_elig_dpnt_api.update_elig_dpnt(
         p_elig_dpnt_id          => p_elig_dpnt_id,
         p_elig_cvrd_dpnt_id     => p_elig_cvrd_dpnt_id,
         p_effective_date        => p_effective_date,
         p_business_group_id     => p_business_group_id,
         p_object_version_number => l_egd_rec.object_version_number,
         p_program_application_id => fnd_global.prog_appl_id,
         p_program_id             => fnd_global.conc_program_id,
         p_request_id             => fnd_global.conc_request_id,
         p_program_update_date    => sysdate);
      --
   end if;
   --
   -- End of cases.
   --
   hr_utility.set_location('Leaving '||l_proc, 75);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO process_dependent;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO process_dependent;
    /* Inserted for nocopy changes */
    p_elig_cvrd_dpnt_id := null;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end process_dependent;
--
--   Procedure: process_dependent_w.
--   Purpose  : Used as a self service wrapper
--   Called from: self service dependents selection screen
--
procedure process_dependent_w(p_validate                in varchar2,
                            p_elig_dpnt_id            in number,
                            p_business_group_id       in number,
                            p_effective_date          in date,
                            p_cvg_strt_dt             in date,
                            p_cvg_thru_dt             in date,
                            p_datetrack_mode          in varchar2,
                            p_elig_cvrd_dpnt_id       out nocopy number,
                            p_effective_start_date    out nocopy date,
                            p_effective_end_date      out nocopy date,
                            p_object_version_number   in  out nocopy number
                           ,p_multi_row_actn          in  varchar2)
IS

   l_proc varchar2(72) := g_package||'.process_dependent - wrapper';

   l_object_version_number number;
   l_elig_cvrd_dpnt_id     number;
   l_effective_start_date  date;
   l_effective_end_date    date;

   l_validate       BOOLEAN;
   l_multi_row_actn BOOLEAN;
   --
begin
   --
  fnd_msg_pub.initialize;
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint process_dependent_w;
  --
  if fnd_global.conc_request_id in (0,-1) then
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
  hr_utility.set_location(l_proc, 20);
  --
  if upper(p_validate) = 'TRUE'
  then
    l_validate := TRUE;
  else
    l_validate := FALSE;
  end if;

  if upper(p_multi_row_actn) = 'TRUE'
  then
    l_multi_row_actn := TRUE;
  else
    l_multi_row_actn := FALSE;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  process_dependent(
     p_validate              => l_validate
    ,p_elig_dpnt_id          => p_elig_dpnt_id
    ,p_business_group_id     => p_business_group_id
    ,p_effective_date        => p_effective_date
    ,p_cvg_strt_dt           => p_cvg_strt_dt
    ,p_cvg_thru_dt           => p_cvg_thru_dt
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_elig_cvrd_dpnt_id     => l_elig_cvrd_dpnt_id
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date
    ,p_object_version_number => p_object_version_number
    ,p_multi_row_actn        => l_multi_row_actn);
  --
  if l_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_cvrd_dpnt_id     := l_elig_cvrd_dpnt_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);

exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO process_dependent_w;
  when app_exception.application_exception then	--Bug 4387247
    ROLLBACK TO process_dependent_w;
    fnd_msg_pub.add;
    --Bug 4436578
    /* Inserted for nocopy changes */
    p_elig_cvrd_dpnt_id := null;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    hr_utility.set_location(' Exception in :'||l_proc, 100);
    --Bug 4387247
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add; -- bug fix 4111762
    ROLLBACK TO process_dependent_w;
    /* Inserted for nocopy changes */
    p_elig_cvrd_dpnt_id := null;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
end process_dependent_w;
--
--   Bug 4114970
--   Procedure: store_crt_ord_warning_ss.
--   Purpose  : Used by self service to store court order warnings
--   Called from: self service dependents selection screen
--
procedure store_crt_ord_warning_ss(p_person_id        in number,
                                   p_crt_ord_warning  in varchar2) is
     l_proc varchar2(72) := g_package||'.store_crt_ord_warning_ss';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
	--
	if p_person_id is not null and p_crt_ord_warning is not null then
		if p_crt_ord_warning = 'CLEAR' then
			DELETE ben_online_warnings
			WHERE session_id = p_person_id;
		else
			INSERT INTO ben_online_warnings(session_id, message_text)
			VALUES (p_person_id, p_crt_ord_warning);
		end if;
	end if;
	--
  hr_utility.set_location('Leaving'|| l_proc, 20);
exception
  when others then
    --
    -- An unexpected error has occured
    --
    hr_utility.set_location(' Exception in :'||l_proc, 100);
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
end store_crt_ord_warning_ss;
--
--   Bug 4114970
--   Procedure: store_crt_ord_warng_DDNA.
--   DDNA => Dependent Designation Not Allowed (plan-options)
--
--   Purpose  : Used by self service to store court order warnings for those plan-options
--              in which dependent designation is not allowed e.g. emp only option.
--   NOTE : This procedure serves similar purpose in SS as bepenrhi.crt_ordr_warning in PUI
--   So care should be taken to keep them in functional sync.
--
--   Called from: self service dependents selection screen
--
procedure store_crt_ord_warng_DDNA(p_person_id             in number,
                                   p_per_in_ler_id         in number,
                                   p_pgm_id                in number,
                                   p_effective_date        in date,
                                   p_business_group_id     in number)
is
  --
  cursor c_crt_ordr_DDNA is
    SELECT pen.person_id,
           pln.pl_id,
    	     typ.pl_typ_id,
    	     (typ.name || ' - ' || pln.name) comp_obj_name
    FROM   ben_prtt_enrt_rslt_f      pen,
           ben_pl_f                  pln,
           ben_pl_typ_f              typ,
           ben_elig_per_elctbl_chc   chc
    WHERE  chc.per_in_ler_id          = p_per_in_ler_id
    AND    chc.pgm_id                 = p_pgm_id
    AND    chc.alws_dpnt_dsgn_flag    = 'N'
    AND    pen.prtt_enrt_rslt_id      = chc.prtt_enrt_rslt_id
    AND    pen.prtt_enrt_rslt_stat_cd IS NULL
    AND    p_effective_date between pen.effective_start_date
                            and     pen.effective_end_date
    AND    pen.enrt_cvg_thru_dt = hr_api.g_eot
    AND    pen.pl_id = pln.pl_id
    AND    pln.pl_stat_cd             = 'A'
    AND    pln.svgs_pl_flag           <> 'Y'
    AND    pln.alws_qmcso_flag        = 'Y'
    AND    p_effective_date between pln.effective_start_date
                            and     pln.effective_end_date
    AND    pln.pl_typ_id = typ.pl_typ_id
    AND    p_effective_date between typ.effective_start_date
                            and     typ.effective_end_date
    AND    EXISTS(SELECT null
                  FROM   ben_crt_ordr crt,
    			               ben_per_in_ler pil
                  WHERE  crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
                  AND    crt.person_id = pen.person_id
                  AND    (crt.pl_id = pln.pl_id or crt.pl_typ_id = typ.pl_typ_id)
                  AND    crt.business_group_id = p_business_group_id
                  AND    pil.per_in_ler_id = pen.per_in_ler_id
                  AND    greatest(pen.enrt_cvg_strt_dt, pil.lf_evt_ocrd_dt)
                                             between greatest(nvl(crt.apls_perd_strtg_dt, p_effective_date)
                                                             ,nvl(crt.detd_qlfd_ordr_dt, crt.apls_perd_strtg_dt)
                                                             )
                                                 and nvl(crt.apls_perd_endg_dt, pen.enrt_cvg_thru_dt)
                          )
    AND NOT EXISTS
       (SELECT 1
        FROM ben_prtt_enrt_rslt_f pen2
        where pen2.rplcs_sspndd_rslt_id = pen.prtt_enrt_rslt_id
        and   pen2.sspndd_flag = 'Y'
        and   pen2.prtt_enrt_rslt_stat_cd is null
        and   p_effective_date between
              pen2.effective_start_date and pen2.effective_end_date
        and   pen2.enrt_cvg_thru_dt = hr_api.g_eot);
  --
	l_comp_obj_list         varchar2(2000) := null;
	l_proc                  varchar2(72) := g_package||'.store_crt_ord_warng_DDNA';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  for l_results in c_crt_ordr_DDNA loop
    if l_comp_obj_list is null then
      l_comp_obj_list := l_results.comp_obj_name;
    else
      l_comp_obj_list := l_comp_obj_list || ' , ' || l_results.comp_obj_name;
    end if;
  end loop;

  if l_comp_obj_list is not null then
    fnd_message.set_name('BEN', 'BEN_94486_CRT_ORD_WARNING_DDNA');
    fnd_message.set_token('PARAM', l_comp_obj_list);

    INSERT INTO ben_online_warnings(session_id, message_text)
    VALUES (p_person_id, fnd_message.get);
  end if;
  --
  hr_utility.set_location('Leaving'|| l_proc, 20);
exception
  when others then
    --
    -- An unexpected error has occured
    --
    hr_utility.set_location(' Exception in :'||l_proc, 100);
    fnd_message.set_name('PER','FFU10_GENERAL_ORACLE_ERROR');
    fnd_message.set_token('2',substr(sqlerrm,1,200));
    fnd_msg_pub.add;
end store_crt_ord_warng_DDNA;
--
--
-- Function to get the eligible dependent record.
--
function get_elig_dpnt_rec(p_elig_dpnt_id  in number,
                           p_elig_dpnt_rec out nocopy ben_elig_dpnt%rowtype)
return boolean is
  --
  cursor c_egd is
     select egd.*
     from   ben_elig_dpnt egd
     where  egd.elig_dpnt_id = p_elig_dpnt_id;
  --
  l_proc varchar2(72) := g_package||'get_elig_dpnt_rec_1';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open  c_egd;
  fetch c_egd into p_elig_dpnt_rec;
  --
  if c_egd%notfound then
     --
     close c_egd;
     return false;
     --
  else
     --
     close c_egd;
     return true;
     --
  end if;
  --
end get_elig_dpnt_rec;
--
--
-- Function to get the eligible dependent record for a covered dependent.
--
function get_elig_dpnt_rec(p_elig_cvrd_dpnt_id  in number,
                           p_effective_date     in date,
                           p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype)
return boolean is
  --
  cursor c_pdp is
     select egd.*
     from   ben_elig_dpnt egd,
            ben_elig_cvrd_dpnt_f pdp,
            ben_per_in_ler       pil
     where  pdp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
     and    pdp.per_in_ler_id = egd.per_in_ler_id
     and    pdp.elig_cvrd_dpnt_id = egd.elig_cvrd_dpnt_id
     and    pdp.dpnt_person_id = egd.dpnt_person_id
     and    pdp.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and    p_effective_date between
            pdp.cvg_strt_dt and pdp.cvg_thru_dt
            --- Fido fix medged by tilak # 2931919
     and    pdp.cvg_thru_dt <= pdp.effective_end_date ;
  --
  l_proc varchar2(72) := g_package||'get_elig_dpnt_rec_2';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open  c_pdp;
  fetch c_pdp into p_elig_dpnt_rec;
  --
  if c_pdp%notfound then
     --
     close c_pdp;
     return false;
     --
  else
     --
     close c_pdp;
     return true;
     --
  end if;
  --
end get_elig_dpnt_rec;
--
--
-- Function to get the eligible dependent record for a dependent
-- and enrollment result.
--
function get_elig_dpnt_rec(p_dpnt_person_id  in number,
                           p_prtt_enrt_rslt_id     in number,
                           p_effective_date        in date,
                           p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype)
return boolean is
  --
  cursor c_pen is
     select egd.*
     from   ben_elig_dpnt egd,
            ben_elig_cvrd_dpnt_f pdp,
            ben_prtt_enrt_rslt_f pen,
            ben_per_in_ler       pil
     where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and    pdp.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
     and    pdp.dpnt_person_id = p_dpnt_person_id
     and    pdp.per_in_ler_id = egd.per_in_ler_id
     and    pdp.elig_cvrd_dpnt_id = egd.elig_cvrd_dpnt_id
     and    pdp.dpnt_person_id = egd.dpnt_person_id
     and    pdp.per_in_ler_id = pil.per_in_ler_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
     and    p_effective_date between
            pen.effective_start_date and pen.effective_end_date
     and    p_effective_date between
            pdp.cvg_strt_dt and pdp.cvg_thru_dt;
  --
  l_proc varchar2(72) := g_package||'get_elig_dpnt_rec_3';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  open  c_pen;
  fetch c_pen into p_elig_dpnt_rec;
  --
  if c_pen%notfound then
     --
     close c_pen;
     return false;
     --
  else
     --
     close c_pen;
     return true;
     --
  end if;
  --
end get_elig_dpnt_rec;
--
-- Function to get the eligible dependent record for a dependent person
-- and comp. object (combination of pgm/pl/oipl).
--
function get_elig_dpnt_rec
  (p_pgm_id          in     number default null
  ,p_pl_id           in     number default null
  ,p_oipl_id         in     number default null
  ,p_dpnt_person_id  in     number
  ,p_effective_date  in     date
  --
  ,p_per_in_ler_id   in     number default null
  ,p_elig_per_id     in     number default null
  ,p_elig_per_opt_id in     number default null
  ,p_opt_id          in     number default null
  --
  ,p_elig_dpnt_rec      out nocopy ben_elig_dpnt%rowtype
  )
return boolean
is
  --
  l_pep_id_va benutils.g_number_table := benutils.g_number_table();
  l_epo_id_va benutils.g_number_table := benutils.g_number_table();
  --
  cursor c_eligdpnt_exists
  is
     select null
     from   ben_elig_dpnt egd
     where  egd.dpnt_person_id = p_dpnt_person_id;
  --
  cursor c_oipl_max_create_dt
    (c_dpnt_person_id in   number
    ,c_effective_date in   date
    ,c_oipl_id        in   number
    ,c_pgm_id         in   number
    )
  is
     select egd.elig_dpnt_id
     from   ben_elig_dpnt egd,
            ben_elig_per_opt_f epo,
            ben_elig_per_f pep,
            ben_per_in_ler pil,
            ben_oipl_f oipl
     where  egd.dpnt_person_id  = c_dpnt_person_id
     and    egd.elig_per_opt_id = epo.elig_per_opt_id
     and    egd.elig_per_id     = epo.elig_per_id
     and    c_effective_date between
            epo.effective_start_date and epo.effective_end_date
     and    epo.elig_per_id     = pep.elig_per_id
     and    c_effective_date between
            pep.effective_start_date and pep.effective_end_date
     and    oipl.pl_id = pep.pl_id
     and    c_effective_date between
            oipl.effective_start_date and oipl.effective_end_date
     and    oipl.oipl_id = c_oipl_id
     and    oipl.opt_id = epo.opt_id
     and    nvl(pep.pgm_id, -1) = c_pgm_id
     and    egd.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     order by egd.create_dt desc;
  --
  cursor c_pl_max_create_dt
    (c_dpnt_person_id number
    ,c_pl_id          number
    ,c_pgm_id         number
    ,c_effective_date date
    )
  is
     select egd.elig_dpnt_id
     from   ben_elig_dpnt egd,
            ben_per_in_ler pil,
            ben_elig_per_f pep
     where  egd.dpnt_person_id = c_dpnt_person_id
     and    egd.elig_per_opt_id is null
     and    egd.elig_per_id = pep.elig_per_id
     and    pep.pl_id = c_pl_id
     and    nvl(pep.pgm_id, -1) = nvl(c_pgm_id, -1)
     and    egd.per_in_ler_id = pil.per_in_ler_id
     and    pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
     and    c_effective_date
       between pep.effective_start_date and pep.effective_end_date
     order by egd.create_dt desc;
  --
  cursor c_pilepodets
    (c_effective_date in   date
    ,c_per_in_ler_id  in   number
    ,c_pl_id          in   number
    ,c_opt_id         in   number
    ,c_pgm_id         in   number
    )
  is
    select epo.elig_per_opt_id,
           epo.elig_per_id
    from   ben_elig_per_opt_f epo,
           ben_elig_per_f pep
    where  epo.per_in_ler_id = c_per_in_ler_id
    and    c_effective_date between
           epo.effective_start_date and epo.effective_end_date
    and    epo.elig_per_id     = pep.elig_per_id
    and    c_effective_date between
           pep.effective_start_date and pep.effective_end_date
      and    pep.pl_id = c_pl_id
      and    epo.opt_id = c_opt_id
    and    nvl(pep.pgm_id, -1) = c_pgm_id;
  --
  cursor c_epoegddets
    (c_elig_per_opt_id in   number
    ,c_elig_per_id     in   number
    ,c_dpnt_person_id  in   number
    ,c_pil_id          in   number
    )
  is
    select egd.elig_dpnt_id
    from   ben_elig_dpnt egd
    where  egd.elig_per_opt_id = c_elig_per_opt_id
    and    egd.elig_per_id = c_elig_per_id
    and    egd.dpnt_person_id = c_dpnt_person_id
    and    egd.per_in_ler_id = c_pil_id
    order by egd.create_dt desc;
  --
  cursor c_pepegddets
    (c_elig_per_id     in   number
    ,c_dpnt_person_id  in   number
    ,c_pil_id          in   number
    )
  is
    select egd.elig_dpnt_id
    from   ben_elig_dpnt egd
    where  egd.elig_per_id = c_elig_per_id
    and    egd.elig_per_opt_id is null
    and    egd.dpnt_person_id = c_dpnt_person_id
    and    egd.per_in_ler_id  = c_pil_id;
  --
  l_elig_dpnt_id     ben_elig_dpnt.elig_dpnt_id%type := null;
  l_return boolean    := false;
  l_proc varchar2(72) := g_package||'get_elig_dpnt_rec_4';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  -- Check if the elig dependent exists
  --
  open  c_eligdpnt_exists;
  fetch c_eligdpnt_exists into l_elig_dpnt_id;
  --
  if c_eligdpnt_exists%found then
    --
    if p_oipl_id is not null then
      --
      -- Currently only supported from benmngle where PIL ID is passed.
      -- This logic was added because of severe performance for customers
      -- with enormous amounts of eligible rows.
      --
      if p_per_in_ler_id is not null
      then
        --
        -- Check if the PEP ID and EPO ID are set from benmngle
        --
        if p_elig_per_id is not null
          and p_elig_per_opt_id is not null
        then
          --
          -- Set the PEPID and EPOID to the value passed from benmngle
          --
          l_pep_id_va.extend(1);
          l_pep_id_va(1) := p_elig_per_id;
          --
          l_epo_id_va.extend(1);
          l_epo_id_va(1) := p_elig_per_opt_id;
          --
        else
          --
          -- When eligibility for the current PILID is found then use the
          -- performant code. However if for some special cases no current
          -- eligibility rows are found for the comp object then revert to the
          -- original unperformant cursor.
          --
          hr_utility.set_location(l_proc, 20);
          open c_pilepodets
            (c_effective_date => p_effective_date
            ,c_per_in_ler_id  => p_per_in_ler_id
            ,c_pl_id          => p_pl_id
            ,c_opt_id         => p_opt_id
            ,c_pgm_id         => nvl(p_pgm_id, -1)
            );
          fetch c_pilepodets BULK COLLECT INTO l_epo_id_va, l_pep_id_va;
          close c_pilepodets;
          --
        end if;
        --
        if l_epo_id_va.count > 0 then
          --
          for epoelenum in l_epo_id_va.first..l_epo_id_va.last
          loop
            --
            open c_epoegddets
              (c_elig_per_opt_id => l_epo_id_va(epoelenum)
              ,c_elig_per_id     => l_pep_id_va(epoelenum)
              ,c_dpnt_person_id  => p_dpnt_person_id
              ,c_pil_id          => p_per_in_ler_id
              );
            fetch c_epoegddets into l_elig_dpnt_id;
            if c_epoegddets%notfound then
              --
              l_elig_dpnt_id := null;
              --
            end if;
            close c_epoegddets;
            --
          end loop;
          --
        else
          --
          open c_oipl_max_create_dt
            (c_dpnt_person_id => p_dpnt_person_id
            ,c_effective_date => p_effective_date
            ,c_oipl_id        => p_oipl_id
            ,c_pgm_id         => nvl(p_pgm_id, -1)
            );
          fetch c_oipl_max_create_dt into l_elig_dpnt_id;
          close c_oipl_max_create_dt;
          --
        end if;
        --
        hr_utility.set_location(l_proc, 25);
        --
      else
        --
        hr_utility.set_location(l_proc, 21);
        open c_oipl_max_create_dt
          (c_dpnt_person_id => p_dpnt_person_id
          ,c_effective_date => p_effective_date
          ,c_oipl_id        => p_oipl_id
          ,c_pgm_id         => nvl(p_pgm_id, -1)
          );
        fetch c_oipl_max_create_dt into l_elig_dpnt_id;
        close c_oipl_max_create_dt;
        hr_utility.set_location(l_proc, 26);
        --
      end if;
      --
    else
      --
      -- When the PEP ID and PIL ID are set fire the performant SQL
      --
      if p_elig_per_id is not null
        and p_per_in_ler_id is not null
      then
        --
        open c_pepegddets
          (c_elig_per_id    => p_elig_per_id
          ,c_dpnt_person_id => p_dpnt_person_id
          ,c_pil_id         => p_per_in_ler_id
          );
        fetch c_pepegddets into l_elig_dpnt_id;
        close c_pepegddets;
        --
      else
        --
        open c_pl_max_create_dt
          (c_dpnt_person_id => p_dpnt_person_id
          ,c_pl_id          => p_pl_id
          ,c_pgm_id         => p_pgm_id
          ,c_effective_date => p_effective_date
          );
        fetch c_pl_max_create_dt into l_elig_dpnt_id;
        close c_pl_max_create_dt;
        --
      end if;
      hr_utility.set_location(l_proc, 30);
      --
    end if;
    --
  end if;
  --
  close c_eligdpnt_exists;
  --
  if l_elig_dpnt_id is not null then
     --
     hr_utility.set_location(l_proc, 40);
     --
     l_return := get_elig_dpnt_rec(p_elig_dpnt_id => l_elig_dpnt_id,
                                   p_elig_dpnt_rec => p_elig_dpnt_rec);
     --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 10);
  --
  return l_return;
  --
end get_elig_dpnt_rec;
--
-- Procedure to obtain the eligible person id's for a participant
-- and the comp. object (combination of pgm/pl/oipl).
--
procedure get_elig_per_id(p_person_id in number,
                          p_pgm_id    in number default null,
                          p_pl_id     in number default null,
                          p_oipl_id   in number default null,
                          p_business_group_id in number,
                          p_effective_date    in date,
                          p_elig_per_id       out nocopy number,
                          p_elig_per_opt_id   out nocopy number) is
   --
   cursor c_oipl is
      select epo.elig_per_id,
             epo.elig_per_opt_id
      from   ben_elig_per_opt_f epo,
             ben_elig_per_f     pep,
             ben_oipl_f         oipl
      where  oipl.oipl_id = p_oipl_id
      and    pep.pl_id = oipl.pl_id
      and    pep.pgm_id = nvl(p_pgm_id, pep.pgm_id)
      and    pep.person_id = p_person_id
      and    pep.business_group_id = p_business_group_id
      and    oipl.opt_id = epo.opt_id
      and    epo.elig_per_id = pep.elig_per_id
      and    pep.elig_flag = 'Y'
      and    epo.elig_flag = 'Y'
      and    p_effective_date between
             oipl.effective_start_date and oipl.effective_end_date
      and    p_effective_date between
             pep.effective_start_date and pep.effective_end_date
      and    p_effective_date between
             epo.effective_start_date and epo.effective_end_date;
   --
   cursor c_pl is
      select pep.elig_per_id
      from   ben_elig_per_f     pep
      where  pep.pl_id = p_pl_id
      and    pep.pgm_id = nvl(p_pgm_id, pep.pgm_id)
      and    pep.person_id = p_person_id
      and    pep.business_group_id = p_business_group_id
      and    pep.elig_flag = 'Y'
      and    p_effective_date between
             pep.effective_start_date and pep.effective_end_date;
   --
   l_proc varchar2(72) := g_package||'get_elig_per_id';
   --
begin
   --
   hr_utility.set_location('Entering '||l_proc, 10);
   --
   p_elig_per_id     := null;
   p_elig_per_opt_id := null;
   --
   if p_oipl_id is not null then
      --
      hr_utility.set_location(l_proc, 20);
      --
      open c_oipl;
      fetch c_oipl into p_elig_per_id, p_elig_per_opt_id;
      close c_oipl;
      --
   else
      --
      hr_utility.set_location(l_proc, 30);
      --
      open c_pl;
      fetch c_pl into p_elig_per_id;
      close c_pl;
      --
   end if;
   --
   hr_utility.set_location('Leaving '||l_proc, 10);
   --
end get_elig_per_id;
--
-- Bug No 4931912
-- Function to return the court order type defined for a person.
--
procedure get_crt_ordr_typ(p_person_id in number,
			   p_pl_id in number,
			   p_pl_typ_id in number,
			   l_crt_ordr_meaning out nocopy varchar2)
IS
cursor get_crt_ordr_typ
      is SELECT crt.CRT_ORDR_TYP_CD
            FROM ben_crt_ordr crt
              WHERE crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
               AND crt.person_id = p_person_id
               AND crt.pl_id = p_pl_id or crt.pl_typ_id = p_pl_typ_id;

   l_crt_ordr_typ_cd       VARCHAR2(30);
begin
  open get_crt_ordr_typ;
  fetch get_crt_ordr_typ into l_crt_ordr_typ_cd;
  close get_crt_ordr_typ;
  l_crt_ordr_meaning := hr_general.decode_lookup
                       (p_lookup_type                 => 'BEN_CRT_ORDR_TYP',
                        p_lookup_code                 => l_crt_ordr_typ_cd
                       );
end get_crt_ordr_typ;
--


/* Added procedure for Bug 8414373  */
procedure chk_enrt_for_dpnt
  (
   p_dpnt_person_id                   in  number
  ,p_dpnt_rltp_id                in  number
  ,p_rltp_type                   in varchar2
  ,p_business_group_id              in number
  ) is

  cursor c_chk_enrt  (c_rltp_start_date date,c_rltp_end_date date) is
    select 'Y' from ben_elig_cvrd_dpnt_f ecd,
	ben_prtt_enrt_rslt_f pen,
	ben_per_in_ler pil
	where ecd.dpnt_person_id = p_dpnt_person_id
	and ecd.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
	and pen.prtt_enrt_rslt_stat_cd is null
	and ecd.per_in_ler_id = pil.per_in_ler_id
	and pil.per_in_ler_stat_cd in ('PROCD','STRTD')
	and ecd.cvg_thru_dt >= ecd.cvg_strt_dt
	and ecd.cvg_strt_dt between c_rltp_start_date and c_rltp_end_date
	and pen.business_group_id = p_business_group_id
	and pil.business_group_id = p_business_group_id
	and ecd.business_group_id = p_business_group_id;

   cursor c_rltp is
   select * from per_contact_relationships
   where contact_person_id = p_dpnt_person_id
   and contact_relationship_id = p_dpnt_rltp_id;

  l_dpnt_rltp_row c_rltp%rowtype;

  l_proc varchar2(72) := g_package||'chk_enrt_for_dpnt';
  l_flag varchar2(2);
  l_rltp_start_date date;
  l_rltp_end_date date;
  begin
        hr_utility.set_location('Entering '||l_proc, 10);
        open c_rltp;
        fetch c_rltp into l_dpnt_rltp_row;
        close c_rltp;

        if(l_dpnt_rltp_row.date_start is not null and l_dpnt_rltp_row.personal_flag = 'Y' and (p_rltp_type <> l_dpnt_rltp_row.contact_type) ) then
	        hr_utility.set_location('Date not null ', 10);
		open c_chk_enrt(l_dpnt_rltp_row.date_start,nvl(l_dpnt_rltp_row.date_end,hr_api.g_eot));
		fetch c_chk_enrt into l_flag;
		if(c_chk_enrt%found) then
		  hr_utility.set_location('Enrollment Rec exists for Dep ', 10);
		  fnd_message.set_name('BEN','BEN_94714_RELATION_TYP_UPD');
		  fnd_message.raise_error;
		   --raise error message;
		end if;
		close c_chk_enrt;
        end if;
	hr_utility.set_location('Leaving '||l_proc, 10);
  end chk_enrt_for_dpnt;

end ben_ELIG_DPNT_api;

/
