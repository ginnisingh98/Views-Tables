--------------------------------------------------------
--  DDL for Package Body PAY_BLT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLT_UPD" as
/* $Header: pybltrhi.pkb 120.0.12010000.2 2008/10/16 09:57:17 asnell ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_blt_upd.';  -- Global package name
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
  (p_rec in out nocopy pay_blt_shd.g_rec_type
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
  pay_blt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the pay_balance_types Row
  --
  update pay_balance_types
    set
     balance_type_id                 = p_rec.balance_type_id
    ,business_group_id               = p_rec.business_group_id
    ,legislation_code                = p_rec.legislation_code
    ,currency_code                   = p_rec.currency_code
    ,assignment_remuneration_flag    = p_rec.assignment_remuneration_flag
    ,balance_name                    = p_rec.balance_name
    ,balance_uom                     = p_rec.balance_uom
    ,comments                        = p_rec.comments
    ,legislation_subgroup            = p_rec.legislation_subgroup
    ,reporting_name                  = p_rec.reporting_name
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,jurisdiction_level              = p_rec.jurisdiction_level
    ,tax_type                        = p_rec.tax_type
    ,object_version_number           = p_rec.object_version_number
    ,balance_category_id             = p_rec.balance_category_id
    ,base_balance_type_id            = p_rec.base_balance_type_id
    ,input_value_id                  = p_rec.input_value_id
    where balance_type_id = p_rec.balance_type_id;
  --
  pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
    pay_blt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
    pay_blt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
    pay_blt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_rec in pay_blt_shd.g_rec_type
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
  ,p_rec                          in pay_blt_shd.g_rec_type
  ,p_balance_name_warning         in number
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    pay_blt_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_balance_type_id             => p_rec.balance_type_id
      ,p_business_group_id           => p_rec.business_group_id
      ,p_legislation_code            => p_rec.legislation_code
      ,p_currency_code               => p_rec.currency_code
      ,p_assignment_remuneration_flag  => p_rec.assignment_remuneration_flag
      ,p_balance_name                  => p_rec.balance_name
      ,p_balance_uom                   => p_rec.balance_uom
      ,p_comments                      => p_rec.comments
      ,p_legislation_subgroup          => p_rec.legislation_subgroup
      ,p_reporting_name                => p_rec.reporting_name
      ,p_attribute_category            => p_rec.attribute_category
      ,p_attribute1                    => p_rec.attribute1
      ,p_attribute2                    => p_rec.attribute2
      ,p_attribute3                    => p_rec.attribute3
      ,p_attribute4                    => p_rec.attribute4
      ,p_attribute5                    => p_rec.attribute5
      ,p_attribute6                    => p_rec.attribute6
      ,p_attribute7                    => p_rec.attribute7
      ,p_attribute8                    => p_rec.attribute8
      ,p_attribute9                    => p_rec.attribute9
      ,p_attribute10                   => p_rec.attribute10
      ,p_attribute11                   => p_rec.attribute11
      ,p_attribute12                   => p_rec.attribute12
      ,p_attribute13                   => p_rec.attribute13
      ,p_attribute14                   => p_rec.attribute14
      ,p_attribute15                   => p_rec.attribute15
      ,p_attribute16                   => p_rec.attribute16
      ,p_attribute17                   => p_rec.attribute17
      ,p_attribute18                   => p_rec.attribute18
      ,p_attribute19                   => p_rec.attribute19
      ,p_attribute20                   => p_rec.attribute20
      ,p_jurisdiction_level            => p_rec.jurisdiction_level
      ,p_tax_type                      => p_rec.tax_type
      ,p_object_version_number         => p_rec.object_version_number
      ,p_balance_category_id           => p_rec.balance_category_id
      ,p_base_balance_type_id          => p_rec.base_balance_type_id
      ,p_input_value_id                => p_rec.input_value_id
      ,p_balance_name_warning     => p_balance_name_warning
      ,p_business_group_id_o      => pay_blt_shd.g_old_rec.business_group_id
      ,p_legislation_code_o       => pay_blt_shd.g_old_rec.legislation_code
      ,p_currency_code_o          => pay_blt_shd.g_old_rec.currency_code
      ,p_assignment_remuneration_fl_o
                           => pay_blt_shd.g_old_rec.assignment_remuneration_flag
      ,p_balance_name_o           => pay_blt_shd.g_old_rec.balance_name
      ,p_balance_uom_o            => pay_blt_shd.g_old_rec.balance_uom
      ,p_comments_o               => pay_blt_shd.g_old_rec.comments
      ,p_legislation_subgroup_o   => pay_blt_shd.g_old_rec.legislation_subgroup
      ,p_reporting_name_o         => pay_blt_shd.g_old_rec.reporting_name
      ,p_attribute_category_o     => pay_blt_shd.g_old_rec.attribute_category
      ,p_attribute1_o             => pay_blt_shd.g_old_rec.attribute1
      ,p_attribute2_o             => pay_blt_shd.g_old_rec.attribute2
      ,p_attribute3_o             => pay_blt_shd.g_old_rec.attribute3
      ,p_attribute4_o             => pay_blt_shd.g_old_rec.attribute4
      ,p_attribute5_o             => pay_blt_shd.g_old_rec.attribute5
      ,p_attribute6_o             => pay_blt_shd.g_old_rec.attribute6
      ,p_attribute7_o             => pay_blt_shd.g_old_rec.attribute7
      ,p_attribute8_o             => pay_blt_shd.g_old_rec.attribute8
      ,p_attribute9_o             => pay_blt_shd.g_old_rec.attribute9
      ,p_attribute10_o            => pay_blt_shd.g_old_rec.attribute10
      ,p_attribute11_o            => pay_blt_shd.g_old_rec.attribute11
      ,p_attribute12_o            => pay_blt_shd.g_old_rec.attribute12
      ,p_attribute13_o            => pay_blt_shd.g_old_rec.attribute13
      ,p_attribute14_o            => pay_blt_shd.g_old_rec.attribute14
      ,p_attribute15_o            => pay_blt_shd.g_old_rec.attribute15
      ,p_attribute16_o            => pay_blt_shd.g_old_rec.attribute16
      ,p_attribute17_o            => pay_blt_shd.g_old_rec.attribute17
      ,p_attribute18_o            => pay_blt_shd.g_old_rec.attribute18
      ,p_attribute19_o            => pay_blt_shd.g_old_rec.attribute19
      ,p_attribute20_o            => pay_blt_shd.g_old_rec.attribute20
      ,p_jurisdiction_level_o     => pay_blt_shd.g_old_rec.jurisdiction_level
      ,p_tax_type_o               => pay_blt_shd.g_old_rec.tax_type
      ,p_object_version_number_o => pay_blt_shd.g_old_rec.object_version_number
      ,p_balance_category_id_o    => pay_blt_shd.g_old_rec.balance_category_id
      ,p_base_balance_type_id_o   => pay_blt_shd.g_old_rec.base_balance_type_id
      ,p_input_value_id_o         => pay_blt_shd.g_old_rec.input_value_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_TYPES'
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
  (p_rec in out nocopy pay_blt_shd.g_rec_type
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
    pay_blt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.legislation_code = hr_api.g_varchar2) then
    p_rec.legislation_code :=
    pay_blt_shd.g_old_rec.legislation_code;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    pay_blt_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.assignment_remuneration_flag = hr_api.g_varchar2) then
    p_rec.assignment_remuneration_flag :=
    pay_blt_shd.g_old_rec.assignment_remuneration_flag;
  End If;
  If (p_rec.balance_name = hr_api.g_varchar2) then
    p_rec.balance_name :=
    pay_blt_shd.g_old_rec.balance_name;
  End If;
  If (p_rec.balance_uom = hr_api.g_varchar2) then
    p_rec.balance_uom :=
    pay_blt_shd.g_old_rec.balance_uom;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    pay_blt_shd.g_old_rec.comments;
  End If;
  If (p_rec.legislation_subgroup = hr_api.g_varchar2) then
    p_rec.legislation_subgroup :=
    pay_blt_shd.g_old_rec.legislation_subgroup;
  End If;
  If (p_rec.reporting_name = hr_api.g_varchar2) then
    p_rec.reporting_name :=
    pay_blt_shd.g_old_rec.reporting_name;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    pay_blt_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    pay_blt_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    pay_blt_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    pay_blt_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    pay_blt_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    pay_blt_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    pay_blt_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    pay_blt_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    pay_blt_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    pay_blt_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    pay_blt_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    pay_blt_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    pay_blt_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    pay_blt_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    pay_blt_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    pay_blt_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    pay_blt_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    pay_blt_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    pay_blt_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    pay_blt_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    pay_blt_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.jurisdiction_level = hr_api.g_number) then
    p_rec.jurisdiction_level :=
    pay_blt_shd.g_old_rec.jurisdiction_level;
  End If;
  If (p_rec.tax_type = hr_api.g_varchar2) then
    p_rec.tax_type :=
    pay_blt_shd.g_old_rec.tax_type;
  End If;
  If (p_rec.balance_category_id = hr_api.g_number) then
    p_rec.balance_category_id :=
    pay_blt_shd.g_old_rec.balance_category_id;
  End If;
  If (p_rec.base_balance_type_id = hr_api.g_number) then
    p_rec.base_balance_type_id :=
    pay_blt_shd.g_old_rec.base_balance_type_id;
  End If;
  If (p_rec.input_value_id = hr_api.g_number) then
    p_rec.input_value_id :=
    pay_blt_shd.g_old_rec.input_value_id;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy pay_blt_shd.g_rec_type
  ,p_balance_name_warning            out nocopy number
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  l_balance_name_warning    number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_blt_shd.lck
    (p_rec.balance_type_id
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

   pay_blt_bus.update_validate
     (p_effective_date
     ,p_rec
     ,l_balance_name_warning
     );
  --

  p_balance_name_warning := l_balance_name_warning;
  --

  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_blt_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_blt_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_blt_upd.post_update
     (p_effective_date
     ,p_rec
     ,l_balance_name_warning
     );
  --
  -- recreate database item if balance name is changed
  --
  if l_balance_name_warning = 2 then
     pay_blt_bus.recreate_db_items(p_rec.balance_type_id);
  end if;
  --
  -- insert associated feed of primary balance
  --
  if p_rec.input_value_id is not null then
    pay_blt_bus.insert_primary_balance_feed
     ( p_effective_date       => p_effective_date
      ,p_business_group_id    => p_rec.business_group_id
      ,p_balance_type_id      => p_rec.balance_type_id
      ,p_input_value_id       => p_rec.input_value_id
     );
  end if;
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
  ,p_balance_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_remuneration_flag in     varchar2  default hr_api.g_varchar2
  ,p_balance_uom                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_balance_name                 in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup         in     varchar2  default hr_api.g_varchar2
  ,p_reporting_name               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_balance_category_id          in     number    default hr_api.g_number
  ,p_base_balance_type_id         in     number    default hr_api.g_number
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_balance_name_warning            out nocopy number
  ) is
--
  l_rec   pay_blt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';

  -- Bug 4248768. jurisdiction_level and tax type
  -- must not be defaulted to null.
  l_jurisdiction_level number        := hr_api.g_number;
  l_tax_type           varchar2(30)  := hr_api.g_varchar2;
  l_balance_name_warning    number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  pay_blt_shd.convert_args
  (p_balance_type_id
  ,p_business_group_id
  ,p_legislation_code
  ,p_currency_code
  ,p_assignment_remuneration_flag
  ,p_balance_name
  ,p_balance_uom
  ,p_comments
  ,p_legislation_subgroup
  ,p_reporting_name
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,l_jurisdiction_level
  ,l_tax_type
  ,p_object_version_number
  ,p_balance_category_id
  ,p_base_balance_type_id
  ,p_input_value_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_blt_upd.upd
     (p_effective_date
     ,l_rec
     ,l_balance_name_warning
     );
  p_balance_name_warning  := l_balance_name_warning;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end pay_blt_upd;

/
