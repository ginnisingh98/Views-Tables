--------------------------------------------------------
--  DDL for Package Body BEN_PEN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEN_UPD" as
/* $Header: bepenrhi.pkb 120.21.12010000.2 2008/08/05 15:11:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pen_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
    (p_rec 			 in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date	 in	date,
     p_datetrack_mode	 in	varchar2,
     p_validation_start_date in	date,
     p_validation_end_date	 in	date) is
--
  l_proc	varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
      (p_base_table_name	=> 'ben_prtt_enrt_rslt_f',
       p_base_key_column	=> 'prtt_enrt_rslt_id',
       p_base_key_value	    => p_rec.prtt_enrt_rslt_id);
    --
    ben_pen_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_prtt_enrt_rslt_f Row
    --
    update  ben_prtt_enrt_rslt_f
    set
    prtt_enrt_rslt_id               = p_rec.prtt_enrt_rslt_id,
    business_group_id               = p_rec.business_group_id,
    oipl_id                         = p_rec.oipl_id,
    person_id                       = p_rec.person_id,
    assignment_id                   = p_rec.assignment_id,
    pgm_id                          = p_rec.pgm_id,
    pl_id                           = p_rec.pl_id,
    rplcs_sspndd_rslt_id            = p_rec.rplcs_sspndd_rslt_id,
    ptip_id                         = p_rec.ptip_id,
    pl_typ_id                       = p_rec.pl_typ_id,
    ler_id                          = p_rec.ler_id,
    sspndd_flag                     = p_rec.sspndd_flag,
    prtt_is_cvrd_flag               = p_rec.prtt_is_cvrd_flag,
    bnft_amt                        = p_rec.bnft_amt,
    uom                             = p_rec.uom     ,
    orgnl_enrt_dt                   = p_rec.orgnl_enrt_dt,
    enrt_mthd_cd                    = p_rec.enrt_mthd_cd,
    no_lngr_elig_flag               = p_rec.no_lngr_elig_flag,
    enrt_ovridn_flag                = p_rec.enrt_ovridn_flag,
    enrt_ovrid_rsn_cd               = p_rec.enrt_ovrid_rsn_cd,
    erlst_deenrt_dt                 = p_rec.erlst_deenrt_dt,
    enrt_cvg_strt_dt                = p_rec.enrt_cvg_strt_dt,
    enrt_cvg_thru_dt                = p_rec.enrt_cvg_thru_dt,
    enrt_ovrid_thru_dt              = p_rec.enrt_ovrid_thru_dt,
    pl_ordr_num                     = p_rec.pl_ordr_num,
    plip_ordr_num                   = p_rec.plip_ordr_num,
    ptip_ordr_num                   = p_rec.ptip_ordr_num,
    oipl_ordr_num                   = p_rec.oipl_ordr_num,
    pen_attribute_category          = p_rec.pen_attribute_category,
    pen_attribute1                  = p_rec.pen_attribute1,
    pen_attribute2                  = p_rec.pen_attribute2,
    pen_attribute3                  = p_rec.pen_attribute3,
    pen_attribute4                  = p_rec.pen_attribute4,
    pen_attribute5                  = p_rec.pen_attribute5,
    pen_attribute6                  = p_rec.pen_attribute6,
    pen_attribute7                  = p_rec.pen_attribute7,
    pen_attribute8                  = p_rec.pen_attribute8,
    pen_attribute9                  = p_rec.pen_attribute9,
    pen_attribute10                 = p_rec.pen_attribute10,
    pen_attribute11                 = p_rec.pen_attribute11,
    pen_attribute12                 = p_rec.pen_attribute12,
    pen_attribute13                 = p_rec.pen_attribute13,
    pen_attribute14                 = p_rec.pen_attribute14,
    pen_attribute15                 = p_rec.pen_attribute15,
    pen_attribute16                 = p_rec.pen_attribute16,
    pen_attribute17                 = p_rec.pen_attribute17,
    pen_attribute18                 = p_rec.pen_attribute18,
    pen_attribute19                 = p_rec.pen_attribute19,
    pen_attribute20                 = p_rec.pen_attribute20,
    pen_attribute21                 = p_rec.pen_attribute21,
    pen_attribute22                 = p_rec.pen_attribute22,
    pen_attribute23                 = p_rec.pen_attribute23,
    pen_attribute24                 = p_rec.pen_attribute24,
    pen_attribute25                 = p_rec.pen_attribute25,
    pen_attribute26                 = p_rec.pen_attribute26,
    pen_attribute27                 = p_rec.pen_attribute27,
    pen_attribute28                 = p_rec.pen_attribute28,
    pen_attribute29                 = p_rec.pen_attribute29,
    pen_attribute30                 = p_rec.pen_attribute30,
    request_id                      = p_rec.request_id,
    program_application_id          = p_rec.program_application_id,
    program_id                      = p_rec.program_id,
    program_update_date             = p_rec.program_update_date,
    object_version_number           = p_rec.object_version_number,
    per_in_ler_id                   = p_rec.per_in_ler_id,
    bnft_typ_cd                     = p_rec.bnft_typ_cd,
    bnft_ordr_num                   = p_rec.bnft_ordr_num,
    prtt_enrt_rslt_stat_cd          = p_rec.prtt_enrt_rslt_stat_cd,
    bnft_nnmntry_uom                = p_rec.bnft_nnmntry_uom,
    comp_lvl_cd                     = p_rec.comp_lvl_cd
    where   prtt_enrt_rslt_id = p_rec.prtt_enrt_rslt_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pen_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pen_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pen_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
    (p_rec 			         in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date	     in	    date,
     p_datetrack_mode	     in	    varchar2,
     p_validation_start_date in	    date,
     p_validation_end_date	 in	    date) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			    => p_rec,
            p_effective_date	    => p_effective_date,
            p_datetrack_mode	    => p_datetrack_mode,
       		p_validation_start_date	=> p_validation_start_date,
            p_validation_end_date	=> p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--	the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details..
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
    (p_rec 			         in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date	     in	    date,
     p_datetrack_mode	     in	    varchar2,
     p_validation_start_date in	    date,
     p_validation_end_date	 in	    date) is
--
  l_proc	         varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    -- 3843657: When PEN record is date-track VOID-ed,
    -- both the new and old records' prtt_enrt_rslt_stat_cd is set to VOIDD.
    --
    if (p_rec.prtt_enrt_rslt_stat_cd = 'VOIDD' /* or
        p_rec.prtt_enrt_rslt_stat_cd = 'BCKDT' */ ) then
        --
        ben_pen_shd.upd_effective_end_date
         (p_effective_date	       => p_effective_date,
          p_base_key_value	       => p_rec.prtt_enrt_rslt_id,
          p_new_effective_end_date => (p_validation_start_date - 1),
          p_validation_start_date  => p_validation_start_date,
          p_validation_end_date    => p_validation_end_date,
          p_prtt_enrt_rslt_stat_cd   => p_rec.prtt_enrt_rslt_stat_cd,
          p_object_version_number  => l_dummy_version_number);
        -- 3843657 Ends
        --
    else
        --
        ben_pen_shd.upd_effective_end_date
         (p_effective_date	       => p_effective_date,
          p_base_key_value	       => p_rec.prtt_enrt_rslt_id,
          p_new_effective_end_date => (p_validation_start_date - 1),
          p_validation_start_date  => p_validation_start_date,
          p_validation_end_date    => p_validation_end_date,
          p_object_version_number  => l_dummy_version_number);
        --
     end if;
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_pen_del.delete_dml
        (p_rec			         => p_rec,
         p_effective_date	     => p_effective_date,
         p_datetrack_mode	     => p_datetrack_mode,
         p_validation_start_date => p_validation_start_date,
         p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_pen_ins.insert_dml
      (p_rec			        => p_rec,
       p_effective_date		    => p_effective_date,
       p_datetrack_mode		    => p_datetrack_mode,
       p_validation_start_date	=> p_validation_start_date,
       p_validation_end_date	=> p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
    (p_rec 			         in out nocopy ben_pen_shd.g_rec_type,
     p_effective_date	     in	    date,
     p_datetrack_mode	     in	    varchar2,
     p_validation_start_date in	    date,
     p_validation_end_date	 in	    date) is
--
  cursor c1 is
   select elig_per_elctbl_chc_id, object_version_number
   from ben_elig_per_elctbl_chc
   where prtt_enrt_rslt_id = p_rec.prtt_enrt_rslt_id;

  l_chc_id number := null;
  l_chc_ovn number := null;

  l_proc	varchar2(72) := g_package||'pre_update';
  l_rowid       varchar2(72);
  l_esd         date;
  l_eed         date;
--
cursor csr_rowid is
select rowid, effective_start_date, effective_end_date
from ben_prtt_enrt_rslt_f
where prtt_enrt_rslt_id = p_rec.prtt_enrt_rslt_id
and p_effective_date between
effective_start_date and effective_end_date;

cursor csr_rowid_u is
select rowid
from ben_prtt_enrt_rslt_f
where prtt_enrt_rslt_id = p_rec.prtt_enrt_rslt_id
and p_effective_date -1 between
effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_rec.enrt_cvg_strt_dt >
     nvl(p_rec.enrt_cvg_thru_dt, p_rec.enrt_cvg_strt_dt)
     and NVL(p_rec.prtt_enrt_rslt_stat_cd,'VOIDD') <> 'BCKDT' then -- BUG 4739922 / 5360430
     p_rec.prtt_enrt_rslt_stat_cd := 'VOIDD';
  end if;

  if p_rec.prtt_enrt_rslt_stat_cd = 'VOIDD' or
     p_rec.prtt_enrt_rslt_stat_cd = 'BCKDT' then
    open c1;
    fetch c1 into l_chc_id, l_chc_ovn;
    close c1;
    if l_chc_id is not null then
      ben_ELIG_PER_ELC_CHC_api.update_ELIG_PER_ELC_CHC
        (p_validate                => FALSE
        ,p_elig_per_elctbl_chc_id  => l_chc_id
        ,p_prtt_enrt_rslt_id       => NULL
        ,p_object_version_number   => l_chc_ovn
        ,p_effective_date          => p_effective_date
        );
    end if;
  end if;

  dt_pre_update
    (p_rec 		             => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  --
  if p_datetrack_mode <> 'CORRECTION' then
     open csr_rowid_u;
     fetch csr_rowid_u into l_rowid;
     close csr_rowid_u;
     l_esd := p_rec.effective_start_date;
     l_eed := p_rec.effective_end_date;
  else
    open csr_rowid;
    fetch csr_rowid into l_rowid, l_esd, l_eed;
    close csr_rowid;
 end if;
  --
  hr_utility.set_location(' pen rhi esd:'||p_rec.effective_start_date, 10);
  hr_utility.set_location(' pen rhi eed:'||p_rec.effective_end_date, 10);
  hr_utility.set_location(' pen rhi l_esd:'||l_esd, 10);
  hr_utility.set_location(' pen rhi l_eed:'||l_eed, 10);

 ben_dt_trgr_handle.prtt_enrt_rslt
    (p_rowid                 => l_rowid
    ,p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_person_id             => p_rec.person_id
    ,p_enrt_cvg_strt_dt      => p_rec.enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt      => p_rec.enrt_cvg_thru_dt
    ,p_bnft_amt              => p_rec.bnft_amt
    ,p_effective_start_date  => l_esd
    ,p_effective_end_date    => l_eed
    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
    (p_rec 			         in ben_pen_shd.g_rec_type,
     p_effective_date	     in date,
     p_datetrack_mode	     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    ben_pen_rku.after_update
      (
  p_prtt_enrt_rslt_id         =>p_rec.prtt_enrt_rslt_id
 ,p_effective_start_date      =>p_rec.effective_start_date
 ,p_effective_end_date        =>p_rec.effective_end_date
 ,p_business_group_id         =>p_rec.business_group_id
 ,p_oipl_id                   =>p_rec.oipl_id
 ,p_person_id                 =>p_rec.person_id
 ,p_assignment_id             =>p_rec.assignment_id
 ,p_pgm_id                    =>p_rec.pgm_id
 ,p_pl_id                     =>p_rec.pl_id
 ,p_rplcs_sspndd_rslt_id      =>p_rec.rplcs_sspndd_rslt_id
 ,p_ptip_id                   =>p_rec.ptip_id
 ,p_pl_typ_id                 =>p_rec.pl_typ_id
 ,p_ler_id                    =>p_rec.ler_id
 ,p_sspndd_flag               =>p_rec.sspndd_flag
 ,p_prtt_is_cvrd_flag         =>p_rec.prtt_is_cvrd_flag
 ,p_bnft_amt                  =>p_rec.bnft_amt
 ,p_uom                       =>p_rec.uom
 ,p_orgnl_enrt_dt             =>p_rec.orgnl_enrt_dt
 ,p_enrt_mthd_cd              =>p_rec.enrt_mthd_cd
 ,p_no_lngr_elig_flag         =>p_rec.no_lngr_elig_flag
 ,p_enrt_ovridn_flag          =>p_rec.enrt_ovridn_flag
 ,p_enrt_ovrid_rsn_cd         =>p_rec.enrt_ovrid_rsn_cd
 ,p_erlst_deenrt_dt           =>p_rec.erlst_deenrt_dt
 ,p_enrt_cvg_strt_dt          =>p_rec.enrt_cvg_strt_dt
 ,p_enrt_cvg_thru_dt          =>p_rec.enrt_cvg_thru_dt
 ,p_enrt_ovrid_thru_dt        =>p_rec.enrt_ovrid_thru_dt
 ,p_pl_ordr_num               =>p_rec.pl_ordr_num
 ,p_plip_ordr_num             =>p_rec.plip_ordr_num
 ,p_ptip_ordr_num             =>p_rec.ptip_ordr_num
 ,p_oipl_ordr_num             =>p_rec.oipl_ordr_num
 ,p_pen_attribute_category    =>p_rec.pen_attribute_category
 ,p_pen_attribute1            =>p_rec.pen_attribute1
 ,p_pen_attribute2            =>p_rec.pen_attribute2
 ,p_pen_attribute3            =>p_rec.pen_attribute3
 ,p_pen_attribute4            =>p_rec.pen_attribute4
 ,p_pen_attribute5            =>p_rec.pen_attribute5
 ,p_pen_attribute6            =>p_rec.pen_attribute6
 ,p_pen_attribute7            =>p_rec.pen_attribute7
 ,p_pen_attribute8            =>p_rec.pen_attribute8
 ,p_pen_attribute9            =>p_rec.pen_attribute9
 ,p_pen_attribute10           =>p_rec.pen_attribute10
 ,p_pen_attribute11           =>p_rec.pen_attribute11
 ,p_pen_attribute12           =>p_rec.pen_attribute12
 ,p_pen_attribute13           =>p_rec.pen_attribute13
 ,p_pen_attribute14           =>p_rec.pen_attribute14
 ,p_pen_attribute15           =>p_rec.pen_attribute15
 ,p_pen_attribute16           =>p_rec.pen_attribute16
 ,p_pen_attribute17           =>p_rec.pen_attribute17
 ,p_pen_attribute18           =>p_rec.pen_attribute18
 ,p_pen_attribute19           =>p_rec.pen_attribute19
 ,p_pen_attribute20           =>p_rec.pen_attribute20
 ,p_pen_attribute21           =>p_rec.pen_attribute21
 ,p_pen_attribute22           =>p_rec.pen_attribute22
 ,p_pen_attribute23           =>p_rec.pen_attribute23
 ,p_pen_attribute24           =>p_rec.pen_attribute24
 ,p_pen_attribute25           =>p_rec.pen_attribute25
 ,p_pen_attribute26           =>p_rec.pen_attribute26
 ,p_pen_attribute27           =>p_rec.pen_attribute27
 ,p_pen_attribute28           =>p_rec.pen_attribute28
 ,p_pen_attribute29           =>p_rec.pen_attribute29
 ,p_pen_attribute30           =>p_rec.pen_attribute30
 ,p_request_id                =>p_rec.request_id
 ,p_program_application_id    =>p_rec.program_application_id
 ,p_program_id                =>p_rec.program_id
 ,p_program_update_date       =>p_rec.program_update_date
 ,p_object_version_number     =>p_rec.object_version_number
 ,p_per_in_ler_id             =>p_rec.per_in_ler_id
 ,p_bnft_typ_cd               =>p_rec.bnft_typ_cd
 ,p_bnft_ordr_num             =>p_rec.bnft_ordr_num
 ,p_prtt_enrt_rslt_stat_cd    =>p_rec.prtt_enrt_rslt_stat_cd
 ,p_bnft_nnmntry_uom          =>p_rec.bnft_nnmntry_uom
 ,p_comp_lvl_cd               =>p_rec.comp_lvl_cd
 ,p_effective_date            =>p_effective_date
 ,p_datetrack_mode            =>p_datetrack_mode
 ,p_validation_start_date     =>p_validation_start_date
 ,p_validation_end_date       =>p_validation_end_date
 ,p_effective_start_date_o    =>ben_pen_shd.g_old_rec.effective_start_date
 ,p_effective_end_date_o      =>ben_pen_shd.g_old_rec.effective_end_date
 ,p_business_group_id_o       =>ben_pen_shd.g_old_rec.business_group_id
 ,p_oipl_id_o                 =>ben_pen_shd.g_old_rec.oipl_id
 ,p_person_id_o               =>ben_pen_shd.g_old_rec.person_id
 ,p_assignment_id_o           =>ben_pen_shd.g_old_rec.assignment_id
 ,p_pgm_id_o                  =>ben_pen_shd.g_old_rec.pgm_id
 ,p_pl_id_o                   =>ben_pen_shd.g_old_rec.pl_id
 ,p_rplcs_sspndd_rslt_id_o    =>ben_pen_shd.g_old_rec.rplcs_sspndd_rslt_id
 ,p_ptip_id_o                 =>ben_pen_shd.g_old_rec.ptip_id
 ,p_pl_typ_id_o               =>ben_pen_shd.g_old_rec.pl_typ_id
 ,p_ler_id_o                  =>ben_pen_shd.g_old_rec.ler_id
 ,p_sspndd_flag_o             =>ben_pen_shd.g_old_rec.sspndd_flag
 ,p_prtt_is_cvrd_flag_o       =>ben_pen_shd.g_old_rec.prtt_is_cvrd_flag
 ,p_bnft_amt_o                =>ben_pen_shd.g_old_rec.bnft_amt
 ,p_uom_o                     =>ben_pen_shd.g_old_rec.uom
 ,p_orgnl_enrt_dt_o           =>ben_pen_shd.g_old_rec.orgnl_enrt_dt
 ,p_enrt_mthd_cd_o            =>ben_pen_shd.g_old_rec.enrt_mthd_cd
 ,p_no_lngr_elig_flag_o       =>ben_pen_shd.g_old_rec.no_lngr_elig_flag
 ,p_enrt_ovridn_flag_o        =>ben_pen_shd.g_old_rec.enrt_ovridn_flag
 ,p_enrt_ovrid_rsn_cd_o       =>ben_pen_shd.g_old_rec.enrt_ovrid_rsn_cd
 ,p_erlst_deenrt_dt_o         =>ben_pen_shd.g_old_rec.erlst_deenrt_dt
 ,p_enrt_cvg_strt_dt_o        =>ben_pen_shd.g_old_rec.enrt_cvg_strt_dt
 ,p_enrt_cvg_thru_dt_o        =>ben_pen_shd.g_old_rec.enrt_cvg_thru_dt
 ,p_enrt_ovrid_thru_dt_o      =>ben_pen_shd.g_old_rec.enrt_ovrid_thru_dt
 ,p_pl_ordr_num_o             =>ben_pen_shd.g_old_rec.pl_ordr_num
 ,p_plip_ordr_num_o           =>ben_pen_shd.g_old_rec.plip_ordr_num
 ,p_ptip_ordr_num_o           =>ben_pen_shd.g_old_rec.ptip_ordr_num
 ,p_oipl_ordr_num_o           =>ben_pen_shd.g_old_rec.oipl_ordr_num
 ,p_pen_attribute_category_o  =>ben_pen_shd.g_old_rec.pen_attribute_category
 ,p_pen_attribute1_o          =>ben_pen_shd.g_old_rec.pen_attribute1
 ,p_pen_attribute2_o          =>ben_pen_shd.g_old_rec.pen_attribute2
 ,p_pen_attribute3_o          =>ben_pen_shd.g_old_rec.pen_attribute3
 ,p_pen_attribute4_o          =>ben_pen_shd.g_old_rec.pen_attribute4
 ,p_pen_attribute5_o          =>ben_pen_shd.g_old_rec.pen_attribute5
 ,p_pen_attribute6_o          =>ben_pen_shd.g_old_rec.pen_attribute6
 ,p_pen_attribute7_o          =>ben_pen_shd.g_old_rec.pen_attribute7
 ,p_pen_attribute8_o          =>ben_pen_shd.g_old_rec.pen_attribute8
 ,p_pen_attribute9_o          =>ben_pen_shd.g_old_rec.pen_attribute9
 ,p_pen_attribute10_o         =>ben_pen_shd.g_old_rec.pen_attribute10
 ,p_pen_attribute11_o         =>ben_pen_shd.g_old_rec.pen_attribute11
 ,p_pen_attribute12_o         =>ben_pen_shd.g_old_rec.pen_attribute12
 ,p_pen_attribute13_o         =>ben_pen_shd.g_old_rec.pen_attribute13
 ,p_pen_attribute14_o         =>ben_pen_shd.g_old_rec.pen_attribute14
 ,p_pen_attribute15_o         =>ben_pen_shd.g_old_rec.pen_attribute15
 ,p_pen_attribute16_o         =>ben_pen_shd.g_old_rec.pen_attribute16
 ,p_pen_attribute17_o         =>ben_pen_shd.g_old_rec.pen_attribute17
 ,p_pen_attribute18_o         =>ben_pen_shd.g_old_rec.pen_attribute18
 ,p_pen_attribute19_o         =>ben_pen_shd.g_old_rec.pen_attribute19
 ,p_pen_attribute20_o         =>ben_pen_shd.g_old_rec.pen_attribute20
 ,p_pen_attribute21_o         =>ben_pen_shd.g_old_rec.pen_attribute21
 ,p_pen_attribute22_o         =>ben_pen_shd.g_old_rec.pen_attribute22
 ,p_pen_attribute23_o         =>ben_pen_shd.g_old_rec.pen_attribute23
 ,p_pen_attribute24_o         =>ben_pen_shd.g_old_rec.pen_attribute24
 ,p_pen_attribute25_o         =>ben_pen_shd.g_old_rec.pen_attribute25
 ,p_pen_attribute26_o         =>ben_pen_shd.g_old_rec.pen_attribute26
 ,p_pen_attribute27_o         =>ben_pen_shd.g_old_rec.pen_attribute27
 ,p_pen_attribute28_o         =>ben_pen_shd.g_old_rec.pen_attribute28
 ,p_pen_attribute29_o         =>ben_pen_shd.g_old_rec.pen_attribute29
 ,p_pen_attribute30_o         =>ben_pen_shd.g_old_rec.pen_attribute30
 ,p_request_id_o              =>ben_pen_shd.g_old_rec.request_id
 ,p_program_application_id_o  =>ben_pen_shd.g_old_rec.program_application_id
 ,p_program_id_o              =>ben_pen_shd.g_old_rec.program_id
 ,p_program_update_date_o     =>ben_pen_shd.g_old_rec.program_update_date
 ,p_object_version_number_o   =>ben_pen_shd.g_old_rec.object_version_number
 ,p_per_in_ler_id_o           =>ben_pen_shd.g_old_rec.per_in_ler_id
 ,p_bnft_typ_cd_o             =>ben_pen_shd.g_old_rec.bnft_typ_cd
 ,p_bnft_ordr_num_o           =>ben_pen_shd.g_old_rec.bnft_ordr_num
 ,p_prtt_enrt_rslt_stat_cd_o  =>ben_pen_shd.g_old_rec.prtt_enrt_rslt_stat_cd
 ,p_bnft_nnmntry_uom_o        =>ben_pen_shd.g_old_rec.bnft_nnmntry_uom
 ,p_comp_lvl_cd_o             =>ben_pen_shd.g_old_rec.comp_lvl_cd
 );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_enrt_rslt_f'
        ,p_hook_type   => 'AU');
  end;
  --
  -- End of API User Hook for post_update.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_pen_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pen_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_pen_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pen_shd.g_old_rec.person_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    ben_pen_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_pen_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_pen_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.rplcs_sspndd_rslt_id = hr_api.g_number) then
    p_rec.rplcs_sspndd_rslt_id :=
    ben_pen_shd.g_old_rec.rplcs_sspndd_rslt_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_pen_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_pen_shd.g_old_rec.pl_typ_id;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_pen_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.sspndd_flag = hr_api.g_varchar2) then
    p_rec.sspndd_flag :=
    ben_pen_shd.g_old_rec.sspndd_flag;
  End If;
  If (p_rec.prtt_is_cvrd_flag = hr_api.g_varchar2) then
    p_rec.prtt_is_cvrd_flag :=
    ben_pen_shd.g_old_rec.prtt_is_cvrd_flag;
  End If;
  If (p_rec.bnft_amt = hr_api.g_number) then
    p_rec.bnft_amt :=
    ben_pen_shd.g_old_rec.bnft_amt;
  End If;
  If (p_rec.uom      = hr_api.g_varchar2) then
    p_rec.uom      :=
    ben_pen_shd.g_old_rec.uom     ;
  End If;
  If (p_rec.orgnl_enrt_dt = hr_api.g_date) then
    p_rec.orgnl_enrt_dt :=
    ben_pen_shd.g_old_rec.orgnl_enrt_dt;
  End If;
  If (p_rec.enrt_mthd_cd = hr_api.g_varchar2) then
    p_rec.enrt_mthd_cd :=
    ben_pen_shd.g_old_rec.enrt_mthd_cd;
  End If;
  If (p_rec.no_lngr_elig_flag = hr_api.g_varchar2) then
    p_rec.no_lngr_elig_flag :=
    ben_pen_shd.g_old_rec.no_lngr_elig_flag;
  End If;
  If (p_rec.enrt_ovridn_flag = hr_api.g_varchar2) then
    p_rec.enrt_ovridn_flag :=
    ben_pen_shd.g_old_rec.enrt_ovridn_flag;
  End If;
  If (p_rec.enrt_ovrid_rsn_cd = hr_api.g_varchar2) then
    p_rec.enrt_ovrid_rsn_cd :=
    ben_pen_shd.g_old_rec.enrt_ovrid_rsn_cd;
  End If;
  If (p_rec.erlst_deenrt_dt = hr_api.g_date) then
    p_rec.erlst_deenrt_dt :=
    ben_pen_shd.g_old_rec.erlst_deenrt_dt;
  End If;
  If (p_rec.enrt_cvg_strt_dt = hr_api.g_date) then
    p_rec.enrt_cvg_strt_dt :=
    ben_pen_shd.g_old_rec.enrt_cvg_strt_dt;
  End If;
  If (p_rec.enrt_cvg_thru_dt = hr_api.g_date) then
    p_rec.enrt_cvg_thru_dt :=
    ben_pen_shd.g_old_rec.enrt_cvg_thru_dt;
  End If;
  If (p_rec.enrt_ovrid_thru_dt = hr_api.g_date) then
    p_rec.enrt_ovrid_thru_dt :=
    ben_pen_shd.g_old_rec.enrt_ovrid_thru_dt;
  End If;
  If (p_rec.pl_ordr_num = hr_api.g_number) then
    p_rec.pl_ordr_num :=
    ben_pen_shd.g_old_rec.pl_ordr_num;
  End If;
  If (p_rec.plip_ordr_num = hr_api.g_number) then
    p_rec.plip_ordr_num :=
    ben_pen_shd.g_old_rec.plip_ordr_num;
  End If;
  If (p_rec.ptip_ordr_num = hr_api.g_number) then
    p_rec.ptip_ordr_num :=
    ben_pen_shd.g_old_rec.ptip_ordr_num;
  End If;
  If (p_rec.oipl_ordr_num = hr_api.g_number) then
    p_rec.oipl_ordr_num :=
    ben_pen_shd.g_old_rec.oipl_ordr_num;
  End If;
  If (p_rec.pen_attribute_category = hr_api.g_varchar2) then
    p_rec.pen_attribute_category :=
    ben_pen_shd.g_old_rec.pen_attribute_category;
  End If;
  If (p_rec.pen_attribute1 = hr_api.g_varchar2) then
    p_rec.pen_attribute1 :=
    ben_pen_shd.g_old_rec.pen_attribute1;
  End If;
  If (p_rec.pen_attribute2 = hr_api.g_varchar2) then
    p_rec.pen_attribute2 :=
    ben_pen_shd.g_old_rec.pen_attribute2;
  End If;
  If (p_rec.pen_attribute3 = hr_api.g_varchar2) then
    p_rec.pen_attribute3 :=
    ben_pen_shd.g_old_rec.pen_attribute3;
  End If;
  If (p_rec.pen_attribute4 = hr_api.g_varchar2) then
    p_rec.pen_attribute4 :=
    ben_pen_shd.g_old_rec.pen_attribute4;
  End If;
  If (p_rec.pen_attribute5 = hr_api.g_varchar2) then
    p_rec.pen_attribute5 :=
    ben_pen_shd.g_old_rec.pen_attribute5;
  End If;
  If (p_rec.pen_attribute6 = hr_api.g_varchar2) then
    p_rec.pen_attribute6 :=
    ben_pen_shd.g_old_rec.pen_attribute6;
  End If;
  If (p_rec.pen_attribute7 = hr_api.g_varchar2) then
    p_rec.pen_attribute7 :=
    ben_pen_shd.g_old_rec.pen_attribute7;
  End If;
  If (p_rec.pen_attribute8 = hr_api.g_varchar2) then
    p_rec.pen_attribute8 :=
    ben_pen_shd.g_old_rec.pen_attribute8;
  End If;
  If (p_rec.pen_attribute9 = hr_api.g_varchar2) then
    p_rec.pen_attribute9 :=
    ben_pen_shd.g_old_rec.pen_attribute9;
  End If;
  If (p_rec.pen_attribute10 = hr_api.g_varchar2) then
    p_rec.pen_attribute10 :=
    ben_pen_shd.g_old_rec.pen_attribute10;
  End If;
  If (p_rec.pen_attribute11 = hr_api.g_varchar2) then
    p_rec.pen_attribute11 :=
    ben_pen_shd.g_old_rec.pen_attribute11;
  End If;
  If (p_rec.pen_attribute12 = hr_api.g_varchar2) then
    p_rec.pen_attribute12 :=
    ben_pen_shd.g_old_rec.pen_attribute12;
  End If;
  If (p_rec.pen_attribute13 = hr_api.g_varchar2) then
    p_rec.pen_attribute13 :=
    ben_pen_shd.g_old_rec.pen_attribute13;
  End If;
  If (p_rec.pen_attribute14 = hr_api.g_varchar2) then
    p_rec.pen_attribute14 :=
    ben_pen_shd.g_old_rec.pen_attribute14;
  End If;
  If (p_rec.pen_attribute15 = hr_api.g_varchar2) then
    p_rec.pen_attribute15 :=
    ben_pen_shd.g_old_rec.pen_attribute15;
  End If;
  If (p_rec.pen_attribute16 = hr_api.g_varchar2) then
    p_rec.pen_attribute16 :=
    ben_pen_shd.g_old_rec.pen_attribute16;
  End If;
  If (p_rec.pen_attribute17 = hr_api.g_varchar2) then
    p_rec.pen_attribute17 :=
    ben_pen_shd.g_old_rec.pen_attribute17;
  End If;
  If (p_rec.pen_attribute18 = hr_api.g_varchar2) then
    p_rec.pen_attribute18 :=
    ben_pen_shd.g_old_rec.pen_attribute18;
  End If;
  If (p_rec.pen_attribute19 = hr_api.g_varchar2) then
    p_rec.pen_attribute19 :=
    ben_pen_shd.g_old_rec.pen_attribute19;
  End If;
  If (p_rec.pen_attribute20 = hr_api.g_varchar2) then
    p_rec.pen_attribute20 :=
    ben_pen_shd.g_old_rec.pen_attribute20;
  End If;
  If (p_rec.pen_attribute21 = hr_api.g_varchar2) then
    p_rec.pen_attribute21 :=
    ben_pen_shd.g_old_rec.pen_attribute21;
  End If;
  If (p_rec.pen_attribute22 = hr_api.g_varchar2) then
    p_rec.pen_attribute22 :=
    ben_pen_shd.g_old_rec.pen_attribute22;
  End If;
  If (p_rec.pen_attribute23 = hr_api.g_varchar2) then
    p_rec.pen_attribute23 :=
    ben_pen_shd.g_old_rec.pen_attribute23;
  End If;
  If (p_rec.pen_attribute24 = hr_api.g_varchar2) then
    p_rec.pen_attribute24 :=
    ben_pen_shd.g_old_rec.pen_attribute24;
  End If;
  If (p_rec.pen_attribute25 = hr_api.g_varchar2) then
    p_rec.pen_attribute25 :=
    ben_pen_shd.g_old_rec.pen_attribute25;
  End If;
  If (p_rec.pen_attribute26 = hr_api.g_varchar2) then
    p_rec.pen_attribute26 :=
    ben_pen_shd.g_old_rec.pen_attribute26;
  End If;
  If (p_rec.pen_attribute27 = hr_api.g_varchar2) then
    p_rec.pen_attribute27 :=
    ben_pen_shd.g_old_rec.pen_attribute27;
  End If;
  If (p_rec.pen_attribute28 = hr_api.g_varchar2) then
    p_rec.pen_attribute28 :=
    ben_pen_shd.g_old_rec.pen_attribute28;
  End If;
  If (p_rec.pen_attribute29 = hr_api.g_varchar2) then
    p_rec.pen_attribute29 :=
    ben_pen_shd.g_old_rec.pen_attribute29;
  End If;
  If (p_rec.pen_attribute30 = hr_api.g_varchar2) then
    p_rec.pen_attribute30 :=
    ben_pen_shd.g_old_rec.pen_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_pen_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_pen_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_pen_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_pen_shd.g_old_rec.program_update_date;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_pen_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.bnft_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_typ_cd :=
    ben_pen_shd.g_old_rec.bnft_typ_cd;
  End If;
  If (p_rec.bnft_ordr_num = hr_api.g_number) then
    p_rec.bnft_ordr_num :=
    ben_pen_shd.g_old_rec.bnft_ordr_num;
  End If;
  If (p_rec.prtt_enrt_rslt_stat_cd = hr_api.g_varchar2) then
    p_rec.prtt_enrt_rslt_stat_cd :=
    ben_pen_shd.g_old_rec.prtt_enrt_rslt_stat_cd;
  End If;
  If (p_rec.bnft_nnmntry_uom = hr_api.g_varchar2) then
    p_rec.bnft_nnmntry_uom :=
    ben_pen_shd.g_old_rec.bnft_nnmntry_uom;
  End If;
  If (p_rec.comp_lvl_cd = hr_api.g_varchar2) then
    p_rec.comp_lvl_cd :=
    ben_pen_shd.g_old_rec.comp_lvl_cd;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec			in out nocopy 	ben_pen_shd.g_rec_type,
  p_effective_date	in 	date,
  p_datetrack_mode	in 	varchar2
  ) is
--
  l_proc			varchar2(72) := g_package||'upd';
  l_validation_start_date	date;
  l_validation_end_date		date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_pen_shd.lck
        (p_effective_date	     => p_effective_date,
      	 p_datetrack_mode	     => p_datetrack_mode,
      	 p_prtt_enrt_rslt_id	 => p_rec.prtt_enrt_rslt_id,
      	 p_object_version_number => p_rec.object_version_number,
      	 p_validation_start_date => l_validation_start_date,
      	 p_validation_end_date	 => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_pen_bus.update_validate
    (p_rec			 => p_rec,
     p_effective_date	 => p_effective_date,
     p_datetrack_mode  	 => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec			         => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec			         => p_rec,
     p_effective_date	     => p_effective_date,
     p_datetrack_mode	     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);
  --
  -- Call Multi_rows_Edit validation
  --
  if (ben_prtt_enrt_result_api.g_multi_rows_validate) then
        ben_pen_bus.multi_rows_edit
          (p_person_id              => p_rec.person_id,
           p_effective_date         => p_effective_date,
           p_business_group_id 	    => p_rec.business_group_id,
           p_pgm_id 		        => p_rec.pgm_id
          );
  end if;
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec			 => p_rec,
     p_effective_date	 => p_effective_date,
     p_datetrack_mode	 => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date	 => l_validation_end_date);

--
  -- DBI - Added DBI Event Logging Hooks
  /* Commented. Need to uncomment when DBI goes into mainline
  5554590 : Enabled DBI logging into mainline */
  if HRI_BPL_BEN_UTIL.enable_ben_col_evt_que then
      hr_utility.set_location(' Logging PEN update event'||l_proc, 5);
      hri_opl_ben_elig_enrl_eq.update_event (
                 p_rec              => p_rec ,
                 p_effective_date   => p_effective_date,
                 p_datetrack_mode   => p_datetrack_mode );
  end if;
--
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_prtt_enrt_rslt_id            in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number        default hr_api.g_number,
  p_oipl_id                      in number        default hr_api.g_number,
  p_person_id                    in number        default hr_api.g_number,
  p_assignment_id                in number        default hr_api.g_number,
  p_pgm_id                       in number        default hr_api.g_number,
  p_pl_id                        in number        default hr_api.g_number,
  p_rplcs_sspndd_rslt_id         in number        default hr_api.g_number,
  p_ptip_id                      in number        default hr_api.g_number,
  p_pl_typ_id                    in number        default hr_api.g_number,
  p_ler_id                       in number        default hr_api.g_number,
  p_sspndd_flag                  in varchar2      default hr_api.g_varchar2,
  p_prtt_is_cvrd_flag            in varchar2      default hr_api.g_varchar2,
  p_bnft_amt                     in number        default hr_api.g_number,
  p_uom                          in varchar2      default hr_api.g_varchar2,
  p_orgnl_enrt_dt                in date          default hr_api.g_date,
  p_enrt_mthd_cd                 in varchar2      default hr_api.g_varchar2,
  p_no_lngr_elig_flag            in varchar2      default hr_api.g_varchar2,
  p_enrt_ovridn_flag             in varchar2      default hr_api.g_varchar2,
  p_enrt_ovrid_rsn_cd            in varchar2      default hr_api.g_varchar2,
  p_erlst_deenrt_dt              in date          default hr_api.g_date,
  p_enrt_cvg_strt_dt             in date          default hr_api.g_date,
  p_enrt_cvg_thru_dt             in date          default hr_api.g_date,
  p_enrt_ovrid_thru_dt           in date          default hr_api.g_date,
  p_pl_ordr_num                  in number        default hr_api.g_number,
  p_plip_ordr_num                in number        default hr_api.g_number,
  p_ptip_ordr_num                in number        default hr_api.g_number,
  p_oipl_ordr_num                in number        default hr_api.g_number,
  p_pen_attribute_category       in varchar2      default hr_api.g_varchar2,
  p_pen_attribute1               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute2               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute3               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute4               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute5               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute6               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute7               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute8               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute9               in varchar2      default hr_api.g_varchar2,
  p_pen_attribute10              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute11              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute12              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute13              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute14              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute15              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute16              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute17              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute18              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute19              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute20              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute21              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute22              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute23              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute24              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute25              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute26              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute27              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute28              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute29              in varchar2      default hr_api.g_varchar2,
  p_pen_attribute30              in varchar2      default hr_api.g_varchar2,
  p_request_id                   in number        default hr_api.g_number,
  p_program_application_id       in number        default hr_api.g_number,
  p_program_id                   in number        default hr_api.g_number,
  p_program_update_date          in date          default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_per_in_ler_id                in number        default hr_api.g_number,
  p_bnft_typ_cd                  in varchar2      default hr_api.g_varchar2,
  p_bnft_ordr_num                in number        default hr_api.g_number,
  p_prtt_enrt_rslt_stat_cd       in varchar2      default hr_api.g_varchar2,
  p_bnft_nnmntry_uom             in varchar2      default hr_api.g_varchar2,
  p_comp_lvl_cd                  in varchar2      default hr_api.g_varchar2,
  p_effective_date		 in date,
  p_datetrack_mode		 in varchar2
  ) is
