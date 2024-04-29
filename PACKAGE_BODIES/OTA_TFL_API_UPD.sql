--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_UPD" as
/* $Header: ottfl01t.pkb 120.0 2005/05/29 07:41:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfl_api_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ota_tfl_api_shd.g_rec_type) is
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
  ota_tfl_api_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_finance_lines Row
  --
  update ota_finance_lines
  set
  finance_line_id                   = p_rec.finance_line_id,
  finance_header_id                 = p_rec.finance_header_id,
  cancelled_flag                    = p_rec.cancelled_flag,
  date_raised                       = p_rec.date_raised,
  line_type                         = p_rec.line_type,
  object_version_number             = p_rec.object_version_number,
  sequence_number                   = p_rec.sequence_number,
  transfer_status                   = p_rec.transfer_status,
  comments                          = p_rec.comments,
  currency_code                     = p_rec.currency_code,
  money_amount                      = p_rec.money_amount,
  standard_amount                   = p_rec.standard_amount,
  trans_information_category        = p_rec.trans_information_category,
  trans_information1                = p_rec.trans_information1,
  trans_information10               = p_rec.trans_information10,
  trans_information11               = p_rec.trans_information11,
  trans_information12               = p_rec.trans_information12,
  trans_information13               = p_rec.trans_information13,
  trans_information14               = p_rec.trans_information14,
  trans_information15               = p_rec.trans_information15,
  trans_information16               = p_rec.trans_information16,
  trans_information17               = p_rec.trans_information17,
  trans_information18               = p_rec.trans_information18,
  trans_information19               = p_rec.trans_information19,
  trans_information2                = p_rec.trans_information2,
  trans_information20               = p_rec.trans_information20,
  trans_information3                = p_rec.trans_information3,
  trans_information4                = p_rec.trans_information4,
  trans_information5                = p_rec.trans_information5,
  trans_information6                = p_rec.trans_information6,
  trans_information7                = p_rec.trans_information7,
  trans_information8                = p_rec.trans_information8,
  trans_information9                = p_rec.trans_information9,
  transfer_date                     = p_rec.transfer_date,
  transfer_message                  = p_rec.transfer_message,
  unitary_amount                    = p_rec.unitary_amount,
  booking_deal_id                   = p_rec.booking_deal_id,
  booking_id                        = p_rec.booking_id,
  resource_allocation_id            = p_rec.resource_allocation_id,
  resource_booking_id               = p_rec.resource_booking_id,
  tfl_information_category          = p_rec.tfl_information_category,
  tfl_information1                  = p_rec.tfl_information1,
  tfl_information2                  = p_rec.tfl_information2,
  tfl_information3                  = p_rec.tfl_information3,
  tfl_information4                  = p_rec.tfl_information4,
  tfl_information5                  = p_rec.tfl_information5,
  tfl_information6                  = p_rec.tfl_information6,
  tfl_information7                  = p_rec.tfl_information7,
  tfl_information8                  = p_rec.tfl_information8,
  tfl_information9                  = p_rec.tfl_information9,
  tfl_information10                 = p_rec.tfl_information10,
  tfl_information11                 = p_rec.tfl_information11,
  tfl_information12                 = p_rec.tfl_information12,
  tfl_information13                 = p_rec.tfl_information13,
  tfl_information14                 = p_rec.tfl_information14,
  tfl_information15                 = p_rec.tfl_information15,
  tfl_information16                 = p_rec.tfl_information16,
  tfl_information17                 = p_rec.tfl_information17,
  tfl_information18                 = p_rec.tfl_information18,
  tfl_information19                 = p_rec.tfl_information19,
  tfl_information20                 = p_rec.tfl_information20
  where finance_line_id = p_rec.finance_line_id;
  --
  ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfl_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfl_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfl_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in out nocopy ota_tfl_api_shd.g_rec_type) is
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
Procedure post_update(p_rec in ota_tfl_api_shd.g_rec_type) is
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
Function convert_defs(p_rec in out nocopy ota_tfl_api_shd.g_rec_type)
         Return ota_tfl_api_shd.g_rec_type is
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
  If (p_rec.finance_header_id = hr_api.g_number) then
    p_rec.finance_header_id :=
    ota_tfl_api_shd.g_old_rec.finance_header_id;
  End If;
  If (p_rec.cancelled_flag = hr_api.g_varchar2) then
    p_rec.cancelled_flag :=
    ota_tfl_api_shd.g_old_rec.cancelled_flag;
  End If;
  If (p_rec.date_raised = hr_api.g_date) then
    p_rec.date_raised :=
    ota_tfl_api_shd.g_old_rec.date_raised;
  End If;
  If (p_rec.line_type = hr_api.g_varchar2) then
    p_rec.line_type :=
    ota_tfl_api_shd.g_old_rec.line_type;
  End If;
  If (p_rec.sequence_number = hr_api.g_number) then
    p_rec.sequence_number :=
    ota_tfl_api_shd.g_old_rec.sequence_number;
  End If;
  If (p_rec.transfer_status = hr_api.g_varchar2) then
    p_rec.transfer_status :=
    ota_tfl_api_shd.g_old_rec.transfer_status;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tfl_api_shd.g_old_rec.comments;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_tfl_api_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.money_amount = hr_api.g_number) then
    p_rec.money_amount :=
    ota_tfl_api_shd.g_old_rec.money_amount;
  End If;
  If (p_rec.standard_amount = hr_api.g_number) then
    p_rec.standard_amount :=
    ota_tfl_api_shd.g_old_rec.standard_amount;
  End If;
  If (p_rec.trans_information_category = hr_api.g_varchar2) then
    p_rec.trans_information_category :=
    ota_tfl_api_shd.g_old_rec.trans_information_category;
  End If;
  If (p_rec.trans_information1 = hr_api.g_varchar2) then
    p_rec.trans_information1 :=
    ota_tfl_api_shd.g_old_rec.trans_information1;
  End If;
  If (p_rec.trans_information10 = hr_api.g_varchar2) then
    p_rec.trans_information10 :=
    ota_tfl_api_shd.g_old_rec.trans_information10;
  End If;
  If (p_rec.trans_information11 = hr_api.g_varchar2) then
    p_rec.trans_information11 :=
    ota_tfl_api_shd.g_old_rec.trans_information11;
  End If;
  If (p_rec.trans_information12 = hr_api.g_varchar2) then
    p_rec.trans_information12 :=
    ota_tfl_api_shd.g_old_rec.trans_information12;
  End If;
  If (p_rec.trans_information13 = hr_api.g_varchar2) then
    p_rec.trans_information13 :=
    ota_tfl_api_shd.g_old_rec.trans_information13;
  End If;
  If (p_rec.trans_information14 = hr_api.g_varchar2) then
    p_rec.trans_information14 :=
    ota_tfl_api_shd.g_old_rec.trans_information14;
  End If;
  If (p_rec.trans_information15 = hr_api.g_varchar2) then
    p_rec.trans_information15 :=
    ota_tfl_api_shd.g_old_rec.trans_information15;
  End If;
  If (p_rec.trans_information16 = hr_api.g_varchar2) then
    p_rec.trans_information16 :=
    ota_tfl_api_shd.g_old_rec.trans_information16;
  End If;
  If (p_rec.trans_information17 = hr_api.g_varchar2) then
    p_rec.trans_information17 :=
    ota_tfl_api_shd.g_old_rec.trans_information17;
  End If;
  If (p_rec.trans_information18 = hr_api.g_varchar2) then
    p_rec.trans_information18 :=
    ota_tfl_api_shd.g_old_rec.trans_information18;
  End If;
  If (p_rec.trans_information19 = hr_api.g_varchar2) then
    p_rec.trans_information19 :=
    ota_tfl_api_shd.g_old_rec.trans_information19;
  End If;
  If (p_rec.trans_information2 = hr_api.g_varchar2) then
    p_rec.trans_information2 :=
    ota_tfl_api_shd.g_old_rec.trans_information2;
  End If;
  If (p_rec.trans_information20 = hr_api.g_varchar2) then
    p_rec.trans_information20 :=
    ota_tfl_api_shd.g_old_rec.trans_information20;
  End If;
  If (p_rec.trans_information3 = hr_api.g_varchar2) then
    p_rec.trans_information3 :=
    ota_tfl_api_shd.g_old_rec.trans_information3;
  End If;
  If (p_rec.trans_information4 = hr_api.g_varchar2) then
    p_rec.trans_information4 :=
    ota_tfl_api_shd.g_old_rec.trans_information4;
  End If;
  If (p_rec.trans_information5 = hr_api.g_varchar2) then
    p_rec.trans_information5 :=
    ota_tfl_api_shd.g_old_rec.trans_information5;
  End If;
  If (p_rec.trans_information6 = hr_api.g_varchar2) then
    p_rec.trans_information6 :=
    ota_tfl_api_shd.g_old_rec.trans_information6;
  End If;
  If (p_rec.trans_information7 = hr_api.g_varchar2) then
    p_rec.trans_information7 :=
    ota_tfl_api_shd.g_old_rec.trans_information7;
  End If;
  If (p_rec.trans_information8 = hr_api.g_varchar2) then
    p_rec.trans_information8 :=
    ota_tfl_api_shd.g_old_rec.trans_information8;
  End If;
  If (p_rec.trans_information9 = hr_api.g_varchar2) then
    p_rec.trans_information9 :=
    ota_tfl_api_shd.g_old_rec.trans_information9;
  End If;
  If (p_rec.transfer_date = hr_api.g_date) then
    p_rec.transfer_date :=
    ota_tfl_api_shd.g_old_rec.transfer_date;
  End If;
  If (p_rec.transfer_message = hr_api.g_varchar2) then
    p_rec.transfer_message :=
    ota_tfl_api_shd.g_old_rec.transfer_message;
  End If;
  If (p_rec.unitary_amount = hr_api.g_number) then
    p_rec.unitary_amount :=
    ota_tfl_api_shd.g_old_rec.unitary_amount;
  End If;
  If (p_rec.booking_deal_id = hr_api.g_number) then
    p_rec.booking_deal_id :=
    ota_tfl_api_shd.g_old_rec.booking_deal_id;
  End If;
  If (p_rec.booking_id = hr_api.g_number) then
    p_rec.booking_id :=
    ota_tfl_api_shd.g_old_rec.booking_id;
  End If;
  If (p_rec.resource_allocation_id = hr_api.g_number) then
    p_rec.resource_allocation_id :=
    ota_tfl_api_shd.g_old_rec.resource_allocation_id;
  End If;
  If (p_rec.resource_booking_id = hr_api.g_number) then
    p_rec.resource_booking_id :=
    ota_tfl_api_shd.g_old_rec.resource_booking_id;
  End If;
  If (p_rec.tfl_information_category = hr_api.g_varchar2) then
    p_rec.tfl_information_category :=
    ota_tfl_api_shd.g_old_rec.tfl_information_category;
  End If;
  If (p_rec.tfl_information1 = hr_api.g_varchar2) then
    p_rec.tfl_information1 :=
    ota_tfl_api_shd.g_old_rec.tfl_information1;
  End If;
  If (p_rec.tfl_information2 = hr_api.g_varchar2) then
    p_rec.tfl_information2 :=
    ota_tfl_api_shd.g_old_rec.tfl_information2;
  End If;
  If (p_rec.tfl_information3 = hr_api.g_varchar2) then
    p_rec.tfl_information3 :=
    ota_tfl_api_shd.g_old_rec.tfl_information3;
  End If;
  If (p_rec.tfl_information4 = hr_api.g_varchar2) then
    p_rec.tfl_information4 :=
    ota_tfl_api_shd.g_old_rec.tfl_information4;
  End If;
  If (p_rec.tfl_information5 = hr_api.g_varchar2) then
    p_rec.tfl_information5 :=
    ota_tfl_api_shd.g_old_rec.tfl_information5;
  End If;
  If (p_rec.tfl_information6 = hr_api.g_varchar2) then
    p_rec.tfl_information6 :=
    ota_tfl_api_shd.g_old_rec.tfl_information6;
  End If;
  If (p_rec.tfl_information7 = hr_api.g_varchar2) then
    p_rec.tfl_information7 :=
    ota_tfl_api_shd.g_old_rec.tfl_information7;
  End If;
  If (p_rec.tfl_information8 = hr_api.g_varchar2) then
    p_rec.tfl_information8 :=
    ota_tfl_api_shd.g_old_rec.tfl_information8;
  End If;
  If (p_rec.tfl_information9 = hr_api.g_varchar2) then
    p_rec.tfl_information9 :=
    ota_tfl_api_shd.g_old_rec.tfl_information9;
  End If;
  If (p_rec.tfl_information10 = hr_api.g_varchar2) then
    p_rec.tfl_information10 :=
    ota_tfl_api_shd.g_old_rec.tfl_information10;
  End If;
  If (p_rec.tfl_information11 = hr_api.g_varchar2) then
    p_rec.tfl_information11 :=
    ota_tfl_api_shd.g_old_rec.tfl_information11;
  End If;
  If (p_rec.tfl_information12 = hr_api.g_varchar2) then
    p_rec.tfl_information12 :=
    ota_tfl_api_shd.g_old_rec.tfl_information12;
  End If;
  If (p_rec.tfl_information13 = hr_api.g_varchar2) then
    p_rec.tfl_information13 :=
    ota_tfl_api_shd.g_old_rec.tfl_information13;
  End If;
  If (p_rec.tfl_information14 = hr_api.g_varchar2) then
    p_rec.tfl_information14 :=
    ota_tfl_api_shd.g_old_rec.tfl_information14;
  End If;
  If (p_rec.tfl_information15 = hr_api.g_varchar2) then
    p_rec.tfl_information15 :=
    ota_tfl_api_shd.g_old_rec.tfl_information15;
  End If;
  If (p_rec.tfl_information16 = hr_api.g_varchar2) then
    p_rec.tfl_information16 :=
    ota_tfl_api_shd.g_old_rec.tfl_information16;
  End If;
  If (p_rec.tfl_information17 = hr_api.g_varchar2) then
    p_rec.tfl_information17 :=
    ota_tfl_api_shd.g_old_rec.tfl_information17;
  End If;
  If (p_rec.tfl_information18 = hr_api.g_varchar2) then
    p_rec.tfl_information18 :=
    ota_tfl_api_shd.g_old_rec.tfl_information18;
  End If;
  If (p_rec.tfl_information19 = hr_api.g_varchar2) then
    p_rec.tfl_information19 :=
    ota_tfl_api_shd.g_old_rec.tfl_information19;
  End If;
  If (p_rec.tfl_information20 = hr_api.g_varchar2) then
    p_rec.tfl_information20 :=
    ota_tfl_api_shd.g_old_rec.tfl_information20;
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
  p_rec                     in out nocopy ota_tfl_api_shd.g_rec_type,
  p_validate                in     boolean          default false,
  p_transaction_type        in     varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';

-- 06/05/97 Change Begins
  temp_var     ota_tfl_api_shd.g_rec_type;
-- 06/05/97 Change Ends
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
    SAVEPOINT upd_ota_tfl_api;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tfl_api_shd.lck
	(
	p_rec.finance_line_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  -- 06/05/97 Change Begins
  temp_var := convert_defs(p_rec);

  ota_tfl_api_bus.update_validate( temp_var
                                 , p_rec.money_amount
                                 , p_rec.unitary_amount
                                 , p_rec.date_raised
                                 , p_rec.sequence_number
                                 , p_transaction_type);
  -- 06/05/97 Change Ends
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
    ROLLBACK TO upd_ota_tfl_api;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_finance_line_id              in number,
  p_finance_header_id            in number           default hr_api.g_number,
  p_cancelled_flag               in varchar2         default hr_api.g_varchar2,
  p_date_raised                  in out nocopy date,
  p_line_type                    in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_sequence_number              in out nocopy number,
  p_transfer_status              in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_money_amount                 in number           default hr_api.g_number,
  p_standard_amount              in number           default hr_api.g_number,
  p_trans_information_category   in varchar2         default hr_api.g_varchar2,
  p_trans_information1           in varchar2         default hr_api.g_varchar2,
  p_trans_information10          in varchar2         default hr_api.g_varchar2,
  p_trans_information11          in varchar2         default hr_api.g_varchar2,
  p_trans_information12          in varchar2         default hr_api.g_varchar2,
  p_trans_information13          in varchar2         default hr_api.g_varchar2,
  p_trans_information14          in varchar2         default hr_api.g_varchar2,
  p_trans_information15          in varchar2         default hr_api.g_varchar2,
  p_trans_information16          in varchar2         default hr_api.g_varchar2,
  p_trans_information17          in varchar2         default hr_api.g_varchar2,
  p_trans_information18          in varchar2         default hr_api.g_varchar2,
  p_trans_information19          in varchar2         default hr_api.g_varchar2,
  p_trans_information2           in varchar2         default hr_api.g_varchar2,
  p_trans_information20          in varchar2         default hr_api.g_varchar2,
  p_trans_information3           in varchar2         default hr_api.g_varchar2,
  p_trans_information4           in varchar2         default hr_api.g_varchar2,
  p_trans_information5           in varchar2         default hr_api.g_varchar2,
  p_trans_information6           in varchar2         default hr_api.g_varchar2,
  p_trans_information7           in varchar2         default hr_api.g_varchar2,
  p_trans_information8           in varchar2         default hr_api.g_varchar2,
  p_trans_information9           in varchar2         default hr_api.g_varchar2,
  p_transfer_date                in date             default hr_api.g_date,
  p_transfer_message             in varchar2         default hr_api.g_varchar2,
  p_unitary_amount               in number           default hr_api.g_number,
  p_booking_deal_id              in number           default hr_api.g_number,
  p_booking_id                   in number           default hr_api.g_number,
  p_resource_allocation_id       in number           default hr_api.g_number,
  p_resource_booking_id          in number           default hr_api.g_number,
  p_tfl_information_category     in varchar2         default hr_api.g_varchar2,
  p_tfl_information1             in varchar2         default hr_api.g_varchar2,
  p_tfl_information2             in varchar2         default hr_api.g_varchar2,
  p_tfl_information3             in varchar2         default hr_api.g_varchar2,
  p_tfl_information4             in varchar2         default hr_api.g_varchar2,
  p_tfl_information5             in varchar2         default hr_api.g_varchar2,
  p_tfl_information6             in varchar2         default hr_api.g_varchar2,
  p_tfl_information7             in varchar2         default hr_api.g_varchar2,
  p_tfl_information8             in varchar2         default hr_api.g_varchar2,
  p_tfl_information9             in varchar2         default hr_api.g_varchar2,
  p_tfl_information10            in varchar2         default hr_api.g_varchar2,
  p_tfl_information11            in varchar2         default hr_api.g_varchar2,
  p_tfl_information12            in varchar2         default hr_api.g_varchar2,
  p_tfl_information13            in varchar2         default hr_api.g_varchar2,
  p_tfl_information14            in varchar2         default hr_api.g_varchar2,
  p_tfl_information15            in varchar2         default hr_api.g_varchar2,
  p_tfl_information16            in varchar2         default hr_api.g_varchar2,
  p_tfl_information17            in varchar2         default hr_api.g_varchar2,
  p_tfl_information18            in varchar2         default hr_api.g_varchar2,
  p_tfl_information19            in varchar2         default hr_api.g_varchar2,
  p_tfl_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_transaction_type             in varchar2
  ) is
--
  l_rec	  ota_tfl_api_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tfl_api_shd.convert_args
  (
  p_finance_line_id,
  p_finance_header_id,
  p_cancelled_flag,
  p_date_raised,
  p_line_type,
  p_object_version_number,
  p_sequence_number,
  p_transfer_status,
  p_comments,
  p_currency_code,
  p_money_amount,
  p_standard_amount,
  p_trans_information_category,
  p_trans_information1,
  p_trans_information10,
  p_trans_information11,
  p_trans_information12,
  p_trans_information13,
  p_trans_information14,
  p_trans_information15,
  p_trans_information16,
  p_trans_information17,
  p_trans_information18,
  p_trans_information19,
  p_trans_information2,
  p_trans_information20,
  p_trans_information3,
  p_trans_information4,
  p_trans_information5,
  p_trans_information6,
  p_trans_information7,
  p_trans_information8,
  p_trans_information9,
  p_transfer_date,
  p_transfer_message,
  p_unitary_amount,
  p_booking_deal_id,
  p_booking_id,
  p_resource_allocation_id,
  p_resource_booking_id,
  p_tfl_information_category,
  p_tfl_information1,
  p_tfl_information2,
  p_tfl_information3,
  p_tfl_information4,
  p_tfl_information5,
  p_tfl_information6,
  p_tfl_information7,
  p_tfl_information8,
  p_tfl_information9,
  p_tfl_information10,
  p_tfl_information11,
  p_tfl_information12,
  p_tfl_information13,
  p_tfl_information14,
  p_tfl_information15,
  p_tfl_information16,
  p_tfl_information17,
  p_tfl_information18,
  p_tfl_information19,
  p_tfl_information20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd( l_rec, p_validate, p_transaction_type);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_tfl_api_upd;

/
