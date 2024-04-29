--------------------------------------------------------
--  DDL for Package Body PER_APL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APL_INS" as
/* $Header: peaplrhi.pkb 120.1 2005/10/25 00:31:11 risgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_apl_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_apl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_apl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_applications
  --
  insert into per_applications
  (	application_id,
	business_group_id,
	person_id,
	date_received,
	comments,
	current_employer,
	projected_hire_date,
	successful_flag,
	termination_reason,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	appl_attribute_category,
	appl_attribute1,
	appl_attribute2,
	appl_attribute3,
	appl_attribute4,
	appl_attribute5,
	appl_attribute6,
	appl_attribute7,
	appl_attribute8,
	appl_attribute9,
	appl_attribute10,
	appl_attribute11,
	appl_attribute12,
	appl_attribute13,
	appl_attribute14,
	appl_attribute15,
	appl_attribute16,
	appl_attribute17,
	appl_attribute18,
	appl_attribute19,
	appl_attribute20,
	object_version_number
  )
  Values
  (	p_rec.application_id,
	p_rec.business_group_id,
	p_rec.person_id,
	p_rec.date_received,
	p_rec.comments,
	p_rec.current_employer,
	p_rec.projected_hire_date,
	p_rec.successful_flag,
	p_rec.termination_reason,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.appl_attribute_category,
	p_rec.appl_attribute1,
	p_rec.appl_attribute2,
	p_rec.appl_attribute3,
	p_rec.appl_attribute4,
	p_rec.appl_attribute5,
	p_rec.appl_attribute6,
	p_rec.appl_attribute7,
	p_rec.appl_attribute8,
	p_rec.appl_attribute9,
	p_rec.appl_attribute10,
	p_rec.appl_attribute11,
	p_rec.appl_attribute12,
	p_rec.appl_attribute13,
	p_rec.appl_attribute14,
	p_rec.appl_attribute15,
	p_rec.appl_attribute16,
	p_rec.appl_attribute17,
	p_rec.appl_attribute18,
	p_rec.appl_attribute19,
	p_rec.appl_attribute20,
	p_rec.object_version_number
  );
  --
  per_apl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
    per_apl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_apl_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_apl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_applications_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.application_id;
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
Procedure post_insert(p_rec             in per_apl_shd.g_rec_type
                     ,p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_insert.
  begin
    per_apl_rki.after_insert
      (p_application_id               => p_rec.application_id
      ,p_business_group_id            => p_rec.business_group_id
      ,p_person_id                    => p_rec.person_id
      ,p_date_received                => p_rec.date_received
      ,p_comments                     => p_rec.comments
      ,p_current_employer             => p_rec.current_employer
      ,p_projected_hire_date          => p_rec.projected_hire_date
      ,p_successful_flag              => p_rec.successful_flag
      ,p_termination_reason           => p_rec.termination_reason
      ,p_request_id                   => p_rec.request_id
      ,p_program_application_id       => p_rec.program_application_id
      ,p_program_id                   => p_rec.program_id
      ,p_program_update_date          => p_rec.program_update_date
      ,p_appl_attribute_category      => p_rec.appl_attribute_category
      ,p_appl_attribute1              => p_rec.appl_attribute1
      ,p_appl_attribute2              => p_rec.appl_attribute2
      ,p_appl_attribute3              => p_rec.appl_attribute3
      ,p_appl_attribute4              => p_rec.appl_attribute4
      ,p_appl_attribute5              => p_rec.appl_attribute5
      ,p_appl_attribute6              => p_rec.appl_attribute6
      ,p_appl_attribute7              => p_rec.appl_attribute7
      ,p_appl_attribute8              => p_rec.appl_attribute8
      ,p_appl_attribute9              => p_rec.appl_attribute9
      ,p_appl_attribute10             => p_rec.appl_attribute10
      ,p_appl_attribute11             => p_rec.appl_attribute11
      ,p_appl_attribute12             => p_rec.appl_attribute12
      ,p_appl_attribute13             => p_rec.appl_attribute13
      ,p_appl_attribute14             => p_rec.appl_attribute14
      ,p_appl_attribute15             => p_rec.appl_attribute15
      ,p_appl_attribute16             => p_rec.appl_attribute16
      ,p_appl_attribute17             => p_rec.appl_attribute17
      ,p_appl_attribute18             => p_rec.appl_attribute18
      ,p_appl_attribute19             => p_rec.appl_attribute19
      ,p_appl_attribute20             => p_rec.appl_attribute20
      ,p_object_version_number        => p_rec.object_version_number
      ,p_effective_date               => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_APPLICATIONS'
        ,p_hook_type   => 'AI'
        );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_apl_shd.g_rec_type,
  p_effective_date in date,
  p_validate       in     boolean default false,
  p_validate_df_flex in   boolean default true --4689836
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
    SAVEPOINT ins_per_apl;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_apl_bus.insert_validate(p_rec
			     ,p_effective_date
			     ,false); --risgupta
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
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
  post_insert(p_rec
             ,p_effective_date);
  --
  -- Call to raise any errors on multi-message list
  --
  hr_multi_message.end_validation_set;
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
    ROLLBACK TO ins_per_apl;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_application_id               out nocopy number,
  p_business_group_id            in number,
  p_person_id                    in number,
  p_date_received                in date,
  p_comments                     in varchar2         default null,
  p_current_employer             in varchar2         default null,
  p_projected_hire_date          in date             default null,
  p_successful_flag              in varchar2         default null,
  p_termination_reason           in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_appl_attribute_category      in varchar2         default null,
  p_appl_attribute1              in varchar2         default null,
  p_appl_attribute2              in varchar2         default null,
  p_appl_attribute3              in varchar2         default null,
  p_appl_attribute4              in varchar2         default null,
  p_appl_attribute5              in varchar2         default null,
  p_appl_attribute6              in varchar2         default null,
  p_appl_attribute7              in varchar2         default null,
  p_appl_attribute8              in varchar2         default null,
  p_appl_attribute9              in varchar2         default null,
  p_appl_attribute10             in varchar2         default null,
  p_appl_attribute11             in varchar2         default null,
  p_appl_attribute12             in varchar2         default null,
  p_appl_attribute13             in varchar2         default null,
  p_appl_attribute14             in varchar2         default null,
  p_appl_attribute15             in varchar2         default null,
  p_appl_attribute16             in varchar2         default null,
  p_appl_attribute17             in varchar2         default null,
  p_appl_attribute18             in varchar2         default null,
  p_appl_attribute19             in varchar2         default null,
  p_appl_attribute20             in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date               in date,
  p_validate                     in boolean   default false,
  p_validate_df_flex             in   boolean default true --4689836
  ) is
--
  l_rec	  per_apl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_apl_shd.convert_args
  (
  null,
  p_business_group_id,
  p_person_id,
  p_date_received,
  p_comments,
  p_current_employer,
  null,
  p_projected_hire_date,
  p_successful_flag,
  p_termination_reason,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_appl_attribute_category,
  p_appl_attribute1,
  p_appl_attribute2,
  p_appl_attribute3,
  p_appl_attribute4,
  p_appl_attribute5,
  p_appl_attribute6,
  p_appl_attribute7,
  p_appl_attribute8,
  p_appl_attribute9,
  p_appl_attribute10,
  p_appl_attribute11,
  p_appl_attribute12,
  p_appl_attribute13,
  p_appl_attribute14,
  p_appl_attribute15,
  p_appl_attribute16,
  p_appl_attribute17,
  p_appl_attribute18,
  p_appl_attribute19,
  p_appl_attribute20,
  null
  );
  --
  -- Having converted the arguments into the per_apl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_application_id := l_rec.application_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_apl_ins;

/
