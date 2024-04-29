--------------------------------------------------------
--  DDL for Package Body OTA_TEA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TEA_INS" as
/* $Header: ottea01t.pkb 120.1 2005/06/09 01:16:02 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tea_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ota_tea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ota_tea_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ota_event_associations
  --
  insert into ota_event_associations
  (	event_association_id,
	event_id,
	customer_id,
        organization_id,
        job_id,
        position_id,
	comments,
	tea_information_category,
	tea_information1,
	tea_information2,
	tea_information3,
	tea_information4,
	tea_information5,
	tea_information6,
	tea_information7,
	tea_information8,
	tea_information9,
	tea_information10,
	tea_information11,
	tea_information12,
	tea_information13,
	tea_information14,
	tea_information15,
	tea_information16,
	tea_information17,
	tea_information18,
	tea_information19,
	tea_information20
  )
  Values
  (	p_rec.event_association_id,
	p_rec.event_id,
	p_rec.customer_id,
        p_rec.organization_id,
        p_rec.job_id,
        p_rec.position_id,
	p_rec.comments,
	p_rec.tea_information_category,
	p_rec.tea_information1,
	p_rec.tea_information2,
	p_rec.tea_information3,
	p_rec.tea_information4,
	p_rec.tea_information5,
	p_rec.tea_information6,
	p_rec.tea_information7,
	p_rec.tea_information8,
	p_rec.tea_information9,
	p_rec.tea_information10,
	p_rec.tea_information11,
	p_rec.tea_information12,
	p_rec.tea_information13,
	p_rec.tea_information14,
	p_rec.tea_information15,
	p_rec.tea_information16,
	p_rec.tea_information17,
	p_rec.tea_information18,
	p_rec.tea_information19,
	p_rec.tea_information20
  );
  --
  ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tea_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tea_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tea_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ota_tea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ota_event_associations_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.event_association_id;
  Close C_Sel1;
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
Procedure post_insert (	 p_business_group_id            in number
			,p_validate			in boolean
                        ,p_price_basis                  in varchar2
                        ,p_event_id                     in number
                        ,p_customer_id                  in number
			,p_booking_id			out nocopy number
			,p_tdb_object_version_number 	out nocopy number
			,p_booking_status_type_id	in number
			,p_booking_contact_id		in number
        		,p_contact_address_id           in number
        		,p_delegate_contact_phone       in varchar2
        		,p_delegate_contact_fax         in varchar2
			,p_internal_booking_flag	in varchar2
			,p_source_of_booking		in varchar2
			,p_number_of_places		in number
			,p_date_booking_placed		in date
			,p_finance_header_id		in number
                        ,p_currency_code                in varchar2
			,p_standard_amount		in number
			,p_unitary_amount		in number
			,p_money_amount			in number
			,p_booking_deal_id		in number
			,p_booking_deal_type		in varchar2
			,p_finance_line_id		in out nocopy number
                  ,p_delegate_contact_email     in varchar2
	) is
l_proc varchar2(30) := g_package||'post_insert';
l_tfl_ovn number;
l_tdb_ovn number;
l_booking_id number;
begin
--
hr_utility.set_location('Entering:'||l_proc,5);
--
ota_event_associations_pkg.maintain_delegate_bookings
	(p_validate			=> p_validate
        ,p_price_basis                  => p_price_basis
	,p_business_group_id		=> p_business_group_id
	,p_event_id			=> p_event_id
	,p_customer_id			=> p_customer_id
	,p_booking_id			=> l_booking_id
        ,p_tdb_object_version_number    => l_tdb_ovn
	,p_booking_status_type_id	=> p_booking_status_type_id
        ,p_date_status_changed          => null
        ,p_status_change_comments       => null
	,p_booking_contact_id	        => p_booking_contact_id
	,p_contact_address_id		=> p_contact_address_id
	,p_delegate_contact_phone	=> p_delegate_contact_phone
	,p_delegate_contact_fax		=> p_delegate_contact_fax
	,p_internal_booking_flag	=> p_internal_booking_flag
	,p_source_of_booking		=> p_source_of_booking
	,p_number_of_places		=> p_number_of_places
	,p_date_booking_placed		=> p_date_booking_placed
        ,p_update_finance_line          => null
        ,p_tfl_object_version_number    => l_tfl_ovn
	,p_finance_header_id		=> p_finance_header_id
	,p_currency_code		=> p_currency_code
	,p_standard_amount		=> p_standard_amount
	,p_unitary_amount		=> p_unitary_amount
	,p_money_amount			=> p_money_amount
	,p_booking_deal_id		=> p_booking_deal_id
	,p_booking_deal_type		=> p_booking_deal_type
	,p_finance_line_id		=> p_finance_line_id
	,p_delegate_contact_email     => p_delegate_contact_email
	);
p_booking_id := l_booking_id;
p_tdb_object_version_number := l_tdb_ovn;
--
hr_utility.set_location('Leaving:'||l_proc,10);
--
end post_insert;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ota_tea_shd.g_rec_type,
  p_validate   in     boolean
        ,p_association_type             in varchar2
        ,p_business_group_id            in  number
        ,p_price_basis                  in  varchar2
	,p_booking_id                   out nocopy number
	,p_tdb_object_version_number	out nocopy number
        ,p_booking_status_type_id       in number
        ,p_booking_contact_id           in number
        ,p_contact_address_id           in number
        ,p_delegate_contact_phone       in varchar2
        ,p_delegate_contact_fax         in varchar2
        ,p_internal_booking_flag        in varchar2
	,p_source_of_booking		in varchar2
	,p_number_of_places             in number
	,p_date_booking_placed		in date
        ,p_finance_header_id            in number
        ,p_currency_code                in varchar2
        ,p_standard_amount		in number
        ,p_unitary_amount               in number
        ,p_money_amount                 in number
        ,p_booking_deal_id              in number
        ,p_booking_deal_type            in varchar2
        ,p_finance_line_id              in out nocopy number
        ,p_delegate_contact_email       in varchar2
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
    SAVEPOINT ins_ota_tea;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ota_tea_bus.insert_validate(p_rec
                             ,p_association_type);
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
  post_insert(
         p_business_group_id
	,p_validate
        ,p_price_basis
        ,p_rec.event_id
        ,p_rec.customer_id
	,p_booking_id
	,p_tdb_object_version_number
        ,p_booking_status_type_id
        ,p_booking_contact_id
        ,p_contact_address_id
        ,p_delegate_contact_phone
        ,p_delegate_contact_fax
        ,p_internal_booking_flag
	,p_source_of_booking
	,p_number_of_places
	,p_date_booking_placed
        ,p_finance_header_id
        ,p_currency_code
        ,p_standard_amount
        ,p_unitary_amount
        ,p_money_amount
        ,p_booking_deal_id
        ,p_booking_deal_type
        ,p_finance_line_id
        ,p_delegate_contact_email
);
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
    ROLLBACK TO ins_ota_tea;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins
  (
  p_event_association_id         out nocopy number,
  p_event_id                     in number,
  p_customer_id                  in number           default null,
  p_organization_id              in number           default null,
  p_job_id                       in number           default null,
  p_position_id                  in number           default null,
  p_comments                     in varchar2         default null,
  p_tea_information_category     in varchar2         default null,
  p_tea_information1             in varchar2         default null,
  p_tea_information2             in varchar2         default null,
  p_tea_information3             in varchar2         default null,
  p_tea_information4             in varchar2         default null,
  p_tea_information5             in varchar2         default null,
  p_tea_information6             in varchar2         default null,
  p_tea_information7             in varchar2         default null,
  p_tea_information8             in varchar2         default null,
  p_tea_information9             in varchar2         default null,
  p_tea_information10            in varchar2         default null,
  p_tea_information11            in varchar2         default null,
  p_tea_information12            in varchar2         default null,
  p_tea_information13            in varchar2         default null,
  p_tea_information14            in varchar2         default null,
  p_tea_information15            in varchar2         default null,
  p_tea_information16            in varchar2         default null,
  p_tea_information17            in varchar2         default null,
  p_tea_information18            in varchar2         default null,
  p_tea_information19            in varchar2         default null,
  p_tea_information20            in varchar2         default null,
  p_validate                     in boolean   default false
        ,p_association_type             in  varchar2
        ,p_business_group_id            in  number  default null
        ,p_price_basis                  in varchar2  default null
	,p_booking_id                   out nocopy number
	,p_tdb_object_version_number	out nocopy number
        ,p_booking_status_type_id       in number  default null
        ,p_booking_contact_id           in number  default null
        ,p_contact_address_id           in number  default null
        ,p_delegate_contact_phone       in varchar2  default null
        ,p_delegate_contact_fax         in varchar2  default null
        ,p_internal_booking_flag        in varchar2  default null
	,p_source_of_booking		in varchar2  default null
	,p_number_of_places             in number  default null
	,p_date_booking_placed		in date  default null
        ,p_finance_header_id            in number  default null
        ,p_currency_code                in varchar2  default null
	,p_standard_amount		in number  default null
        ,p_unitary_amount               in number  default null
        ,p_money_amount                 in number  default null
        ,p_booking_deal_id              in number  default null
        ,p_booking_deal_type            in varchar2  default null
        ,p_finance_line_id              in out nocopy number
        ,p_delegate_contact_email       in varchar2
  ) is
--
  l_rec	  ota_tea_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ota_tea_shd.convert_args
  (
  null,
  p_event_id,
  p_customer_id,
  p_organization_id,
  p_job_id,
  p_position_id,
  p_comments,
  p_tea_information_category,
  p_tea_information1,
  p_tea_information2,
  p_tea_information3,
  p_tea_information4,
  p_tea_information5,
  p_tea_information6,
  p_tea_information7,
  p_tea_information8,
  p_tea_information9,
  p_tea_information10,
  p_tea_information11,
  p_tea_information12,
  p_tea_information13,
  p_tea_information14,
  p_tea_information15,
  p_tea_information16,
  p_tea_information17,
  p_tea_information18,
  p_tea_information19,
  p_tea_information20
  );
  --
  -- Having converted the arguments into the ota_tea_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate
        ,p_association_type
        ,p_business_group_id
        ,p_price_basis
	,p_booking_id
	,p_tdb_object_version_number
        ,p_booking_status_type_id
        ,p_booking_contact_id
        ,p_contact_address_id
        ,p_delegate_contact_phone
        ,p_delegate_contact_fax
        ,p_internal_booking_flag
	,p_source_of_booking
	,p_number_of_places
	,p_date_booking_placed
        ,p_finance_header_id
        ,p_currency_code
        ,p_standard_amount
        ,p_unitary_amount
        ,p_money_amount
        ,p_booking_deal_id
        ,p_booking_deal_type
        ,p_finance_line_id
        ,p_delegate_contact_email
);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_event_association_id := l_rec.event_association_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
Procedure ins
  (
  p_event_association_id         out nocopy number,
  p_event_id                     in number,
  p_customer_id                  in number,
  p_comments                     in varchar2,
  p_tea_information_category     in varchar2,
  p_tea_information1             in varchar2,
  p_tea_information2             in varchar2,
  p_tea_information3             in varchar2,
  p_tea_information4             in varchar2,
  p_tea_information5             in varchar2,
  p_tea_information6             in varchar2,
  p_tea_information7             in varchar2,
  p_tea_information8             in varchar2,
  p_tea_information9             in varchar2,
  p_tea_information10            in varchar2,
  p_tea_information11            in varchar2,
  p_tea_information12            in varchar2,
  p_tea_information13            in varchar2,
  p_tea_information14            in varchar2,
  p_tea_information15            in varchar2,
  p_tea_information16            in varchar2,
  p_tea_information17            in varchar2,
  p_tea_information18            in varchar2,
  p_tea_information19            in varchar2,
  p_tea_information20            in varchar2,
  p_validate                     in boolean
        ,p_business_group_id            in  number
        ,p_price_basis                  in varchar2
	,p_booking_id                   out nocopy number
	,p_tdb_object_version_number	out nocopy number
        ,p_booking_status_type_id       in number
        ,p_booking_contact_id           in number
        ,p_contact_address_id           in number
        ,p_delegate_contact_phone       in varchar2
        ,p_delegate_contact_fax         in varchar2
        ,p_internal_booking_flag        in varchar2
	,p_source_of_booking		in varchar2
	,p_number_of_places             in number
	,p_date_booking_placed		in date
        ,p_finance_header_id            in number
        ,p_currency_code                in varchar2
	,p_standard_amount		in number
        ,p_unitary_amount               in number
        ,p_money_amount                 in number
        ,p_booking_deal_id              in number
        ,p_booking_deal_type            in varchar2
        ,p_finance_line_id              in out nocopy number
        ,p_delegate_contact_email       in varchar2
  ) is
begin
   ins(
  p_event_association_id         => p_event_association_id
 ,p_event_id                     => p_event_id
 ,p_customer_id                  => p_customer_id
 ,p_organization_id              => null
 ,p_job_id                       => null
 ,p_position_id                  => null
 ,p_comments                     => p_comments
 ,p_tea_information_category     => p_tea_information_category
 ,p_tea_information1             => p_tea_information1
 ,p_tea_information2             => p_tea_information2
 ,p_tea_information3             => p_tea_information3
 ,p_tea_information4             => p_tea_information4
 ,p_tea_information5             => p_tea_information5
 ,p_tea_information6             => p_tea_information6
 ,p_tea_information7             => p_tea_information7
 ,p_tea_information8             => p_tea_information8
 ,p_tea_information9             => p_tea_information9
 ,p_tea_information10            => p_tea_information10
 ,p_tea_information11            => p_tea_information11
 ,p_tea_information12            => p_tea_information12
 ,p_tea_information13            => p_tea_information13
 ,p_tea_information14            => p_tea_information14
 ,p_tea_information15            => p_tea_information15
 ,p_tea_information16            => p_tea_information16
 ,p_tea_information17            => p_tea_information17
 ,p_tea_information18            => p_tea_information18
 ,p_tea_information19            => p_tea_information19
 ,p_tea_information20            => p_tea_information20
 ,p_validate                     => p_validate
 ,p_association_type             => 'C'
 ,p_business_group_id            => p_business_group_id
 ,p_price_basis                  => p_price_basis
 ,p_booking_id                   => p_booking_id
 ,p_tdb_object_version_number	 => p_tdb_object_version_number
 ,p_booking_status_type_id       => p_booking_status_type_id
 ,p_booking_contact_id           => p_booking_contact_id
 ,p_contact_address_id           => p_contact_address_id
 ,p_delegate_contact_phone       => p_delegate_contact_phone
 ,p_delegate_contact_fax         => p_delegate_contact_fax
 ,p_internal_booking_flag        => p_internal_booking_flag
 ,p_source_of_booking		 => p_source_of_booking
 ,p_number_of_places             => p_number_of_places
 ,p_date_booking_placed		 => p_date_booking_placed
 ,p_finance_header_id            => p_finance_header_id
 ,p_currency_code                => p_currency_code
 ,p_standard_amount		 => p_standard_amount
 ,p_unitary_amount               => p_unitary_amount
 ,p_money_amount                 => p_money_amount
 ,p_booking_deal_id              => p_booking_deal_id
 ,p_booking_deal_type            => p_booking_deal_type
 ,p_finance_line_id              => p_finance_line_id
 ,p_delegate_contact_email       => p_delegate_contact_email
  );
end ins;
--
Procedure ins
  (
  p_event_association_id         out nocopy number,
  p_event_id                     in number,
  p_organization_id              in number,
  p_job_id                       in number,
  p_position_id                  in number,
  p_comments                     in varchar2,
  p_tea_information_category     in varchar2,
  p_tea_information1             in varchar2,
  p_tea_information2             in varchar2,
  p_tea_information3             in varchar2,
  p_tea_information4             in varchar2,
  p_tea_information5             in varchar2,
  p_tea_information6             in varchar2,
  p_tea_information7             in varchar2,
  p_tea_information8             in varchar2,
  p_tea_information9             in varchar2,
  p_tea_information10            in varchar2,
  p_tea_information11            in varchar2,
  p_tea_information12            in varchar2,
  p_tea_information13            in varchar2,
  p_tea_information14            in varchar2,
  p_tea_information15            in varchar2,
  p_tea_information16            in varchar2,
  p_tea_information17            in varchar2,
  p_tea_information18            in varchar2,
  p_tea_information19            in varchar2,
  p_tea_information20            in varchar2,
  p_validate                     in boolean
  ) is
--
l_booking_id number;
l_tdb_object_version_number number;
l_finance_line_id number;
--
begin
   ins(
  p_event_association_id         => p_event_association_id
 ,p_event_id                     => p_event_id
 ,p_customer_id                  => null
 ,p_organization_id              => p_organization_id
 ,p_job_id                       => p_job_id
 ,p_position_id                  => p_position_id
 ,p_comments                     => p_comments
 ,p_tea_information_category     => p_tea_information_category
 ,p_tea_information1             => p_tea_information1
 ,p_tea_information2             => p_tea_information2
 ,p_tea_information3             => p_tea_information3
 ,p_tea_information4             => p_tea_information4
 ,p_tea_information5             => p_tea_information5
 ,p_tea_information6             => p_tea_information6
 ,p_tea_information7             => p_tea_information7
 ,p_tea_information8             => p_tea_information8
 ,p_tea_information9             => p_tea_information9
 ,p_tea_information10            => p_tea_information10
 ,p_tea_information11            => p_tea_information11
 ,p_tea_information12            => p_tea_information12
 ,p_tea_information13            => p_tea_information13
 ,p_tea_information14            => p_tea_information14
 ,p_tea_information15            => p_tea_information15
 ,p_tea_information16            => p_tea_information16
 ,p_tea_information17            => p_tea_information17
 ,p_tea_information18            => p_tea_information18
 ,p_tea_information19            => p_tea_information19
 ,p_tea_information20            => p_tea_information20
 ,p_validate                     => p_validate
 ,p_association_type             => 'A'
 ,p_business_group_id            => null
 ,p_price_basis                  => null
 ,p_booking_id                   => l_booking_id
 ,p_tdb_object_version_number	 => l_tdb_object_version_number
 ,p_booking_status_type_id       => null
 ,p_booking_contact_id           => null
 ,p_contact_address_id           => null
 ,p_delegate_contact_phone       => null
 ,p_delegate_contact_fax         => null
 ,p_internal_booking_flag        => null
 ,p_source_of_booking		 => null
 ,p_number_of_places             => null
 ,p_date_booking_placed		 => null
 ,p_finance_header_id            => null
 ,p_currency_code                => null
 ,p_standard_amount		 => null
 ,p_unitary_amount               => null
 ,p_money_amount                 => null
 ,p_booking_deal_id              => null
 ,p_booking_deal_type            => null
 ,p_finance_line_id              => l_finance_line_id
 ,p_delegate_contact_email       => null
  );
end ins;
--
end ota_tea_ins;

/
