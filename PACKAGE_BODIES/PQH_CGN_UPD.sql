--------------------------------------------------------
--  DDL for Package Body PQH_CGN_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CGN_UPD" as
/* $Header: pqcgnrhi.pkb 115.7 2002/11/27 04:43:27 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cgn_upd.';  -- Global package name
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
  (p_rec in out nocopy pqh_cgn_shd.g_rec_type
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
  -- Update the pqh_de_case_groups Row
  --
  update pqh_de_case_groups
    set
     case_group_id                   = p_rec.case_group_id
    ,case_group_number               = p_rec.case_group_number
    ,description                     = p_rec.description
    ,advanced_pay_grade              = p_rec.advanced_pay_grade
    ,entries_in_minute               = p_rec.entries_in_minute
    ,period_of_prob_advmnt           = p_rec.period_of_prob_advmnt
    ,period_of_time_advmnt           = p_rec.period_of_time_advmnt
    ,advancement_to                  = p_rec.advancement_to
    ,object_version_number           = p_rec.object_version_number
    ,advancement_additional_pyt      = p_rec.advancement_additional_pyt
    ,time_advanced_pay_grade         = p_rec.time_advanced_pay_grade
    ,time_advancement_to             = p_rec.time_advancement_to
    ,business_group_id               = p_rec.business_group_id
    ,time_advn_units                 = p_rec.time_advn_units
    ,prob_advn_units                 = p_rec.prob_advn_units
    ,sub_csgrp_description           = p_rec.sub_csgrp_description
    where case_group_id = p_rec.case_group_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pqh_cgn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pqh_cgn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pqh_cgn_shd.constraint_error
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
  (p_rec in pqh_cgn_shd.g_rec_type
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
  ,p_rec                          in pqh_cgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pqh_cgn_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_case_group_id
      => p_rec.case_group_id
      ,p_case_group_number
      => p_rec.case_group_number
      ,p_description
      => p_rec.description
      ,p_advanced_pay_grade
      => p_rec.advanced_pay_grade
      ,p_entries_in_minute
      => p_rec.entries_in_minute
      ,p_period_of_prob_advmnt
      => p_rec.period_of_prob_advmnt
      ,p_period_of_time_advmnt
      => p_rec.period_of_time_advmnt
      ,p_advancement_to
      => p_rec.advancement_to
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_advancement_additional_pyt
      => p_rec.advancement_additional_pyt
      ,p_time_advanced_pay_grade
      => p_rec.time_advanced_pay_grade
      ,p_time_advancement_to
      => p_rec.time_advancement_to
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_time_advn_units
      => p_rec.time_advn_units
      ,p_prob_advn_units
      => p_rec.prob_advn_units
      ,p_sub_csgrp_description
      => p_rec.sub_csgrp_description
      ,p_case_group_number_o
      => pqh_cgn_shd.g_old_rec.case_group_number
      ,p_description_o
      => pqh_cgn_shd.g_old_rec.description
      ,p_advanced_pay_grade_o
      => pqh_cgn_shd.g_old_rec.advanced_pay_grade
      ,p_entries_in_minute_o
      => pqh_cgn_shd.g_old_rec.entries_in_minute
      ,p_period_of_prob_advmnt_o
      => pqh_cgn_shd.g_old_rec.period_of_prob_advmnt
      ,p_period_of_time_advmnt_o
      => pqh_cgn_shd.g_old_rec.period_of_time_advmnt
      ,p_advancement_to_o
      => pqh_cgn_shd.g_old_rec.advancement_to
      ,p_object_version_number_o
      => pqh_cgn_shd.g_old_rec.object_version_number
      ,p_advancement_additional_pyt_o
      => pqh_cgn_shd.g_old_rec.advancement_additional_pyt
      ,p_time_advanced_pay_grade_o
      => pqh_cgn_shd.g_old_rec.time_advanced_pay_grade
      ,p_time_advancement_to_o
      => pqh_cgn_shd.g_old_rec.time_advancement_to
      ,p_business_group_id_o
      => pqh_cgn_shd.g_old_rec.business_group_id
      ,p_time_advn_units_o
      => pqh_cgn_shd.g_old_rec.time_advn_units
      ,p_prob_advn_units_o
      => pqh_cgn_shd.g_old_rec.prob_advn_units
      ,p_sub_csgrp_description_o
      => pqh_cgn_shd.g_old_rec.sub_csgrp_description
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_DE_CASE_GROUPS'
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
  (p_rec in out nocopy pqh_cgn_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.case_group_number = hr_api.g_varchar2) then
    p_rec.case_group_number :=
    pqh_cgn_shd.g_old_rec.case_group_number;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pqh_cgn_shd.g_old_rec.description;
  End If;
  If (p_rec.advanced_pay_grade = hr_api.g_number) then
    p_rec.advanced_pay_grade :=
    pqh_cgn_shd.g_old_rec.advanced_pay_grade;
  End If;
  If (p_rec.entries_in_minute = hr_api.g_varchar2) then
    p_rec.entries_in_minute :=
    pqh_cgn_shd.g_old_rec.entries_in_minute;
  End If;
  If (p_rec.period_of_prob_advmnt = hr_api.g_number) then
    p_rec.period_of_prob_advmnt :=
    pqh_cgn_shd.g_old_rec.period_of_prob_advmnt;
  End If;
  If (p_rec.period_of_time_advmnt = hr_api.g_number) then
    p_rec.period_of_time_advmnt :=
    pqh_cgn_shd.g_old_rec.period_of_time_advmnt;
  End If;
  If (p_rec.advancement_to = hr_api.g_number) then
    p_rec.advancement_to :=
    pqh_cgn_shd.g_old_rec.advancement_to;
  End If;
  If (p_rec.advancement_additional_pyt = hr_api.g_number) then
    p_rec.advancement_additional_pyt :=
    pqh_cgn_shd.g_old_rec.advancement_additional_pyt;
  End If;
  If (p_rec.time_advanced_pay_grade = hr_api.g_number) then
    p_rec.time_advanced_pay_grade :=
    pqh_cgn_shd.g_old_rec.time_advanced_pay_grade;
  End If;
  If (p_rec.time_advancement_to = hr_api.g_number) then
    p_rec.time_advancement_to :=
    pqh_cgn_shd.g_old_rec.time_advancement_to;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqh_cgn_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.time_advn_units = hr_api.g_varchar2) then
    p_rec.time_advn_units :=
    pqh_cgn_shd.g_old_rec.time_advn_units;
  End If;
  If (p_rec.prob_advn_units = hr_api.g_varchar2) then
    p_rec.prob_advn_units :=
    pqh_cgn_shd.g_old_rec.prob_advn_units;
  End If;
  If (p_rec.sub_csgrp_description = hr_api.g_varchar2) then
    p_rec.sub_csgrp_description :=
    pqh_cgn_shd.g_old_rec.sub_csgrp_description;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pqh_cgn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- We must lock the row which we need to update.
  --


  pqh_cgn_shd.lck
    (p_rec.case_group_id
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
  pqh_cgn_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pqh_cgn_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pqh_cgn_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pqh_cgn_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_case_group_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_case_group_number            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_advanced_pay_grade           in     number    default hr_api.g_number
  ,p_entries_in_minute            in     varchar2  default hr_api.g_varchar2
  ,p_period_of_prob_advmnt        in     number    default hr_api.g_number
  ,p_period_of_time_advmnt        in     number    default hr_api.g_number
  ,p_advancement_to               in     number    default hr_api.g_number
  ,p_advancement_additional_pyt   in     number    default hr_api.g_number
  ,p_time_advanced_pay_grade      in     number    default hr_api.g_number
  ,p_time_advancement_to          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_time_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_prob_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_sub_csgrp_description        in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pqh_cgn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pqh_cgn_shd.convert_args
  (p_case_group_id
  ,p_case_group_number
  ,p_description
  ,p_advanced_pay_grade
  ,p_entries_in_minute
  ,p_period_of_prob_advmnt
  ,p_period_of_time_advmnt
  ,p_advancement_to
  ,p_object_version_number
  ,p_advancement_additional_pyt
  ,p_time_advanced_pay_grade
  ,p_time_advancement_to
  ,p_business_group_id
  ,p_time_advn_units
  ,p_prob_advn_units
  ,p_sub_csgrp_description
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pqh_cgn_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pqh_cgn_upd;

/
