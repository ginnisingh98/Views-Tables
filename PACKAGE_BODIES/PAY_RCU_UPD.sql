--------------------------------------------------------
--  DDL for Package Body PAY_RCU_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RCU_UPD" as
/* $Header: pyrcurhi.pkb 120.1 2005/06/20 05:01:52 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rcu_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_rcu_shd.g_rec_type
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
  -- Update the pay_retro_component_usages Row
  --
  update pay_retro_component_usages
    set
     retro_component_usage_id        = p_rec.retro_component_usage_id
    ,retro_component_id              = p_rec.retro_component_id
    ,creator_id                      = p_rec.creator_id
    ,creator_type                    = p_rec.creator_type
    ,default_component               = p_rec.default_component
    ,reprocess_type                  = p_rec.reprocess_type
    ,object_version_number           = p_rec.object_version_number
    ,replace_run_flag		     = p_rec.replace_run_flag
    ,use_override_dates              = p_rec.use_override_dates
    where retro_component_usage_id = p_rec.retro_component_usage_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_rcu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_rcu_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_rcu_shd.constraint_error
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
  (p_rec in pay_rcu_shd.g_rec_type
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
  ,p_rec                          in pay_rcu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_rcu_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_retro_component_usage_id
      => p_rec.retro_component_usage_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_retro_component_id
      => p_rec.retro_component_id
      ,p_creator_id
      => p_rec.creator_id
      ,p_creator_type
      => p_rec.creator_type
      ,p_default_component
      => p_rec.default_component
      ,p_reprocess_type
      => p_rec.reprocess_type
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_replace_run_flag
      => p_rec.replace_run_flag
      ,p_use_override_dates
      => p_rec.use_override_dates
      ,p_business_group_id_o
      => pay_rcu_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_rcu_shd.g_old_rec.legislation_code
      ,p_retro_component_id_o
      => pay_rcu_shd.g_old_rec.retro_component_id
      ,p_creator_id_o
      => pay_rcu_shd.g_old_rec.creator_id
      ,p_creator_type_o
      => pay_rcu_shd.g_old_rec.creator_type
      ,p_default_component_o
      => pay_rcu_shd.g_old_rec.default_component
      ,p_reprocess_type_o
      => pay_rcu_shd.g_old_rec.reprocess_type
      ,p_object_version_number_o
      => pay_rcu_shd.g_old_rec.object_version_number
      ,p_replace_run_flag_o
      => pay_rcu_shd.g_old_rec.replace_run_flag
      ,p_use_override_dates_o
      => pay_rcu_shd.g_old_rec.use_override_dates
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RETRO_COMPONENT_USAGES'
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
  (p_rec in out nocopy pay_rcu_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pay_rcu_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_rcu_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.retro_component_id = hr_api.g_number) then
    p_rec.retro_component_id :=
    pay_rcu_shd.g_old_rec.retro_component_id;
  End If;
  If (p_rec.creator_id = hr_api.g_number) then
    p_rec.creator_id :=
    pay_rcu_shd.g_old_rec.creator_id;
  End If;
  If (p_rec.creator_type = hr_api.g_varchar2) then
    p_rec.creator_type :=
    pay_rcu_shd.g_old_rec.creator_type;
  End If;
  If (p_rec.default_component = hr_api.g_varchar2) then
    p_rec.default_component :=
    pay_rcu_shd.g_old_rec.default_component;
  End If;
  If (p_rec.reprocess_type = hr_api.g_varchar2) then
    p_rec.reprocess_type :=
    pay_rcu_shd.g_old_rec.reprocess_type;
  End If;
  If (p_rec.replace_run_flag = hr_api.g_varchar2) then
    p_rec.replace_run_flag :=
    pay_rcu_shd.g_old_rec.replace_run_flag;
  End If;
  If (p_rec.use_override_dates = hr_api.g_varchar2) then
    p_rec.use_override_dates :=
    pay_rcu_shd.g_old_rec.use_override_dates;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pay_rcu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_rcu_shd.lck
    (p_rec.retro_component_usage_id
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
  pay_rcu_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_rcu_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_rcu_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_rcu_upd.post_update
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
  ,p_retro_component_usage_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_retro_component_id           in     number    default hr_api.g_number
  ,p_creator_id                   in     number    default hr_api.g_number
  ,p_creator_type                 in     varchar2  default hr_api.g_varchar2
  ,p_default_component            in     varchar2  default hr_api.g_varchar2
  ,p_reprocess_type               in     varchar2  default hr_api.g_varchar2
  ,p_replace_run_flag		  in	 varchar2  default hr_api.g_varchar2
  ,p_use_override_dates		  in	 varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pay_rcu_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_rcu_shd.convert_args
  (p_retro_component_usage_id
  ,hr_api.g_number
  ,hr_api.g_varchar2
  ,p_retro_component_id
  ,p_creator_id
  ,p_creator_type
  ,p_default_component
  ,p_reprocess_type
  ,p_object_version_number
  ,p_replace_run_flag
  ,p_use_override_dates
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_rcu_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_rcu_upd;

/
