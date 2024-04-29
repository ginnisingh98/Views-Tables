--------------------------------------------------------
--  DDL for Package Body OTA_EVT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_UPD" as
/* $Header: otevt01t.pkb 120.13.12010000.5 2009/07/29 07:12:13 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_evt_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ota_evt_shd.g_rec_type) is
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
  ota_evt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_events Row
  --
  update ota_events
  set
  event_id                          = p_rec.event_id,
  vendor_id                         = p_rec.vendor_id,
  activity_version_id               = p_rec.activity_version_id,
  business_group_id                 = p_rec.business_group_id,
  organization_id                   = p_rec.organization_id,
  event_type                        = p_rec.event_type,
  object_version_number             = p_rec.object_version_number,
  title                             = p_rec.title,
  budget_cost                       = p_rec.budget_cost,
  actual_cost                       = p_rec.actual_cost,
  budget_currency_code              = p_rec.budget_currency_code,
  centre                            = p_rec.centre,
  comments                          = p_rec.comments,
  course_end_date                   = p_rec.course_end_date,
  course_end_time                   = p_rec.course_end_time,
  course_start_date                 = p_rec.course_start_date,
  course_start_time                 = p_rec.course_start_time,
  duration                          = p_rec.duration,
  duration_units                    = p_rec.duration_units,
  enrolment_end_date                = p_rec.enrolment_end_date,
  enrolment_start_date              = p_rec.enrolment_start_date,
  language_id                       = p_rec.language_id,
  user_status                       = p_rec.user_status,
  development_event_type            = p_rec.development_event_type,
  event_status                      = p_rec.event_status,
  price_basis                       = p_rec.price_basis,
  currency_code                     = p_rec.currency_code,
  maximum_attendees                 = p_rec.maximum_attendees,
  maximum_internal_attendees        = p_rec.maximum_internal_attendees,
  minimum_attendees                 = p_rec.minimum_attendees,
  standard_price                    = p_rec.standard_price,
  category_code                     = p_rec.category_code,
  parent_event_id                   = p_rec.parent_event_id,
  book_independent_flag             = p_rec.book_independent_flag,
  public_event_flag                 = p_rec.public_event_flag,
  secure_event_flag                 = p_rec.secure_event_flag,
  evt_information_category          = p_rec.evt_information_category,
  evt_information1                  = p_rec.evt_information1,
  evt_information2                  = p_rec.evt_information2,
  evt_information3                  = p_rec.evt_information3,
  evt_information4                  = p_rec.evt_information4,
  evt_information5                  = p_rec.evt_information5,
  evt_information6                  = p_rec.evt_information6,
  evt_information7                  = p_rec.evt_information7,
  evt_information8                  = p_rec.evt_information8,
  evt_information9                  = p_rec.evt_information9,
  evt_information10                 = p_rec.evt_information10,
  evt_information11                 = p_rec.evt_information11,
  evt_information12                 = p_rec.evt_information12,
  evt_information13                 = p_rec.evt_information13,
  evt_information14                 = p_rec.evt_information14,
  evt_information15                 = p_rec.evt_information15,
  evt_information16                 = p_rec.evt_information16,
  evt_information17                 = p_rec.evt_information17,
  evt_information18                 = p_rec.evt_information18,
  evt_information19                 = p_rec.evt_information19,
  evt_information20                 = p_rec.evt_information20,
  project_id                        = p_rec.project_id,
  owner_id					        = p_rec.owner_id,
  line_id					        = p_rec.line_id,
  org_id					        = p_rec.org_id,
  training_center_id                = p_rec.training_center_id,
  location_id                       = p_rec.location_id,
  offering_id				        = p_rec.offering_id,
  timezone			     		    = p_rec.timezone,
  parent_offering_id				= p_rec.parent_offering_id,
  data_source 				        = p_rec.data_source,
  event_availability                = p_rec.event_availability
  where event_id = p_rec.event_id;
  --
  ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
    ota_evt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_evt_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ota_evt_shd.g_rec_type) is
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
Procedure post_update(p_rec in ota_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ota_evt_bus.chk_status_changed
  		(p_line_id 	 	=> p_rec.line_id
	      ,p_event_status   => p_rec.event_status
  	      ,p_event_id		=> p_rec.event_id
  	      ,p_org_id 		=> p_rec.org_id
		,p_owner_id		=> p_rec.owner_id
		,p_event_title	=> p_rec.title);

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
Function convert_defs(p_rec in out nocopy ota_evt_shd.g_rec_type)
         Return ota_evt_shd.g_rec_type is
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
    ota_evt_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    ota_evt_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_evt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_evt_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.event_type = hr_api.g_varchar2) then
    p_rec.event_type :=
    ota_evt_shd.g_old_rec.event_type;
  End If;
  If (p_rec.title = hr_api.g_varchar2) then
    p_rec.title :=
    ota_evt_shd.g_old_rec.title;
  End If;
  If (p_rec.budget_cost = hr_api.g_number) then
    p_rec.budget_cost :=
    ota_evt_shd.g_old_rec.budget_cost;
  End If;
  If (p_rec.actual_cost = hr_api.g_number) then
    p_rec.actual_cost :=
    ota_evt_shd.g_old_rec.actual_cost;
  End If;
  If (p_rec.budget_currency_code = hr_api.g_varchar2) then
    p_rec.budget_currency_code :=
    ota_evt_shd.g_old_rec.budget_currency_code;
  End If;
  If (p_rec.centre = hr_api.g_varchar2) then
    p_rec.centre :=
    ota_evt_shd.g_old_rec.centre;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_evt_shd.g_old_rec.comments;
  End If;
  If (p_rec.course_end_date = hr_api.g_date) then
    p_rec.course_end_date :=
    ota_evt_shd.g_old_rec.course_end_date;
  End If;
  If (p_rec.course_end_time = hr_api.g_varchar2) then
    p_rec.course_end_time :=
    ota_evt_shd.g_old_rec.course_end_time;
  End If;
  If (p_rec.course_start_date = hr_api.g_date) then
    p_rec.course_start_date :=
    ota_evt_shd.g_old_rec.course_start_date;
  End If;
  If (p_rec.course_start_time = hr_api.g_varchar2) then
    p_rec.course_start_time :=
    ota_evt_shd.g_old_rec.course_start_time;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    ota_evt_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_units = hr_api.g_varchar2) then
    p_rec.duration_units :=
    ota_evt_shd.g_old_rec.duration_units;
  End If;
  If (p_rec.enrolment_end_date = hr_api.g_date) then
    p_rec.enrolment_end_date :=
    ota_evt_shd.g_old_rec.enrolment_end_date;
  End If;
  If (p_rec.enrolment_start_date = hr_api.g_date) then
    p_rec.enrolment_start_date :=
    ota_evt_shd.g_old_rec.enrolment_start_date;
  End If;
  If (p_rec.language_id = hr_api.g_number) then
    p_rec.language_id :=
    ota_evt_shd.g_old_rec.language_id;
  End If;
  If (p_rec.user_status = hr_api.g_varchar2) then
    p_rec.user_status :=
    ota_evt_shd.g_old_rec.user_status;
  End If;
  If (p_rec.development_event_type = hr_api.g_varchar2) then
    p_rec.development_event_type :=
    ota_evt_shd.g_old_rec.development_event_type;
  End If;
  If (p_rec.event_status = hr_api.g_varchar2) then
    p_rec.event_status :=
    ota_evt_shd.g_old_rec.event_status;
  End If;
  If (p_rec.price_basis = hr_api.g_varchar2) then
    p_rec.price_basis :=
    ota_evt_shd.g_old_rec.price_basis;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_evt_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.maximum_attendees = hr_api.g_number) then
    p_rec.maximum_attendees :=
    ota_evt_shd.g_old_rec.maximum_attendees;
  End If;
  If (p_rec.maximum_internal_attendees = hr_api.g_number) then
    p_rec.maximum_internal_attendees :=
    ota_evt_shd.g_old_rec.maximum_internal_attendees;
  End If;
  If (p_rec.minimum_attendees = hr_api.g_number) then
    p_rec.minimum_attendees :=
    ota_evt_shd.g_old_rec.minimum_attendees;
  End If;
  If (p_rec.standard_price = hr_api.g_number) then
    p_rec.standard_price :=
    ota_evt_shd.g_old_rec.standard_price;
  End If;
  If (p_rec.category_code = hr_api.g_varchar2) then
    p_rec.category_code :=
    ota_evt_shd.g_old_rec.category_code;
  End If;
  If (p_rec.parent_event_id = hr_api.g_number) then
    p_rec.parent_event_id :=
    ota_evt_shd.g_old_rec.parent_event_id;
  End If;
  If (p_rec.book_independent_flag = hr_api.g_varchar2) then
    p_rec.book_independent_flag :=
    ota_evt_shd.g_old_rec.book_independent_flag;
  End If;
  If (p_rec.public_event_flag = hr_api.g_varchar2) then
    p_rec.public_event_flag :=
    ota_evt_shd.g_old_rec.public_event_flag;
  End If;
  If (p_rec.secure_event_flag = hr_api.g_varchar2) then
    p_rec.secure_event_flag :=
    ota_evt_shd.g_old_rec.secure_event_flag;
  End If;
  If (p_rec.evt_information_category = hr_api.g_varchar2) then
    p_rec.evt_information_category :=
    ota_evt_shd.g_old_rec.evt_information_category;
  End If;
  If (p_rec.evt_information1 = hr_api.g_varchar2) then
    p_rec.evt_information1 :=
    ota_evt_shd.g_old_rec.evt_information1;
  End If;
  If (p_rec.evt_information2 = hr_api.g_varchar2) then
    p_rec.evt_information2 :=
    ota_evt_shd.g_old_rec.evt_information2;
  End If;
  If (p_rec.evt_information3 = hr_api.g_varchar2) then
    p_rec.evt_information3 :=
    ota_evt_shd.g_old_rec.evt_information3;
  End If;
  If (p_rec.evt_information4 = hr_api.g_varchar2) then
    p_rec.evt_information4 :=
    ota_evt_shd.g_old_rec.evt_information4;
  End If;
  If (p_rec.evt_information5 = hr_api.g_varchar2) then
    p_rec.evt_information5 :=
    ota_evt_shd.g_old_rec.evt_information5;
  End If;
  If (p_rec.evt_information6 = hr_api.g_varchar2) then
    p_rec.evt_information6 :=
    ota_evt_shd.g_old_rec.evt_information6;
  End If;
  If (p_rec.evt_information7 = hr_api.g_varchar2) then
    p_rec.evt_information7 :=
    ota_evt_shd.g_old_rec.evt_information7;
  End If;
  If (p_rec.evt_information8 = hr_api.g_varchar2) then
    p_rec.evt_information8 :=
    ota_evt_shd.g_old_rec.evt_information8;
  End If;
  If (p_rec.evt_information9 = hr_api.g_varchar2) then
    p_rec.evt_information9 :=
    ota_evt_shd.g_old_rec.evt_information9;
  End If;
  If (p_rec.evt_information10 = hr_api.g_varchar2) then
    p_rec.evt_information10 :=
    ota_evt_shd.g_old_rec.evt_information10;
  End If;
  If (p_rec.evt_information11 = hr_api.g_varchar2) then
    p_rec.evt_information11 :=
    ota_evt_shd.g_old_rec.evt_information11;
  End If;
  If (p_rec.evt_information12 = hr_api.g_varchar2) then
    p_rec.evt_information12 :=
    ota_evt_shd.g_old_rec.evt_information12;
  End If;
  If (p_rec.evt_information13 = hr_api.g_varchar2) then
    p_rec.evt_information13 :=
    ota_evt_shd.g_old_rec.evt_information13;
  End If;
  If (p_rec.evt_information14 = hr_api.g_varchar2) then
    p_rec.evt_information14 :=
    ota_evt_shd.g_old_rec.evt_information14;
  End If;
  If (p_rec.evt_information15 = hr_api.g_varchar2) then
    p_rec.evt_information15 :=
    ota_evt_shd.g_old_rec.evt_information15;
  End If;
  If (p_rec.evt_information16 = hr_api.g_varchar2) then
    p_rec.evt_information16 :=
    ota_evt_shd.g_old_rec.evt_information16;
  End If;
  If (p_rec.evt_information17 = hr_api.g_varchar2) then
    p_rec.evt_information17 :=
    ota_evt_shd.g_old_rec.evt_information17;
  End If;
  If (p_rec.evt_information18 = hr_api.g_varchar2) then
    p_rec.evt_information18 :=
    ota_evt_shd.g_old_rec.evt_information18;
  End If;
  If (p_rec.evt_information19 = hr_api.g_varchar2) then
    p_rec.evt_information19 :=
    ota_evt_shd.g_old_rec.evt_information19;
  End If;
  If (p_rec.evt_information20 = hr_api.g_varchar2) then
    p_rec.evt_information20 :=
    ota_evt_shd.g_old_rec.evt_information20;
  End If;
  If (p_rec.project_id = hr_api.g_number) then
    p_rec.project_id :=
   ota_evt_shd.g_old_rec.project_id;
  End If;
  If (p_rec.owner_id = hr_api.g_number) then
    p_rec.owner_id :=
   ota_evt_shd.g_old_rec.owner_id;
  End If;
  If (p_rec.line_id = hr_api.g_number) then
    p_rec.line_id :=
   ota_evt_shd.g_old_rec.line_id;
  End If;
  If (p_rec.org_id = hr_api.g_number) then
    p_rec.org_id :=
   ota_evt_shd.g_old_rec.org_id;
  End If;
  If (p_rec.training_center_id = hr_api.g_number) then
    p_rec.training_center_id :=
   ota_evt_shd.g_old_rec.training_center_id;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
   ota_evt_shd.g_old_rec.location_id;
  End If;

  If (p_rec.offering_id = hr_api.g_number) then
    p_rec.offering_id :=
   ota_evt_shd.g_old_rec.offering_id;
  End If;

  If (p_rec.timezone = hr_api.g_varchar2) then
    p_rec.timezone :=
   ota_evt_shd.g_old_rec.timezone;
  End If;

  If (p_rec.parent_offering_id = hr_api.g_number) then
    p_rec.parent_offering_id :=
   ota_evt_shd.g_old_rec.parent_offering_id;
  End If;

  If (p_rec.data_source = hr_api.g_varchar2) then
    p_rec.data_source :=
   ota_evt_shd.g_old_rec.data_source;
  End If;

  If (p_rec.event_availability = hr_api.g_varchar2) then
    p_rec.event_availability :=
   ota_evt_shd.g_old_rec.event_availability;
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
  p_rec        in out nocopy ota_evt_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
  -- VT 05/06/97 #488173
  temp_var ota_evt_shd.g_rec_type;
  l_course_start_date_changed boolean;
  l_course_end_date_changed   boolean;
  l_course_start_time_changed boolean;
  l_course_end_time_changed boolean;
  l_location_id_changed    boolean;
  l_training_center_id_changed boolean;
  l_class_title_changed boolean;
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
    SAVEPOINT upd_ota_evt;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_evt_shd.lck
	(
	p_rec.event_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  -- VT 05/06/97 #488173
  temp_var := convert_defs(p_rec);
  ota_evt_bus.update_validate(temp_var);
    -- added for eBS by asud
     hr_multi_message.end_validation_set;
  -- added for eBS by asud
  -- ota_evt_bus.update_validate(convert_defs(p_rec));
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
  -- added for eBS by asud
     hr_multi_message.end_validation_set;
  -- added for eBS by asud
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
 -- CODING FOR NTF PROCESS

  l_course_start_date_changed
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_start_date,
			       temp_var.course_start_date);
  l_course_end_date_changed
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_end_date,
           		       temp_var.course_end_date);
  l_course_start_time_changed := ota_general.value_changed(ota_evt_shd.g_old_rec.course_start_time,
           		       temp_var.course_start_time);
  l_course_end_time_changed := ota_general.value_changed(ota_evt_shd.g_old_rec.course_end_time,
           		       temp_var.course_end_time);

   l_location_id_changed
  := ota_general.value_changed(ota_evt_shd.g_old_rec.location_id,
					temp_var.location_id);

   l_training_center_id_changed
  := ota_general.value_changed(ota_evt_shd.g_old_rec.training_center_id,
					temp_var.training_center_id);

   l_class_title_changed := ota_general.value_changed(ota_evt_shd.g_old_rec.title ,temp_var.title);



  if (l_course_start_date_changed or
  l_course_end_date_changed   or
  l_course_start_time_changed or
  l_course_end_time_changed ) then
  --send notification to all instructors for class/session rescheduling
   OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid 	=> p_rec.event_id,
            p_event_fired => 'CLASS_RESCHEDULE');

   if ota_evt_shd.g_old_rec.parent_event_id is null then
     --send notification to all learners for class rescheduling
   OTA_INITIALIZATION_WF.initialize_wf(p_process => 'OTA_CLASS_CANCEL_JSP_PRC',
            p_item_type 	=> 'OTWF',
            p_eventid 	=> p_rec.event_id,
            p_event_fired => 'CLASS_RESCHEDULE');
    end if;

  elsif l_location_id_changed  then

        --send notification to all instructors for class/session  location change
   OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid 	=> p_rec.event_id,
            p_event_fired => 'LOCATION_CHANGE');

  end if;

  ------------ Start Raise Business Event --------------------
if ota_evt_shd.g_old_rec.parent_event_id is null then

  if (l_course_start_date_changed or
  l_course_end_date_changed   or
  l_course_start_time_changed or
  l_course_end_time_changed ) then
   --Raise Business Event to all learners for class rescheduling
    OTA_INITIALIZATION_WF.RAISE_BUSINESS_EVENT(
		p_eventid => p_rec.event_id,
            	p_event_fired => 'oracle.apps.ota.api.event_api.update_class_schedule',
                 p_type  => 'class_reschedule');
    ---
  end if;

   if l_class_title_changed then
  OTA_INITIALIZATION_WF.RAISE_BUSINESS_EVENT(
		p_eventid => p_rec.event_id,
            	p_event_fired => 'oracle.apps.ota.api.event_api.update_class_schedule',
              p_type  => 'class_title_change');
  end if;

 if l_location_id_changed and l_training_center_id_changed then
  --- Raise Business Event to all learners for class/session  location change & Training center change
   OTA_INITIALIZATION_WF.RAISE_BUSINESS_EVENT(
           p_eventid 	=> p_rec.event_id,
           p_event_fired => 'oracle.apps.ota.api.event_api.update_trng_cntr_and_location');

  elsif l_location_id_changed then
   --- Raise Business Event to all learners for class/session  Location change
   OTA_INITIALIZATION_WF.RAISE_BUSINESS_EVENT(
            p_eventid 	=> p_rec.event_id,
           p_event_fired => 'oracle.apps.ota.api.event_api.update_location');
   ---

  elsif l_training_center_id_changed then
    --- Raise Business Event to all learners for class/session  Training center change
   OTA_INITIALIZATION_WF.RAISE_BUSINESS_EVENT(
            p_eventid 	=> p_rec.event_id,
            p_event_fired => 'oracle.apps.ota.api.event_api.update_training_center');
    ---
  end if;
end if;

------------ End Raise Business Event --------------------

  if (l_course_start_date_changed and trunc(temp_var.course_start_date) <= trunc(sysdate)
  and ota_evt_shd.g_old_rec.course_start_date > trunc(sysdate)
  and ota_evt_shd.g_old_rec.parent_event_id is null) then
  -- send notification to all waitlisted learners of class begining
  if (ota_utility.is_con_prog_periodic('OTEVTNTF')) then
  ota_initialization_wf.Initialize_auto_wf(p_process => 'OTA_ENROLL_STATUS_CHNG_JSP_PRC',
            p_item_type => 'OTWF',
            p_event_fired => 'CLASS_START',
            p_event_id 	=> p_rec.event_id);

  end if;
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ota_evt;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_event_id                     in number,
  p_vendor_id                    in number           default hr_api.g_number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_event_type                   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_budget_cost                  in number           default hr_api.g_number,
  p_actual_cost                  in number           default hr_api.g_number,
  p_budget_currency_code         in varchar2         default hr_api.g_varchar2,
  p_centre                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_course_end_date              in date             default hr_api.g_date,
  p_course_end_time              in varchar2         default hr_api.g_varchar2,
  p_course_start_date            in date             default hr_api.g_date,
  p_course_start_time            in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_enrolment_end_date           in date             default hr_api.g_date,
  p_enrolment_start_date         in date             default hr_api.g_date,
  p_language_id                  in number           default hr_api.g_number,
  p_user_status                  in varchar2         default hr_api.g_varchar2,
  p_development_event_type       in varchar2         default hr_api.g_varchar2,
  p_event_status                 in varchar2         default hr_api.g_varchar2,
  p_price_basis                  in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_maximum_attendees            in number           default hr_api.g_number,
  p_maximum_internal_attendees   in number           default hr_api.g_number,
  p_minimum_attendees            in number           default hr_api.g_number,
  p_standard_price               in number           default hr_api.g_number,
  p_category_code                in varchar2         default hr_api.g_varchar2,
  p_parent_event_id              in number           default hr_api.g_number,
  p_book_independent_flag        in varchar2         default hr_api.g_varchar2,
  p_public_event_flag            in varchar2         default hr_api.g_varchar2,
  p_secure_event_flag            in varchar2         default hr_api.g_varchar2,
  p_evt_information_category     in varchar2         default hr_api.g_varchar2,
  p_evt_information1             in varchar2         default hr_api.g_varchar2,
  p_evt_information2             in varchar2         default hr_api.g_varchar2,
  p_evt_information3             in varchar2         default hr_api.g_varchar2,
  p_evt_information4             in varchar2         default hr_api.g_varchar2,
  p_evt_information5             in varchar2         default hr_api.g_varchar2,
  p_evt_information6             in varchar2         default hr_api.g_varchar2,
  p_evt_information7             in varchar2         default hr_api.g_varchar2,
  p_evt_information8             in varchar2         default hr_api.g_varchar2,
  p_evt_information9             in varchar2         default hr_api.g_varchar2,
  p_evt_information10            in varchar2         default hr_api.g_varchar2,
  p_evt_information11            in varchar2         default hr_api.g_varchar2,
  p_evt_information12            in varchar2         default hr_api.g_varchar2,
  p_evt_information13            in varchar2         default hr_api.g_varchar2,
  p_evt_information14            in varchar2         default hr_api.g_varchar2,
  p_evt_information15            in varchar2         default hr_api.g_varchar2,
  p_evt_information16            in varchar2         default hr_api.g_varchar2,
  p_evt_information17            in varchar2         default hr_api.g_varchar2,
  p_evt_information18            in varchar2         default hr_api.g_varchar2,
  p_evt_information19            in varchar2         default hr_api.g_varchar2,
  p_evt_information20            in varchar2         default hr_api.g_varchar2,
  p_project_id                   in number           default hr_api.g_number,
  p_owner_id                     in number           default hr_api.g_number,
  p_line_id	                     in number           default hr_api.g_number,
  p_org_id	                     in number           default hr_api.g_number,
  p_training_center_id           in number           default hr_api.g_number,
  p_location_id	                 in number           default hr_api.g_number,
  p_offering_id		             in number           default hr_api.g_number,
  p_timezone	                 in varchar2         default hr_api.g_varchar2,
  p_parent_offering_id           in number           default hr_api.g_number,
  p_data_source	                 in varchar2         default hr_api.g_varchar2,
-- Bug#2200078 Corrected default value for offering_id and timezone
--  p_offering_id		         in number           default null,
--  p_timezone	               in varchar2         default null,
  p_validate                     in boolean      default false,
  p_event_availability           in varchar2     default hr_api.g_varchar2
  ) is
--
  l_rec	  ota_evt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_evt_shd.convert_args
  (
  p_event_id,
  p_vendor_id,
  p_activity_version_id,
  p_business_group_id,
  p_organization_id,
  p_event_type,
  p_object_version_number,
  p_title,
  p_budget_cost,
  p_actual_cost,
  p_budget_currency_code,
  p_centre,
  p_comments,
  p_course_end_date,
  p_course_end_time,
  p_course_start_date,
  p_course_start_time,
  p_duration,
  p_duration_units,
  p_enrolment_end_date,
  p_enrolment_start_date,
  p_language_id,
  p_user_status,
  p_development_event_type,
  p_event_status,
  p_price_basis,
  p_currency_code,
  p_maximum_attendees,
  p_maximum_internal_attendees,
  p_minimum_attendees,
  p_standard_price,
  p_category_code,
  p_parent_event_id,
  p_book_independent_flag,
  p_public_event_flag,
  p_secure_event_flag,
  p_evt_information_category,
  p_evt_information1,
  p_evt_information2,
  p_evt_information3,
  p_evt_information4,
  p_evt_information5,
  p_evt_information6,
  p_evt_information7,
  p_evt_information8,
  p_evt_information9,
  p_evt_information10,
  p_evt_information11,
  p_evt_information12,
  p_evt_information13,
  p_evt_information14,
  p_evt_information15,
  p_evt_information16,
  p_evt_information17,
  p_evt_information18,
  p_evt_information19,
  p_evt_information20,
  p_project_id,
  p_owner_id,
  p_line_id,
  p_org_id,
  p_training_center_id,
  p_location_id,
  p_offering_id,
  p_timezone,
  p_parent_offering_id ,
  p_data_source,
  p_event_availability
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
end ota_evt_upd;

/
