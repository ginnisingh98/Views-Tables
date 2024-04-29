--------------------------------------------------------
--  DDL for Package Body OTA_TSR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TSR_UPD" as
/* $Header: ottsr01t.pkb 120.2 2005/08/08 23:27:40 ssur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tsr_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ota_tsr_shd.g_rec_type) is
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
  ota_tsr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_suppliable_resources Row
  --
  update ota_suppliable_resources
  set
  supplied_resource_id              = p_rec.supplied_resource_id,
  vendor_id                         = p_rec.vendor_id,
  business_group_id                 = p_rec.business_group_id,
  resource_definition_id            = p_rec.resource_definition_id,
  consumable_flag                   = p_rec.consumable_flag,
  object_version_number             = p_rec.object_version_number,
  resource_type                     = p_rec.resource_type,
  start_date                        = p_rec.start_date,
  comments                          = p_rec.comments,
  cost                              = p_rec.cost,
  cost_unit                         = p_rec.cost_unit,
  currency_code                     = p_rec.currency_code,
  end_date                          = p_rec.end_date,
  internal_address_line             = p_rec.internal_address_line,
  lead_time                         = p_rec.lead_time,
  name                              = p_rec.name,
  supplier_reference                = p_rec.supplier_reference,
  tsr_information_category          = p_rec.tsr_information_category,
  tsr_information1                  = p_rec.tsr_information1,
  tsr_information2                  = p_rec.tsr_information2,
  tsr_information3                  = p_rec.tsr_information3,
  tsr_information4                  = p_rec.tsr_information4,
  tsr_information5                  = p_rec.tsr_information5,
  tsr_information6                  = p_rec.tsr_information6,
  tsr_information7                  = p_rec.tsr_information7,
  tsr_information8                  = p_rec.tsr_information8,
  tsr_information9                  = p_rec.tsr_information9,
  tsr_information10                 = p_rec.tsr_information10,
  tsr_information11                 = p_rec.tsr_information11,
  tsr_information12                 = p_rec.tsr_information12,
  tsr_information13                 = p_rec.tsr_information13,
  tsr_information14                 = p_rec.tsr_information14,
  tsr_information15                 = p_rec.tsr_information15,
  tsr_information16                 = p_rec.tsr_information16,
  tsr_information17                 = p_rec.tsr_information17,
  tsr_information18                 = p_rec.tsr_information18,
  tsr_information19                 = p_rec.tsr_information19,
  tsr_information20                 = p_rec.tsr_information20,
  training_center_id                = p_rec.training_center_id,
  location_id                       = p_rec.location_id,
  trainer_id                        = p_rec.trainer_id,
  special_instruction               = p_rec.special_instruction
  where supplied_resource_id = p_rec.supplied_resource_id;
  --
  ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tsr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tsr_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ota_tsr_shd.g_rec_type) is
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ota_tsr_shd.g_rec_type) is
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
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy ota_tsr_shd.g_rec_type)
         Return ota_tsr_shd.g_rec_type is
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
  If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    ota_tsr_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_tsr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.resource_definition_id = hr_api.g_number) then
    p_rec.resource_definition_id :=
    ota_tsr_shd.g_old_rec.resource_definition_id;
  End If;
  If (p_rec.consumable_flag = hr_api.g_varchar2) then
    p_rec.consumable_flag :=
    ota_tsr_shd.g_old_rec.consumable_flag;
  End If;
  If (p_rec.resource_type = hr_api.g_varchar2) then
    p_rec.resource_type :=
    ota_tsr_shd.g_old_rec.resource_type;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_tsr_shd.g_old_rec.start_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tsr_shd.g_old_rec.comments;
  End If;
  If (p_rec.cost = hr_api.g_number) then
    p_rec.cost :=
    ota_tsr_shd.g_old_rec.cost;
  End If;
  If (p_rec.cost_unit = hr_api.g_varchar2) then
    p_rec.cost_unit :=
    ota_tsr_shd.g_old_rec.cost_unit;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_tsr_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_tsr_shd.g_old_rec.end_date;
  End If;
  If (p_rec.internal_address_line = hr_api.g_varchar2) then
    p_rec.internal_address_line :=
    ota_tsr_shd.g_old_rec.internal_address_line;
  End If;
  If (p_rec.lead_time = hr_api.g_number) then
    p_rec.lead_time :=
    ota_tsr_shd.g_old_rec.lead_time;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ota_tsr_shd.g_old_rec.name;
  End If;
  If (p_rec.supplier_reference = hr_api.g_varchar2) then
    p_rec.supplier_reference :=
    ota_tsr_shd.g_old_rec.supplier_reference;
  End If;
  If (p_rec.tsr_information_category = hr_api.g_varchar2) then
    p_rec.tsr_information_category :=
    ota_tsr_shd.g_old_rec.tsr_information_category;
  End If;
  If (p_rec.tsr_information1 = hr_api.g_varchar2) then
    p_rec.tsr_information1 :=
    ota_tsr_shd.g_old_rec.tsr_information1;
  End If;
  If (p_rec.tsr_information2 = hr_api.g_varchar2) then
    p_rec.tsr_information2 :=
    ota_tsr_shd.g_old_rec.tsr_information2;
  End If;
  If (p_rec.tsr_information3 = hr_api.g_varchar2) then
    p_rec.tsr_information3 :=
    ota_tsr_shd.g_old_rec.tsr_information3;
  End If;
  If (p_rec.tsr_information4 = hr_api.g_varchar2) then
    p_rec.tsr_information4 :=
    ota_tsr_shd.g_old_rec.tsr_information4;
  End If;
  If (p_rec.tsr_information5 = hr_api.g_varchar2) then
    p_rec.tsr_information5 :=
    ota_tsr_shd.g_old_rec.tsr_information5;
  End If;
  If (p_rec.tsr_information6 = hr_api.g_varchar2) then
    p_rec.tsr_information6 :=
    ota_tsr_shd.g_old_rec.tsr_information6;
  End If;
  If (p_rec.tsr_information7 = hr_api.g_varchar2) then
    p_rec.tsr_information7 :=
    ota_tsr_shd.g_old_rec.tsr_information7;
  End If;
  If (p_rec.tsr_information8 = hr_api.g_varchar2) then
    p_rec.tsr_information8 :=
    ota_tsr_shd.g_old_rec.tsr_information8;
  End If;
  If (p_rec.tsr_information9 = hr_api.g_varchar2) then
    p_rec.tsr_information9 :=
    ota_tsr_shd.g_old_rec.tsr_information9;
  End If;
  If (p_rec.tsr_information10 = hr_api.g_varchar2) then
    p_rec.tsr_information10 :=
    ota_tsr_shd.g_old_rec.tsr_information10;
  End If;
  If (p_rec.tsr_information11 = hr_api.g_varchar2) then
    p_rec.tsr_information11 :=
    ota_tsr_shd.g_old_rec.tsr_information11;
  End If;
  If (p_rec.tsr_information12 = hr_api.g_varchar2) then
    p_rec.tsr_information12 :=
    ota_tsr_shd.g_old_rec.tsr_information12;
  End If;
  If (p_rec.tsr_information13 = hr_api.g_varchar2) then
    p_rec.tsr_information13 :=
    ota_tsr_shd.g_old_rec.tsr_information13;
  End If;
  If (p_rec.tsr_information14 = hr_api.g_varchar2) then
    p_rec.tsr_information14 :=
    ota_tsr_shd.g_old_rec.tsr_information14;
  End If;
  If (p_rec.tsr_information15 = hr_api.g_varchar2) then
    p_rec.tsr_information15 :=
    ota_tsr_shd.g_old_rec.tsr_information15;
  End If;
  If (p_rec.tsr_information16 = hr_api.g_varchar2) then
    p_rec.tsr_information16 :=
    ota_tsr_shd.g_old_rec.tsr_information16;
  End If;
  If (p_rec.tsr_information17 = hr_api.g_varchar2) then
    p_rec.tsr_information17 :=
    ota_tsr_shd.g_old_rec.tsr_information17;
  End If;
  If (p_rec.tsr_information18 = hr_api.g_varchar2) then
    p_rec.tsr_information18 :=
    ota_tsr_shd.g_old_rec.tsr_information18;
  End If;
  If (p_rec.tsr_information19 = hr_api.g_varchar2) then
    p_rec.tsr_information19 :=
    ota_tsr_shd.g_old_rec.tsr_information19;
  End If;
  If (p_rec.tsr_information20 = hr_api.g_varchar2) then
    p_rec.tsr_information20 :=
    ota_tsr_shd.g_old_rec.tsr_information20;
  End If;
  If (p_rec.training_center_id = hr_api.g_number) then
    p_rec.training_center_id :=
    ota_tsr_shd.g_old_rec.training_center_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    ota_tsr_shd.g_old_rec.location_id;
  End If;
  If (p_rec.trainer_id = hr_api.g_number) then
    p_rec.trainer_id :=
    ota_tsr_shd.g_old_rec.trainer_id;
  End If;
  If (p_rec.special_instruction = hr_api.g_varchar2) then
    p_rec.special_instruction :=
    ota_tsr_shd.g_old_rec.special_instruction;
  End If;  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ota_tsr_shd.g_rec_type,
  p_validate   in     boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ota_tsr;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tsr_shd.lck
	(
	p_rec.supplied_resource_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_tsr_bus.update_validate(convert_defs(p_rec));
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
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ota_tsr;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_supplied_resource_id         in number,
  p_vendor_id                    in number,
  p_business_group_id            in number,
  p_resource_definition_id       in number,
  p_consumable_flag              in varchar2,
  p_object_version_number        in out nocopy number,
  p_resource_type                in varchar2,
  p_start_date                   in date   ,
  p_comments                     in varchar2,
  p_cost                         in number  ,
  p_cost_unit                    in varchar2,
  p_currency_code                in varchar2,
  p_end_date                     in date   ,
  p_internal_address_line        in varchar2,
  p_lead_time                    in number  ,
  p_name                         in varchar2,
  p_supplier_reference           in varchar2,
  p_tsr_information_category     in varchar2,
  p_tsr_information1             in varchar2 ,
  p_tsr_information2             in varchar2,
  p_tsr_information3             in varchar2,
  p_tsr_information4             in varchar2,
  p_tsr_information5             in varchar2,
  p_tsr_information6             in varchar2,
  p_tsr_information7             in varchar2,
  p_tsr_information8             in varchar2,
  p_tsr_information9             in varchar2,
  p_tsr_information10            in varchar2,
  p_tsr_information11            in varchar2,
  p_tsr_information12            in varchar2,
  p_tsr_information13            in varchar2,
  p_tsr_information14            in varchar2,
  p_tsr_information15            in varchar2,
  p_tsr_information16            in varchar2,
  p_tsr_information17            in varchar2,
  p_tsr_information18            in varchar2,
  p_tsr_information19            in varchar2,
  p_tsr_information20            in varchar2,
  p_training_center_id           in number,
  p_location_id			   in number,
  p_trainer_id                   in number,
  p_special_instruction          in varchar2,
  p_validate                     in boolean
  ) is
--
  l_rec	  ota_tsr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tsr_shd.convert_args
  (
  p_supplied_resource_id,
  p_vendor_id,
  p_business_group_id,
  p_resource_definition_id,
  p_consumable_flag,
  p_object_version_number,
  p_resource_type,
  p_start_date,
  p_comments,
  p_cost,
  p_cost_unit,
  p_currency_code,
  p_end_date,
  p_internal_address_line,
  p_lead_time,
  p_name,
  p_supplier_reference,
  p_tsr_information_category,
  p_tsr_information1,
  p_tsr_information2,
  p_tsr_information3,
  p_tsr_information4,
  p_tsr_information5,
  p_tsr_information6,
  p_tsr_information7,
  p_tsr_information8,
  p_tsr_information9,
  p_tsr_information10,
  p_tsr_information11,
  p_tsr_information12,
  p_tsr_information13,
  p_tsr_information14,
  p_tsr_information15,
  p_tsr_information16,
  p_tsr_information17,
  p_tsr_information18,
  p_tsr_information19,
  p_tsr_information20,
  p_training_center_id,
  p_location_id,
  p_trainer_id,
  p_special_instruction
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_tsr_upd;

/
