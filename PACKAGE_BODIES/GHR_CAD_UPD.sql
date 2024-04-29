--------------------------------------------------------
--  DDL for Package Body GHR_CAD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CAD_UPD" as
/* $Header: ghcadrhi.pkb 115.4 2003/01/30 19:24:51 asubrahm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ghr_cad_upd.';  -- Global package name
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
Procedure update_dml
  (p_rec in out nocopy ghr_cad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the ghr_compl_adrs Row
  --
  update ghr_compl_adrs
    set
     compl_adr_id                    = p_rec.compl_adr_id
    ,complaint_id                    = p_rec.complaint_id
    ,stage                           = p_rec.stage
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,adr_resource                    = p_rec.adr_resource
    ,technique                       = p_rec.technique
    ,outcome                         = p_rec.outcome
    ,adr_offered                     = p_rec.adr_offered
    ,date_accepted                   = p_rec.date_accepted
    ,object_version_number           = p_rec.object_version_number
    where compl_adr_id = p_rec.compl_adr_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ghr_cad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ghr_cad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ghr_cad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
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
Procedure pre_update
  (p_rec in ghr_cad_shd.g_rec_type
  ) is
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
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
  (p_effective_date               in date
  ,p_rec                          in ghr_cad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  begin
    --
    ghr_cad_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_compl_adr_id                => p_rec.compl_adr_id
      ,p_complaint_id                => p_rec.complaint_id
      ,p_stage                       => p_rec.stage
      ,p_start_date                  => p_rec.start_date
      ,p_end_date                    => p_rec.end_date
      ,p_adr_resource                => p_rec.adr_resource
      ,p_technique                   => p_rec.technique
      ,p_outcome                     => p_rec.outcome
      ,p_adr_offered                 => p_rec.adr_offered
      ,p_date_accepted               => p_rec.date_accepted
      ,p_object_version_number       => p_rec.object_version_number
      ,p_complaint_id_o              => ghr_cad_shd.g_old_rec.complaint_id
      ,p_stage_o                     => ghr_cad_shd.g_old_rec.stage
      ,p_start_date_o                => ghr_cad_shd.g_old_rec.start_date
      ,p_end_date_o                  => ghr_cad_shd.g_old_rec.end_date
      ,p_adr_resource_o              => ghr_cad_shd.g_old_rec.adr_resource
      ,p_technique_o                 => ghr_cad_shd.g_old_rec.technique
      ,p_outcome_o                   => ghr_cad_shd.g_old_rec.outcome
      ,p_adr_offered_o               => ghr_cad_shd.g_old_rec.adr_offered
      ,p_date_accepted_o             => ghr_cad_shd.g_old_rec.date_accepted
      ,p_object_version_number_o     => ghr_cad_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'GHR_COMPL_ADRS'
        ,p_hook_type   => 'AU');
      --
  end;

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
--   A Pl/Sql record structure.
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
Procedure convert_defs
  (p_rec in out nocopy ghr_cad_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.complaint_id = hr_api.g_number) then
    p_rec.complaint_id :=
    ghr_cad_shd.g_old_rec.complaint_id;
  End If;
  If (p_rec.stage = hr_api.g_varchar2) then
    p_rec.stage :=
    ghr_cad_shd.g_old_rec.stage;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ghr_cad_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ghr_cad_shd.g_old_rec.end_date;
  End If;
  If (p_rec.adr_resource = hr_api.g_varchar2) then
    p_rec.adr_resource :=
    ghr_cad_shd.g_old_rec.adr_resource;
  End If;
  If (p_rec.technique = hr_api.g_varchar2) then
    p_rec.technique :=
    ghr_cad_shd.g_old_rec.technique;
  End If;
  If (p_rec.outcome = hr_api.g_varchar2) then
    p_rec.outcome :=
    ghr_cad_shd.g_old_rec.outcome;
  End If;
  If (p_rec.adr_offered = hr_api.g_varchar2) then
    p_rec.adr_offered :=
    ghr_cad_shd.g_old_rec.adr_offered;
  End If;
  If (p_rec.date_accepted = hr_api.g_date) then
    p_rec.date_accepted :=
    ghr_cad_shd.g_old_rec.date_accepted;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ghr_cad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ghr_cad_shd.lck
    (p_rec.compl_adr_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ghr_cad_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  ghr_cad_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ghr_cad_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ghr_cad_upd.post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_compl_adr_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number
  ,p_stage                        in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_adr_resource                 in     varchar2
  ,p_technique                    in     varchar2
  ,p_outcome                      in     varchar2
  ,p_adr_offered                  in     varchar2
  ,p_date_accepted                in     date
  ) is
--
  l_rec   ghr_cad_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_cad_shd.convert_args
  (p_compl_adr_id
  ,p_complaint_id
  ,p_stage
  ,p_start_date
  ,p_end_date
  ,p_adr_resource
  ,p_technique
  ,p_outcome
  ,p_adr_offered
  ,p_date_accepted
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ghr_cad_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_cad_upd;

/
