--------------------------------------------------------
--  DDL for Package Body SSP_MAT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_MAT_INS" as
/* $Header: spmatrhi.pkb 120.5.12010000.3 2008/08/13 13:27:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_mat_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
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
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ssp_mat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ssp_mat_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ssp_maternities
  --
  insert into ssp_maternities
  (	maternity_id,
	due_date,
	person_id,
	start_date_maternity_allowance,
	notification_of_birth_date,
	unfit_for_scheduled_return,
	stated_return_date,
	intend_to_return_flag,
	start_date_with_new_employer,
	smp_must_be_paid_by_date,
	pay_smp_as_lump_sum,
	live_birth_flag,
	actual_birth_date,
	mpp_start_date,
	object_version_number,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
    LEAVE_TYPE,
    MATCHING_DATE ,
    PLACEMENT_DATE ,
    DISRUPTED_PLACEMENT_DATE,
    mat_information_category,
    mat_information1,
    mat_information2,
    mat_information3,
    mat_information4,
    mat_information5,
    mat_information6,
    mat_information7,
    mat_information8,
    mat_information9,
    mat_information10,
    mat_information11,
    mat_information12,
    mat_information13,
    mat_information14,
    mat_information15,
    mat_information16,
    mat_information17,
    mat_information18,
    mat_information19,
    mat_information20,
    mat_information21,
    mat_information22,
    mat_information23,
    mat_information24,
    mat_information25,
    mat_information26,
    mat_information27,
    mat_information28,
    mat_information29,
    mat_information30
   )
  Values
  (	p_rec.maternity_id,
	p_rec.due_date,
	p_rec.person_id,
	p_rec.start_date_maternity_allowance,
	p_rec.notification_of_birth_date,
	p_rec.unfit_for_scheduled_return,
	p_rec.stated_return_date,
	p_rec.intend_to_return_flag,
	p_rec.start_date_with_new_employer,
	p_rec.smp_must_be_paid_by_date,
	p_rec.pay_smp_as_lump_sum,
	p_rec.live_birth_flag,
	p_rec.actual_birth_date,
	p_rec.mpp_start_date,
	p_rec.object_version_number,
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,
    p_rec.LEAVE_TYPE,
    p_rec.MATCHING_DATE,
    p_rec.PLACEMENT_DATE,
    p_rec.DISRUPTED_PLACEMENT_DATE,
    p_rec.mat_information_category,
    p_rec.mat_information1,
    p_rec.mat_information2,
    p_rec.mat_information3,
    p_rec.mat_information4,
    p_rec.mat_information5,
    p_rec.mat_information6,
    p_rec.mat_information7,
    p_rec.mat_information8,
    p_rec.mat_information9,
    p_rec.mat_information10,
    p_rec.mat_information11,
    p_rec.mat_information12,
    p_rec.mat_information13,
    p_rec.mat_information14,
    p_rec.mat_information15,
    p_rec.mat_information16,
    p_rec.mat_information17,
    p_rec.mat_information18,
    p_rec.mat_information19,
    p_rec.mat_information20,
    p_rec.mat_information21,
    p_rec.mat_information22,
    p_rec.mat_information23,
    p_rec.mat_information24,
    p_rec.mat_information25,
    p_rec.mat_information26,
    p_rec.mat_information27,
    p_rec.mat_information28,
    p_rec.mat_information29,
    p_rec.mat_information30
   );
  --
  ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
    ssp_mat_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ssp_mat_shd.g_api_dml := false;   -- Unset the api dml status
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
-- In Parameters:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ssp_mat_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ssp_maternities_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.maternity_id;
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
-- In Parameters:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ssp_mat_shd.g_rec_type) is
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
  p_rec        in out nocopy ssp_mat_shd.g_rec_type,
  p_validate   in     boolean default false
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
    SAVEPOINT ins_ssp_mat;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ssp_mat_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ssp_mat;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_maternity_id                 out nocopy number,
  p_object_version_number        out nocopy number,
  p_due_date                     in date,
  p_person_id                    in number,
  p_start_date_SMA in date	default null,
  p_notification_of_birth_date   in date	default null,
  p_unfit_for_scheduled_return   in varchar2	default 'N',
  p_stated_return_date           in date	default null,
  p_intend_to_return_flag        in varchar2	default 'Y',
  p_start_date_with_new_employer in date	default null,
  p_smp_must_be_paid_by_date     in date	default null,
  p_pay_smp_as_lump_sum          in varchar2	default 'N',
  p_live_birth_flag              in varchar2	default 'Y',
  p_actual_birth_date            in date	default null,
  p_mpp_start_date               in date	default null,
  p_attribute_category           in varchar2	default null,
  p_attribute1                   in varchar2	default null,
  p_attribute2                   in varchar2	default null,
  p_attribute3                   in varchar2	default null,
  p_attribute4                   in varchar2	default null,
  p_attribute5                   in varchar2	default null,
  p_attribute6                   in varchar2	default null,
  p_attribute7                   in varchar2	default null,
  p_attribute8                   in varchar2	default null,
  p_attribute9                   in varchar2	default null,
  p_attribute10                  in varchar2	default null,
  p_attribute11                  in varchar2	default null,
  p_attribute12                  in varchar2	default null,
  p_attribute13                  in varchar2	default null,
  p_attribute14                  in varchar2	default null,
  p_attribute15                  in varchar2	default null,
  p_attribute16                  in varchar2	default null,
  p_attribute17                  in varchar2	default null,
  p_attribute18                  in varchar2	default null,
  p_attribute19                  in varchar2	default null,
  p_attribute20                  in varchar2	default null,
  p_LEAVE_TYPE                   in VARCHAR2 default 'MA',
  p_MATCHING_DATE                in DATE default null,
  p_PLACEMENT_DATE               in DATE default null,
  p_DISRUPTED_PLACEMENT_DATE     in DATE default null,
  p_validate                     in boolean	default false,
  p_mat_information_category     in varchar2    default null,
  p_mat_information1             in varchar2    default null,
  p_mat_information2             in varchar2    default null,
  p_mat_information3             in varchar2    default null,
  p_mat_information4             in varchar2    default null,
  p_mat_information5             in varchar2    default null,
  p_mat_information6             in varchar2    default null,
  p_mat_information7             in varchar2    default null,
  p_mat_information8             in varchar2    default null,
  p_mat_information9             in varchar2    default null,
  p_mat_information10            in varchar2    default null,
  p_mat_information11            in varchar2    default null,
  p_mat_information12            in varchar2    default null,
  p_mat_information13            in varchar2    default null,
  p_mat_information14            in varchar2    default null,
  p_mat_information15            in varchar2    default null,
  p_mat_information16            in varchar2    default null,
  p_mat_information17            in varchar2    default null,
  p_mat_information18            in varchar2    default null,
  p_mat_information19            in varchar2    default null,
  p_mat_information20            in varchar2    default null,
  p_mat_information21            in varchar2    default null,
  p_mat_information22            in varchar2    default null,
  p_mat_information23            in varchar2    default null,
  p_mat_information24            in varchar2    default null,
  p_mat_information25            in varchar2    default null,
  p_mat_information26            in varchar2    default null,
  p_mat_information27            in varchar2    default null,
  p_mat_information28            in varchar2    default null,
  p_mat_information29            in varchar2    default null,
  p_mat_information30            in varchar2    default null
  ) is
--
  l_rec	  ssp_mat_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ssp_mat_shd.convert_args
  (
  null,
  p_due_date,
  p_person_id,
  p_start_date_SMA,
  p_notification_of_birth_date,
  p_unfit_for_scheduled_return,
  p_stated_return_date,
  p_intend_to_return_flag,
  p_start_date_with_new_employer,
  p_smp_must_be_paid_by_date,
  p_pay_smp_as_lump_sum,
  p_live_birth_flag,
  p_actual_birth_date,
  p_mpp_start_date,
  null,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
  p_LEAVE_TYPE,
  p_MATCHING_DATE,
  p_PLACEMENT_DATE ,
  p_DISRUPTED_PLACEMENT_DATE,
  p_mat_information_category,
  p_mat_information1,
  p_mat_information2,
  p_mat_information3,
  p_mat_information4,
  p_mat_information5,
  p_mat_information6,
  p_mat_information7,
  p_mat_information8,
  p_mat_information9,
  p_mat_information10,
  p_mat_information11,
  p_mat_information12,
  p_mat_information13,
  p_mat_information14,
  p_mat_information15,
  p_mat_information16,
  p_mat_information17,
  p_mat_information18,
  p_mat_information19,
  p_mat_information20,
  p_mat_information21,
  p_mat_information22,
  p_mat_information23,
  p_mat_information24,
  p_mat_information25,
  p_mat_information26,
  p_mat_information27,
  p_mat_information28,
  p_mat_information29,
  p_mat_information30
   );
  --
  -- Having converted the arguments into the ssp_mat_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_maternity_id := l_rec.maternity_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ssp_mat_ins;

/
