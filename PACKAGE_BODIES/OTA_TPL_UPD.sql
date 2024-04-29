--------------------------------------------------------
--  DDL for Package Body OTA_TPL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPL_UPD" as
/* $Header: ottpl01t.pkb 115.2 99/07/16 00:55:57 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tpl_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out ota_tpl_shd.g_rec_type) is
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
  ota_tpl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_price_lists Row
  --
  update ota_price_lists
  set
  price_list_id                     = p_rec.price_list_id,
  business_group_id                 = p_rec.business_group_id,
  currency_code                     = p_rec.currency_code,
  default_flag                      = p_rec.default_flag,
  name                              = p_rec.name,
  object_version_number             = p_rec.object_version_number,
  price_list_type                   = p_rec.price_list_type,
  start_date                        = p_rec.start_date,
  comments                          = p_rec.comments,
  description                       = p_rec.description,
  end_date                          = p_rec.end_date,
  single_unit_price                 = p_rec.single_unit_price,
  training_unit_type                = p_rec.training_unit_type,
  tpl_information_category          = p_rec.tpl_information_category,
  tpl_information1                  = p_rec.tpl_information1,
  tpl_information2                  = p_rec.tpl_information2,
  tpl_information3                  = p_rec.tpl_information3,
  tpl_information4                  = p_rec.tpl_information4,
  tpl_information5                  = p_rec.tpl_information5,
  tpl_information6                  = p_rec.tpl_information6,
  tpl_information7                  = p_rec.tpl_information7,
  tpl_information8                  = p_rec.tpl_information8,
  tpl_information9                  = p_rec.tpl_information9,
  tpl_information10                 = p_rec.tpl_information10,
  tpl_information11                 = p_rec.tpl_information11,
  tpl_information12                 = p_rec.tpl_information12,
  tpl_information13                 = p_rec.tpl_information13,
  tpl_information14                 = p_rec.tpl_information14,
  tpl_information15                 = p_rec.tpl_information15,
  tpl_information16                 = p_rec.tpl_information16,
  tpl_information17                 = p_rec.tpl_information17,
  tpl_information18                 = p_rec.tpl_information18,
  tpl_information19                 = p_rec.tpl_information19,
  tpl_information20                 = p_rec.tpl_information20
  where price_list_id = p_rec.price_list_id;
  --
  ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tpl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tpl_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ota_tpl_shd.g_rec_type) is
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
Procedure post_update(p_rec in ota_tpl_shd.g_rec_type) is
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
Function convert_defs(p_rec in out ota_tpl_shd.g_rec_type)
         Return ota_tpl_shd.g_rec_type is
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
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_tpl_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_tpl_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.default_flag = hr_api.g_varchar2) then
    p_rec.default_flag :=
    ota_tpl_shd.g_old_rec.default_flag;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    ota_tpl_shd.g_old_rec.name;
  End If;
  If (p_rec.price_list_type = hr_api.g_varchar2) then
    p_rec.price_list_type :=
    ota_tpl_shd.g_old_rec.price_list_type;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_tpl_shd.g_old_rec.start_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tpl_shd.g_old_rec.comments;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    ota_tpl_shd.g_old_rec.description;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_tpl_shd.g_old_rec.end_date;
  End If;
  If (p_rec.single_unit_price = hr_api.g_number) then
    p_rec.single_unit_price :=
    ota_tpl_shd.g_old_rec.single_unit_price;
  End If;
  If (p_rec.training_unit_type = hr_api.g_varchar2) then
    p_rec.training_unit_type :=
    ota_tpl_shd.g_old_rec.training_unit_type;
  End If;
  If (p_rec.tpl_information_category = hr_api.g_varchar2) then
    p_rec.tpl_information_category :=
    ota_tpl_shd.g_old_rec.tpl_information_category;
  End If;
  If (p_rec.tpl_information1 = hr_api.g_varchar2) then
    p_rec.tpl_information1 :=
    ota_tpl_shd.g_old_rec.tpl_information1;
  End If;
  If (p_rec.tpl_information2 = hr_api.g_varchar2) then
    p_rec.tpl_information2 :=
    ota_tpl_shd.g_old_rec.tpl_information2;
  End If;
  If (p_rec.tpl_information3 = hr_api.g_varchar2) then
    p_rec.tpl_information3 :=
    ota_tpl_shd.g_old_rec.tpl_information3;
  End If;
  If (p_rec.tpl_information4 = hr_api.g_varchar2) then
    p_rec.tpl_information4 :=
    ota_tpl_shd.g_old_rec.tpl_information4;
  End If;
  If (p_rec.tpl_information5 = hr_api.g_varchar2) then
    p_rec.tpl_information5 :=
    ota_tpl_shd.g_old_rec.tpl_information5;
  End If;
  If (p_rec.tpl_information6 = hr_api.g_varchar2) then
    p_rec.tpl_information6 :=
    ota_tpl_shd.g_old_rec.tpl_information6;
  End If;
  If (p_rec.tpl_information7 = hr_api.g_varchar2) then
    p_rec.tpl_information7 :=
    ota_tpl_shd.g_old_rec.tpl_information7;
  End If;
  If (p_rec.tpl_information8 = hr_api.g_varchar2) then
    p_rec.tpl_information8 :=
    ota_tpl_shd.g_old_rec.tpl_information8;
  End If;
  If (p_rec.tpl_information9 = hr_api.g_varchar2) then
    p_rec.tpl_information9 :=
    ota_tpl_shd.g_old_rec.tpl_information9;
  End If;
  If (p_rec.tpl_information10 = hr_api.g_varchar2) then
    p_rec.tpl_information10 :=
    ota_tpl_shd.g_old_rec.tpl_information10;
  End If;
  If (p_rec.tpl_information11 = hr_api.g_varchar2) then
    p_rec.tpl_information11 :=
    ota_tpl_shd.g_old_rec.tpl_information11;
  End If;
  If (p_rec.tpl_information12 = hr_api.g_varchar2) then
    p_rec.tpl_information12 :=
    ota_tpl_shd.g_old_rec.tpl_information12;
  End If;
  If (p_rec.tpl_information13 = hr_api.g_varchar2) then
    p_rec.tpl_information13 :=
    ota_tpl_shd.g_old_rec.tpl_information13;
  End If;
  If (p_rec.tpl_information14 = hr_api.g_varchar2) then
    p_rec.tpl_information14 :=
    ota_tpl_shd.g_old_rec.tpl_information14;
  End If;
  If (p_rec.tpl_information15 = hr_api.g_varchar2) then
    p_rec.tpl_information15 :=
    ota_tpl_shd.g_old_rec.tpl_information15;
  End If;
  If (p_rec.tpl_information16 = hr_api.g_varchar2) then
    p_rec.tpl_information16 :=
    ota_tpl_shd.g_old_rec.tpl_information16;
  End If;
  If (p_rec.tpl_information17 = hr_api.g_varchar2) then
    p_rec.tpl_information17 :=
    ota_tpl_shd.g_old_rec.tpl_information17;
  End If;
  If (p_rec.tpl_information18 = hr_api.g_varchar2) then
    p_rec.tpl_information18 :=
    ota_tpl_shd.g_old_rec.tpl_information18;
  End If;
  If (p_rec.tpl_information19 = hr_api.g_varchar2) then
    p_rec.tpl_information19 :=
    ota_tpl_shd.g_old_rec.tpl_information19;
  End If;
  If (p_rec.tpl_information20 = hr_api.g_varchar2) then
    p_rec.tpl_information20 :=
    ota_tpl_shd.g_old_rec.tpl_information20;
  End If;
  --
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
  p_rec        in out ota_tpl_shd.g_rec_type,
  p_validate   in     boolean default false
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
    SAVEPOINT upd_ota_tpl;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tpl_shd.lck
	(
	p_rec.price_list_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_tpl_bus.update_validate(convert_defs(p_rec));
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
    ROLLBACK TO upd_ota_tpl;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_price_list_id                in number,
  p_business_group_id            in number           default hr_api.g_number,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_default_flag                 in varchar2         default hr_api.g_varchar2,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out number,
  p_price_list_type              in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_end_date                     in date             default hr_api.g_date,
  p_single_unit_price            in number           default hr_api.g_number,
  p_training_unit_type           in varchar2         default hr_api.g_varchar2,
  p_tpl_information_category     in varchar2         default hr_api.g_varchar2,
  p_tpl_information1             in varchar2         default hr_api.g_varchar2,
  p_tpl_information2             in varchar2         default hr_api.g_varchar2,
  p_tpl_information3             in varchar2         default hr_api.g_varchar2,
  p_tpl_information4             in varchar2         default hr_api.g_varchar2,
  p_tpl_information5             in varchar2         default hr_api.g_varchar2,
  p_tpl_information6             in varchar2         default hr_api.g_varchar2,
  p_tpl_information7             in varchar2         default hr_api.g_varchar2,
  p_tpl_information8             in varchar2         default hr_api.g_varchar2,
  p_tpl_information9             in varchar2         default hr_api.g_varchar2,
  p_tpl_information10            in varchar2         default hr_api.g_varchar2,
  p_tpl_information11            in varchar2         default hr_api.g_varchar2,
  p_tpl_information12            in varchar2         default hr_api.g_varchar2,
  p_tpl_information13            in varchar2         default hr_api.g_varchar2,
  p_tpl_information14            in varchar2         default hr_api.g_varchar2,
  p_tpl_information15            in varchar2         default hr_api.g_varchar2,
  p_tpl_information16            in varchar2         default hr_api.g_varchar2,
  p_tpl_information17            in varchar2         default hr_api.g_varchar2,
  p_tpl_information18            in varchar2         default hr_api.g_varchar2,
  p_tpl_information19            in varchar2         default hr_api.g_varchar2,
  p_tpl_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  ota_tpl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tpl_shd.convert_args
  (
  p_price_list_id,
  p_business_group_id,
  p_currency_code,
  p_default_flag,
  p_name,
  p_object_version_number,
  p_price_list_type,
  p_start_date,
  p_comments,
  p_description,
  p_end_date,
  p_single_unit_price,
  p_training_unit_type,
  p_tpl_information_category,
  p_tpl_information1,
  p_tpl_information2,
  p_tpl_information3,
  p_tpl_information4,
  p_tpl_information5,
  p_tpl_information6,
  p_tpl_information7,
  p_tpl_information8,
  p_tpl_information9,
  p_tpl_information10,
  p_tpl_information11,
  p_tpl_information12,
  p_tpl_information13,
  p_tpl_information14,
  p_tpl_information15,
  p_tpl_information16,
  p_tpl_information17,
  p_tpl_information18,
  p_tpl_information19,
  p_tpl_information20
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
end ota_tpl_upd;

/
