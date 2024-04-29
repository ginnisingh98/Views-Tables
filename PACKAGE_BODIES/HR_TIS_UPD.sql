--------------------------------------------------------
--  DDL for Package Body HR_TIS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIS_UPD" as
/* $Header: hrtisrhi.pkb 120.3 2008/02/25 13:24:06 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_tis_upd.';  -- Global package name
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
  (p_rec in out nocopy hr_tis_shd.g_rec_type
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
  -- Update the hr_ki_topic_integrations Row
  --
  update hr_ki_topic_integrations
    set
     topic_integrations_id         = p_rec.topic_integrations_id
    ,topic_id                      = p_rec.topic_id
    ,integration_id                = p_rec.integration_id
    ,param_name1                   = p_rec.param_name1
    ,param_value1                  = p_rec.param_value1
    ,param_name2                   = p_rec.param_name2
    ,param_value2                  = p_rec.param_value2
    ,param_name3                   = p_rec.param_name3
    ,param_value3                  = p_rec.param_value3
    ,param_name4                   = p_rec.param_name4
    ,param_value4                  = p_rec.param_value4
    ,param_name5                   = p_rec.param_name5
    ,param_value5                  = p_rec.param_value5
    ,param_name6                   = p_rec.param_name6
    ,param_value6                  = p_rec.param_value6
    ,param_name7                   = p_rec.param_name7
    ,param_value7                  = p_rec.param_value7
    ,param_name8                   = p_rec.param_name8
    ,param_value8                  = p_rec.param_value8
    ,param_name9                   = p_rec.param_name9
    ,param_value9                  = p_rec.param_value9
    ,param_name10                  = p_rec.param_name10
    ,param_value10                 = p_rec.param_value10
    ,object_version_number         = p_rec.object_version_number
    where topic_integrations_id    = p_rec.topic_integrations_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_tis_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_tis_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_tis_shd.constraint_error
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
  (p_rec in hr_tis_shd.g_rec_type
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
  (p_rec                          in hr_tis_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_tis_rku.after_update
      (p_topic_integrations_id    => p_rec.topic_integrations_id
      ,p_topic_id                 => p_rec.topic_id
      ,p_integration_id           => p_rec.integration_id
      ,p_param_name1              => p_rec.param_name1
      ,p_param_value1             => p_rec.param_value1
      ,p_param_name2              => p_rec.param_name2
      ,p_param_value2             => p_rec.param_value2
      ,p_param_name3              => p_rec.param_name3
      ,p_param_value3             => p_rec.param_value3
      ,p_param_name4              => p_rec.param_name4
      ,p_param_value4             => p_rec.param_value4
      ,p_param_name5              => p_rec.param_name5
      ,p_param_value5             => p_rec.param_value5
      ,p_param_name6              => p_rec.param_name6
      ,p_param_value6             => p_rec.param_value6
      ,p_param_name7              => p_rec.param_name7
      ,p_param_value7             => p_rec.param_value7
      ,p_param_name8              => p_rec.param_name8
      ,p_param_value8             => p_rec.param_value8
      ,p_param_name9              => p_rec.param_name9
      ,p_param_value9             => p_rec.param_value9
      ,p_param_name10             => p_rec.param_name10
      ,p_param_value10            => p_rec.param_value10
      ,p_object_version_number    => p_rec.object_version_number
      ,p_topic_id_o               => hr_tis_shd.g_old_rec.topic_id
      ,p_integration_id_o         => hr_tis_shd.g_old_rec.integration_id
      ,p_param_name1_o            => hr_tis_shd.g_old_rec.param_name1
      ,p_param_value1_o           => hr_tis_shd.g_old_rec.param_value1
      ,p_param_name2_o            => hr_tis_shd.g_old_rec.param_name2
      ,p_param_value2_o           => hr_tis_shd.g_old_rec.param_value2
      ,p_param_name3_o            => hr_tis_shd.g_old_rec.param_name3
      ,p_param_value3_o           => hr_tis_shd.g_old_rec.param_value3
      ,p_param_name4_o            => hr_tis_shd.g_old_rec.param_name4
      ,p_param_value4_o           => hr_tis_shd.g_old_rec.param_value4
      ,p_param_name5_o            => hr_tis_shd.g_old_rec.param_name5
      ,p_param_value5_o           => hr_tis_shd.g_old_rec.param_value5
      ,p_param_name6_o            => hr_tis_shd.g_old_rec.param_name6
      ,p_param_value6_o           => hr_tis_shd.g_old_rec.param_value6
      ,p_param_name7_o            => hr_tis_shd.g_old_rec.param_name7
      ,p_param_value7_o           => hr_tis_shd.g_old_rec.param_value7
      ,p_param_name8_o            => hr_tis_shd.g_old_rec.param_name8
      ,p_param_value8_o           => hr_tis_shd.g_old_rec.param_value8
      ,p_param_name9_o            => hr_tis_shd.g_old_rec.param_name9
      ,p_param_value9_o           => hr_tis_shd.g_old_rec.param_value9
      ,p_param_name10_o           => hr_tis_shd.g_old_rec.param_name10
      ,p_param_value10_o          => hr_tis_shd.g_old_rec.param_value10
      ,p_object_version_number_o  => hr_tis_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_TOPIC_INTEGRATIONS'
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
  (p_rec in out nocopy hr_tis_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.topic_id = hr_api.g_number) then
    p_rec.topic_id :=
    hr_tis_shd.g_old_rec.topic_id;
  End If;
  If (p_rec.integration_id = hr_api.g_number) then
    p_rec.integration_id :=
    hr_tis_shd.g_old_rec.integration_id;
  End If;
  If (p_rec.param_name1 = hr_api.g_varchar2) then
    p_rec.param_name1  := hr_tis_shd.g_old_rec.param_name1;
  End If;
  If (p_rec.param_value1 = hr_api.g_varchar2) then
    p_rec.param_value1  := hr_tis_shd.g_old_rec.param_value1;
  End If;
  If (p_rec.param_name2 = hr_api.g_varchar2) then
    p_rec.param_name2  := hr_tis_shd.g_old_rec.param_name2;
  End If;
  If (p_rec.param_value2 = hr_api.g_varchar2) then
    p_rec.param_value2  := hr_tis_shd.g_old_rec.param_value2;
  End If;
  If (p_rec.param_name3 = hr_api.g_varchar2) then
    p_rec.param_name3  := hr_tis_shd.g_old_rec.param_name3;
  End If;
  If (p_rec.param_value3 = hr_api.g_varchar2) then
    p_rec.param_value3  := hr_tis_shd.g_old_rec.param_value3;
  End If;
  If (p_rec.param_name4 = hr_api.g_varchar2) then
    p_rec.param_name4  := hr_tis_shd.g_old_rec.param_name4;
  End If;
  If (p_rec.param_value4 = hr_api.g_varchar2) then
    p_rec.param_value4  := hr_tis_shd.g_old_rec.param_value4;
  End If;
  If (p_rec.param_name5 = hr_api.g_varchar2) then
    p_rec.param_name5  := hr_tis_shd.g_old_rec.param_name5;
  End If;
  If (p_rec.param_value5 = hr_api.g_varchar2) then
    p_rec.param_value5  := hr_tis_shd.g_old_rec.param_value5;
  End If;
  If (p_rec.param_name6 = hr_api.g_varchar2) then
    p_rec.param_name6  := hr_tis_shd.g_old_rec.param_name6;
  End If;
  If (p_rec.param_value6 = hr_api.g_varchar2) then
    p_rec.param_value6  := hr_tis_shd.g_old_rec.param_value6;
  End If;
  If (p_rec.param_name7 = hr_api.g_varchar2) then
    p_rec.param_name7  := hr_tis_shd.g_old_rec.param_name7;
  End If;
  If (p_rec.param_value7 = hr_api.g_varchar2) then
    p_rec.param_value7  := hr_tis_shd.g_old_rec.param_value7;
  End If;
  If (p_rec.param_name8 = hr_api.g_varchar2) then
    p_rec.param_name8  := hr_tis_shd.g_old_rec.param_name8;
  End If;
  If (p_rec.param_value8 = hr_api.g_varchar2) then
    p_rec.param_value8  := hr_tis_shd.g_old_rec.param_value8;
  End If;
  If (p_rec.param_name9 = hr_api.g_varchar2) then
    p_rec.param_name9  := hr_tis_shd.g_old_rec.param_name9;
  End If;
  If (p_rec.param_value9 = hr_api.g_varchar2) then
    p_rec.param_value9  := hr_tis_shd.g_old_rec.param_value9;
  End If;
  If (p_rec.param_name10 = hr_api.g_varchar2) then
    p_rec.param_name10  := hr_tis_shd.g_old_rec.param_name10;
  End If;
  If (p_rec.param_value10 = hr_api.g_varchar2) then
    p_rec.param_value10  := hr_tis_shd.g_old_rec.param_value10;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy hr_tis_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  hr_tis_shd.lck
    (p_rec.topic_integrations_id
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
  hr_tis_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  hr_tis_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  hr_tis_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  hr_tis_upd.post_update
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
  (p_topic_integrations_id        in     number
  ,p_topic_id                     in     number   default hr_api.g_number
  ,p_integration_id               in     number   default hr_api.g_number
  ,p_param_name1                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value1                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name2                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value2                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name3                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value3                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name4                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value4                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name5                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value5                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name6                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value6                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name7                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value7                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name8                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value8                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name9                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value9                 in     varchar2 default hr_api.g_varchar2
  ,p_param_name10                 in     varchar2 default hr_api.g_varchar2
  ,p_param_value10                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ) is
--
  l_rec   hr_tis_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  hr_tis_shd.convert_args
  (p_topic_integrations_id
  ,p_topic_id
  ,p_integration_id
  ,p_param_name1
  ,p_param_value1
  ,p_param_name2
  ,p_param_value2
  ,p_param_name3
  ,p_param_value3
  ,p_param_name4
  ,p_param_value4
  ,p_param_name5
  ,p_param_value5
  ,p_param_name6
  ,p_param_value6
  ,p_param_name7
  ,p_param_value7
  ,p_param_name8
  ,p_param_value8
  ,p_param_name9
  ,p_param_value9
  ,p_param_name10
  ,p_param_value10
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  hr_tis_upd.upd
     (l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end hr_tis_upd;

/
