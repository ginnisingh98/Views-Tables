--------------------------------------------------------
--  DDL for Package Body BEN_BMN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BMN_UPD" as
/* $Header: bebmnrhi.pkb 115.7 2002/12/09 12:40:49 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bmn_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ben_bmn_shd.g_rec_type) is
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
  ben_bmn_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_reporting Row
  --
  update ben_reporting
  set
  reporting_id                      = p_rec.reporting_id,
  benefit_action_id                 = p_rec.benefit_action_id,
  thread_id                         = p_rec.thread_id,
  sequence                          = p_rec.sequence,
  text                              = p_rec.text,
  rep_typ_cd                        = p_rec.rep_typ_cd,
  error_message_code                = p_rec.error_message_code,
  national_identifier               = p_rec.national_identifier,
  related_person_ler_id             = p_rec.related_person_ler_id,
  temporal_ler_id                   = p_rec.temporal_ler_id,
  ler_id                            = p_rec.ler_id,
  person_id                         = p_rec.person_id,
  pgm_id                            = p_rec.pgm_id,
  pl_id                             = p_rec.pl_id,
  related_person_id                 = p_rec.related_person_id,
  oipl_id                           = p_rec.oipl_id,
  pl_typ_id                         = p_rec.pl_typ_id,
  actl_prem_id                      = p_rec.actl_prem_id,
  val                               = p_rec.val,
  mo_num                            = p_rec.mo_num,
  yr_num                            = p_rec.yr_num,
  object_version_number             = p_rec.object_version_number
  where reporting_id = p_rec.reporting_id;
  --
  ben_bmn_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bmn_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bmn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_bmn_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bmn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bmn_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bmn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bmn_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ben_bmn_shd.g_rec_type) is
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
Procedure post_update(p_rec in ben_bmn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
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
Procedure convert_defs(p_rec in out nocopy ben_bmn_shd.g_rec_type) is
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
    ben_bmn_shd.g_old_rec.benefit_action_id;
  End If;
  If (p_rec.thread_id = hr_api.g_number) then
    p_rec.thread_id :=
    ben_bmn_shd.g_old_rec.thread_id;
  End If;
  If (p_rec.sequence = hr_api.g_number) then
    p_rec.sequence :=
    ben_bmn_shd.g_old_rec.sequence;
  End If;
  If (p_rec.rep_typ_cd = hr_api.g_varchar2) then
    p_rec.rep_typ_cd :=
    ben_bmn_shd.g_old_rec.rep_typ_cd;
  End If;
  If (p_rec.error_message_code = hr_api.g_varchar2) then
    p_rec.error_message_code :=
    ben_bmn_shd.g_old_rec.error_message_code;
  End If;
  If (p_rec.national_identifier = hr_api.g_varchar2) then
    p_rec.national_identifier :=
    ben_bmn_shd.g_old_rec.national_identifier;
  End If;
  If (p_rec.related_person_ler_id = hr_api.g_number) then
    p_rec.related_person_ler_id :=
    ben_bmn_shd.g_old_rec.related_person_ler_id;
  End If;
  If (p_rec.temporal_ler_id = hr_api.g_number) then
    p_rec.temporal_ler_id :=
    ben_bmn_shd.g_old_rec.temporal_ler_id;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_bmn_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_bmn_shd.g_old_rec.person_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_bmn_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_bmn_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.related_person_id = hr_api.g_number) then
    p_rec.related_person_id :=
    ben_bmn_shd.g_old_rec.related_person_id;
  End If;
  If (p_rec.oipl_id = hr_api.g_number) then
    p_rec.oipl_id :=
    ben_bmn_shd.g_old_rec.oipl_id;
  End If;
  If (p_rec.pl_typ_id = hr_api.g_number) then
    p_rec.pl_typ_id :=
    ben_bmn_shd.g_old_rec.pl_typ_id;
  End If;

  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_bmn_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.val = hr_api.g_number) then
    p_rec.val :=
    ben_bmn_shd.g_old_rec.val;
  End If;
  If (p_rec.mo_num = hr_api.g_number) then
    p_rec.mo_num :=
    ben_bmn_shd.g_old_rec.mo_num;
  End If;
  If (p_rec.yr_num = hr_api.g_number) then
    p_rec.yr_num :=
    ben_bmn_shd.g_old_rec.yr_num;
  End If;


  If (p_rec.text = hr_api.g_varchar2) then
    p_rec.text :=
    ben_bmn_shd.g_old_rec.text;
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
  p_rec        in out nocopy ben_bmn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ben_bmn_shd.lck
	(
	p_rec.reporting_id,
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
  ben_bmn_bus.update_validate(p_rec);
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
  post_update(p_rec);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_reporting_id                 in number,
  p_benefit_action_id            in number           default hr_api.g_number,
  p_thread_id                    in number           default hr_api.g_number,
  p_sequence                     in number           default hr_api.g_number,
  p_text                         in varchar2         default hr_api.g_varchar2,
  p_rep_typ_cd                   in varchar2         default hr_api.g_varchar2,
  p_error_message_code           in varchar2         default hr_api.g_varchar2,
  p_national_identifier          in varchar2         default hr_api.g_varchar2,
  p_related_person_ler_id        in number           default hr_api.g_number,
  p_temporal_ler_id              in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_related_person_id            in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
        p_actl_prem_id                  in    number default hr_api.g_number,
        p_val                           in    number default hr_api.g_number,
        p_mo_num                        in    number default hr_api.g_number,
        p_yr_num                        in    number default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ben_bmn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_bmn_shd.convert_args
  (
  p_reporting_id,
  p_benefit_action_id,
  p_thread_id,
  p_sequence,
  p_text,
  p_rep_typ_cd,
  p_error_message_code,
  p_national_identifier,
  p_related_person_ler_id,
  p_temporal_ler_id,
  p_ler_id,
  p_person_id,
  p_pgm_id,
  p_pl_id,
  p_related_person_id,
  p_oipl_id,
  p_pl_typ_id,
  p_actl_prem_id                      ,
  p_val                               ,
  p_mo_num                            ,
  p_yr_num                            ,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_bmn_upd;

/
