--------------------------------------------------------
--  DDL for Package Body BEN_BEC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEC_UPD" as
/* $Header: bebecrhi.pkb 120.0 2005/05/28 00:37:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bec_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_bec_shd.g_rec_type) is
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
  ben_bec_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_batch_elctbl_chc_info Row
  --
  update ben_batch_elctbl_chc_info
  set
  batch_elctbl_id                   = p_rec.batch_elctbl_id,
  benefit_action_id                 = p_rec.benefit_action_id,
  person_id                         = p_rec.person_id,
  pgm_id                            = p_rec.pgm_id,
  pl_id                             = p_rec.pl_id,
  oipl_id                           = p_rec.oipl_id,
  enrt_cvg_strt_dt                  = p_rec.enrt_cvg_strt_dt,
  enrt_perd_strt_dt                 = p_rec.enrt_perd_strt_dt,
  enrt_perd_end_dt                  = p_rec.enrt_perd_end_dt,
  erlst_deenrt_dt                   = p_rec.erlst_deenrt_dt,
  dflt_enrt_dt                      = p_rec.dflt_enrt_dt,
  enrt_typ_cycl_cd                  = p_rec.enrt_typ_cycl_cd,
  comp_lvl_cd                       = p_rec.comp_lvl_cd,
  mndtry_flag                       = p_rec.mndtry_flag,
  dflt_flag                         = p_rec.dflt_flag,
  business_group_id                 = p_rec.business_group_id,
  object_version_number             = p_rec.object_version_number
  where batch_elctbl_id = p_rec.batch_elctbl_id;
  --
  ben_bec_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bec_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bec_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_bec_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bec_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bec_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bec_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bec_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_bec_shd.g_rec_type) is
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
Procedure post_update(p_effective_date in date,
                      p_rec            in ben_bec_shd.g_rec_type) is
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
    ben_bec_rku.after_update
      (p_batch_elctbl_id         =>p_rec.batch_elctbl_id
      ,p_benefit_action_id       =>p_rec.benefit_action_id
      ,p_person_id               =>p_rec.person_id
      ,p_pgm_id                  =>p_rec.pgm_id
      ,p_pl_id                   =>p_rec.pl_id
      ,p_oipl_id                 =>p_rec.oipl_id
      ,p_enrt_cvg_strt_dt        =>p_rec.enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt       =>p_rec.enrt_perd_strt_dt
      ,p_enrt_perd_end_dt        =>p_rec.enrt_perd_end_dt
      ,p_erlst_deenrt_dt         =>p_rec.erlst_deenrt_dt
      ,p_dflt_enrt_dt            =>p_rec.dflt_enrt_dt
      ,p_enrt_typ_cycl_cd        =>p_rec.enrt_typ_cycl_cd
      ,p_comp_lvl_cd             =>p_rec.comp_lvl_cd
      ,p_mndtry_flag             =>p_rec.mndtry_flag
      ,p_dflt_flag               =>p_rec.dflt_flag
      ,p_business_group_id       =>p_rec.business_group_id
      ,p_object_version_number   =>p_rec.object_version_number
      ,p_effective_date          =>p_effective_date
      ,p_benefit_action_id_o     =>ben_bec_shd.g_old_rec.benefit_action_id
      ,p_person_id_o             =>ben_bec_shd.g_old_rec.person_id
      ,p_pgm_id_o                =>ben_bec_shd.g_old_rec.pgm_id
      ,p_pl_id_o                 =>ben_bec_shd.g_old_rec.pl_id
      ,p_oipl_id_o               =>ben_bec_shd.g_old_rec.oipl_id
      ,p_enrt_cvg_strt_dt_o      =>ben_bec_shd.g_old_rec.enrt_cvg_strt_dt
      ,p_enrt_perd_strt_dt_o     =>ben_bec_shd.g_old_rec.enrt_perd_strt_dt
      ,p_enrt_perd_end_dt_o      =>ben_bec_shd.g_old_rec.enrt_perd_end_dt
      ,p_erlst_deenrt_dt_o       =>ben_bec_shd.g_old_rec.erlst_deenrt_dt
      ,p_dflt_enrt_dt_o          =>ben_bec_shd.g_old_rec.dflt_enrt_dt
      ,p_enrt_typ_cycl_cd_o      =>ben_bec_shd.g_old_rec.enrt_typ_cycl_cd
      ,p_comp_lvl_cd_o           =>ben_bec_shd.g_old_rec.comp_lvl_cd
      ,p_mndtry_flag_o           =>ben_bec_shd.g_old_rec.mndtry_flag
      ,p_dflt_flag_o             =>ben_bec_shd.g_old_rec.dflt_flag
      ,p_business_group_id_o     =>ben_bec_shd.g_old_rec.business_group_id
      ,p_object_version_number_o =>ben_bec_shd.g_old_rec.object_version_number);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_batch_elctbl_chc_info'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
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
Procedure convert_defs(p_rec in out nocopy ben_bec_shd.g_rec_type) is
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
  If (p_rec.benefit_action_id = hr_api.g_number) then
    p_rec.benefit_action_id :=
    ben_bec_shd.g_old_rec.benefit_action_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_bec_shd.g_old_rec.person_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_bec_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_bec_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_bec_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.enrt_cvg_strt_dt = hr_api.g_date) then
    p_rec.enrt_cvg_strt_dt :=
    ben_bec_shd.g_old_rec.enrt_cvg_strt_dt;
  End If;
  If (p_rec.enrt_perd_strt_dt = hr_api.g_date) then
    p_rec.enrt_perd_strt_dt :=
    ben_bec_shd.g_old_rec.enrt_perd_strt_dt;
  End If;
  If (p_rec.enrt_perd_end_dt = hr_api.g_date) then
    p_rec.enrt_perd_end_dt :=
    ben_bec_shd.g_old_rec.enrt_perd_end_dt;
  End If;
  If (p_rec.erlst_deenrt_dt = hr_api.g_date) then
    p_rec.erlst_deenrt_dt :=
    ben_bec_shd.g_old_rec.erlst_deenrt_dt;
  End If;
  If (p_rec.dflt_enrt_dt = hr_api.g_date) then
    p_rec.dflt_enrt_dt :=
    ben_bec_shd.g_old_rec.dflt_enrt_dt;
  End If;
  If (p_rec.enrt_typ_cycl_cd = hr_api.g_varchar2) then
    p_rec.enrt_typ_cycl_cd :=
    ben_bec_shd.g_old_rec.enrt_typ_cycl_cd;
  End If;
  If (p_rec.comp_lvl_cd = hr_api.g_varchar2) then
    p_rec.comp_lvl_cd :=
    ben_bec_shd.g_old_rec.comp_lvl_cd;
  End If;
  If (p_rec.mndtry_flag = hr_api.g_varchar2) then
    p_rec.mndtry_flag :=
    ben_bec_shd.g_old_rec.mndtry_flag;
  End If;
  If (p_rec.dflt_flag = hr_api.g_varchar2) then
    p_rec.dflt_flag :=
    ben_bec_shd.g_old_rec.dflt_flag;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_bec_shd.g_old_rec.business_group_id;
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
  p_rec        in out nocopy ben_bec_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_bec_shd.lck
	(
	p_rec.batch_elctbl_id,
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
  ben_bec_bus.update_validate(p_rec,p_effective_date);
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
  p_batch_elctbl_id              in number,
  p_benefit_action_id            in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_enrt_cvg_strt_dt             in date             default hr_api.g_date,
  p_enrt_perd_strt_dt            in date             default hr_api.g_date,
  p_enrt_perd_end_dt             in date             default hr_api.g_date,
  p_erlst_deenrt_dt              in date             default hr_api.g_date,
  p_dflt_enrt_dt                 in date             default hr_api.g_date,
  p_enrt_typ_cycl_cd             in varchar2         default hr_api.g_varchar2,
  p_comp_lvl_cd                  in varchar2         default hr_api.g_varchar2,
  p_mndtry_flag                  in varchar2         default hr_api.g_varchar2,
  p_dflt_flag                    in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_bec_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_bec_shd.convert_args
  (
  p_batch_elctbl_id,
  p_benefit_action_id,
  p_person_id,
  p_pgm_id,
  p_pl_id,
  p_oipl_id,
  p_enrt_cvg_strt_dt,
  p_enrt_perd_strt_dt,
  p_enrt_perd_end_dt,
  p_erlst_deenrt_dt,
  p_dflt_enrt_dt,
  p_enrt_typ_cycl_cd,
  p_comp_lvl_cd,
  p_mndtry_flag,
  p_dflt_flag,
  p_business_group_id,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date,l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_bec_upd;

/
