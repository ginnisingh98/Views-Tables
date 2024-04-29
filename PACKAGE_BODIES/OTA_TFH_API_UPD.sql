--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_UPD" as
/* $Header: ottfh01t.pkb 120.0 2005/05/29 07:40:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfh_api_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ota_tfh_api_shd.g_rec_type) is
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
  ota_tfh_api_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_finance_headers Row
  --
  update ota_finance_headers
  set
  finance_header_id                 = p_rec.finance_header_id,
  superceding_header_id             = p_rec.superceding_header_id,
  authorizer_person_id              = p_rec.authorizer_person_id,
  organization_id                   = p_rec.organization_id,
  administrator                     = p_rec.administrator,
  cancelled_flag                    = p_rec.cancelled_flag,
  currency_code                     = p_rec.currency_code,
  date_raised                       = p_rec.date_raised,
  object_version_number             = p_rec.object_version_number,
  payment_status_flag               = p_rec.payment_status_flag,
  transfer_status                   = p_rec.transfer_status,
  comments                          = p_rec.comments,
  external_reference                = p_rec.external_reference,
  invoice_address                   = p_rec.invoice_address,
  invoice_contact                   = p_rec.invoice_contact,
  payment_method                    = p_rec.payment_method,
  pym_attribute1                    = p_rec.pym_attribute1,
  pym_attribute10                   = p_rec.pym_attribute10,
  pym_attribute11                   = p_rec.pym_attribute11,
  pym_attribute12                   = p_rec.pym_attribute12,
  pym_attribute13                   = p_rec.pym_attribute13,
  pym_attribute14                   = p_rec.pym_attribute14,
  pym_attribute15                   = p_rec.pym_attribute15,
  pym_attribute16                   = p_rec.pym_attribute16,
  pym_attribute17                   = p_rec.pym_attribute17,
  pym_attribute18                   = p_rec.pym_attribute18,
  pym_attribute19                   = p_rec.pym_attribute19,
  pym_attribute2                    = p_rec.pym_attribute2,
  pym_attribute20                   = p_rec.pym_attribute20,
  pym_attribute3                    = p_rec.pym_attribute3,
  pym_attribute4                    = p_rec.pym_attribute4,
  pym_attribute5                    = p_rec.pym_attribute5,
  pym_attribute6                    = p_rec.pym_attribute6,
  pym_attribute7                    = p_rec.pym_attribute7,
  pym_attribute8                    = p_rec.pym_attribute8,
  pym_attribute9                    = p_rec.pym_attribute9,
  pym_information_category          = p_rec.pym_information_category,
  transfer_date                     = p_rec.transfer_date,
  transfer_message                  = p_rec.transfer_message,
  vendor_id                         = p_rec.vendor_id,
  contact_id                        = p_rec.contact_id,
  address_id                        = p_rec.address_id,
  customer_id                       = p_rec.customer_id,
  tfh_information_category          = p_rec.tfh_information_category,
  tfh_information1                  = p_rec.tfh_information1,
  tfh_information2                  = p_rec.tfh_information2,
  tfh_information3                  = p_rec.tfh_information3,
  tfh_information4                  = p_rec.tfh_information4,
  tfh_information5                  = p_rec.tfh_information5,
  tfh_information6                  = p_rec.tfh_information6,
  tfh_information7                  = p_rec.tfh_information7,
  tfh_information8                  = p_rec.tfh_information8,
  tfh_information9                  = p_rec.tfh_information9,
  tfh_information10                 = p_rec.tfh_information10,
  tfh_information11                 = p_rec.tfh_information11,
  tfh_information12                 = p_rec.tfh_information12,
  tfh_information13                 = p_rec.tfh_information13,
  tfh_information14                 = p_rec.tfh_information14,
  tfh_information15                 = p_rec.tfh_information15,
  tfh_information16                 = p_rec.tfh_information16,
  tfh_information17                 = p_rec.tfh_information17,
  tfh_information18                 = p_rec.tfh_information18,
  tfh_information19                 = p_rec.tfh_information19,
  tfh_information20                 = p_rec.tfh_information20,
  paying_cost_center                = p_rec.paying_cost_center,
  receiving_cost_center             = p_rec.receiving_cost_center,
  transfer_from_set_of_books_id     = p_rec.transfer_from_set_of_book_id,
  transfer_to_set_of_books_id       = p_rec.transfer_to_set_of_book_id,
  from_segment1                     = p_rec.from_segment1,
  from_segment2				= p_rec.from_segment2,
  from_segment3				= p_rec.from_segment3,
  from_segment4				= p_rec.from_segment4,
  from_segment5				= p_rec.from_segment5,
  from_segment6                     = p_rec.from_segment6,
  from_segment7				= p_rec.from_segment7,
  from_segment8				= p_rec.from_segment8,
  from_segment9				= p_rec.from_segment9,
  from_segment10				= p_rec.from_segment10,
  from_segment11                     = p_rec.from_segment11,
  from_segment12				= p_rec.from_segment12,
  from_segment13				= p_rec.from_segment13,
  from_segment14				= p_rec.from_segment14,
  from_segment15				= p_rec.from_segment15,
  from_segment16                     = p_rec.from_segment16,
  from_segment17				= p_rec.from_segment17,
  from_segment18				= p_rec.from_segment18,
  from_segment19				= p_rec.from_segment19,
  from_segment20				= p_rec.from_segment20,
  from_segment21                     = p_rec.from_segment21,
  from_segment22				= p_rec.from_segment22,
  from_segment23				= p_rec.from_segment23,
  from_segment24				= p_rec.from_segment24,
  from_segment25				= p_rec.from_segment25,
  from_segment26                     = p_rec.from_segment26,
  from_segment27				= p_rec.from_segment27,
  from_segment28				= p_rec.from_segment28,
  from_segment29				= p_rec.from_segment29,
  from_segment30				= p_rec.from_segment30,
  to_segment1                     = p_rec.to_segment1,
  to_segment2				= p_rec.to_segment2,
  to_segment3				= p_rec.to_segment3,
  to_segment4				= p_rec.to_segment4,
  to_segment5				= p_rec.to_segment5,
  to_segment6                     = p_rec.to_segment6,
  to_segment7				= p_rec.to_segment7,
  to_segment8				= p_rec.to_segment8,
  to_segment9				= p_rec.to_segment9,
  to_segment10				= p_rec.to_segment10,
  to_segment11                     = p_rec.to_segment11,
  to_segment12				= p_rec.to_segment12,
  to_segment13				= p_rec.to_segment13,
  to_segment14				= p_rec.to_segment14,
  to_segment15				= p_rec.to_segment15,
  to_segment16                     = p_rec.to_segment16,
  to_segment17				= p_rec.to_segment17,
  to_segment18				= p_rec.to_segment18,
  to_segment19				= p_rec.to_segment19,
  to_segment20				= p_rec.to_segment20,
  to_segment21                     = p_rec.to_segment21,
  to_segment22				= p_rec.to_segment22,
  to_segment23				= p_rec.to_segment23,
  to_segment24				= p_rec.to_segment24,
  to_segment25				= p_rec.to_segment25,
  to_segment26                     = p_rec.to_segment26,
  to_segment27				= p_rec.to_segment27,
  to_segment28				= p_rec.to_segment28,
  to_segment29				= p_rec.to_segment29,
  to_segment30				= p_rec.to_segment30,
  transfer_from_cc_id               = p_rec.transfer_from_cc_id,
  transfer_to_cc_id                 = p_rec.transfer_to_cc_id
  where finance_header_id = p_rec.finance_header_id;
  --
  ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfh_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfh_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tfh_api_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ota_tfh_api_shd.g_rec_type) is
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
Procedure post_update(p_rec in ota_tfh_api_shd.g_rec_type) is
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
Function convert_defs(p_rec in out nocopy ota_tfh_api_shd.g_rec_type)
         Return ota_tfh_api_shd.g_rec_type is
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
  If (p_rec.superceding_header_id = hr_api.g_number) then
    p_rec.superceding_header_id :=
    ota_tfh_api_shd.g_old_rec.superceding_header_id;
  End If;
  If (p_rec.authorizer_person_id = hr_api.g_number) then
    p_rec.authorizer_person_id :=
    ota_tfh_api_shd.g_old_rec.authorizer_person_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_tfh_api_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.administrator = hr_api.g_number) then
    p_rec.administrator :=
    ota_tfh_api_shd.g_old_rec.administrator;
  End If;
  If (p_rec.cancelled_flag = hr_api.g_varchar2) then
    p_rec.cancelled_flag :=
    ota_tfh_api_shd.g_old_rec.cancelled_flag;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_tfh_api_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.date_raised = hr_api.g_date) then
    p_rec.date_raised :=
    ota_tfh_api_shd.g_old_rec.date_raised;
  End If;
  If (p_rec.payment_status_flag = hr_api.g_varchar2) then
    p_rec.payment_status_flag :=
    ota_tfh_api_shd.g_old_rec.payment_status_flag;
  End If;
  If (p_rec.transfer_status = hr_api.g_varchar2) then
    p_rec.transfer_status :=
    ota_tfh_api_shd.g_old_rec.transfer_status;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    ota_tfh_api_shd.g_old_rec.type;
  End If;
  If (p_rec.receivable_type = hr_api.g_varchar2) then
    p_rec.receivable_type :=
    ota_tfh_api_shd.g_old_rec.receivable_type;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tfh_api_shd.g_old_rec.comments;
  End If;
  If (p_rec.external_reference = hr_api.g_varchar2) then
    p_rec.external_reference :=
    ota_tfh_api_shd.g_old_rec.external_reference;
  End If;
  If (p_rec.invoice_address = hr_api.g_varchar2) then
    p_rec.invoice_address :=
    ota_tfh_api_shd.g_old_rec.invoice_address;
  End If;
  If (p_rec.invoice_contact = hr_api.g_varchar2) then
    p_rec.invoice_contact :=
    ota_tfh_api_shd.g_old_rec.invoice_contact;
  End If;
  If (p_rec.payment_method = hr_api.g_varchar2) then
    p_rec.payment_method :=
    ota_tfh_api_shd.g_old_rec.payment_method;
  End If;
  If (p_rec.pym_attribute1 = hr_api.g_varchar2) then
    p_rec.pym_attribute1 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute1;
  End If;
  If (p_rec.pym_attribute10 = hr_api.g_varchar2) then
    p_rec.pym_attribute10 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute10;
  End If;
  If (p_rec.pym_attribute11 = hr_api.g_varchar2) then
    p_rec.pym_attribute11 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute11;
  End If;
  If (p_rec.pym_attribute12 = hr_api.g_varchar2) then
    p_rec.pym_attribute12 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute12;
  End If;
  If (p_rec.pym_attribute13 = hr_api.g_varchar2) then
    p_rec.pym_attribute13 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute13;
  End If;
  If (p_rec.pym_attribute14 = hr_api.g_varchar2) then
    p_rec.pym_attribute14 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute14;
  End If;
  If (p_rec.pym_attribute15 = hr_api.g_varchar2) then
    p_rec.pym_attribute15 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute15;
  End If;
  If (p_rec.pym_attribute16 = hr_api.g_varchar2) then
    p_rec.pym_attribute16 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute16;
  End If;
  If (p_rec.pym_attribute17 = hr_api.g_varchar2) then
    p_rec.pym_attribute17 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute17;
  End If;
  If (p_rec.pym_attribute18 = hr_api.g_varchar2) then
    p_rec.pym_attribute18 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute18;
  End If;
  If (p_rec.pym_attribute19 = hr_api.g_varchar2) then
    p_rec.pym_attribute19 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute19;
  End If;
  If (p_rec.pym_attribute2 = hr_api.g_varchar2) then
    p_rec.pym_attribute2 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute2;
  End If;
  If (p_rec.pym_attribute20 = hr_api.g_varchar2) then
    p_rec.pym_attribute20 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute20;
  End If;
  If (p_rec.pym_attribute3 = hr_api.g_varchar2) then
    p_rec.pym_attribute3 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute3;
  End If;
  If (p_rec.pym_attribute4 = hr_api.g_varchar2) then
    p_rec.pym_attribute4 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute4;
  End If;
  If (p_rec.pym_attribute5 = hr_api.g_varchar2) then
    p_rec.pym_attribute5 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute5;
  End If;
  If (p_rec.pym_attribute6 = hr_api.g_varchar2) then
    p_rec.pym_attribute6 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute6;
  End If;
  If (p_rec.pym_attribute7 = hr_api.g_varchar2) then
    p_rec.pym_attribute7 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute7;
  End If;
  If (p_rec.pym_attribute8 = hr_api.g_varchar2) then
    p_rec.pym_attribute8 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute8;
  End If;
  If (p_rec.pym_attribute9 = hr_api.g_varchar2) then
    p_rec.pym_attribute9 :=
    ota_tfh_api_shd.g_old_rec.pym_attribute9;
  End If;
  If (p_rec.pym_information_category = hr_api.g_varchar2) then
    p_rec.pym_information_category :=
    ota_tfh_api_shd.g_old_rec.pym_information_category;
  End If;
  If (p_rec.transfer_date = hr_api.g_date) then
    p_rec.transfer_date :=
    ota_tfh_api_shd.g_old_rec.transfer_date;
  End If;
  If (p_rec.transfer_message = hr_api.g_varchar2) then
    p_rec.transfer_message :=
    ota_tfh_api_shd.g_old_rec.transfer_message;
  End If;
  If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    ota_tfh_api_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.contact_id = hr_api.g_number) then
    p_rec.contact_id :=
    ota_tfh_api_shd.g_old_rec.contact_id;
  End If;
  If (p_rec.address_id = hr_api.g_number) then
    p_rec.address_id :=
    ota_tfh_api_shd.g_old_rec.address_id;
  End If;
  If (p_rec.customer_id = hr_api.g_number) then
    p_rec.customer_id :=
    ota_tfh_api_shd.g_old_rec.customer_id;
  End If;
  If (p_rec.tfh_information_category = hr_api.g_varchar2) then
    p_rec.tfh_information_category :=
    ota_tfh_api_shd.g_old_rec.tfh_information_category;
  End If;
  If (p_rec.tfh_information1 = hr_api.g_varchar2) then
    p_rec.tfh_information1 :=
    ota_tfh_api_shd.g_old_rec.tfh_information1;
  End If;
  If (p_rec.tfh_information2 = hr_api.g_varchar2) then
    p_rec.tfh_information2 :=
    ota_tfh_api_shd.g_old_rec.tfh_information2;
  End If;
  If (p_rec.tfh_information3 = hr_api.g_varchar2) then
    p_rec.tfh_information3 :=
    ota_tfh_api_shd.g_old_rec.tfh_information3;
  End If;
  If (p_rec.tfh_information4 = hr_api.g_varchar2) then
    p_rec.tfh_information4 :=
    ota_tfh_api_shd.g_old_rec.tfh_information4;
  End If;
  If (p_rec.tfh_information5 = hr_api.g_varchar2) then
    p_rec.tfh_information5 :=
    ota_tfh_api_shd.g_old_rec.tfh_information5;
  End If;
  If (p_rec.tfh_information6 = hr_api.g_varchar2) then
    p_rec.tfh_information6 :=
    ota_tfh_api_shd.g_old_rec.tfh_information6;
  End If;
  If (p_rec.tfh_information7 = hr_api.g_varchar2) then
    p_rec.tfh_information7 :=
    ota_tfh_api_shd.g_old_rec.tfh_information7;
  End If;
  If (p_rec.tfh_information8 = hr_api.g_varchar2) then
    p_rec.tfh_information8 :=
    ota_tfh_api_shd.g_old_rec.tfh_information8;
  End If;
  If (p_rec.tfh_information9 = hr_api.g_varchar2) then
    p_rec.tfh_information9 :=
    ota_tfh_api_shd.g_old_rec.tfh_information9;
  End If;
  If (p_rec.tfh_information10 = hr_api.g_varchar2) then
    p_rec.tfh_information10 :=
    ota_tfh_api_shd.g_old_rec.tfh_information10;
  End If;
  If (p_rec.tfh_information11 = hr_api.g_varchar2) then
    p_rec.tfh_information11 :=
    ota_tfh_api_shd.g_old_rec.tfh_information11;
  End If;
  If (p_rec.tfh_information12 = hr_api.g_varchar2) then
    p_rec.tfh_information12 :=
    ota_tfh_api_shd.g_old_rec.tfh_information12;
  End If;
  If (p_rec.tfh_information13 = hr_api.g_varchar2) then
    p_rec.tfh_information13 :=
    ota_tfh_api_shd.g_old_rec.tfh_information13;
  End If;
  If (p_rec.tfh_information14 = hr_api.g_varchar2) then
    p_rec.tfh_information14 :=
    ota_tfh_api_shd.g_old_rec.tfh_information14;
  End If;
  If (p_rec.tfh_information15 = hr_api.g_varchar2) then
    p_rec.tfh_information15 :=
    ota_tfh_api_shd.g_old_rec.tfh_information15;
  End If;
  If (p_rec.tfh_information16 = hr_api.g_varchar2) then
    p_rec.tfh_information16 :=
    ota_tfh_api_shd.g_old_rec.tfh_information16;
  End If;
  If (p_rec.tfh_information17 = hr_api.g_varchar2) then
    p_rec.tfh_information17 :=
    ota_tfh_api_shd.g_old_rec.tfh_information17;
  End If;
  If (p_rec.tfh_information18 = hr_api.g_varchar2) then
    p_rec.tfh_information18 :=
    ota_tfh_api_shd.g_old_rec.tfh_information18;
  End If;
  If (p_rec.tfh_information19 = hr_api.g_varchar2) then
    p_rec.tfh_information19 :=
    ota_tfh_api_shd.g_old_rec.tfh_information19;
  End If;
  If (p_rec.tfh_information20 = hr_api.g_varchar2) then
    p_rec.tfh_information20 :=
    ota_tfh_api_shd.g_old_rec.tfh_information20;
  End If;
  If (p_rec.paying_cost_center = hr_api.g_varchar2) then
    p_rec.paying_cost_center :=
    ota_tfh_api_shd.g_old_rec.paying_cost_center;
  End If;
  If (p_rec.receiving_cost_center = hr_api.g_varchar2) then
    p_rec.receiving_cost_center :=
    ota_tfh_api_shd.g_old_rec.receiving_cost_center;
  End If;
  If (p_rec.transfer_from_set_of_book_id = hr_api.g_number) then
    p_rec.transfer_from_set_of_book_id :=
    ota_tfh_api_shd.g_old_rec.transfer_from_set_of_book_id;
  End If;
  If (p_rec.transfer_to_set_of_book_id = hr_api.g_number) then
    p_rec.transfer_to_set_of_book_id :=
    ota_tfh_api_shd.g_old_rec.transfer_to_set_of_book_id;
  End If;
  If (p_rec.from_segment1 = hr_api.g_varchar2) then
    p_rec.from_segment1 :=
    ota_tfh_api_shd.g_old_rec.from_segment1;
  End If;
  If (p_rec.from_segment2 = hr_api.g_varchar2) then
    p_rec.from_segment2 :=
    ota_tfh_api_shd.g_old_rec.from_segment2;
  End If;
  If (p_rec.from_segment3 = hr_api.g_varchar2) then
    p_rec.from_segment3 :=
    ota_tfh_api_shd.g_old_rec.from_segment3;
  End If;
  If (p_rec.from_segment4 = hr_api.g_varchar2) then
    p_rec.from_segment4 :=
    ota_tfh_api_shd.g_old_rec.from_segment4;
  End If;
  If (p_rec.from_segment5 = hr_api.g_varchar2) then
    p_rec.from_segment5 :=
    ota_tfh_api_shd.g_old_rec.from_segment5;
  End If;
  If (p_rec.from_segment6 = hr_api.g_varchar2) then
    p_rec.from_segment6 :=
    ota_tfh_api_shd.g_old_rec.from_segment6;
  End If;
  If (p_rec.from_segment7 = hr_api.g_varchar2) then
    p_rec.from_segment7 :=
    ota_tfh_api_shd.g_old_rec.from_segment7;
  End If;
  If (p_rec.from_segment8 = hr_api.g_varchar2) then
    p_rec.from_segment8 :=
    ota_tfh_api_shd.g_old_rec.from_segment8;
  End If;
  If (p_rec.from_segment9 = hr_api.g_varchar2) then
    p_rec.from_segment9 :=
    ota_tfh_api_shd.g_old_rec.from_segment9;
  End If;
  If (p_rec.from_segment10 = hr_api.g_varchar2) then
    p_rec.from_segment10 :=
    ota_tfh_api_shd.g_old_rec.from_segment10;
  End If;
    If (p_rec.from_segment11 = hr_api.g_varchar2) then
    p_rec.from_segment11 :=
    ota_tfh_api_shd.g_old_rec.from_segment11;
  End If;
  If (p_rec.from_segment12 = hr_api.g_varchar2) then
    p_rec.from_segment12 :=
    ota_tfh_api_shd.g_old_rec.from_segment12;
  End If;
  If (p_rec.from_segment13 = hr_api.g_varchar2) then
    p_rec.from_segment13 :=
    ota_tfh_api_shd.g_old_rec.from_segment13;
  End If;
  If (p_rec.from_segment14 = hr_api.g_varchar2) then
    p_rec.from_segment14 :=
    ota_tfh_api_shd.g_old_rec.from_segment14;
  End If;
  If (p_rec.from_segment15 = hr_api.g_varchar2) then
    p_rec.from_segment15 :=
    ota_tfh_api_shd.g_old_rec.from_segment15;
  End If;
  If (p_rec.from_segment16 = hr_api.g_varchar2) then
    p_rec.from_segment16 :=
    ota_tfh_api_shd.g_old_rec.from_segment16;
  End If;
  If (p_rec.from_segment17 = hr_api.g_varchar2) then
    p_rec.from_segment17 :=
    ota_tfh_api_shd.g_old_rec.from_segment17;
  End If;
  If (p_rec.from_segment18 = hr_api.g_varchar2) then
    p_rec.from_segment18 :=
    ota_tfh_api_shd.g_old_rec.from_segment18;
  End If;
  If (p_rec.from_segment19 = hr_api.g_varchar2) then
    p_rec.from_segment19 :=
    ota_tfh_api_shd.g_old_rec.from_segment19;
  End If;
  If (p_rec.from_segment20 = hr_api.g_varchar2) then
    p_rec.from_segment20 :=
    ota_tfh_api_shd.g_old_rec.from_segment20;
  End If;
  If (p_rec.from_segment21 = hr_api.g_varchar2) then
    p_rec.from_segment21 :=
    ota_tfh_api_shd.g_old_rec.from_segment21;
  End If;
  If (p_rec.from_segment22 = hr_api.g_varchar2) then
    p_rec.from_segment22 :=
    ota_tfh_api_shd.g_old_rec.from_segment22;
  End If;
  If (p_rec.from_segment23 = hr_api.g_varchar2) then
    p_rec.from_segment23 :=
    ota_tfh_api_shd.g_old_rec.from_segment23;
  End If;
  If (p_rec.from_segment24 = hr_api.g_varchar2) then
    p_rec.from_segment24 :=
    ota_tfh_api_shd.g_old_rec.from_segment24;
  End If;
  If (p_rec.from_segment25 = hr_api.g_varchar2) then
    p_rec.from_segment25 :=
    ota_tfh_api_shd.g_old_rec.from_segment25;
  End If;
  If (p_rec.from_segment26 = hr_api.g_varchar2) then
    p_rec.from_segment26 :=
    ota_tfh_api_shd.g_old_rec.from_segment26;
  End If;
  If (p_rec.from_segment27 = hr_api.g_varchar2) then
    p_rec.from_segment27 :=
    ota_tfh_api_shd.g_old_rec.from_segment27;
  End If;
  If (p_rec.from_segment28 = hr_api.g_varchar2) then
    p_rec.from_segment28 :=
    ota_tfh_api_shd.g_old_rec.from_segment28;
  End If;
  If (p_rec.from_segment29 = hr_api.g_varchar2) then
    p_rec.from_segment29 :=
    ota_tfh_api_shd.g_old_rec.from_segment29;
  End If;
  If (p_rec.from_segment30 = hr_api.g_varchar2) then
    p_rec.from_segment30 :=
    ota_tfh_api_shd.g_old_rec.from_segment30;
  End If;


If (p_rec.to_segment1 = hr_api.g_varchar2) then
    p_rec.to_segment1 :=
    ota_tfh_api_shd.g_old_rec.to_segment1;
  End If;
  If (p_rec.to_segment2 = hr_api.g_varchar2) then
    p_rec.to_segment2 :=
    ota_tfh_api_shd.g_old_rec.to_segment2;
  End If;
  If (p_rec.to_segment3 = hr_api.g_varchar2) then
    p_rec.to_segment3 :=
    ota_tfh_api_shd.g_old_rec.to_segment3;
  End If;
  If (p_rec.to_segment4 = hr_api.g_varchar2) then
    p_rec.to_segment4 :=
    ota_tfh_api_shd.g_old_rec.to_segment4;
  End If;
  If (p_rec.to_segment5 = hr_api.g_varchar2) then
    p_rec.to_segment5 :=
    ota_tfh_api_shd.g_old_rec.to_segment5;
  End If;
  If (p_rec.to_segment6 = hr_api.g_varchar2) then
    p_rec.to_segment6 :=
    ota_tfh_api_shd.g_old_rec.to_segment6;
  End If;
  If (p_rec.to_segment7 = hr_api.g_varchar2) then
    p_rec.to_segment7 :=
    ota_tfh_api_shd.g_old_rec.to_segment7;
  End If;
  If (p_rec.to_segment8 = hr_api.g_varchar2) then
    p_rec.to_segment8 :=
    ota_tfh_api_shd.g_old_rec.to_segment8;
  End If;
  If (p_rec.to_segment9 = hr_api.g_varchar2) then
    p_rec.to_segment9 :=
    ota_tfh_api_shd.g_old_rec.to_segment9;
  End If;
  If (p_rec.to_segment10 = hr_api.g_varchar2) then
    p_rec.to_segment10 :=
    ota_tfh_api_shd.g_old_rec.to_segment10;
  End If;
    If (p_rec.to_segment11 = hr_api.g_varchar2) then
    p_rec.to_segment11 :=
    ota_tfh_api_shd.g_old_rec.to_segment11;
  End If;
  If (p_rec.to_segment12 = hr_api.g_varchar2) then
    p_rec.to_segment12 :=
    ota_tfh_api_shd.g_old_rec.to_segment12;
  End If;
  If (p_rec.to_segment13 = hr_api.g_varchar2) then
    p_rec.to_segment13 :=
    ota_tfh_api_shd.g_old_rec.to_segment13;
  End If;
  If (p_rec.to_segment14 = hr_api.g_varchar2) then
    p_rec.to_segment14 :=
    ota_tfh_api_shd.g_old_rec.to_segment14;
  End If;
  If (p_rec.to_segment15 = hr_api.g_varchar2) then
    p_rec.to_segment15 :=
    ota_tfh_api_shd.g_old_rec.to_segment15;
  End If;
  If (p_rec.to_segment16 = hr_api.g_varchar2) then
    p_rec.to_segment16 :=
    ota_tfh_api_shd.g_old_rec.to_segment16;
  End If;
  If (p_rec.to_segment17 = hr_api.g_varchar2) then
    p_rec.to_segment17 :=
    ota_tfh_api_shd.g_old_rec.to_segment17;
  End If;
  If (p_rec.to_segment18 = hr_api.g_varchar2) then
    p_rec.to_segment18 :=
    ota_tfh_api_shd.g_old_rec.to_segment18;
  End If;
  If (p_rec.to_segment19 = hr_api.g_varchar2) then
    p_rec.to_segment19 :=
    ota_tfh_api_shd.g_old_rec.to_segment19;
  End If;
  If (p_rec.to_segment20 = hr_api.g_varchar2) then
    p_rec.to_segment20 :=
    ota_tfh_api_shd.g_old_rec.to_segment20;
  End If;
  If (p_rec.to_segment21 = hr_api.g_varchar2) then
    p_rec.to_segment21 :=
    ota_tfh_api_shd.g_old_rec.to_segment21;
  End If;
  If (p_rec.to_segment22 = hr_api.g_varchar2) then
    p_rec.to_segment22 :=
    ota_tfh_api_shd.g_old_rec.to_segment22;
  End If;
  If (p_rec.to_segment23 = hr_api.g_varchar2) then
    p_rec.to_segment23 :=
    ota_tfh_api_shd.g_old_rec.to_segment23;
  End If;
  If (p_rec.to_segment24 = hr_api.g_varchar2) then
    p_rec.to_segment24 :=
    ota_tfh_api_shd.g_old_rec.to_segment24;
  End If;
  If (p_rec.to_segment25 = hr_api.g_varchar2) then
    p_rec.to_segment25 :=
    ota_tfh_api_shd.g_old_rec.to_segment25;
  End If;
  If (p_rec.to_segment26 = hr_api.g_varchar2) then
    p_rec.to_segment26 :=
    ota_tfh_api_shd.g_old_rec.to_segment26;
  End If;
  If (p_rec.to_segment27 = hr_api.g_varchar2) then
    p_rec.to_segment27 :=
    ota_tfh_api_shd.g_old_rec.to_segment27;
  End If;
  If (p_rec.to_segment28 = hr_api.g_varchar2) then
    p_rec.to_segment28 :=
    ota_tfh_api_shd.g_old_rec.to_segment28;
  End If;
  If (p_rec.to_segment29 = hr_api.g_varchar2) then
    p_rec.to_segment29 :=
    ota_tfh_api_shd.g_old_rec.to_segment29;
  End If;
  If (p_rec.to_segment30 = hr_api.g_varchar2) then
    p_rec.to_segment30 :=
    ota_tfh_api_shd.g_old_rec.to_segment30;
  End If;
  If (p_rec.transfer_from_cc_id = hr_api.g_number) then
    p_rec.transfer_from_cc_id :=
    ota_tfh_api_shd.g_old_rec.transfer_from_cc_id;
  End If;
  If (p_rec.transfer_to_cc_id = hr_api.g_number) then
    p_rec.transfer_to_cc_id :=
    ota_tfh_api_shd.g_old_rec.transfer_to_cc_id;
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
  p_rec        in out nocopy ota_tfh_api_shd.g_rec_type,
  p_validate   in     boolean default false,
  p_transaction_type    in     varchar2 default 'UPDATE'
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
-- 06/05/97  Change Begins
  temp_var     ota_tfh_api_shd.g_rec_type;
-- 06/05/97  Change Ends
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
    SAVEPOINT upd_ota_tfh;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tfh_api_shd.lck
	(
	p_rec.finance_header_id,
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

  ota_tfh_api_bus.update_validate(temp_var
                                 ,p_transaction_type);

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
  ota_tfh_api_business_rules2.update_finance_lines (p_rec);
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
    ROLLBACK TO upd_ota_tfh;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_finance_header_id            in number,
  p_superceding_header_id        in number           default hr_api.g_number,
  p_authorizer_person_id         in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_administrator                in number           default hr_api.g_number,
  p_cancelled_flag               in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_date_raised                  in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_payment_status_flag          in varchar2         default hr_api.g_varchar2,
  p_transfer_status              in varchar2         default hr_api.g_varchar2,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_receivable_type              in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_external_reference           in varchar2         default hr_api.g_varchar2,
  p_invoice_address              in varchar2         default hr_api.g_varchar2,
  p_invoice_contact              in varchar2         default hr_api.g_varchar2,
  p_payment_method               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pym_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pym_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pym_information_category     in varchar2         default hr_api.g_varchar2,
  p_transfer_date                in date             default hr_api.g_date,
  p_transfer_message             in varchar2         default hr_api.g_varchar2,
  p_vendor_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_address_id                   in number           default hr_api.g_number,
  p_customer_id                  in number           default hr_api.g_number,
  p_tfh_information_category     in varchar2         default hr_api.g_varchar2,
  p_tfh_information1             in varchar2         default hr_api.g_varchar2,
  p_tfh_information2             in varchar2         default hr_api.g_varchar2,
  p_tfh_information3             in varchar2         default hr_api.g_varchar2,
  p_tfh_information4             in varchar2         default hr_api.g_varchar2,
  p_tfh_information5             in varchar2         default hr_api.g_varchar2,
  p_tfh_information6             in varchar2         default hr_api.g_varchar2,
  p_tfh_information7             in varchar2         default hr_api.g_varchar2,
  p_tfh_information8             in varchar2         default hr_api.g_varchar2,
  p_tfh_information9             in varchar2         default hr_api.g_varchar2,
  p_tfh_information10            in varchar2         default hr_api.g_varchar2,
  p_tfh_information11            in varchar2         default hr_api.g_varchar2,
  p_tfh_information12            in varchar2         default hr_api.g_varchar2,
  p_tfh_information13            in varchar2         default hr_api.g_varchar2,
  p_tfh_information14            in varchar2         default hr_api.g_varchar2,
  p_tfh_information15            in varchar2         default hr_api.g_varchar2,
  p_tfh_information16            in varchar2         default hr_api.g_varchar2,
  p_tfh_information17            in varchar2         default hr_api.g_varchar2,
  p_tfh_information18            in varchar2         default hr_api.g_varchar2,
  p_tfh_information19            in varchar2         default hr_api.g_varchar2,
  p_tfh_information20            in varchar2         default hr_api.g_varchar2,
  p_paying_cost_center           in varchar2         default hr_api.g_varchar2,
  p_receiving_cost_center        in varchar2         default hr_api.g_varchar2,
p_transfer_from_set_of_book_id in number		default hr_api.g_number,
  p_transfer_to_set_of_book_id   in number		default hr_api.g_number,
  p_from_segment1                 in varchar2		default hr_api.g_varchar2,
  p_from_segment2                 in varchar2		default hr_api.g_varchar2,
  p_from_segment3                 in varchar2		default hr_api.g_varchar2,
  p_from_segment4                 in varchar2		default hr_api.g_varchar2,
  p_from_segment5                 in varchar2		default hr_api.g_varchar2,
  p_from_segment6                 in varchar2		default hr_api.g_varchar2,
  p_from_segment7                 in varchar2		default hr_api.g_varchar2,
  p_from_segment8                 in varchar2		default hr_api.g_varchar2,
  p_from_segment9                 in varchar2		default hr_api.g_varchar2,
  p_from_segment10                in varchar2		default hr_api.g_varchar2,
  p_from_segment11                 in varchar2		default hr_api.g_varchar2,
  p_from_segment12                 in varchar2		default hr_api.g_varchar2,
  p_from_segment13                 in varchar2		default hr_api.g_varchar2,
  p_from_segment14                 in varchar2		default hr_api.g_varchar2,
  p_from_segment15                 in varchar2		default hr_api.g_varchar2,
  p_from_segment16                 in varchar2		default hr_api.g_varchar2,
  p_from_segment17                 in varchar2		default hr_api.g_varchar2,
  p_from_segment18                 in varchar2		default hr_api.g_varchar2,
  p_from_segment19                 in varchar2		default hr_api.g_varchar2,
  p_from_segment20                in varchar2		default hr_api.g_varchar2,
  p_from_segment21                 in varchar2		default hr_api.g_varchar2,
  p_from_segment22                 in varchar2		default hr_api.g_varchar2,
  p_from_segment23                 in varchar2		default hr_api.g_varchar2,
  p_from_segment24                 in varchar2		default hr_api.g_varchar2,
  p_from_segment25                 in varchar2		default hr_api.g_varchar2,
  p_from_segment26                 in varchar2		default hr_api.g_varchar2,
  p_from_segment27                 in varchar2		default hr_api.g_varchar2,
  p_from_segment28                 in varchar2		default hr_api.g_varchar2,
  p_from_segment29                	in varchar2		default hr_api.g_varchar2,
  p_from_segment30                	in varchar2		default hr_api.g_varchar2,
  p_to_segment1                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment2                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment3                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment4                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment5                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment6                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment7                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment8                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment9                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment10                	in varchar2		default hr_api.g_varchar2,
  p_to_segment11                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment12                	in varchar2		default hr_api.g_varchar2,
  p_to_segment13                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment14                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment15                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment16                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment17                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment18                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment19                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment20                	in varchar2		default hr_api.g_varchar2,
  p_to_segment21                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment22                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment23                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment24                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment25                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment26                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment27                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment28                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment29                 	in varchar2		default hr_api.g_varchar2,
  p_to_segment30                	in varchar2 	default hr_api.g_varchar2,
  p_transfer_from_cc_id             in number         default hr_api.g_number,
  p_transfer_to_cc_id               in number         default hr_api.g_number,
  p_validate                     in boolean          default false,
  p_transaction_type             in varchar2         default 'UPDATE'
  ) is
--
  l_rec	  ota_tfh_api_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tfh_api_shd.convert_args
  (
  p_finance_header_id,
  p_superceding_header_id,
  p_authorizer_person_id,
  p_organization_id,
  p_administrator,
  p_cancelled_flag,
  p_currency_code,
  p_date_raised,
  p_object_version_number,
  p_payment_status_flag,
  p_transfer_status,
  p_type,
  p_receivable_type,
  p_comments,
  p_external_reference,
  p_invoice_address,
  p_invoice_contact,
  p_payment_method,
  p_pym_attribute1,
  p_pym_attribute10,
  p_pym_attribute11,
  p_pym_attribute12,
  p_pym_attribute13,
  p_pym_attribute14,
  p_pym_attribute15,
  p_pym_attribute16,
  p_pym_attribute17,
  p_pym_attribute18,
  p_pym_attribute19,
  p_pym_attribute2,
  p_pym_attribute20,
  p_pym_attribute3,
  p_pym_attribute4,
  p_pym_attribute5,
  p_pym_attribute6,
  p_pym_attribute7,
  p_pym_attribute8,
  p_pym_attribute9,
  p_pym_information_category,
  p_transfer_date,
  p_transfer_message,
  p_vendor_id,
  p_contact_id,
  p_address_id,
  p_customer_id,
  p_tfh_information_category,
  p_tfh_information1,
  p_tfh_information2,
  p_tfh_information3,
  p_tfh_information4,
  p_tfh_information5,
  p_tfh_information6,
  p_tfh_information7,
  p_tfh_information8,
  p_tfh_information9,
  p_tfh_information10,
  p_tfh_information11,
  p_tfh_information12,
  p_tfh_information13,
  p_tfh_information14,
  p_tfh_information15,
  p_tfh_information16,
  p_tfh_information17,
  p_tfh_information18,
  p_tfh_information19,
  p_tfh_information20,
  p_paying_cost_center,
  p_receiving_cost_center,
  p_transfer_from_set_of_book_id,
  p_transfer_to_set_of_book_id,
  p_from_segment1,
  p_from_segment2,
  p_from_segment3,
  p_from_segment4,
  p_from_segment5,
  p_from_segment6,
  p_from_segment7,
  p_from_segment8,
  p_from_segment9,
  p_from_segment10,
  p_from_segment11,
  p_from_segment12,
  p_from_segment13,
  p_from_segment14,
  p_from_segment15,
  p_from_segment16,
  p_from_segment17,
  p_from_segment18,
  p_from_segment19,
  p_from_segment20,
  p_from_segment21,
  p_from_segment22,
  p_from_segment23,
  p_from_segment24,
  p_from_segment25,
  p_from_segment26,
  p_from_segment27,
  p_from_segment28,
  p_from_segment29,
  p_from_segment30,
  p_to_segment1,
  p_to_segment2,
  p_to_segment3,
  p_to_segment4,
  p_to_segment5,
  p_to_segment6,
  p_to_segment7,
  p_to_segment8,
  p_to_segment9,
  p_to_segment10,
  p_to_segment11,
  p_to_segment12,
  p_to_segment13,
  p_to_segment14,
  p_to_segment15,
  p_to_segment16,
  p_to_segment17,
  p_to_segment18,
  p_to_segment19,
  p_to_segment20,
  p_to_segment21,
  p_to_segment22,
  p_to_segment23,
  p_to_segment24,
  p_to_segment25,
  p_to_segment26,
  p_to_segment27,
  p_to_segment28,
  p_to_segment29,
  p_to_segment30,
  p_transfer_from_cc_id,
  p_transfer_to_cc_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate, p_transaction_type);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_tfh_api_upd;

/
