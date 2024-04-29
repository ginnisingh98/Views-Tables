--------------------------------------------------------
--  DDL for Package Body BEN_PPL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_UPD" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppl_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_ppl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_ptnl_ler_for_per Row
  --
  update ben_ptnl_ler_for_per
  set
  ptnl_ler_for_per_id               = p_rec.ptnl_ler_for_per_id,
  csd_by_ptnl_ler_for_per_id        = p_rec.csd_by_ptnl_ler_for_per_id,
  lf_evt_ocrd_dt                    = p_rec.lf_evt_ocrd_dt,
  trgr_table_pk_id                  = p_rec.trgr_table_pk_id,
  ptnl_ler_for_per_stat_cd          = p_rec.ptnl_ler_for_per_stat_cd,
  ptnl_ler_for_per_src_cd           = p_rec.ptnl_ler_for_per_src_cd,
  mnl_dt                            = p_rec.mnl_dt,
  enrt_perd_id                      = p_rec.enrt_perd_id,
  ntfn_dt                           = p_rec.ntfn_dt,
  dtctd_dt                          = p_rec.dtctd_dt,
  procd_dt                          = p_rec.procd_dt,
  unprocd_dt                        = p_rec.unprocd_dt,
  voidd_dt                          = p_rec.voidd_dt,
  mnlo_dt                           = p_rec.mnlo_dt,
  ler_id                            = p_rec.ler_id,
  person_id                         = p_rec.person_id,
  business_group_id                 = p_rec.business_group_id,
  request_id                        = p_rec.request_id,
  program_application_id            = p_rec.program_application_id,
  program_id                        = p_rec.program_id,
  program_update_date               = p_rec.program_update_date,
  object_version_number             = p_rec.object_version_number
  where ptnl_ler_for_per_id = p_rec.ptnl_ler_for_per_id;
  --
  ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure post_update(
p_effective_date in date,p_rec in ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_update.
  --
  begin
    --
    ben_ppl_rku.after_update
      (
  p_ptnl_ler_for_per_id           =>p_rec.ptnl_ler_for_per_id
 ,p_csd_by_ptnl_ler_for_per_id    =>p_rec.csd_by_ptnl_ler_for_per_id
 ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id              =>p_rec.trgr_table_pk_id
 ,p_ptnl_ler_for_per_stat_cd      =>p_rec.ptnl_ler_for_per_stat_cd
 ,p_ptnl_ler_for_per_src_cd       =>p_rec.ptnl_ler_for_per_src_cd
 ,p_mnl_dt                        =>p_rec.mnl_dt
 ,p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_ntfn_dt                       =>p_rec.ntfn_dt
 ,p_dtctd_dt                      =>p_rec.dtctd_dt
 ,p_procd_dt                      =>p_rec.procd_dt
 ,p_unprocd_dt                    =>p_rec.unprocd_dt
 ,p_voidd_dt                      =>p_rec.voidd_dt
 ,p_mnlo_dt                       =>p_rec.mnlo_dt
 ,p_ler_id                        =>p_rec.ler_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_csd_by_ptnl_ler_for_per_id_o  =>ben_ppl_shd.g_old_rec.csd_by_ptnl_ler_for_per_id
 ,p_lf_evt_ocrd_dt_o              =>ben_ppl_shd.g_old_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id_o            =>ben_ppl_shd.g_old_rec.trgr_table_pk_id
 ,p_ptnl_ler_for_per_stat_cd_o    =>ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd
 ,p_ptnl_ler_for_per_src_cd_o     =>ben_ppl_shd.g_old_rec.ptnl_ler_for_per_src_cd
 ,p_mnl_dt_o                      =>ben_ppl_shd.g_old_rec.mnl_dt
 ,p_enrt_perd_id_o                =>ben_ppl_shd.g_old_rec.enrt_perd_id
 ,p_ntfn_dt_o                     =>ben_ppl_shd.g_old_rec.ntfn_dt
 ,p_dtctd_dt_o                    =>ben_ppl_shd.g_old_rec.dtctd_dt
 ,p_procd_dt_o                    =>ben_ppl_shd.g_old_rec.procd_dt
 ,p_unprocd_dt_o                  =>ben_ppl_shd.g_old_rec.unprocd_dt
 ,p_voidd_dt_o                    =>ben_ppl_shd.g_old_rec.voidd_dt
 ,p_mnlo_dt_o                     =>ben_ppl_shd.g_old_rec.mnlo_dt
 ,p_ler_id_o                      =>ben_ppl_shd.g_old_rec.ler_id
 ,p_person_id_o                   =>ben_ppl_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_ppl_shd.g_old_rec.business_group_id
 ,p_request_id_o                  =>ben_ppl_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_ppl_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_ppl_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_ppl_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_ppl_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ptnl_ler_for_per'
        ,p_hook_type   => 'AU');
      --
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
--   errors within this procedure will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_ppl_shd.g_rec_type) is
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
  If (p_rec.csd_by_ptnl_ler_for_per_id = hr_api.g_number) then
    p_rec.csd_by_ptnl_ler_for_per_id :=
    ben_ppl_shd.g_old_rec.csd_by_ptnl_ler_for_per_id;
  End If;
  If (p_rec.lf_evt_ocrd_dt = hr_api.g_date) then
    p_rec.lf_evt_ocrd_dt :=
    ben_ppl_shd.g_old_rec.lf_evt_ocrd_dt;
  End If;
  If (p_rec.trgr_table_pk_id = hr_api.g_number) then
    p_rec.trgr_table_pk_id :=
    ben_ppl_shd.g_old_rec.trgr_table_pk_id;
  End If;
  If (p_rec.ptnl_ler_for_per_stat_cd = hr_api.g_varchar2) then
    p_rec.ptnl_ler_for_per_stat_cd :=
    ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd;
  End If;
  If (p_rec.ptnl_ler_for_per_src_cd = hr_api.g_varchar2) then
    p_rec.ptnl_ler_for_per_src_cd :=
    ben_ppl_shd.g_old_rec.ptnl_ler_for_per_src_cd;
  End If;
  If (p_rec.mnl_dt = hr_api.g_date) then
    p_rec.mnl_dt :=
    ben_ppl_shd.g_old_rec.mnl_dt;
  End If;
  If (p_rec.enrt_perd_id = hr_api.g_number) then
    p_rec.enrt_perd_id :=
    ben_ppl_shd.g_old_rec.enrt_perd_id;
  End If;
  If (p_rec.ntfn_dt = hr_api.g_date) then
    p_rec.ntfn_dt :=
    ben_ppl_shd.g_old_rec.ntfn_dt;
  End If;
  If (p_rec.dtctd_dt = hr_api.g_date) then
    p_rec.dtctd_dt :=
    ben_ppl_shd.g_old_rec.dtctd_dt;
  End If;
  If (p_rec.procd_dt = hr_api.g_date) then
    p_rec.procd_dt :=
    ben_ppl_shd.g_old_rec.procd_dt;
  End If;
  If (p_rec.unprocd_dt = hr_api.g_date) then
    p_rec.unprocd_dt :=
    ben_ppl_shd.g_old_rec.unprocd_dt;
  End If;
  If (p_rec.voidd_dt = hr_api.g_date) then
    p_rec.voidd_dt :=
    ben_ppl_shd.g_old_rec.voidd_dt;
  End If;
  If (p_rec.mnlo_dt = hr_api.g_date) then
    p_rec.mnlo_dt :=
    ben_ppl_shd.g_old_rec.mnlo_dt;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_ppl_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_ppl_shd.g_old_rec.person_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_ppl_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_ppl_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_ppl_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_ppl_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_ppl_shd.g_old_rec.program_update_date;
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
  p_effective_date in date,
  p_rec        in out nocopy ben_ppl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_ppl_shd.lck
	(
	p_rec.ptnl_ler_for_per_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_ppl_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_effective_date,p_rec);
  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_effective_date in date,
  p_ptnl_ler_for_per_id          in number,
  p_csd_by_ptnl_ler_for_per_id   in number           default hr_api.g_number,
  p_lf_evt_ocrd_dt               in date             default hr_api.g_date,
  p_trgr_table_pk_id             in number           default hr_api.g_number,
  p_ptnl_ler_for_per_stat_cd     in varchar2         default hr_api.g_varchar2,
  p_ptnl_ler_for_per_src_cd      in varchar2         default hr_api.g_varchar2,
  p_mnl_dt                       in date             default hr_api.g_date,
  p_enrt_perd_id                 in number           default hr_api.g_number,
  p_ntfn_dt                      in date             default hr_api.g_date,
  p_dtctd_dt                     in date             default hr_api.g_date,
  p_procd_dt                     in date             default hr_api.g_date,
  p_unprocd_dt                   in date             default hr_api.g_date,
  p_voidd_dt                     in date             default hr_api.g_date,
  p_mnlo_dt                      in date             default hr_api.g_date,
  p_ler_id                       in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_ppl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_ppl_shd.convert_args
  (
  p_ptnl_ler_for_per_id,
  p_csd_by_ptnl_ler_for_per_id,
  p_lf_evt_ocrd_dt,
  p_trgr_table_pk_id,
  p_ptnl_ler_for_per_stat_cd,
  p_ptnl_ler_for_per_src_cd,
  p_mnl_dt,
  p_enrt_perd_id,
  p_ntfn_dt,
  p_dtctd_dt,
  p_procd_dt,
  p_unprocd_dt,
  p_voidd_dt,
  p_mnlo_dt,
  p_ler_id,
  p_person_id,
  p_business_group_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(
    p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_ppl_upd;

/
