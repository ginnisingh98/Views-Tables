--------------------------------------------------------
--  DDL for Package Body HR_CTX_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CTX_UPD" as
/* $Header: hrctxrhi.pkb 120.0 2005/05/30 23:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ctx_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_ctx_shd.g_rec_type
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
  -- Update the hr_ki_contexts Row
  --
  update hr_ki_contexts
    set
     context_id                      = p_rec.context_id
    ,view_name                       = p_rec.view_name
    ,param_1                         = p_rec.param_1
    ,param_2                         = p_rec.param_2
    ,param_3                         = p_rec.param_3
    ,param_4                         = p_rec.param_4
    ,param_5                         = p_rec.param_5
    ,param_6                         = p_rec.param_6
    ,param_7                         = p_rec.param_7
    ,param_8                         = p_rec.param_8
    ,param_9                         = p_rec.param_9
    ,param_10                        = p_rec.param_10
    ,param_11                        = p_rec.param_11
    ,param_12                        = p_rec.param_12
    ,param_13                        = p_rec.param_13
    ,param_14                        = p_rec.param_14
    ,param_15                        = p_rec.param_15
    ,param_16                        = p_rec.param_16
    ,param_17                        = p_rec.param_17
    ,param_18                        = p_rec.param_18
    ,param_19                        = p_rec.param_19
    ,param_20                        = p_rec.param_20
    ,param_21                        = p_rec.param_21
    ,param_22                        = p_rec.param_22
    ,param_23                        = p_rec.param_23
    ,param_24                        = p_rec.param_24
    ,param_25                        = p_rec.param_25
    ,param_26                        = p_rec.param_26
    ,param_27                        = p_rec.param_27
    ,param_28                        = p_rec.param_28
    ,param_29                        = p_rec.param_29
    ,param_30                        = p_rec.param_30
    ,object_version_number           = p_rec.object_version_number
    where context_id = p_rec.context_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_ctx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_ctx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_ctx_shd.constraint_error
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
  (p_rec in hr_ctx_shd.g_rec_type
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
  (p_rec                          in hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_ctx_rku.after_update
      (p_context_id
      => p_rec.context_id
      ,p_view_name
      => p_rec.view_name
      ,p_param_1
      => p_rec.param_1
      ,p_param_2
      => p_rec.param_2
      ,p_param_3
      => p_rec.param_3
      ,p_param_4
      => p_rec.param_4
      ,p_param_5
      => p_rec.param_5
      ,p_param_6
      => p_rec.param_6
      ,p_param_7
      => p_rec.param_7
      ,p_param_8
      => p_rec.param_8
      ,p_param_9
      => p_rec.param_9
      ,p_param_10
      => p_rec.param_10
      ,p_param_11
      => p_rec.param_11
      ,p_param_12
      => p_rec.param_12
      ,p_param_13
      => p_rec.param_13
      ,p_param_14
      => p_rec.param_14
      ,p_param_15
      => p_rec.param_15
      ,p_param_16
      => p_rec.param_16
      ,p_param_17
      => p_rec.param_17
      ,p_param_18
      => p_rec.param_18
      ,p_param_19
      => p_rec.param_19
      ,p_param_20
      => p_rec.param_20
      ,p_param_21
      => p_rec.param_21
      ,p_param_22
      => p_rec.param_22
      ,p_param_23
      => p_rec.param_23
      ,p_param_24
      => p_rec.param_24
      ,p_param_25
      => p_rec.param_25
      ,p_param_26
      => p_rec.param_26
      ,p_param_27
      => p_rec.param_27
      ,p_param_28
      => p_rec.param_28
      ,p_param_29
      => p_rec.param_29
      ,p_param_30
      => p_rec.param_30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_view_name_o
      => hr_ctx_shd.g_old_rec.view_name
      ,p_param_1_o
      => hr_ctx_shd.g_old_rec.param_1
      ,p_param_2_o
      => hr_ctx_shd.g_old_rec.param_2
      ,p_param_3_o
      => hr_ctx_shd.g_old_rec.param_3
      ,p_param_4_o
      => hr_ctx_shd.g_old_rec.param_4
      ,p_param_5_o
      => hr_ctx_shd.g_old_rec.param_5
      ,p_param_6_o
      => hr_ctx_shd.g_old_rec.param_6
      ,p_param_7_o
      => hr_ctx_shd.g_old_rec.param_7
      ,p_param_8_o
      => hr_ctx_shd.g_old_rec.param_8
      ,p_param_9_o
      => hr_ctx_shd.g_old_rec.param_9
      ,p_param_10_o
      => hr_ctx_shd.g_old_rec.param_10
      ,p_param_11_o
      => hr_ctx_shd.g_old_rec.param_11
      ,p_param_12_o
      => hr_ctx_shd.g_old_rec.param_12
      ,p_param_13_o
      => hr_ctx_shd.g_old_rec.param_13
      ,p_param_14_o
      => hr_ctx_shd.g_old_rec.param_14
      ,p_param_15_o
      => hr_ctx_shd.g_old_rec.param_15
      ,p_param_16_o
      => hr_ctx_shd.g_old_rec.param_16
      ,p_param_17_o
      => hr_ctx_shd.g_old_rec.param_17
      ,p_param_18_o
      => hr_ctx_shd.g_old_rec.param_18
      ,p_param_19_o
      => hr_ctx_shd.g_old_rec.param_19
      ,p_param_20_o
      => hr_ctx_shd.g_old_rec.param_20
      ,p_param_21_o
      => hr_ctx_shd.g_old_rec.param_21
      ,p_param_22_o
      => hr_ctx_shd.g_old_rec.param_22
      ,p_param_23_o
      => hr_ctx_shd.g_old_rec.param_23
      ,p_param_24_o
      => hr_ctx_shd.g_old_rec.param_24
      ,p_param_25_o
      => hr_ctx_shd.g_old_rec.param_25
      ,p_param_26_o
      => hr_ctx_shd.g_old_rec.param_26
      ,p_param_27_o
      => hr_ctx_shd.g_old_rec.param_27
      ,p_param_28_o
      => hr_ctx_shd.g_old_rec.param_28
      ,p_param_29_o
      => hr_ctx_shd.g_old_rec.param_29
      ,p_param_30_o
      => hr_ctx_shd.g_old_rec.param_30
      ,p_object_version_number_o
      => hr_ctx_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_CONTEXTS'
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
  (p_rec in out nocopy hr_ctx_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.view_name = hr_api.g_varchar2) then
    p_rec.view_name :=
    hr_ctx_shd.g_old_rec.view_name;
  End If;
  If (p_rec.param_1 = hr_api.g_varchar2) then
    p_rec.param_1 :=
    hr_ctx_shd.g_old_rec.param_1;
  End If;
  If (p_rec.param_2 = hr_api.g_varchar2) then
    p_rec.param_2 :=
    hr_ctx_shd.g_old_rec.param_2;
  End If;
  If (p_rec.param_3 = hr_api.g_varchar2) then
    p_rec.param_3 :=
    hr_ctx_shd.g_old_rec.param_3;
  End If;
  If (p_rec.param_4 = hr_api.g_varchar2) then
    p_rec.param_4 :=
    hr_ctx_shd.g_old_rec.param_4;
  End If;
  If (p_rec.param_5 = hr_api.g_varchar2) then
    p_rec.param_5 :=
    hr_ctx_shd.g_old_rec.param_5;
  End If;
  If (p_rec.param_6 = hr_api.g_varchar2) then
    p_rec.param_6 :=
    hr_ctx_shd.g_old_rec.param_6;
  End If;
  If (p_rec.param_7 = hr_api.g_varchar2) then
    p_rec.param_7 :=
    hr_ctx_shd.g_old_rec.param_7;
  End If;
  If (p_rec.param_8 = hr_api.g_varchar2) then
    p_rec.param_8 :=
    hr_ctx_shd.g_old_rec.param_8;
  End If;
  If (p_rec.param_9 = hr_api.g_varchar2) then
    p_rec.param_9 :=
    hr_ctx_shd.g_old_rec.param_9;
  End If;
  If (p_rec.param_10 = hr_api.g_varchar2) then
    p_rec.param_10 :=
    hr_ctx_shd.g_old_rec.param_10;
  End If;
  If (p_rec.param_11 = hr_api.g_varchar2) then
    p_rec.param_11 :=
    hr_ctx_shd.g_old_rec.param_11;
  End If;
  If (p_rec.param_12 = hr_api.g_varchar2) then
    p_rec.param_12 :=
    hr_ctx_shd.g_old_rec.param_12;
  End If;
  If (p_rec.param_13 = hr_api.g_varchar2) then
    p_rec.param_13 :=
    hr_ctx_shd.g_old_rec.param_13;
  End If;
  If (p_rec.param_14 = hr_api.g_varchar2) then
    p_rec.param_14 :=
    hr_ctx_shd.g_old_rec.param_14;
  End If;
  If (p_rec.param_15 = hr_api.g_varchar2) then
    p_rec.param_15 :=
    hr_ctx_shd.g_old_rec.param_15;
  End If;
  If (p_rec.param_16 = hr_api.g_varchar2) then
    p_rec.param_16 :=
    hr_ctx_shd.g_old_rec.param_16;
  End If;
  If (p_rec.param_17 = hr_api.g_varchar2) then
    p_rec.param_17 :=
    hr_ctx_shd.g_old_rec.param_17;
  End If;
  If (p_rec.param_18 = hr_api.g_varchar2) then
    p_rec.param_18 :=
    hr_ctx_shd.g_old_rec.param_18;
  End If;
  If (p_rec.param_19 = hr_api.g_varchar2) then
    p_rec.param_19 :=
    hr_ctx_shd.g_old_rec.param_19;
  End If;
  If (p_rec.param_20 = hr_api.g_varchar2) then
    p_rec.param_20 :=
    hr_ctx_shd.g_old_rec.param_20;
  End If;
  If (p_rec.param_21 = hr_api.g_varchar2) then
    p_rec.param_21 :=
    hr_ctx_shd.g_old_rec.param_21;
  End If;
  If (p_rec.param_22 = hr_api.g_varchar2) then
    p_rec.param_22 :=
    hr_ctx_shd.g_old_rec.param_22;
  End If;
  If (p_rec.param_23 = hr_api.g_varchar2) then
    p_rec.param_23 :=
    hr_ctx_shd.g_old_rec.param_23;
  End If;
  If (p_rec.param_24 = hr_api.g_varchar2) then
    p_rec.param_24 :=
    hr_ctx_shd.g_old_rec.param_24;
  End If;
  If (p_rec.param_25 = hr_api.g_varchar2) then
    p_rec.param_25 :=
    hr_ctx_shd.g_old_rec.param_25;
  End If;
  If (p_rec.param_26 = hr_api.g_varchar2) then
    p_rec.param_26 :=
    hr_ctx_shd.g_old_rec.param_26;
  End If;
  If (p_rec.param_27 = hr_api.g_varchar2) then
    p_rec.param_27 :=
    hr_ctx_shd.g_old_rec.param_27;
  End If;
  If (p_rec.param_28 = hr_api.g_varchar2) then
    p_rec.param_28 :=
    hr_ctx_shd.g_old_rec.param_28;
  End If;
  If (p_rec.param_29 = hr_api.g_varchar2) then
    p_rec.param_29 :=
    hr_ctx_shd.g_old_rec.param_29;
  End If;
  If (p_rec.param_30 = hr_api.g_varchar2) then
    p_rec.param_30 :=
    hr_ctx_shd.g_old_rec.param_30;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_ctx_shd.lck
    (p_rec.context_id
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
  hr_ctx_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_ctx_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_ctx_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_ctx_upd.post_update
     (p_rec
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
  (p_context_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_view_name                    in     varchar2  default hr_api.g_varchar2
  ,p_param_1                      in     varchar2  default hr_api.g_varchar2
  ,p_param_2                      in     varchar2  default hr_api.g_varchar2
  ,p_param_3                      in     varchar2  default hr_api.g_varchar2
  ,p_param_4                      in     varchar2  default hr_api.g_varchar2
  ,p_param_5                      in     varchar2  default hr_api.g_varchar2
  ,p_param_6                      in     varchar2  default hr_api.g_varchar2
  ,p_param_7                      in     varchar2  default hr_api.g_varchar2
  ,p_param_8                      in     varchar2  default hr_api.g_varchar2
  ,p_param_9                      in     varchar2  default hr_api.g_varchar2
  ,p_param_10                     in     varchar2  default hr_api.g_varchar2
  ,p_param_11                     in     varchar2  default hr_api.g_varchar2
  ,p_param_12                     in     varchar2  default hr_api.g_varchar2
  ,p_param_13                     in     varchar2  default hr_api.g_varchar2
  ,p_param_14                     in     varchar2  default hr_api.g_varchar2
  ,p_param_15                     in     varchar2  default hr_api.g_varchar2
  ,p_param_16                     in     varchar2  default hr_api.g_varchar2
  ,p_param_17                     in     varchar2  default hr_api.g_varchar2
  ,p_param_18                     in     varchar2  default hr_api.g_varchar2
  ,p_param_19                     in     varchar2  default hr_api.g_varchar2
  ,p_param_20                     in     varchar2  default hr_api.g_varchar2
  ,p_param_21                     in     varchar2  default hr_api.g_varchar2
  ,p_param_22                     in     varchar2  default hr_api.g_varchar2
  ,p_param_23                     in     varchar2  default hr_api.g_varchar2
  ,p_param_24                     in     varchar2  default hr_api.g_varchar2
  ,p_param_25                     in     varchar2  default hr_api.g_varchar2
  ,p_param_26                     in     varchar2  default hr_api.g_varchar2
  ,p_param_27                     in     varchar2  default hr_api.g_varchar2
  ,p_param_28                     in     varchar2  default hr_api.g_varchar2
  ,p_param_29                     in     varchar2  default hr_api.g_varchar2
  ,p_param_30                     in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   hr_ctx_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_ctx_shd.convert_args
  (p_context_id
  ,p_view_name
  ,p_param_1
  ,p_param_2
  ,p_param_3
  ,p_param_4
  ,p_param_5
  ,p_param_6
  ,p_param_7
  ,p_param_8
  ,p_param_9
  ,p_param_10
  ,p_param_11
  ,p_param_12
  ,p_param_13
  ,p_param_14
  ,p_param_15
  ,p_param_16
  ,p_param_17
  ,p_param_18
  ,p_param_19
  ,p_param_20
  ,p_param_21
  ,p_param_22
  ,p_param_23
  ,p_param_24
  ,p_param_25
  ,p_param_26
  ,p_param_27
  ,p_param_28
  ,p_param_29
  ,p_param_30
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_ctx_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_ctx_upd;

/
