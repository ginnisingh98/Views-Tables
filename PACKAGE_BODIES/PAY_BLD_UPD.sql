--------------------------------------------------------
--  DDL for Package Body PAY_BLD_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLD_UPD" as
/* $Header: pybldrhi.pkb 120.0 2005/05/29 03:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bld_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  --
  -- Update the pay_balance_dimensions Row
  --
  update pay_balance_dimensions
    set
     balance_dimension_id            = p_rec.balance_dimension_id
    ,business_group_id               = p_rec.business_group_id
    ,legislation_code                = p_rec.legislation_code
    ,route_id                        = p_rec.route_id
    ,database_item_suffix            = p_rec.database_item_suffix
    ,dimension_name                  = p_rec.dimension_name
    ,dimension_type                  = p_rec.dimension_type
    ,description                     = p_rec.description
    ,feed_checking_code              = p_rec.feed_checking_code
    ,legislation_subgroup            = p_rec.legislation_subgroup
    ,payments_flag                   = p_rec.payments_flag
    ,expiry_checking_code            = p_rec.expiry_checking_code
    ,expiry_checking_level           = p_rec.expiry_checking_level
    ,feed_checking_type              = p_rec.feed_checking_type
    ,dimension_level                 = p_rec.dimension_level
    ,period_type                     = p_rec.period_type
    ,asg_action_balance_dim_id       = p_rec.asg_action_balance_dim_id
    ,database_item_function          = p_rec.database_item_function
    ,save_run_balance_enabled        = p_rec.save_run_balance_enabled
    ,start_date_code                 = p_rec.start_date_code
    where balance_dimension_id = p_rec.balance_dimension_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    pay_bld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    pay_bld_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    pay_bld_shd.constraint_error
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
  (p_rec in pay_bld_shd.g_rec_type
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
  (p_rec                          in pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_bld_rku.after_update
      (p_balance_dimension_id
      => p_rec.balance_dimension_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_legislation_code
      => p_rec.legislation_code
      ,p_route_id
      => p_rec.route_id
      ,p_database_item_suffix
      => p_rec.database_item_suffix
      ,p_dimension_name
      => p_rec.dimension_name
      ,p_dimension_type
      => p_rec.dimension_type
      ,p_description
      => p_rec.description
      ,p_feed_checking_code
      => p_rec.feed_checking_code
      ,p_legislation_subgroup
      => p_rec.legislation_subgroup
      ,p_payments_flag
      => p_rec.payments_flag
      ,p_expiry_checking_code
      => p_rec.expiry_checking_code
      ,p_expiry_checking_level
      => p_rec.expiry_checking_level
      ,p_feed_checking_type
      => p_rec.feed_checking_type
      ,p_dimension_level
      => p_rec.dimension_level
      ,p_period_type
      => p_rec.period_type
      ,p_asg_action_balance_dim_id
      => p_rec.asg_action_balance_dim_id
      ,p_database_item_function
      => p_rec.database_item_function
      ,p_save_run_balance_enabled
      => p_rec.save_run_balance_enabled
      ,p_start_date_code
      => p_rec.start_date_code
      ,p_business_group_id_o
      => pay_bld_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_bld_shd.g_old_rec.legislation_code
      ,p_route_id_o
      => pay_bld_shd.g_old_rec.route_id
      ,p_database_item_suffix_o
      => pay_bld_shd.g_old_rec.database_item_suffix
      ,p_dimension_name_o
      => pay_bld_shd.g_old_rec.dimension_name
      ,p_dimension_type_o
      => pay_bld_shd.g_old_rec.dimension_type
      ,p_description_o
      => pay_bld_shd.g_old_rec.description
      ,p_feed_checking_code_o
      => pay_bld_shd.g_old_rec.feed_checking_code
      ,p_legislation_subgroup_o
      => pay_bld_shd.g_old_rec.legislation_subgroup
      ,p_payments_flag_o
      => pay_bld_shd.g_old_rec.payments_flag
      ,p_expiry_checking_code_o
      => pay_bld_shd.g_old_rec.expiry_checking_code
      ,p_expiry_checking_level_o
      => pay_bld_shd.g_old_rec.expiry_checking_level
      ,p_feed_checking_type_o
      => pay_bld_shd.g_old_rec.feed_checking_type
      ,p_dimension_level_o
      => pay_bld_shd.g_old_rec.dimension_level
      ,p_period_type_o
      => pay_bld_shd.g_old_rec.period_type
      ,p_asg_action_balance_dim_id_o
      => pay_bld_shd.g_old_rec.asg_action_balance_dim_id
      ,p_database_item_function_o
      => pay_bld_shd.g_old_rec.database_item_function
      ,p_save_run_balance_enabled_o
      => pay_bld_shd.g_old_rec.save_run_balance_enabled
      ,p_start_date_code_o
      => pay_bld_shd.g_old_rec.start_date_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_DIMENSIONS'
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
  (p_rec in out nocopy pay_bld_shd.g_rec_type
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
    pay_bld_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_bld_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.route_id = hr_api.g_number) then
    p_rec.route_id :=
    pay_bld_shd.g_old_rec.route_id;
  End If;
  If (p_rec.database_item_suffix = hr_api.g_varchar2) then
    p_rec.database_item_suffix :=
    pay_bld_shd.g_old_rec.database_item_suffix;
  End If;
  If (p_rec.dimension_name = hr_api.g_varchar2) then
    p_rec.dimension_name :=
    pay_bld_shd.g_old_rec.dimension_name;
  End If;
  If (p_rec.dimension_type = hr_api.g_varchar2) then
    p_rec.dimension_type :=
    pay_bld_shd.g_old_rec.dimension_type;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    pay_bld_shd.g_old_rec.description;
  End If;
  If (p_rec.feed_checking_code = hr_api.g_varchar2) then
    p_rec.feed_checking_code :=
    pay_bld_shd.g_old_rec.feed_checking_code;
  End If;
  If (p_rec.legislation_subgroup = hr_api.g_varchar2) then
    p_rec.legislation_subgroup :=
    pay_bld_shd.g_old_rec.legislation_subgroup;
  End If;
  If (p_rec.payments_flag = hr_api.g_varchar2) then
    p_rec.payments_flag :=
    pay_bld_shd.g_old_rec.payments_flag;
  End If;
  If (p_rec.expiry_checking_code = hr_api.g_varchar2) then
    p_rec.expiry_checking_code :=
    pay_bld_shd.g_old_rec.expiry_checking_code;
  End If;
  If (p_rec.expiry_checking_level = hr_api.g_varchar2) then
    p_rec.expiry_checking_level :=
    pay_bld_shd.g_old_rec.expiry_checking_level;
  End If;
  If (p_rec.feed_checking_type = hr_api.g_varchar2) then
    p_rec.feed_checking_type :=
    pay_bld_shd.g_old_rec.feed_checking_type;
  End If;
  If (p_rec.dimension_level = hr_api.g_varchar2) then
    p_rec.dimension_level :=
    pay_bld_shd.g_old_rec.dimension_level;
  End If;
  If (p_rec.period_type = hr_api.g_varchar2) then
    p_rec.period_type :=
    pay_bld_shd.g_old_rec.period_type;
  End If;
  If (p_rec.asg_action_balance_dim_id = hr_api.g_number) then
    p_rec.asg_action_balance_dim_id :=
    pay_bld_shd.g_old_rec.asg_action_balance_dim_id;
  End If;
  If (p_rec.database_item_function = hr_api.g_varchar2) then
    p_rec.database_item_function :=
    pay_bld_shd.g_old_rec.database_item_function;
  End If;
  If (p_rec.save_run_balance_enabled = hr_api.g_varchar2) then
    p_rec.save_run_balance_enabled :=
    pay_bld_shd.g_old_rec.save_run_balance_enabled;
  End If;
  If (p_rec.start_date_code = hr_api.g_varchar2) then
    p_rec.start_date_code :=
    pay_bld_shd.g_old_rec.start_date_code;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec                          in out nocopy pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_bld_shd.lck
    (p_rec.balance_dimension_id
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_bld_bus.update_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_bld_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_bld_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_bld_upd.post_update
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
  (p_balance_dimension_id         in     number
  ,p_route_id                     in     number    default hr_api.g_number
  ,p_database_item_suffix         in     varchar2  default hr_api.g_varchar2
  ,p_dimension_name               in     varchar2  default hr_api.g_varchar2
  ,p_dimension_type               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_feed_checking_code           in     varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup         in     varchar2  default hr_api.g_varchar2
  ,p_payments_flag                in     varchar2  default hr_api.g_varchar2
  ,p_expiry_checking_code         in     varchar2  default hr_api.g_varchar2
  ,p_expiry_checking_level        in     varchar2  default hr_api.g_varchar2
  ,p_feed_checking_type           in     varchar2  default hr_api.g_varchar2
  ,p_dimension_level              in     varchar2  default hr_api.g_varchar2
  ,p_period_type                  in     varchar2  default hr_api.g_varchar2
  ,p_asg_action_balance_dim_id    in     number    default hr_api.g_number
  ,p_database_item_function       in     varchar2  default hr_api.g_varchar2
  ,p_save_run_balance_enabled     in     varchar2  default hr_api.g_varchar2
  ,p_start_date_code              in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   pay_bld_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_bld_shd.convert_args
  (p_balance_dimension_id
  ,p_business_group_id
  ,p_legislation_code
  ,p_route_id
  ,p_database_item_suffix
  ,p_dimension_name
  ,p_dimension_type
  ,p_description
  ,p_feed_checking_code
  ,p_legislation_subgroup
  ,p_payments_flag
  ,p_expiry_checking_code
  ,p_expiry_checking_level
  ,p_feed_checking_type
  ,p_dimension_level
  ,p_period_type
  ,p_asg_action_balance_dim_id
  ,p_database_item_function
  ,p_save_run_balance_enabled
  ,p_start_date_code
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_bld_upd.upd
     (l_rec
     );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_bld_upd;

/
