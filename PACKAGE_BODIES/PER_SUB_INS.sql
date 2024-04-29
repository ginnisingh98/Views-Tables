--------------------------------------------------------
--  DDL for Package Body PER_SUB_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUB_INS" as
/* $Header: pesubrhi.pkb 115.14 2004/02/23 01:47:08 smparame ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sub_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy per_sub_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  per_sub_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_subjects_taken
  --
  insert into per_subjects_taken
  (	subjects_taken_id,
	start_date,
	major,
	subject_status,
	subject,
	grade_attained,
	end_date,
	qualification_id,
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
	sub_information_category,
	sub_information1,
	sub_information2,
	sub_information3,
	sub_information4,
	sub_information5,
	sub_information6,
	sub_information7,
	sub_information8,
	sub_information9,
	sub_information10,
	sub_information11,
	sub_information12,
	sub_information13,
	sub_information14,
	sub_information15,
	sub_information16,
	sub_information17,
	sub_information18,
	sub_information19,
	sub_information20
  )
  Values
  (	p_rec.subjects_taken_id,
	p_rec.start_date,
	p_rec.major,
	p_rec.subject_status,
	p_rec.subject,
	p_rec.grade_attained,
	p_rec.end_date,
	p_rec.qualification_id,
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
	p_rec.sub_information_category,
	p_rec.sub_information1,
	p_rec.sub_information2,
	p_rec.sub_information3,
	p_rec.sub_information4,
	p_rec.sub_information5,
	p_rec.sub_information6,
	p_rec.sub_information7,
	p_rec.sub_information8,
	p_rec.sub_information9,
	p_rec.sub_information10,
	p_rec.sub_information11,
	p_rec.sub_information12,
	p_rec.sub_information13,
	p_rec.sub_information14,
	p_rec.sub_information15,
	p_rec.sub_information16,
	p_rec.sub_information17,
	p_rec.sub_information18,
	p_rec.sub_information19,
	p_rec.sub_information20

  );
  --
  per_sub_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_sub_shd.g_api_dml := false;   -- Unset the api dml status
    per_sub_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_sub_shd.g_api_dml := false;   -- Unset the api dml status
    per_sub_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_sub_shd.g_api_dml := false;   -- Unset the api dml status
    per_sub_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_sub_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy per_sub_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_subjects_taken_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.subjects_taken_id;
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
Procedure post_insert(p_rec             in per_sub_shd.g_rec_type,
                      p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of Row Handler User Hook for post_insert.
  --
  Begin
    per_sub_rki.after_insert
      (
      p_subjects_taken_id            => p_rec.subjects_taken_id,
      p_start_date                   => p_rec.start_date,
      p_major                        => p_rec.major,
      p_subject_status               => p_rec.subject_status,
      p_subject                      => p_rec.subject,
      p_grade_attained               => p_rec.grade_attained,
      p_end_date                     => p_rec.end_date,
      p_qualification_id             => p_rec.qualification_id,
      p_object_version_number        => p_rec.object_version_number,
      p_attribute_category           => p_rec.attribute_category,
      p_attribute1                   => p_rec.attribute1,
      p_attribute2                   => p_rec.attribute2,
      p_attribute3                   => p_rec.attribute3,
      p_attribute4                   => p_rec.attribute4,
      p_attribute5                   => p_rec.attribute5,
      p_attribute6                   => p_rec.attribute6,
      p_attribute7                   => p_rec.attribute7,
      p_attribute8                   => p_rec.attribute8,
      p_attribute9                   => p_rec.attribute9,
      p_attribute10                  => p_rec.attribute10,
      p_attribute11                  => p_rec.attribute11,
      p_attribute12                  => p_rec.attribute12,
      p_attribute13                  => p_rec.attribute13,
      p_attribute14                  => p_rec.attribute14,
      p_attribute15                  => p_rec.attribute15,
      p_attribute16                  => p_rec.attribute16,
      p_attribute17                  => p_rec.attribute17,
      p_attribute18                  => p_rec.attribute18,
      p_attribute19                  => p_rec.attribute19,
      p_attribute20                  => p_rec.attribute20,
      p_sub_information_category           => p_rec.sub_information_category,
      p_sub_information1                   => p_rec.sub_information1,
      p_sub_information2                   => p_rec.sub_information2,
      p_sub_information3                   => p_rec.sub_information3,
      p_sub_information4                   => p_rec.sub_information4,
      p_sub_information5                   => p_rec.sub_information5,
      p_sub_information6                   => p_rec.sub_information6,
      p_sub_information7                   => p_rec.sub_information7,
      p_sub_information8                   => p_rec.sub_information8,
      p_sub_information9                   => p_rec.sub_information9,
      p_sub_information10                  => p_rec.sub_information10,
      p_sub_information11                  => p_rec.sub_information11,
      p_sub_information12                  => p_rec.sub_information12,
      p_sub_information13                  => p_rec.sub_information13,
      p_sub_information14                  => p_rec.sub_information14,
      p_sub_information15                  => p_rec.sub_information15,
      p_sub_information16                  => p_rec.sub_information16,
      p_sub_information17                  => p_rec.sub_information17,
      p_sub_information18                  => p_rec.sub_information18,
      p_sub_information19                  => p_rec.sub_information19,
      p_sub_information20                  => p_rec.sub_information20,
      p_effective_date               => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SUBJECTS_TAKEN'
        ,p_hook_type   => 'AI'
        );
  end;
  --
  -- End of Row Handler User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_sub_shd.g_rec_type,
  p_effective_date in     date,
  p_validate       in     boolean default false
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
    SAVEPOINT ins_sub;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  per_sub_bus.insert_validate(p_rec,p_effective_date);
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
    ROLLBACK TO ins_sub;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_subjects_taken_id            out nocopy number,
  p_start_date                   in date,
  p_major                        in varchar2,
  p_subject_status               in varchar2,
  p_subject                      in varchar2,
  p_grade_attained               in varchar2         default null,
  p_end_date                     in date             default null,
  p_qualification_id             in number,
  p_object_version_number        out nocopy number,
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
	p_sub_information_category            in varchar2 default null,
	p_sub_information1                    in varchar2 default null,
	p_sub_information2                    in varchar2 default null,
	p_sub_information3                    in varchar2 default null,
	p_sub_information4                    in varchar2 default null,
	p_sub_information5                    in varchar2 default null,
	p_sub_information6                    in varchar2 default null,
	p_sub_information7                    in varchar2 default null,
	p_sub_information8                    in varchar2 default null,
	p_sub_information9                    in varchar2 default null,
	p_sub_information10                   in varchar2 default null,
	p_sub_information11                   in varchar2 default null,
	p_sub_information12                   in varchar2 default null,
	p_sub_information13                   in varchar2 default null,
	p_sub_information14                   in varchar2 default null,
	p_sub_information15                   in varchar2 default null,
	p_sub_information16                   in varchar2 default null,
	p_sub_information17                   in varchar2 default null,
	p_sub_information18                   in varchar2 default null,
	p_sub_information19                   in varchar2 default null,
	p_sub_information20                   in varchar2 default null,
  p_effective_date               in date,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  per_sub_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_sub_shd.convert_args
  (
  null,
  p_start_date,
  p_major,
  p_subject_status,
  p_subject,
  p_grade_attained,
  p_end_date,
  p_qualification_id,
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
	p_sub_information_category,
	p_sub_information1,
	p_sub_information2,
	p_sub_information3,
	p_sub_information4,
	p_sub_information5,
	p_sub_information6,
	p_sub_information7,
	p_sub_information8,
	p_sub_information9,
	p_sub_information10,
	p_sub_information11,
	p_sub_information12,
	p_sub_information13,
	p_sub_information14,
	p_sub_information15,
	p_sub_information16,
	p_sub_information17,
	p_sub_information18,
	p_sub_information19,
	p_sub_information20
  );
  --
  -- Having converted the arguments into the sub_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_subjects_taken_id := l_rec.subjects_taken_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_sub_ins;

/
