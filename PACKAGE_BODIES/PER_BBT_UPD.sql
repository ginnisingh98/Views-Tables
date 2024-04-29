--------------------------------------------------------
--  DDL for Package Body PER_BBT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBT_UPD" as
/* $Header: pebbtrhi.pkb 115.7 2002/12/02 13:20:16 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bbt_upd.';  -- Global package name
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
  (p_rec in out nocopy per_bbt_shd.g_rec_type
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
  -- Update the per_bf_balance_types Row
  --
  update per_bf_balance_types
    set
     balance_type_id                 = p_rec.balance_type_id
    ,input_value_id                  = p_rec.input_value_id
    ,displayed_name                  = p_rec.displayed_name
    ,internal_name                   = p_rec.internal_name
    ,uom                             = p_rec.uom
    ,currency                        = p_rec.currency
    ,category                        = p_rec.category
    ,date_from                       = p_rec.date_from
    ,date_to                         = p_rec.date_to
    ,object_version_number           = p_rec.object_version_number
    where balance_type_id = p_rec.balance_type_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_bbt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_bbt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_bbt_shd.constraint_error
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
  (p_rec in per_bbt_shd.g_rec_type
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
Procedure post_update
  (p_effective_date               in date
  ,p_rec                         in per_bbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_bbt_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_balance_type_id               => p_rec.balance_type_id
      ,p_input_value_id               => p_rec.input_value_id
      ,p_business_group_id            => p_rec.business_group_id
      ,p_displayed_name               => p_rec.displayed_name
      ,p_internal_name                => p_rec.internal_name
      ,p_uom                          => p_rec.uom
      ,p_currency                     => p_rec.currency
      ,p_category                     => p_rec.category
      ,p_date_from                    => p_rec.date_from
      ,p_date_to                      => p_rec.date_to
      ,p_object_version_number        => p_rec.object_version_number
      ,p_input_value_id_o
      => per_bbt_shd.g_old_rec.input_value_id
      ,p_business_group_id_o
      => per_bbt_shd.g_old_rec.business_group_id
      ,p_displayed_name_o
      => per_bbt_shd.g_old_rec.displayed_name
      ,p_internal_name_o
      => per_bbt_shd.g_old_rec.internal_name
      ,p_uom_o
      => per_bbt_shd.g_old_rec.uom
      ,p_currency_o
      => per_bbt_shd.g_old_rec.currency
      ,p_category_o
      => per_bbt_shd.g_old_rec.category
      ,p_date_from_o
      => per_bbt_shd.g_old_rec.date_from
      ,p_date_to_o
      => per_bbt_shd.g_old_rec.date_to
      ,p_object_version_number_o
      => per_bbt_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_BF_BALANCE_TYPES'
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
--   A Pl/Sql record structre.
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
  (p_rec in out nocopy per_bbt_shd.g_rec_type
  ) is
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
  If (p_rec.input_value_id = hr_api.g_number) then
    p_rec.input_value_id :=
    per_bbt_shd.g_old_rec.input_value_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_bbt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.displayed_name = hr_api.g_varchar2) then
    p_rec.displayed_name :=
    per_bbt_shd.g_old_rec.displayed_name;
  End If;
  If (p_rec.internal_name = hr_api.g_varchar2) then
    p_rec.internal_name :=
    per_bbt_shd.g_old_rec.internal_name;
  End If;
  If (p_rec.uom = hr_api.g_varchar2) then
    p_rec.uom :=
    per_bbt_shd.g_old_rec.uom;
  End If;
  If (p_rec.currency = hr_api.g_varchar2) then
    p_rec.currency :=
    per_bbt_shd.g_old_rec.currency;
  End If;
  If (p_rec.category = hr_api.g_varchar2) then
    p_rec.category :=
    per_bbt_shd.g_old_rec.category;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_bbt_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_bbt_shd.g_old_rec.date_to;
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_bbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_bbt_shd.lck
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
  per_bbt_bus.update_validate
     (p_effective_date
     ,p_rec
     );
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
  post_update
     (p_effective_date
     ,p_rec
     );
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_balance_type_id              in number
  ,p_input_value_id               in number     default hr_api.g_number
  ,p_displayed_name               in varchar2   default hr_api.g_varchar2
  ,p_internal_name               in varchar2   default hr_api.g_varchar2
  ,p_uom                          in varchar2   default hr_api.g_varchar2
  ,p_currency                     in varchar2   default hr_api.g_varchar2
  ,p_category                     in varchar2   default hr_api.g_varchar2
  ,p_date_from                    in date       default hr_api.g_date
  ,p_date_to                      in date       default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  per_bbt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_bbt_shd.convert_args
  (p_balance_type_id
  ,p_input_value_id
  ,hr_api.g_number
  ,p_displayed_name
  ,p_internal_name
  ,p_uom
  ,p_currency
  ,p_category
  ,p_date_from
  ,p_date_to
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_bbt_upd;

/
