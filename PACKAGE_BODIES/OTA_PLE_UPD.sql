--------------------------------------------------------
--  DDL for Package Body OTA_PLE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PLE_UPD" as
/* $Header: otple01t.pkb 115.3 99/07/16 00:52:56 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ple_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out ota_ple_shd.g_rec_type) is
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
  ota_ple_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_price_list_entries Row
  --
  update ota_price_list_entries
  set
  price_list_entry_id               = p_rec.price_list_entry_id,
  vendor_supply_id                  = p_rec.vendor_supply_id,
  activity_version_id               = p_rec.activity_version_id,
  price_list_id                     = p_rec.price_list_id,
  object_version_number             = p_rec.object_version_number,
  price                             = p_rec.price,
  price_basis                       = p_rec.price_basis,
  start_date                        = p_rec.start_date,
  comments                          = p_rec.comments,
  end_date                          = p_rec.end_date,
  maximum_attendees                 = p_rec.maximum_attendees,
  minimum_attendees                 = p_rec.minimum_attendees,
  ple_information_category          = p_rec.ple_information_category,
  ple_information1                  = p_rec.ple_information1,
  ple_information2                  = p_rec.ple_information2,
  ple_information3                  = p_rec.ple_information3,
  ple_information4                  = p_rec.ple_information4,
  ple_information5                  = p_rec.ple_information5,
  ple_information6                  = p_rec.ple_information6,
  ple_information7                  = p_rec.ple_information7,
  ple_information8                  = p_rec.ple_information8,
  ple_information9                  = p_rec.ple_information9,
  ple_information10                 = p_rec.ple_information10,
  ple_information11                 = p_rec.ple_information11,
  ple_information12                 = p_rec.ple_information12,
  ple_information13                 = p_rec.ple_information13,
  ple_information14                 = p_rec.ple_information14,
  ple_information15                 = p_rec.ple_information15,
  ple_information16                 = p_rec.ple_information16,
  ple_information17                 = p_rec.ple_information17,
  ple_information18                 = p_rec.ple_information18,
  ple_information19                 = p_rec.ple_information19,
  ple_information20                 = p_rec.ple_information20
  where price_list_entry_id = p_rec.price_list_entry_id;
  --
  ota_ple_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_ple_shd.g_api_dml := false;   -- Unset the api dml status
    ota_ple_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_ple_shd.g_api_dml := false;   -- Unset the api dml status
    ota_ple_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_ple_shd.g_api_dml := false;   -- Unset the api dml status
    ota_ple_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_ple_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ota_ple_shd.g_rec_type) is
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
Procedure post_update(p_rec in ota_ple_shd.g_rec_type) is
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
Function convert_defs(p_rec in out ota_ple_shd.g_rec_type)
         Return ota_ple_shd.g_rec_type is
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
  If (p_rec.vendor_supply_id = hr_api.g_number) then
    p_rec.vendor_supply_id :=
    ota_ple_shd.g_old_rec.vendor_supply_id;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    ota_ple_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.price_list_id = hr_api.g_number) then
    p_rec.price_list_id :=
    ota_ple_shd.g_old_rec.price_list_id;
  End If;
  If (p_rec.price = hr_api.g_number) then
    p_rec.price :=
    ota_ple_shd.g_old_rec.price;
  End If;
  If (p_rec.price_basis = hr_api.g_varchar2) then
    p_rec.price_basis :=
    ota_ple_shd.g_old_rec.price_basis;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_ple_shd.g_old_rec.start_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_ple_shd.g_old_rec.comments;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_ple_shd.g_old_rec.end_date;
  End If;
  If (p_rec.maximum_attendees = hr_api.g_number) then
    p_rec.maximum_attendees :=
    ota_ple_shd.g_old_rec.maximum_attendees;
  End If;
  If (p_rec.minimum_attendees = hr_api.g_number) then
    p_rec.minimum_attendees :=
    ota_ple_shd.g_old_rec.minimum_attendees;
  End If;
  If (p_rec.ple_information_category = hr_api.g_varchar2) then
    p_rec.ple_information_category :=
    ota_ple_shd.g_old_rec.ple_information_category;
  End If;
  If (p_rec.ple_information1 = hr_api.g_varchar2) then
    p_rec.ple_information1 :=
    ota_ple_shd.g_old_rec.ple_information1;
  End If;
  If (p_rec.ple_information2 = hr_api.g_varchar2) then
    p_rec.ple_information2 :=
    ota_ple_shd.g_old_rec.ple_information2;
  End If;
  If (p_rec.ple_information3 = hr_api.g_varchar2) then
    p_rec.ple_information3 :=
    ota_ple_shd.g_old_rec.ple_information3;
  End If;
  If (p_rec.ple_information4 = hr_api.g_varchar2) then
    p_rec.ple_information4 :=
    ota_ple_shd.g_old_rec.ple_information4;
  End If;
  If (p_rec.ple_information5 = hr_api.g_varchar2) then
    p_rec.ple_information5 :=
    ota_ple_shd.g_old_rec.ple_information5;
  End If;
  If (p_rec.ple_information6 = hr_api.g_varchar2) then
    p_rec.ple_information6 :=
    ota_ple_shd.g_old_rec.ple_information6;
  End If;
  If (p_rec.ple_information7 = hr_api.g_varchar2) then
    p_rec.ple_information7 :=
    ota_ple_shd.g_old_rec.ple_information7;
  End If;
  If (p_rec.ple_information8 = hr_api.g_varchar2) then
    p_rec.ple_information8 :=
    ota_ple_shd.g_old_rec.ple_information8;
  End If;
  If (p_rec.ple_information9 = hr_api.g_varchar2) then
    p_rec.ple_information9 :=
    ota_ple_shd.g_old_rec.ple_information9;
  End If;
  If (p_rec.ple_information10 = hr_api.g_varchar2) then
    p_rec.ple_information10 :=
    ota_ple_shd.g_old_rec.ple_information10;
  End If;
  If (p_rec.ple_information11 = hr_api.g_varchar2) then
    p_rec.ple_information11 :=
    ota_ple_shd.g_old_rec.ple_information11;
  End If;
  If (p_rec.ple_information12 = hr_api.g_varchar2) then
    p_rec.ple_information12 :=
    ota_ple_shd.g_old_rec.ple_information12;
  End If;
  If (p_rec.ple_information13 = hr_api.g_varchar2) then
    p_rec.ple_information13 :=
    ota_ple_shd.g_old_rec.ple_information13;
  End If;
  If (p_rec.ple_information14 = hr_api.g_varchar2) then
    p_rec.ple_information14 :=
    ota_ple_shd.g_old_rec.ple_information14;
  End If;
  If (p_rec.ple_information15 = hr_api.g_varchar2) then
    p_rec.ple_information15 :=
    ota_ple_shd.g_old_rec.ple_information15;
  End If;
  If (p_rec.ple_information16 = hr_api.g_varchar2) then
    p_rec.ple_information16 :=
    ota_ple_shd.g_old_rec.ple_information16;
  End If;
  If (p_rec.ple_information17 = hr_api.g_varchar2) then
    p_rec.ple_information17 :=
    ota_ple_shd.g_old_rec.ple_information17;
  End If;
  If (p_rec.ple_information18 = hr_api.g_varchar2) then
    p_rec.ple_information18 :=
    ota_ple_shd.g_old_rec.ple_information18;
  End If;
  If (p_rec.ple_information19 = hr_api.g_varchar2) then
    p_rec.ple_information19 :=
    ota_ple_shd.g_old_rec.ple_information19;
  End If;
  If (p_rec.ple_information20 = hr_api.g_varchar2) then
    p_rec.ple_information20 :=
    ota_ple_shd.g_old_rec.ple_information20;
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
  p_rec        in out ota_ple_shd.g_rec_type,
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
    SAVEPOINT upd_ota_ple;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_ple_shd.lck
	(
	p_rec.price_list_entry_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_ple_bus.update_validate(convert_defs(p_rec));
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
    ROLLBACK TO upd_ota_ple;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_price_list_entry_id          in number,
  p_vendor_supply_id             in number           default hr_api.g_number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_price_list_id                in number           default hr_api.g_number,
  p_object_version_number        in out number,
  p_price                        in number           default hr_api.g_number,
  p_price_basis                  in varchar2         default hr_api.g_varchar2,
  p_start_date                   in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_end_date                     in date             default hr_api.g_date,
  p_maximum_attendees            in number           default hr_api.g_number,
  p_minimum_attendees            in number           default hr_api.g_number,
  p_ple_information_category     in varchar2         default hr_api.g_varchar2,
  p_ple_information1             in varchar2         default hr_api.g_varchar2,
  p_ple_information2             in varchar2         default hr_api.g_varchar2,
  p_ple_information3             in varchar2         default hr_api.g_varchar2,
  p_ple_information4             in varchar2         default hr_api.g_varchar2,
  p_ple_information5             in varchar2         default hr_api.g_varchar2,
  p_ple_information6             in varchar2         default hr_api.g_varchar2,
  p_ple_information7             in varchar2         default hr_api.g_varchar2,
  p_ple_information8             in varchar2         default hr_api.g_varchar2,
  p_ple_information9             in varchar2         default hr_api.g_varchar2,
  p_ple_information10            in varchar2         default hr_api.g_varchar2,
  p_ple_information11            in varchar2         default hr_api.g_varchar2,
  p_ple_information12            in varchar2         default hr_api.g_varchar2,
  p_ple_information13            in varchar2         default hr_api.g_varchar2,
  p_ple_information14            in varchar2         default hr_api.g_varchar2,
  p_ple_information15            in varchar2         default hr_api.g_varchar2,
  p_ple_information16            in varchar2         default hr_api.g_varchar2,
  p_ple_information17            in varchar2         default hr_api.g_varchar2,
  p_ple_information18            in varchar2         default hr_api.g_varchar2,
  p_ple_information19            in varchar2         default hr_api.g_varchar2,
  p_ple_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ) is
--
  l_rec	  ota_ple_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_ple_shd.convert_args
  (
  p_price_list_entry_id,
  p_vendor_supply_id,
  p_activity_version_id,
  p_price_list_id,
  p_object_version_number,
  p_price,
  p_price_basis,
  p_start_date,
  p_comments,
  p_end_date,
  p_maximum_attendees,
  p_minimum_attendees,
  p_ple_information_category,
  p_ple_information1,
  p_ple_information2,
  p_ple_information3,
  p_ple_information4,
  p_ple_information5,
  p_ple_information6,
  p_ple_information7,
  p_ple_information8,
  p_ple_information9,
  p_ple_information10,
  p_ple_information11,
  p_ple_information12,
  p_ple_information13,
  p_ple_information14,
  p_ple_information15,
  p_ple_information16,
  p_ple_information17,
  p_ple_information18,
  p_ple_information19,
  p_ple_information20
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
end ota_ple_upd;

/
