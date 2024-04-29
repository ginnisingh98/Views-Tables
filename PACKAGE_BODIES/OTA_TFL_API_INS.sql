--------------------------------------------------------
--  DDL for Package Body OTA_TFL_API_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFL_API_INS" as
/* $Header: ottfl01t.pkb 120.0 2005/05/29 07:41:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tfl_api_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_finance_line_id_i  number   default null;

-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (finance_line_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ota_tfl_api_ins.g_finance_line_id_i := finance_line_id;
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
Procedure insert_dml(p_rec in out nocopy ota_tfl_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ota_tfl_api_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_finance_lines
  --
  insert into ota_finance_lines
  (	finance_line_id,
	finance_header_id,
	cancelled_flag,
	date_raised,
	line_type,
	object_version_number,
	sequence_number,
	transfer_status,
	comments,
	currency_code,
	money_amount,
	standard_amount,
	trans_information_category,
	trans_information1,
	trans_information10,
	trans_information11,
	trans_information12,
	trans_information13,
	trans_information14,
	trans_information15,
	trans_information16,
	trans_information17,
	trans_information18,
	trans_information19,
	trans_information2,
	trans_information20,
	trans_information3,
	trans_information4,
	trans_information5,
	trans_information6,
	trans_information7,
	trans_information8,
	trans_information9,
	transfer_date,
	transfer_message,
	unitary_amount,
	booking_deal_id,
	booking_id,
	resource_allocation_id,
	resource_booking_id,
	tfl_information_category,
	tfl_information1,
	tfl_information2,
	tfl_information3,
	tfl_information4,
	tfl_information5,
	tfl_information6,
	tfl_information7,
	tfl_information8,
	tfl_information9,
	tfl_information10,
	tfl_information11,
	tfl_information12,
	tfl_information13,
	tfl_information14,
	tfl_information15,
	tfl_information16,
	tfl_information17,
	tfl_information18,
	tfl_information19,
	tfl_information20
  )
  Values
  (	p_rec.finance_line_id,
	p_rec.finance_header_id,
	p_rec.cancelled_flag,
	p_rec.date_raised,
	p_rec.line_type,
	p_rec.object_version_number,
	p_rec.sequence_number,
	p_rec.transfer_status,
	p_rec.comments,
	p_rec.currency_code,
	p_rec.money_amount,
	p_rec.standard_amount,
	p_rec.trans_information_category,
	p_rec.trans_information1,
	p_rec.trans_information10,
	p_rec.trans_information11,
	p_rec.trans_information12,
	p_rec.trans_information13,
	p_rec.trans_information14,
	p_rec.trans_information15,
	p_rec.trans_information16,
	p_rec.trans_information17,
	p_rec.trans_information18,
	p_rec.trans_information19,
	p_rec.trans_information2,
	p_rec.trans_information20,
	p_rec.trans_information3,
	p_rec.trans_information4,
	p_rec.trans_information5,
	p_rec.trans_information6,
	p_rec.trans_information7,
	p_rec.trans_information8,
	p_rec.trans_information9,
	p_rec.transfer_date,
	p_rec.transfer_message,
	p_rec.unitary_amount,
	p_rec.booking_deal_id,
	p_rec.booking_id,
	p_rec.resource_allocation_id,
	p_rec.resource_booking_id,
	p_rec.tfl_information_category,
	p_rec.tfl_information1,
	p_rec.tfl_information2,
	p_rec.tfl_information3,
	p_rec.tfl_information4,
	p_rec.tfl_information5,
	p_rec.tfl_information6,
	p_rec.tfl_information7,
	p_rec.tfl_information8,
	p_rec.tfl_information9,
	p_rec.tfl_information10,
	p_rec.tfl_information11,
	p_rec.tfl_information12,
	p_rec.tfl_information13,
	p_rec.tfl_information14,
	p_rec.tfl_information15,
	p_rec.tfl_information16,
	p_rec.tfl_information17,
	p_rec.tfl_information18,
	p_rec.tfl_information19,
	p_rec.tfl_information20
  );
  --
  ota_tfl_api_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure pre_insert(p_rec  in out nocopy ota_tfl_api_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_finance_lines_s.nextval from sys.dual;
--

--
  Cursor C_Sel2 is
    Select null
      from ota_finance_lines
     where finance_line_id =
             ota_tfl_api_ins.g_finance_line_id_i;
--

  l_exists varchar2(1);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   If (ota_tfl_api_ins.g_finance_line_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ota_finance_lines');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.finance_line_id :=
      ota_tfl_api_ins.g_finance_line_id_i;
    ota_tfl_api_ins.g_finance_line_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --

    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.finance_line_id;
    Close C_Sel1;
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;

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
Procedure post_insert(p_rec in ota_tfl_api_shd.g_rec_type) is
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
  p_rec                     in out nocopy ota_tfl_api_shd.g_rec_type,
  p_validate                in     boolean          default false,
  p_transaction_type        in     varchar2
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
    SAVEPOINT ins_ota_tfl_api;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tfl_api_bus.insert_validate( p_rec, p_transaction_type);
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
    ROLLBACK TO ins_ota_tfl_api;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_finance_line_id              out nocopy number,
  p_finance_header_id            in number           default null,
  p_cancelled_flag               in varchar2,
  p_date_raised                  in out nocopy date,
  p_line_type                    in varchar2,
  p_object_version_number        out nocopy number,
  p_sequence_number              in out nocopy number,
  p_transfer_status              in varchar2,
  p_comments                     in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_money_amount                 in number           default null,
  p_standard_amount              in number           default null,
  p_trans_information_category   in varchar2         default null,
  p_trans_information1           in varchar2         default null,
  p_trans_information10          in varchar2         default null,
  p_trans_information11          in varchar2         default null,
  p_trans_information12          in varchar2         default null,
  p_trans_information13          in varchar2         default null,
  p_trans_information14          in varchar2         default null,
  p_trans_information15          in varchar2         default null,
  p_trans_information16          in varchar2         default null,
  p_trans_information17          in varchar2         default null,
  p_trans_information18          in varchar2         default null,
  p_trans_information19          in varchar2         default null,
  p_trans_information2           in varchar2         default null,
  p_trans_information20          in varchar2         default null,
  p_trans_information3           in varchar2         default null,
  p_trans_information4           in varchar2         default null,
  p_trans_information5           in varchar2         default null,
  p_trans_information6           in varchar2         default null,
  p_trans_information7           in varchar2         default null,
  p_trans_information8           in varchar2         default null,
  p_trans_information9           in varchar2         default null,
  p_transfer_date                in date             default null,
  p_transfer_message             in varchar2         default null,
  p_unitary_amount               in number           default null,
  p_booking_deal_id              in number           default null,
  p_booking_id                   in number           default null,
  p_resource_allocation_id       in number           default null,
  p_resource_booking_id          in number           default null,
  p_tfl_information_category     in varchar2         default null,
  p_tfl_information1             in varchar2         default null,
  p_tfl_information2             in varchar2         default null,
  p_tfl_information3             in varchar2         default null,
  p_tfl_information4             in varchar2         default null,
  p_tfl_information5             in varchar2         default null,
  p_tfl_information6             in varchar2         default null,
  p_tfl_information7             in varchar2         default null,
  p_tfl_information8             in varchar2         default null,
  p_tfl_information9             in varchar2         default null,
  p_tfl_information10            in varchar2         default null,
  p_tfl_information11            in varchar2         default null,
  p_tfl_information12            in varchar2         default null,
  p_tfl_information13            in varchar2         default null,
  p_tfl_information14            in varchar2         default null,
  p_tfl_information15            in varchar2         default null,
  p_tfl_information16            in varchar2         default null,
  p_tfl_information17            in varchar2         default null,
  p_tfl_information18            in varchar2         default null,
  p_tfl_information19            in varchar2         default null,
  p_tfl_information20            in varchar2         default null,
  p_validate                     in boolean          default false,
  p_transaction_type             in varchar2
  ) is
--
  l_rec	  ota_tfl_api_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tfl_api_shd.convert_args
  (
  null,
  p_finance_header_id,
  p_cancelled_flag,
  p_date_raised,
  p_line_type,
  null,
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
  -- Having converted the arguments into the ota_tfl_api_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins( l_rec, p_validate, p_transaction_type);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_finance_line_id := l_rec.finance_line_id;
  p_sequence_number := l_rec.sequence_number;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ota_tfl_api_ins;

/
