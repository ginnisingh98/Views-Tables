--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_INS" as
/* $Header: ottfh01t.pkb 120.0 2005/05/29 07:40:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfh_api_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_finance_header_id_i  number   default null;

-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (finance_header_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tfh_api_ins.g_finance_header_id_i := finance_header_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ota_tfh_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tfh_api_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_finance_headers
  --
  insert into ota_finance_headers
  (	finance_header_id,
	superceding_header_id,
	authorizer_person_id,
	organization_id,
	administrator,
	cancelled_flag,
	currency_code,
	date_raised,
	object_version_number,
	payment_status_flag,
	transfer_status,
	type,
	receivable_type,
	comments,
	external_reference,
	invoice_address,
	invoice_contact,
	payment_method,
	pym_attribute1,
	pym_attribute10,
	pym_attribute11,
	pym_attribute12,
	pym_attribute13,
	pym_attribute14,
	pym_attribute15,
	pym_attribute16,
	pym_attribute17,
	pym_attribute18,
	pym_attribute19,
	pym_attribute2,
	pym_attribute20,
	pym_attribute3,
	pym_attribute4,
	pym_attribute5,
	pym_attribute6,
	pym_attribute7,
	pym_attribute8,
	pym_attribute9,
	pym_information_category,
	transfer_date,
	transfer_message,
	vendor_id,
	contact_id,
	address_id,
	customer_id,
	tfh_information_category,
	tfh_information1,
	tfh_information2,
	tfh_information3,
	tfh_information4,
	tfh_information5,
	tfh_information6,
	tfh_information7,
	tfh_information8,
	tfh_information9,
	tfh_information10,
	tfh_information11,
	tfh_information12,
	tfh_information13,
	tfh_information14,
	tfh_information15,
	tfh_information16,
	tfh_information17,
	tfh_information18,
	tfh_information19,
	tfh_information20,
      paying_cost_center,
      receiving_cost_center,
      transfer_from_set_of_books_id,
      transfer_to_set_of_books_id,
      from_segment1,
      from_segment2,
      from_segment3,
      from_segment4,
      from_segment5,
      from_segment6,
      from_segment7,
      from_segment8,
      from_segment9,
      from_segment10,
	from_segment11,
      from_segment12,
      from_segment13,
      from_segment14,
      from_segment15,
      from_segment16,
      from_segment17,
      from_segment18,
      from_segment19,
      from_segment20,
      from_segment21,
      from_segment22,
      from_segment23,
      from_segment24,
      from_segment25,
      from_segment26,
      from_segment27,
      from_segment28,
      from_segment29,
      from_segment30,
      to_segment1,
      to_segment2,
      to_segment3,
      to_segment4,
      to_segment5,
      to_segment6,
      to_segment7,
      to_segment8,
      to_segment9,
      to_segment10,
	to_segment11,
      to_segment12,
      to_segment13,
      to_segment14,
      to_segment15,
      to_segment16,
      to_segment17,
      to_segment18,
      to_segment19,
      to_segment20,
      to_segment21,
      to_segment22,
      to_segment23,
      to_segment24,
      to_segment25,
      to_segment26,
      to_segment27,
      to_segment28,
      to_segment29,
      to_segment30,
      transfer_from_cc_id,
      transfer_to_cc_id
    )
  Values
  (	p_rec.finance_header_id,
	p_rec.superceding_header_id,
	p_rec.authorizer_person_id,
	p_rec.organization_id,
	p_rec.administrator,
	p_rec.cancelled_flag,
	p_rec.currency_code,
	p_rec.date_raised,
	p_rec.object_version_number,
	p_rec.payment_status_flag,
	p_rec.transfer_status,
	p_rec.type,
	p_rec.receivable_type,
	p_rec.comments,
	p_rec.external_reference,
	p_rec.invoice_address,
	p_rec.invoice_contact,
	p_rec.payment_method,
	p_rec.pym_attribute1,
	p_rec.pym_attribute10,
	p_rec.pym_attribute11,
	p_rec.pym_attribute12,
	p_rec.pym_attribute13,
	p_rec.pym_attribute14,
	p_rec.pym_attribute15,
	p_rec.pym_attribute16,
	p_rec.pym_attribute17,
	p_rec.pym_attribute18,
	p_rec.pym_attribute19,
	p_rec.pym_attribute2,
	p_rec.pym_attribute20,
	p_rec.pym_attribute3,
	p_rec.pym_attribute4,
	p_rec.pym_attribute5,
	p_rec.pym_attribute6,
	p_rec.pym_attribute7,
	p_rec.pym_attribute8,
	p_rec.pym_attribute9,
	p_rec.pym_information_category,
	p_rec.transfer_date,
	p_rec.transfer_message,
	p_rec.vendor_id,
	p_rec.contact_id,
	p_rec.address_id,
	p_rec.customer_id,
	p_rec.tfh_information_category,
	p_rec.tfh_information1,
	p_rec.tfh_information2,
	p_rec.tfh_information3,
	p_rec.tfh_information4,
	p_rec.tfh_information5,
	p_rec.tfh_information6,
	p_rec.tfh_information7,
	p_rec.tfh_information8,
	p_rec.tfh_information9,
	p_rec.tfh_information10,
	p_rec.tfh_information11,
	p_rec.tfh_information12,
	p_rec.tfh_information13,
	p_rec.tfh_information14,
	p_rec.tfh_information15,
	p_rec.tfh_information16,
	p_rec.tfh_information17,
	p_rec.tfh_information18,
	p_rec.tfh_information19,
	p_rec.tfh_information20,
      p_rec.paying_cost_center,
      p_rec.receiving_cost_center,
      p_rec.transfer_from_set_of_book_id,
      p_rec.transfer_to_set_of_book_id,
      p_rec.from_segment1,
      p_rec.from_segment2,
      p_rec.from_segment3,
      p_rec.from_segment4,
      p_rec.from_segment5,
      p_rec.from_segment6,
      p_rec.from_segment7,
      p_rec.from_segment8,
      p_rec.from_segment9,
      p_rec.from_segment10,
	p_rec.from_segment11,
      p_rec.from_segment12,
      p_rec.from_segment13,
      p_rec.from_segment14,
      p_rec.from_segment15,
      p_rec.from_segment16,
      p_rec.from_segment17,
      p_rec.from_segment18,
      p_rec.from_segment19,
      p_rec.from_segment20,
      p_rec.from_segment21,
      p_rec.from_segment22,
      p_rec.from_segment23,
      p_rec.from_segment24,
      p_rec.from_segment25,
      p_rec.from_segment26,
      p_rec.from_segment27,
      p_rec.from_segment28,
      p_rec.from_segment29,
      p_rec.from_segment30,
      p_rec.to_segment1,
      p_rec.to_segment2,
      p_rec.to_segment3,
      p_rec.to_segment4,
      p_rec.to_segment5,
      p_rec.to_segment6,
      p_rec.to_segment7,
      p_rec.to_segment8,
      p_rec.to_segment9,
      p_rec.to_segment10,
	p_rec.to_segment11,
      p_rec.to_segment12,
      p_rec.to_segment13,
      p_rec.to_segment14,
      p_rec.to_segment15,
      p_rec.to_segment16,
      p_rec.to_segment17,
      p_rec.to_segment18,
      p_rec.to_segment19,
      p_rec.to_segment20,
      p_rec.to_segment21,
      p_rec.to_segment22,
      p_rec.to_segment23,
      p_rec.to_segment24,
      p_rec.to_segment25,
      p_rec.to_segment26,
      p_rec.to_segment27,
      p_rec.to_segment28,
      p_rec.to_segment29,
      p_rec.to_segment30,
      p_rec.transfer_from_cc_id,
      p_rec.transfer_to_cc_id
  );
  --
  ota_tfh_api_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ota_tfh_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_finance_headers_s.nextval from sys.dual;
--

--
  Cursor C_Sel2 is
    Select null
      from ota_finance_headers
     where finance_header_id =
             ota_tfh_api_ins.g_finance_header_id_i;
--

  l_exists varchar2(1);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   If (ota_tfh_api_ins.g_finance_header_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','ota_finance_headers');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.finance_header_id :=
      ota_tfh_api_ins.g_finance_header_id_i;
    ota_tfh_api_ins.g_finance_header_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --

    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.finance_header_id;
    Close C_Sel1;
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ota_tfh_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec                     in out nocopy ota_tfh_api_shd.g_rec_type,
  p_validate                in     boolean          default false,
  p_transaction_type        in     varchar2         default 'INSERT'
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
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
    SAVEPOINT ins_ota_api_tfh;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tfh_api_bus.insert_validate(p_rec, p_transaction_type);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec);
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
    ROLLBACK TO ins_ota_api_tfh;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_finance_header_id            out nocopy number,
  p_superceding_header_id        in number           default null,
  p_authorizer_person_id         in number           default null,
  p_organization_id              in number,
  p_administrator                in number,
  p_cancelled_flag               in varchar2,
  p_currency_code                in varchar2,
  p_date_raised                  in date,
  p_object_version_number        out nocopy number,
  p_payment_status_flag          in varchar2,
  p_transfer_status              in varchar2,
  p_type                         in varchar2,
  p_receivable_type              in varchar2,
  p_comments                     in varchar2         default null,
  p_external_reference           in varchar2         default null,
  p_invoice_address              in varchar2         default null,
  p_invoice_contact              in varchar2         default null,
  p_payment_method               in varchar2         default null,
  p_pym_attribute1               in varchar2         default null,
  p_pym_attribute10              in varchar2         default null,
  p_pym_attribute11              in varchar2         default null,
  p_pym_attribute12              in varchar2         default null,
  p_pym_attribute13              in varchar2         default null,
  p_pym_attribute14              in varchar2         default null,
  p_pym_attribute15              in varchar2         default null,
  p_pym_attribute16              in varchar2         default null,
  p_pym_attribute17              in varchar2         default null,
  p_pym_attribute18              in varchar2         default null,
  p_pym_attribute19              in varchar2         default null,
  p_pym_attribute2               in varchar2         default null,
  p_pym_attribute20              in varchar2         default null,
  p_pym_attribute3               in varchar2         default null,
  p_pym_attribute4               in varchar2         default null,
  p_pym_attribute5               in varchar2         default null,
  p_pym_attribute6               in varchar2         default null,
  p_pym_attribute7               in varchar2         default null,
  p_pym_attribute8               in varchar2         default null,
  p_pym_attribute9               in varchar2         default null,
  p_pym_information_category     in varchar2         default null,
  p_transfer_date                in date             default null,
  p_transfer_message             in varchar2         default null,
  p_vendor_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_address_id                   in number           default null,
  p_customer_id                  in number           default null,
  p_tfh_information_category     in varchar2         default null,
  p_tfh_information1             in varchar2         default null,
  p_tfh_information2             in varchar2         default null,
  p_tfh_information3             in varchar2         default null,
  p_tfh_information4             in varchar2         default null,
  p_tfh_information5             in varchar2         default null,
  p_tfh_information6             in varchar2         default null,
  p_tfh_information7             in varchar2         default null,
  p_tfh_information8             in varchar2         default null,
  p_tfh_information9             in varchar2         default null,
  p_tfh_information10            in varchar2         default null,
  p_tfh_information11            in varchar2         default null,
  p_tfh_information12            in varchar2         default null,
  p_tfh_information13            in varchar2         default null,
  p_tfh_information14            in varchar2         default null,
  p_tfh_information15            in varchar2         default null,
  p_tfh_information16            in varchar2         default null,
  p_tfh_information17            in varchar2         default null,
  p_tfh_information18            in varchar2         default null,
  p_tfh_information19            in varchar2         default null,
  p_tfh_information20            in varchar2         default null,
  p_paying_cost_center           in varchar2         default null,
  p_receiving_cost_center        in varchar2         default null,
p_transfer_from_set_of_book_id in number		default null,
  p_transfer_to_set_of_book_id   in number		default null,
  p_from_segment1                 in varchar2		default null,
  p_from_segment2                 in varchar2		default null,
  p_from_segment3                 in varchar2		default null,
  p_from_segment4                 in varchar2		default null,
  p_from_segment5                 in varchar2		default null,
  p_from_segment6                 in varchar2		default null,
  p_from_segment7                 in varchar2		default null,
  p_from_segment8                 in varchar2		default null,
  p_from_segment9                 in varchar2		default null,
  p_from_segment10                in varchar2		default null,
  p_from_segment11                 in varchar2		default null,
  p_from_segment12                 in varchar2		default null,
  p_from_segment13                 in varchar2		default null,
  p_from_segment14                 in varchar2		default null,
  p_from_segment15                 in varchar2		default null,
  p_from_segment16                 in varchar2		default null,
  p_from_segment17                 in varchar2		default null,
  p_from_segment18                 in varchar2		default null,
  p_from_segment19                 in varchar2		default null,
  p_from_segment20                in varchar2		default null,
  p_from_segment21                 in varchar2		default null,
  p_from_segment22                 in varchar2		default null,
  p_from_segment23                 in varchar2		default null,
  p_from_segment24                 in varchar2		default null,
  p_from_segment25                 in varchar2		default null,
  p_from_segment26                 in varchar2		default null,
  p_from_segment27                 in varchar2		default null,
  p_from_segment28                 in varchar2		default null,
  p_from_segment29                 in varchar2		default null,
  p_from_segment30                in varchar2		default null,
  p_to_segment1                 in varchar2		default null,
  p_to_segment2                 in varchar2		default null,
  p_to_segment3                 in varchar2		default null,
  p_to_segment4                 in varchar2		default null,
  p_to_segment5                 in varchar2		default null,
  p_to_segment6                 in varchar2		default null,
  p_to_segment7                 in varchar2		default null,
  p_to_segment8                 in varchar2		default null,
  p_to_segment9                 in varchar2		default null,
  p_to_segment10                in varchar2		default null,
  p_to_segment11                 in varchar2	default null,
  p_to_segment12                 in varchar2	default null,
  p_to_segment13                 in varchar2	default null,
  p_to_segment14                 in varchar2	default null,
  p_to_segment15                 in varchar2	default null,
  p_to_segment16                 in varchar2	default null,
  p_to_segment17                 in varchar2	default null,
  p_to_segment18                 in varchar2	default null,
  p_to_segment19                 in varchar2	default null,
  p_to_segment20                 in varchar2		default null,
  p_to_segment21                 in varchar2	default null,
  p_to_segment22                 in varchar2	default null,
  p_to_segment23                 in varchar2	default null,
  p_to_segment24                 in varchar2	default null,
  p_to_segment25                 in varchar2	default null,
  p_to_segment26                 in varchar2	default null,
  p_to_segment27                 in varchar2	default null,
  p_to_segment28                 in varchar2	default null,
  p_to_segment29                 in varchar2	default null,
  p_to_segment30                 in varchar2 	default null,
  p_transfer_from_cc_id          in number        default null,
  p_transfer_to_cc_id            in number        default null,
  p_validate                     in boolean       default false,
  p_transaction_type             in varchar2      default 'INSERT'
  ) is
--
  l_rec	  ota_tfh_api_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tfh_api_shd.convert_args
  (
  null,
  p_superceding_header_id,
  p_authorizer_person_id,
  p_organization_id,
  p_administrator,
  p_cancelled_flag,
  p_currency_code,
  p_date_raised,
  null,
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
  -- Having converted the arguments into the ota_tfh_api_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate,p_transaction_type);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_finance_header_id := l_rec.finance_header_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tfh_api_ins;

/