--
  l_rec		ben_pen_shd.g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pen_shd.convert_args
  (
  p_prtt_enrt_rslt_id,
  null,
  null,
  p_business_group_id,
  p_oipl_id,
  p_person_id,
  p_assignment_id,
  p_pgm_id,
  p_pl_id,
  p_rplcs_sspndd_rslt_id,
  p_ptip_id,
  p_pl_typ_id,
  p_ler_id,
  p_sspndd_flag,
  p_prtt_is_cvrd_flag,
  p_bnft_amt,
  p_uom     ,
  p_orgnl_enrt_dt,
  p_enrt_mthd_cd,
  p_no_lngr_elig_flag,
  p_enrt_ovridn_flag,
  p_enrt_ovrid_rsn_cd,
  p_erlst_deenrt_dt,
  p_enrt_cvg_strt_dt,
  p_enrt_cvg_thru_dt,
  p_enrt_ovrid_thru_dt,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_oipl_ordr_num,
  p_pen_attribute_category,
  p_pen_attribute1,
  p_pen_attribute2,
  p_pen_attribute3,
  p_pen_attribute4,
  p_pen_attribute5,
  p_pen_attribute6,
  p_pen_attribute7,
  p_pen_attribute8,
  p_pen_attribute9,
  p_pen_attribute10,
  p_pen_attribute11,
  p_pen_attribute12,
  p_pen_attribute13,
  p_pen_attribute14,
  p_pen_attribute15,
  p_pen_attribute16,
  p_pen_attribute17,
  p_pen_attribute18,
  p_pen_attribute19,
  p_pen_attribute20,
  p_pen_attribute21,
  p_pen_attribute22,
  p_pen_attribute23,
  p_pen_attribute24,
  p_pen_attribute25,
  p_pen_attribute26,
  p_pen_attribute27,
  p_pen_attribute28,
  p_pen_attribute29,
  p_pen_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number,
  p_per_in_ler_id,
  p_bnft_typ_cd,
  p_bnft_ordr_num,
  p_prtt_enrt_rslt_stat_cd,
  p_bnft_nnmntry_uom,
  p_comp_lvl_cd
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pen_upd;

/
