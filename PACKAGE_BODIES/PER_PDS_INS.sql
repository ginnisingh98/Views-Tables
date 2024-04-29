--------------------------------------------------------
--  DDL for Package Body PER_PDS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_INS" as
/* $Header: pepdsrhi.pkb 120.7.12010000.2 2009/07/15 10:28:27 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_period_of_service_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_period_of_service_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_pds_ins.g_period_of_service_id_i := p_period_of_service_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_pds_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_periods_of_service
  --
  insert into per_periods_of_service
  (	period_of_service_id,
	business_group_id,
	termination_accepted_person_id,
	person_id,
	date_start,
	accepted_termination_date,
	actual_termination_date,
	comments,
	final_process_date,
	last_standard_process_date,
	leaving_reason,
	notified_termination_date,
	projected_termination_date,
        adjusted_svc_date,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
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
	object_version_number,
	prior_employment_ssp_weeks,
	prior_employment_ssp_paid_to,
	pds_information_category,
	pds_information1,
	pds_information2,
	pds_information3,
	pds_information4,
	pds_information5,
	pds_information6,
	pds_information7,
	pds_information8,
	pds_information9,
	pds_information10,
	pds_information11,
	pds_information12,
	pds_information13,
	pds_information14,
	pds_information15,
	pds_information16,
	pds_information17,
	pds_information18,
	pds_information19,
	pds_information20,
	pds_information21,
	pds_information22,
	pds_information23,
	pds_information24,
	pds_information25,
	pds_information26,
	pds_information27,
	pds_information28,
	pds_information29,
	pds_information30
  )
  Values
  (	p_rec.period_of_service_id,
	p_rec.business_group_id,
	p_rec.termination_accepted_person_id,
	p_rec.person_id,
	p_rec.date_start,
	p_rec.accepted_termination_date,
	p_rec.actual_termination_date,
	p_rec.comments,
	p_rec.final_process_date,
	p_rec.last_standard_process_date,
	p_rec.leaving_reason,
	p_rec.notified_termination_date,
	p_rec.projected_termination_date,
        p_rec.adjusted_svc_date,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
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
	p_rec.object_version_number,
	p_rec.prior_employment_ssp_weeks,
	p_rec.prior_employment_ssp_paid_to,
	p_rec.pds_information_category,
	p_rec.pds_information1,
	p_rec.pds_information2,
	p_rec.pds_information3,
	p_rec.pds_information4,
	p_rec.pds_information5,
	p_rec.pds_information6,
	p_rec.pds_information7,
	p_rec.pds_information8,
	p_rec.pds_information9,
	p_rec.pds_information10,
	p_rec.pds_information11,
	p_rec.pds_information12,
	p_rec.pds_information13,
	p_rec.pds_information14,
	p_rec.pds_information15,
	p_rec.pds_information16,
	p_rec.pds_information17,
	p_rec.pds_information18,
	p_rec.pds_information19,
	p_rec.pds_information20,
	p_rec.pds_information21,
	p_rec.pds_information22,
	p_rec.pds_information23,
	p_rec.pds_information24,
	p_rec.pds_information25,
	p_rec.pds_information26,
	p_rec.pds_information27,
	p_rec.pds_information28,
	p_rec.pds_information29,
	p_rec.pds_information30
  );
  --
  per_pds_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_periods_of_service_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.period_of_service_id;
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in per_pds_shd.g_rec_type,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
-- START WWBUG 1390173 fix
--
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG 1390173 fix
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- GP
  --
  -- BEGIN of FIX for WWBUG 1390173
  --
  l_old.PERSON_ID := null;
  l_old.BUSINESS_GROUP_ID := null;
  l_old.DATE_START := null;
  l_old.ACTUAL_TERMINATION_DATE := null;
  l_old.LEAVING_REASON := null;
  l_old.ADJUSTED_SVC_DATE := null;
  l_old.ATTRIBUTE1 := null;
  l_old.ATTRIBUTE2 := null;
  l_old.ATTRIBUTE3 := null;
  l_old.ATTRIBUTE4 := null;
  l_old.ATTRIBUTE5 := null;
  l_old.FINAL_PROCESS_DATE := null;
  l_new.PERSON_ID := p_rec.person_id;
  l_new.BUSINESS_GROUP_ID := p_rec.business_group_id;
  l_new.DATE_START := p_rec.date_start;
  l_new.ACTUAL_TERMINATION_DATE := p_rec.actual_termination_date;
  l_new.LEAVING_REASON := p_rec.leaving_reason;
  l_new.ADJUSTED_SVC_DATE := p_rec.adjusted_svc_date;
  l_new.ATTRIBUTE1 := p_rec.attribute1;
  l_new.ATTRIBUTE2 := p_rec.attribute2;
  l_new.ATTRIBUTE3 := p_rec.attribute3;
  l_new.ATTRIBUTE4 := p_rec.attribute4;
  l_new.ATTRIBUTE5 := p_rec.attribute5;
  l_new.FINAL_PROCESS_DATE := p_rec.FINAL_PROCESS_DATE;
  --
  ben_pps_ler.ler_chk(p_old            => l_old
                     ,p_new            => l_new
                     ,p_event          => 'INSERTING'
                     ,p_effective_date => p_effective_date);
  --
  -- END of FIX for 1390173
  --
  -- Start of API User Hook for post_insert.
  begin
    per_pds_rki.after_insert
    (
     p_period_of_service_id 		=>p_rec.period_of_service_id
    ,p_business_group_id                =>p_rec.business_group_id
    ,p_person_id                        =>p_rec.person_id
    ,p_date_start                       =>p_rec.date_start
    ,p_comments                         =>p_rec.comments
    ,p_adjusted_svc_date                =>p_rec.adjusted_svc_date
    ,p_request_id                       =>p_rec.request_id
    ,p_program_application_id           =>p_rec.program_application_id
    ,p_program_id                       =>p_rec.program_id
    ,p_program_update_date              =>p_rec.program_update_date
    ,p_attribute_category               =>p_rec.attribute_category
    ,p_attribute1                       =>p_rec.attribute1
    ,p_attribute2                       =>p_rec.attribute2
    ,p_attribute3                       =>p_rec.attribute3
    ,p_attribute4                       =>p_rec.attribute4
    ,p_attribute5                       =>p_rec.attribute5
    ,p_attribute6                       =>p_rec.attribute6
    ,p_attribute7                       =>p_rec.attribute7
    ,p_attribute8                       =>p_rec.attribute8
    ,p_attribute9                       =>p_rec.attribute9
    ,p_attribute10                      =>p_rec.attribute10
    ,p_attribute11                      =>p_rec.attribute11
    ,p_attribute12                      =>p_rec.attribute12
    ,p_attribute13                      =>p_rec.attribute13
    ,p_attribute14                      =>p_rec.attribute14
    ,p_attribute15                      =>p_rec.attribute15
    ,p_attribute16                      =>p_rec.attribute16
    ,p_attribute17                      =>p_rec.attribute17
    ,p_attribute18                      =>p_rec.attribute18
    ,p_attribute19                      =>p_rec.attribute19
    ,p_attribute20                      =>p_rec.attribute20
    ,p_object_version_number            =>p_rec.object_version_number
    ,p_prior_employment_ssp_weeks       =>p_rec.prior_employment_ssp_weeks
    ,p_prior_employment_ssp_paid_to     =>p_rec.prior_employment_ssp_paid_to
    ,p_effective_date                   =>p_effective_date
    ,p_pds_information_category      =>p_rec.pds_information_category
    ,p_pds_information1              =>p_rec.pds_information1
    ,p_pds_information2              =>p_rec.pds_information2
    ,p_pds_information3              =>p_rec.pds_information3
    ,p_pds_information4              =>p_rec.pds_information4
    ,p_pds_information5              =>p_rec.pds_information5
    ,p_pds_information6              =>p_rec.pds_information6
    ,p_pds_information7              =>p_rec.pds_information7
    ,p_pds_information8              =>p_rec.pds_information8
    ,p_pds_information9              =>p_rec.pds_information9
    ,p_pds_information10             =>p_rec.pds_information10
    ,p_pds_information11             =>p_rec.pds_information11
    ,p_pds_information12             =>p_rec.pds_information12
    ,p_pds_information13             =>p_rec.pds_information13
    ,p_pds_information14             =>p_rec.pds_information14
    ,p_pds_information15             =>p_rec.pds_information15
    ,p_pds_information16             =>p_rec.pds_information16
    ,p_pds_information17             =>p_rec.pds_information17
    ,p_pds_information18             =>p_rec.pds_information18
    ,p_pds_information19             =>p_rec.pds_information19
    ,p_pds_information20             =>p_rec.pds_information20
    ,p_pds_information21             =>p_rec.pds_information21
    ,p_pds_information22             =>p_rec.pds_information22
    ,p_pds_information23             =>p_rec.pds_information23
    ,p_pds_information24             =>p_rec.pds_information24
    ,p_pds_information25             =>p_rec.pds_information25
    ,p_pds_information26             =>p_rec.pds_information26
    ,p_pds_information27             =>p_rec.pds_information27
    ,p_pds_information28             =>p_rec.pds_information28
    ,p_pds_information29             =>p_rec.pds_information29
    ,p_pds_information30             =>p_rec.pds_information30
    );
       exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
                 (       p_module_name => 'PER_PERIOD_OF_SERVICE',
                         p_hook_type   => 'AI'
                 );
     end;
--   End of API User Hook for post_insert.
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec               in out nocopy per_pds_shd.g_rec_type,
  p_effective_date    in date,
  p_validate          in boolean default false,
  p_validate_df_flex  in boolean default true
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
    SAVEPOINT ins_per_pds;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_pds_bus.insert_validate(p_rec
                             ,p_effective_date
                             ,p_validate_df_flex);
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
  post_insert(p_rec, p_effective_date);
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
    ROLLBACK TO ins_per_pds;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  --
  -- 70.3 change a start.
  --
  p_period_of_service_id         out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_date_start                   in date,
  p_comments                     in varchar2         default null,
  p_adjusted_svc_date            in date             default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_prior_employment_ssp_weeks   in number           default null,
  p_prior_employment_ssp_paid_to in date             default null,
  p_pds_information_category     in varchar2         default null,
  p_pds_information1             in varchar2         default null,
  p_pds_information2             in varchar2         default null,
  p_pds_information3             in varchar2         default null,
  p_pds_information4             in varchar2         default null,
  p_pds_information5             in varchar2         default null,
  p_pds_information6             in varchar2         default null,
  p_pds_information7             in varchar2         default null,
  p_pds_information8             in varchar2         default null,
  p_pds_information9             in varchar2         default null,
  p_pds_information10            in varchar2         default null,
  p_pds_information11            in varchar2         default null,
  p_pds_information12            in varchar2         default null,
  p_pds_information13            in varchar2         default null,
  p_pds_information14            in varchar2         default null,
  p_pds_information15            in varchar2         default null,
  p_pds_information16            in varchar2         default null,
  p_pds_information17            in varchar2         default null,
  p_pds_information18            in varchar2         default null,
  p_pds_information19            in varchar2         default null,
  p_pds_information20            in varchar2         default null,
  p_pds_information21            in varchar2         default null,
  p_pds_information22            in varchar2         default null,
  p_pds_information23            in varchar2         default null,
  p_pds_information24            in varchar2         default null,
  p_pds_information25            in varchar2         default null,
  p_pds_information26            in varchar2         default null,
  p_pds_information27            in varchar2         default null,
  p_pds_information28            in varchar2         default null,
  p_pds_information29            in varchar2         default null,
  p_pds_information30            in varchar2         default null,
  p_effective_date               in date,
  p_validate                     in boolean          default false,
  p_validate_df_flex             in boolean          default true
) is
--
  l_rec	  per_pds_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pds_shd.convert_args
  (
  null,
  p_business_group_id,
  null,
  p_person_id,
  p_date_start,
  null,
  null,
  p_comments,
  null,
  null,
  null,
  null,
  null,
  p_adjusted_svc_date,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
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
  null ,
  p_prior_employment_ssp_weeks,
  p_prior_employment_ssp_paid_to,
  p_pds_information_category,
  p_pds_information1,
  p_pds_information2,
  p_pds_information3,
  p_pds_information4,
  p_pds_information5,
  p_pds_information6,
  p_pds_information7,
  p_pds_information8,
  p_pds_information9,
  p_pds_information10,
  p_pds_information11,
  p_pds_information12,
  p_pds_information13,
  p_pds_information14,
  p_pds_information15,
  p_pds_information16,
  p_pds_information17,
  p_pds_information18,
  p_pds_information19,
  p_pds_information20,
  p_pds_information21,
  p_pds_information22,
  p_pds_information23,
  p_pds_information24,
  p_pds_information25,
  p_pds_information26,
  p_pds_information27,
  p_pds_information28,
  p_pds_information29,
  p_pds_information30
  );
  --
  -- 70.3 change a end.
  --
  -- Having converted the arguments into the per_pds_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date, p_validate, p_validate_df_flex);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_period_of_service_id := l_rec.period_of_service_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pds_ins;

/
