--------------------------------------------------------
--  DDL for Package Body OTA_TEA_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TEA_UPD" as
/* $Header: ottea01t.pkb 120.1 2005/06/09 01:16:02 jbharath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tea_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ota_tea_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  ota_tea_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_event_associations Row
  --
  update ota_event_associations
  set
  event_association_id              = p_rec.event_association_id,
  event_id                          = p_rec.event_id,
  customer_id                       = p_rec.customer_id,
  organization_id                   = p_rec.organization_id,
  job_id                            = p_rec.job_id,
  position_id                       = p_rec.position_id,
  comments                          = p_rec.comments,
  tea_information_category          = p_rec.tea_information_category,
  tea_information1                  = p_rec.tea_information1,
  tea_information2                  = p_rec.tea_information2,
  tea_information3                  = p_rec.tea_information3,
  tea_information4                  = p_rec.tea_information4,
  tea_information5                  = p_rec.tea_information5,
  tea_information6                  = p_rec.tea_information6,
  tea_information7                  = p_rec.tea_information7,
  tea_information8                  = p_rec.tea_information8,
  tea_information9                  = p_rec.tea_information9,
  tea_information10                 = p_rec.tea_information10,
  tea_information11                 = p_rec.tea_information11,
  tea_information12                 = p_rec.tea_information12,
  tea_information13                 = p_rec.tea_information13,
  tea_information14                 = p_rec.tea_information14,
  tea_information15                 = p_rec.tea_information15,
  tea_information16                 = p_rec.tea_information16,
  tea_information17                 = p_rec.tea_information17,
  tea_information18                 = p_rec.tea_information18,
  tea_information19                 = p_rec.tea_information19,
  tea_information20                 = p_rec.tea_information20
  where event_association_id = p_rec.event_association_id;
  --
  ota_tea_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
Procedure pre_update(p_rec in ota_tea_shd.g_rec_type) is
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
Procedure post_update (	 p_business_group_id            in number
			,p_validate			in boolean
                        ,p_price_basis                  in varchar2
                        ,p_event_id                     in number
                        ,p_customer_id                  in number
			,p_booking_id			in out nocopy number
			,p_tdb_object_version_number 	in out nocopy number
			,p_booking_status_type_id	in number
                        ,p_date_status_changed          in date
                        ,p_status_change_comments       in varchar2
			,p_booking_contact_id		in number
        		,p_contact_address_id           in number
        		,p_delegate_contact_phone       in varchar2
        		,p_delegate_contact_fax         in varchar2
			,p_internal_booking_flag	in varchar2
			,p_source_of_booking		in varchar2
			,p_number_of_places		in number
			,p_date_booking_placed		in date
                        ,p_update_finance_line          in varchar2
                        ,p_tfl_object_version_number    in out nocopy number
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
--
  l_proc  varchar2(72) := g_package||'post_update';
l_number number;
l_cancel_finance_line boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_update_finance_line in ('C','Y') then
     l_cancel_finance_line := (p_update_finance_line = 'C');
     ota_finance.maintain_finance_line
		       (p_finance_header_id     => p_finance_header_id,
		        p_booking_id            => p_booking_id   ,
		        p_currency_code         => p_currency_code    ,
			p_standard_amount       => p_standard_amount,
		        p_unitary_amount        => p_unitary_amount   ,
		        p_money_amount          => p_money_amount     ,
			p_booking_deal_id       => p_booking_deal_id  ,
		        p_booking_deal_type     => p_booking_deal_type,
		        p_object_version_number => p_tfl_object_version_number,
		        p_finance_line_id       => p_finance_line_id,
		        p_cancel_finance_line   => l_cancel_finance_line);
  end if;
ota_event_associations_pkg.maintain_delegate_bookings
	(p_validate			=> p_validate
        ,p_price_basis                  => p_price_basis
	,p_business_group_id		=> p_business_group_id
	,p_event_id			=> p_event_id
	,p_customer_id			=> p_customer_id
	,p_booking_id			=> p_booking_id
        ,p_tdb_object_version_number    => p_tdb_object_version_number
	,p_booking_status_type_id	=> p_booking_status_type_id
        ,p_date_status_changed          => p_date_status_changed
        ,p_status_change_comments       => p_status_change_comments
	,p_booking_contact_id	        => p_booking_contact_id
	,p_contact_address_id		=> p_contact_address_id
	,p_delegate_contact_phone	=> p_delegate_contact_phone
	,p_delegate_contact_fax		=> p_delegate_contact_fax
	,p_internal_booking_flag	=> p_internal_booking_flag
	,p_source_of_booking		=> p_source_of_booking
	,p_number_of_places		=> p_number_of_places
	,p_date_booking_placed		=> p_date_booking_placed
        ,p_update_finance_line          => p_update_finance_line
        ,p_tfl_object_version_number    => p_tfl_object_version_number
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
Function convert_defs(p_rec in out nocopy ota_tea_shd.g_rec_type)
         Return ota_tea_shd.g_rec_type is
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
  If (p_rec.event_id = hr_api.g_number) then
    p_rec.event_id :=
    ota_tea_shd.g_old_rec.event_id;
  End If;
  If (p_rec.customer_id = hr_api.g_number) then
    p_rec.customer_id :=
    ota_tea_shd.g_old_rec.customer_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_tea_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    ota_tea_shd.g_old_rec.job_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    ota_tea_shd.g_old_rec.position_id;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tea_shd.g_old_rec.comments;
  End If;
  If (p_rec.tea_information_category = hr_api.g_varchar2) then
    p_rec.tea_information_category :=
    ota_tea_shd.g_old_rec.tea_information_category;
  End If;
  If (p_rec.tea_information1 = hr_api.g_varchar2) then
    p_rec.tea_information1 :=
    ota_tea_shd.g_old_rec.tea_information1;
  End If;
  If (p_rec.tea_information2 = hr_api.g_varchar2) then
    p_rec.tea_information2 :=
    ota_tea_shd.g_old_rec.tea_information2;
  End If;
  If (p_rec.tea_information3 = hr_api.g_varchar2) then
    p_rec.tea_information3 :=
    ota_tea_shd.g_old_rec.tea_information3;
  End If;
  If (p_rec.tea_information4 = hr_api.g_varchar2) then
    p_rec.tea_information4 :=
    ota_tea_shd.g_old_rec.tea_information4;
  End If;
  If (p_rec.tea_information5 = hr_api.g_varchar2) then
    p_rec.tea_information5 :=
    ota_tea_shd.g_old_rec.tea_information5;
  End If;
  If (p_rec.tea_information6 = hr_api.g_varchar2) then
    p_rec.tea_information6 :=
    ota_tea_shd.g_old_rec.tea_information6;
  End If;
  If (p_rec.tea_information7 = hr_api.g_varchar2) then
    p_rec.tea_information7 :=
    ota_tea_shd.g_old_rec.tea_information7;
  End If;
  If (p_rec.tea_information8 = hr_api.g_varchar2) then
    p_rec.tea_information8 :=
    ota_tea_shd.g_old_rec.tea_information8;
  End If;
  If (p_rec.tea_information9 = hr_api.g_varchar2) then
    p_rec.tea_information9 :=
    ota_tea_shd.g_old_rec.tea_information9;
  End If;
  If (p_rec.tea_information10 = hr_api.g_varchar2) then
    p_rec.tea_information10 :=
    ota_tea_shd.g_old_rec.tea_information10;
  End If;
  If (p_rec.tea_information11 = hr_api.g_varchar2) then
    p_rec.tea_information11 :=
    ota_tea_shd.g_old_rec.tea_information11;
  End If;
  If (p_rec.tea_information12 = hr_api.g_varchar2) then
    p_rec.tea_information12 :=
    ota_tea_shd.g_old_rec.tea_information12;
  End If;
  If (p_rec.tea_information13 = hr_api.g_varchar2) then
    p_rec.tea_information13 :=
    ota_tea_shd.g_old_rec.tea_information13;
  End If;
  If (p_rec.tea_information14 = hr_api.g_varchar2) then
    p_rec.tea_information14 :=
    ota_tea_shd.g_old_rec.tea_information14;
  End If;
  If (p_rec.tea_information15 = hr_api.g_varchar2) then
    p_rec.tea_information15 :=
    ota_tea_shd.g_old_rec.tea_information15;
  End If;
  If (p_rec.tea_information16 = hr_api.g_varchar2) then
    p_rec.tea_information16 :=
    ota_tea_shd.g_old_rec.tea_information16;
  End If;
  If (p_rec.tea_information17 = hr_api.g_varchar2) then
    p_rec.tea_information17 :=
    ota_tea_shd.g_old_rec.tea_information17;
  End If;
  If (p_rec.tea_information18 = hr_api.g_varchar2) then
    p_rec.tea_information18 :=
    ota_tea_shd.g_old_rec.tea_information18;
  End If;
  If (p_rec.tea_information19 = hr_api.g_varchar2) then
    p_rec.tea_information19 :=
    ota_tea_shd.g_old_rec.tea_information19;
  End If;
  If (p_rec.tea_information20 = hr_api.g_varchar2) then
    p_rec.tea_information20 :=
    ota_tea_shd.g_old_rec.tea_information20;
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
  p_rec        in out nocopy ota_tea_shd.g_rec_type,
  p_validate   in     boolean
  ,p_association_type           in varchar2
  ,p_business_group_id          in number
  ,p_price_basis                in varchar2
  ,p_booking_id                 in out nocopy number
  ,p_tdb_object_version_number  in out nocopy number
  ,p_booking_status_type_id     in number
  ,p_date_status_changed        in date
  ,p_status_change_comments     in varchar2
        ,p_booking_contact_id           in number
        ,p_contact_address_id           in number
        ,p_delegate_contact_phone       in varchar2
        ,p_delegate_contact_fax         in varchar2
        ,p_internal_booking_flag        in varchar2
	,p_source_of_booking		in varchar2
	,p_number_of_places             in number
	,p_date_booking_placed		in date
        ,p_tfl_object_version_number    in out nocopy number
        ,p_update_finance_line          in varchar2
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
    SAVEPOINT upd_ota_tea;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tea_shd.lck
	(
	p_rec.event_association_id
	,p_booking_id
	,p_tdb_object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_tea_bus.update_validate(convert_defs(p_rec)
                             ,p_association_type);
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
  post_update(
         p_business_group_id
	,p_validate
        ,p_price_basis
        ,p_rec.event_id
        ,p_rec.customer_id
	,p_booking_id
	,p_tdb_object_version_number
        ,p_booking_status_type_id
        ,p_date_status_changed
        ,p_status_change_comments
        ,p_booking_contact_id
        ,p_contact_address_id
        ,p_delegate_contact_phone
        ,p_delegate_contact_fax
        ,p_internal_booking_flag
	,p_source_of_booking
	,p_number_of_places
	,p_date_booking_placed
        ,p_update_finance_line
        ,p_tfl_object_version_number
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
    ROLLBACK TO upd_ota_tea;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
 Procedure upd
  (
  p_event_association_id         in number,
  p_event_id                     in number           default hr_api.g_number,
  p_customer_id                  in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tea_information_category     in varchar2         default hr_api.g_varchar2,
  p_tea_information1             in varchar2         default hr_api.g_varchar2,
  p_tea_information2             in varchar2         default hr_api.g_varchar2,
  p_tea_information3             in varchar2         default hr_api.g_varchar2,
  p_tea_information4             in varchar2         default hr_api.g_varchar2,
  p_tea_information5             in varchar2         default hr_api.g_varchar2,
  p_tea_information6             in varchar2         default hr_api.g_varchar2,
  p_tea_information7             in varchar2         default hr_api.g_varchar2,
  p_tea_information8             in varchar2         default hr_api.g_varchar2,
  p_tea_information9             in varchar2         default hr_api.g_varchar2,
  p_tea_information10            in varchar2         default hr_api.g_varchar2,
  p_tea_information11            in varchar2         default hr_api.g_varchar2,
  p_tea_information12            in varchar2         default hr_api.g_varchar2,
  p_tea_information13            in varchar2         default hr_api.g_varchar2,
  p_tea_information14            in varchar2         default hr_api.g_varchar2,
  p_tea_information15            in varchar2         default hr_api.g_varchar2,
  p_tea_information16            in varchar2         default hr_api.g_varchar2,
  p_tea_information17            in varchar2         default hr_api.g_varchar2,
  p_tea_information18            in varchar2         default hr_api.g_varchar2,
  p_tea_information19            in varchar2         default hr_api.g_varchar2,
  p_tea_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ,p_association_type           in varchar2
  ,p_business_group_id          in number   default null
  ,p_price_basis                in varchar2   default null
  ,p_booking_id                 in out nocopy number
  ,p_tdb_object_version_number  in out nocopy number
  ,p_booking_status_type_id     in number   default null
  ,p_date_status_changed        in date   default null
  ,p_status_change_comments     in varchar2   default null
        ,p_booking_contact_id           in number   default null
        ,p_contact_address_id           in number   default null
        ,p_delegate_contact_phone       in varchar2   default null
        ,p_delegate_contact_fax         in varchar2   default null
        ,p_internal_booking_flag        in varchar2   default null
	,p_source_of_booking		in varchar2   default null
	,p_number_of_places             in number   default null
	,p_date_booking_placed		in date   default null
        ,p_tfl_object_version_number    in out nocopy number
        ,p_update_finance_line          in varchar2   default null
        ,p_finance_header_id            in number   default null
        ,p_currency_code                in varchar2   default null
        ,p_standard_amount		in number   default null
        ,p_unitary_amount               in number   default null
        ,p_money_amount                 in number   default null
        ,p_booking_deal_id              in number   default null
        ,p_booking_deal_type            in varchar2   default null
        ,p_finance_line_id              in out nocopy number
        ,p_delegate_contact_email       in varchar2
  ) is
--
  l_rec	  ota_tea_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tea_shd.convert_args
  (
  p_event_association_id,
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
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec
  ,p_validate
  ,p_association_type
  ,p_business_group_id
  ,p_price_basis
  ,p_booking_id
  ,p_tdb_object_version_number
  ,p_booking_status_type_id
  ,p_date_status_changed
  ,p_status_change_comments
        ,p_booking_contact_id
        ,p_contact_address_id
        ,p_delegate_contact_phone
        ,p_delegate_contact_fax
        ,p_internal_booking_flag
	,p_source_of_booking
	,p_number_of_places
	,p_date_booking_placed
        ,p_tfl_object_version_number
        ,p_update_finance_line
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
Procedure upd
  (
 p_event_association_id         in number,
  p_event_id                     in number           default hr_api.g_number,
  p_customer_id                  in number           default hr_api.g_number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_tea_information_category     in varchar2         default hr_api.g_varchar2,
  p_tea_information1             in varchar2         default hr_api.g_varchar2,
  p_tea_information2             in varchar2         default hr_api.g_varchar2,
  p_tea_information3             in varchar2         default hr_api.g_varchar2,
  p_tea_information4             in varchar2         default hr_api.g_varchar2,
  p_tea_information5             in varchar2         default hr_api.g_varchar2,
  p_tea_information6             in varchar2         default hr_api.g_varchar2,
  p_tea_information7             in varchar2         default hr_api.g_varchar2,
  p_tea_information8             in varchar2         default hr_api.g_varchar2,
  p_tea_information9             in varchar2         default hr_api.g_varchar2,
  p_tea_information10            in varchar2         default hr_api.g_varchar2,
  p_tea_information11            in varchar2         default hr_api.g_varchar2,
  p_tea_information12            in varchar2         default hr_api.g_varchar2,
  p_tea_information13            in varchar2         default hr_api.g_varchar2,
  p_tea_information14            in varchar2         default hr_api.g_varchar2,
  p_tea_information15            in varchar2         default hr_api.g_varchar2,
  p_tea_information16            in varchar2         default hr_api.g_varchar2,
  p_tea_information17            in varchar2         default hr_api.g_varchar2,
  p_tea_information18            in varchar2         default hr_api.g_varchar2,
  p_tea_information19            in varchar2         default hr_api.g_varchar2,
  p_tea_information20            in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean
        ,p_business_group_id            in  number
        ,p_price_basis                  in varchar2
	,p_booking_id                   in out nocopy number
	,p_tdb_object_version_number	in out nocopy number
        ,p_booking_status_type_id       in number
        ,p_date_status_changed        in date
        ,p_status_change_comments     in varchar2
        ,p_booking_contact_id           in number
        ,p_contact_address_id           in number
        ,p_delegate_contact_phone       in varchar2
        ,p_delegate_contact_fax         in varchar2
        ,p_internal_booking_flag        in varchar2
	,p_source_of_booking		in varchar2
	,p_number_of_places             in number
	,p_date_booking_placed		in date
        ,p_tfl_object_version_number    in out nocopy number
        ,p_update_finance_line          in varchar2
        ,p_finance_header_id            in number
        ,p_currency_code                in varchar2
	,p_standard_amount		in number
        ,p_unitary_amount               in number
        ,p_money_amount                 in number
        ,p_booking_deal_id              in number
        ,p_booking_deal_type            in varchar2
        ,p_finance_line_id              in out nocopy number
        , p_delegate_contact_email      in varchar2
  ) is
begin
   upd(
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
 ,p_date_status_changed          => p_date_status_changed
 ,p_status_change_comments       => p_status_change_comments
 ,p_booking_contact_id           => p_booking_contact_id
 ,p_contact_address_id           => p_contact_address_id
 ,p_delegate_contact_phone       => p_delegate_contact_phone
 ,p_delegate_contact_fax         => p_delegate_contact_fax
 ,p_internal_booking_flag        => p_internal_booking_flag
 ,p_source_of_booking		 => p_source_of_booking
 ,p_number_of_places             => p_number_of_places
 ,p_date_booking_placed		 => p_date_booking_placed
 ,p_tfl_object_version_number    => p_tfl_object_version_number
 ,p_update_finance_line          => p_update_finance_line
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
end upd;
--
Procedure upd
  (
  p_event_association_id         in number,
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
l_tfl_object_version_number number;
l_finance_line_id number;
--
begin
   upd(
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
 ,p_date_status_changed          => null
 ,p_status_change_comments       => null
 ,p_booking_contact_id           => null
 ,p_contact_address_id           => null
 ,p_delegate_contact_phone       => null
 ,p_delegate_contact_fax         => null
 ,p_internal_booking_flag        => null
 ,p_source_of_booking		 => null
 ,p_number_of_places             => null
 ,p_date_booking_placed		 => null
 ,p_tfl_object_version_number    => l_tfl_object_version_number
 ,p_update_finance_line          => null
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
end upd;
end ota_tea_upd;

/
