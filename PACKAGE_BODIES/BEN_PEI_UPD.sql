--------------------------------------------------------
--  DDL for Package Body BEN_PEI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEI_UPD" as
/* $Header: bepeirhi.pkb 120.0 2005/05/28 10:33:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pei_upd.';  -- Global package name
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
    (p_rec			in out nocopy ben_pei_shd.g_rec_type,
     p_effective_date		in    date,
     p_datetrack_mode		in    varchar2,
     p_validation_start_date	in    date,
     p_validation_end_date      in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
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
      (p_base_table_name    => 'ben_pl_extract_identifier_f',
       p_base_key_column    => 'pl_extract_identifier_id',
       p_base_key_value     => p_rec.pl_extract_identifier_id);
    --
    ben_pei_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_pl_f Row
    --
    update  ben_pl_extract_identifier_f
    set
    pl_id                          = p_rec.pl_id
    ,plip_id                  	   = p_rec.plip_id
    ,oipl_id                  	   = p_rec.oipl_id
    ,third_party_identifier   	   = p_rec.third_party_identifier
    ,organization_id          	   = p_rec.organization_id
    ,job_id                   	   = p_rec.job_id
    ,position_id              	   = p_rec.position_id
    ,people_group_id          	   = p_rec.people_group_id
    ,grade_id                 	   = p_rec.grade_id
    ,payroll_id               	   = p_rec.payroll_id
    ,home_state               	   = p_rec.home_state
    ,home_zip                 	   = p_rec.home_zip
    ,object_version_number	   = p_rec.object_version_number
    ,business_group_id		   = p_rec.business_group_id
    where   pl_extract_identifier_id = p_rec.pl_extract_identifier_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pei_shd.g_api_dml := false;   -- Unset the api dml status
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
    ben_pei_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pei_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pei_shd.g_api_dml := false;   -- Unset the api dml status
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
    (p_rec			in out nocopy ben_pei_shd.g_rec_type,
     p_effective_date		in    date,
     p_datetrack_mode		in    varchar2,
     p_validation_start_date	in    date,
     p_validation_end_date      in    date) is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec			=> p_rec,
                p_effective_date	=> p_effective_date,
		p_datetrack_mode	=> p_datetrack_mode,
                p_validation_start_date => p_validation_start_date,
		p_validation_end_date   => p_validation_end_date);
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
--    the validation_start_date.
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
    (p_rec			in out nocopy    ben_pei_shd.g_rec_type,
     p_effective_date		in    date,
     p_datetrack_mode		in    varchar2,
     p_validation_start_date	in    date,
     p_validation_end_date      in    date) is
--
  l_proc             varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_pei_shd.upd_effective_end_date
     (p_effective_date         => p_effective_date,
      p_base_key_value         => p_rec.pl_extract_identifier_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_pei_del.delete_dml
        (p_rec			 => p_rec,
         p_effective_date	 => p_effective_date,
         p_datetrack_mode	 => p_datetrack_mode,
         p_validation_start_date => p_validation_start_date,
         p_validation_end_date   => p_validation_end_date);
      --
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_pei_ins.insert_dml
      (p_rec			=> p_rec,
       p_effective_date         => p_effective_date,
       p_datetrack_mode         => p_datetrack_mode,
       p_validation_start_date  => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
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
    (p_rec			in out nocopy    ben_pei_shd.g_rec_type,
     p_effective_date		in    date,
     p_datetrack_mode		in    varchar2,
     p_validation_start_date	in    date,
     p_validation_end_date      in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec                    => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date    => p_validation_end_date);
  --
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
    (p_rec			in ben_pei_shd.g_rec_type,
     p_effective_date		in date,
     p_datetrack_mode		in varchar2,
     p_validation_start_date	in date,
     p_validation_end_date      in date) is
--
  l_proc    varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    --
    ben_pei_rku.after_update
    (
     p_pl_extract_identifier_id    =>  p_rec.pl_extract_identifier_id
     ,p_pl_id                       =>  p_rec.pl_id
     ,p_plip_id                     =>  p_rec.plip_id
     ,p_oipl_id                     =>  p_rec.oipl_id
     ,p_third_party_identifier      =>  p_rec.third_party_identifier
     ,p_organization_id             =>  p_rec.organization_id
     ,p_job_id                      =>  p_rec.job_id
     ,p_position_id                 =>  p_rec.position_id
     ,p_people_group_id             =>  p_rec.people_group_id
     ,p_grade_id                    =>  p_rec.grade_id
     ,p_payroll_id                  =>  p_rec.payroll_id
     ,p_home_state                  =>  p_rec.home_state
     ,p_home_zip                    =>  p_rec.home_zip
     ,p_effective_start_date        =>  p_rec.effective_start_date
     ,p_effective_end_date          =>  p_rec.effective_end_date
     ,p_object_version_number       =>  p_rec.object_version_number
     ,p_business_group_id           =>  p_rec.business_group_id
     ,p_effective_date              =>  p_effective_date
     ,p_datetrack_mode              =>  p_datetrack_mode
     ,p_validation_start_date       =>  p_validation_start_date
     ,p_validation_end_date         =>  p_validation_end_date
     ,p_pl_id_o                     =>  ben_pei_shd.g_old_rec.pl_id
     ,p_plip_id_o                   =>  ben_pei_shd.g_old_rec.plip_id
     ,p_oipl_id_o                   =>  ben_pei_shd.g_old_rec.oipl_id
     ,p_third_party_identifier_o    =>  ben_pei_shd.g_old_rec.third_party_identifier
     ,p_organization_id_o           =>  ben_pei_shd.g_old_rec.organization_id
     ,p_job_id_o                    =>  ben_pei_shd.g_old_rec.job_id
     ,p_position_id_o               =>  ben_pei_shd.g_old_rec.position_id
     ,p_people_group_id_o           =>  ben_pei_shd.g_old_rec.people_group_id
     ,p_grade_id_o                  =>  ben_pei_shd.g_old_rec.grade_id
     ,p_payroll_id_o                =>  ben_pei_shd.g_old_rec.payroll_id
     ,p_home_state_o                =>  ben_pei_shd.g_old_rec.home_state
     ,p_home_zip_o                  =>  ben_pei_shd.g_old_rec.home_zip
     ,p_effective_start_date_o      =>  ben_pei_shd.g_old_rec.effective_start_date
     ,p_effective_end_date_o        =>  ben_pei_shd.g_old_rec.effective_end_date
     ,p_object_version_number_o     =>  ben_pei_shd.g_old_rec.object_version_number
     ,p_business_group_id_o         =>  ben_pei_shd.g_old_rec.business_group_id
    );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pl_extract_identifier_f'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy     ben_pei_shd.g_rec_type,
  p_effective_date    in     date,
  p_datetrack_mode    in     varchar2
  ) is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date    date;
  l_validation_end_date        date;
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
  ben_pei_shd.lck
          (p_effective_date		=> p_effective_date,
           p_datetrack_mode		=> p_datetrack_mode,
           p_pl_extract_identifier_id   => p_rec.pl_extract_identifier_id,
           p_object_version_number	=> p_rec.object_version_number,
           p_validation_start_date	=> l_validation_start_date,
           p_validation_end_date	=> l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ben_pei_upd2.convert_defs(p_rec);
  ben_pei_bus.update_validate
    (p_rec			=> p_rec,
     p_effective_date		=> p_effective_date,
     p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> l_validation_start_date,
     p_validation_end_date      => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec			=> p_rec,
     p_effective_date		=> p_effective_date,
     p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> l_validation_start_date,
     p_validation_end_date      => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec			=> p_rec,
     p_effective_date		=> p_effective_date,
     p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> l_validation_start_date,
     p_validation_end_date      => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec			=> p_rec,
     p_effective_date		=> p_effective_date,
     p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> l_validation_start_date,
     p_validation_end_date      => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
   p_pl_extract_identifier_id    in  number,
   p_effective_start_date        out nocopy date,
   p_effective_end_date          out nocopy date,
   p_pl_id                       in  number    default hr_api.g_number,
   p_plip_id                     in  number    default hr_api.g_number,
   p_oipl_id                     in  number    default hr_api.g_number,
   p_third_party_identifier      in  varchar2  default hr_api.g_varchar2,
   p_organization_id             in  number    default hr_api.g_number,
   p_job_id                      in  number    default hr_api.g_number,
   p_position_id                 in  number    default hr_api.g_number,
   p_people_group_id             in  number    default hr_api.g_number,
   p_grade_id                    in  number    default hr_api.g_number,
   p_payroll_id                  in  number    default hr_api.g_number,
   p_home_state                  in  varchar2  default hr_api.g_varchar2,
   p_home_zip                    in  varchar2  default hr_api.g_varchar2,
   p_business_group_id           in  number    default hr_api.g_number,
   p_object_version_number       in  out nocopy number,
   p_effective_date              in  date,
   p_datetrack_mode	       in  varchar2
  ) is
--
  l_rec     ben_pei_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
     ben_pei_shd.convert_args
     (
       p_pl_extract_identifier_id
       ,p_pl_id
       ,p_plip_id
       ,p_oipl_id
       ,p_third_party_identifier
       ,p_organization_id
       ,p_job_id
       ,p_position_id
       ,p_people_group_id
       ,p_grade_id
       ,p_payroll_id
       ,p_home_state
       ,p_home_zip
       ,null
       ,null
       ,p_object_version_number
       ,p_business_group_id
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
end ben_pei_upd;

/
