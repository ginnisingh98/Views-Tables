--------------------------------------------------------
--  DDL for Package Body PE_AEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_AEI_INS" as
/* $Header: peaeirhi.pkb 115.8 2002/12/03 15:36:45 raranjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_aei_ins.';  -- Global package name
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: per_assignment_extra_info
  --
  insert into per_assignment_extra_info
  (	assignment_extra_info_id,
	assignment_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	aei_attribute_category,
	aei_attribute1,
	aei_attribute2,
	aei_attribute3,
	aei_attribute4,
	aei_attribute5,
	aei_attribute6,
	aei_attribute7,
	aei_attribute8,
	aei_attribute9,
	aei_attribute10,
	aei_attribute11,
	aei_attribute12,
	aei_attribute13,
	aei_attribute14,
	aei_attribute15,
	aei_attribute16,
	aei_attribute17,
	aei_attribute18,
	aei_attribute19,
	aei_attribute20,
	aei_information_category,
	aei_information1,
	aei_information2,
	aei_information3,
	aei_information4,
	aei_information5,
	aei_information6,
	aei_information7,
	aei_information8,
	aei_information9,
	aei_information10,
	aei_information11,
	aei_information12,
	aei_information13,
	aei_information14,
	aei_information15,
	aei_information16,
	aei_information17,
	aei_information18,
	aei_information19,
	aei_information20,
	aei_information21,
	aei_information22,
	aei_information23,
	aei_information24,
	aei_information25,
	aei_information26,
	aei_information27,
	aei_information28,
	aei_information29,
	aei_information30,
	object_version_number
  )
  Values
  (	p_rec.assignment_extra_info_id,
	p_rec.assignment_id,
	p_rec.information_type,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.aei_attribute_category,
	p_rec.aei_attribute1,
	p_rec.aei_attribute2,
	p_rec.aei_attribute3,
	p_rec.aei_attribute4,
	p_rec.aei_attribute5,
	p_rec.aei_attribute6,
	p_rec.aei_attribute7,
	p_rec.aei_attribute8,
	p_rec.aei_attribute9,
	p_rec.aei_attribute10,
	p_rec.aei_attribute11,
	p_rec.aei_attribute12,
	p_rec.aei_attribute13,
	p_rec.aei_attribute14,
	p_rec.aei_attribute15,
	p_rec.aei_attribute16,
	p_rec.aei_attribute17,
	p_rec.aei_attribute18,
	p_rec.aei_attribute19,
	p_rec.aei_attribute20,
	p_rec.aei_information_category,
	p_rec.aei_information1,
	p_rec.aei_information2,
	p_rec.aei_information3,
	p_rec.aei_information4,
	p_rec.aei_information5,
	p_rec.aei_information6,
	p_rec.aei_information7,
	p_rec.aei_information8,
	p_rec.aei_information9,
	p_rec.aei_information10,
	p_rec.aei_information11,
	p_rec.aei_information12,
	p_rec.aei_information13,
	p_rec.aei_information14,
	p_rec.aei_information15,
	p_rec.aei_information16,
	p_rec.aei_information17,
	p_rec.aei_information18,
	p_rec.aei_information19,
	p_rec.aei_information20,
	p_rec.aei_information21,
	p_rec.aei_information22,
	p_rec.aei_information23,
	p_rec.aei_information24,
	p_rec.aei_information25,
	p_rec.aei_information26,
	p_rec.aei_information27,
	p_rec.aei_information28,
	p_rec.aei_information29,
	p_rec.aei_information30,
	p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pe_aei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pe_aei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pe_aei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_assignment_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.assignment_extra_info_id;
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
Procedure post_insert(p_rec in pe_aei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     pe_aei_rki.after_insert	(
	p_assignment_extra_info_id	=>	p_rec.assignment_extra_info_id	,
	p_assignment_id			=>	p_rec.assignment_id			,
	p_information_type		=>	p_rec.information_type			,
	p_request_id			=>	p_rec.request_id				,
	p_program_application_id	=>	p_rec.program_application_id		,
	p_program_id			=>	p_rec.program_id				,
	p_program_update_date		=>	p_rec.program_update_date		,
	p_aei_attribute_category	=>	p_rec.aei_attribute_category		,
	p_aei_attribute1			=>	p_rec.aei_attribute1			,
	p_aei_attribute2			=>	p_rec.aei_attribute2			,
	p_aei_attribute3			=>	p_rec.aei_attribute3			,
	p_aei_attribute4			=>	p_rec.aei_attribute4			,
	p_aei_attribute5			=>	p_rec.aei_attribute5			,
	p_aei_attribute6			=>	p_rec.aei_attribute6			,
	p_aei_attribute7			=>	p_rec.aei_attribute7			,
	p_aei_attribute8			=>	p_rec.aei_attribute8			,
	p_aei_attribute9			=>	p_rec.aei_attribute9			,
	p_aei_attribute10			=>	p_rec.aei_attribute10			,
	p_aei_attribute11			=>	p_rec.aei_attribute11			,
	p_aei_attribute12			=>	p_rec.aei_attribute12			,
	p_aei_attribute13			=>	p_rec.aei_attribute13			,
	p_aei_attribute14			=>	p_rec.aei_attribute14			,
	p_aei_attribute15			=>	p_rec.aei_attribute15			,
	p_aei_attribute16			=>	p_rec.aei_attribute16			,
	p_aei_attribute17			=>	p_rec.aei_attribute17			,
	p_aei_attribute18			=>	p_rec.aei_attribute18			,
	p_aei_attribute19			=>	p_rec.aei_attribute19			,
	p_aei_attribute20			=>	p_rec.aei_attribute20			,
	p_aei_information_category	=>	p_rec.aei_information_category	,
	p_aei_information1		=>	p_rec.aei_information1	,
	p_aei_information2		=>	p_rec.aei_information2	,
	p_aei_information3		=>	p_rec.aei_information3	,
	p_aei_information4		=>	p_rec.aei_information4	,
	p_aei_information5		=>	p_rec.aei_information5	,
	p_aei_information6		=>	p_rec.aei_information6	,
	p_aei_information7		=>	p_rec.aei_information7	,
	p_aei_information8		=>	p_rec.aei_information8	,
	p_aei_information9		=>	p_rec.aei_information9	,
	p_aei_information10		=>	p_rec.aei_information10	,
	p_aei_information11		=>	p_rec.aei_information11	,
	p_aei_information12		=>	p_rec.aei_information12	,
	p_aei_information13		=>	p_rec.aei_information13	,
	p_aei_information14		=>	p_rec.aei_information14	,
	p_aei_information15		=>	p_rec.aei_information15	,
	p_aei_information16		=>	p_rec.aei_information16	,
	p_aei_information17		=>	p_rec.aei_information17	,
	p_aei_information18		=>	p_rec.aei_information18	,
	p_aei_information19		=>	p_rec.aei_information19	,
	p_aei_information20		=>	p_rec.aei_information20	,
	p_aei_information21		=>	p_rec.aei_information21	,
	p_aei_information22		=>	p_rec.aei_information22	,
	p_aei_information23		=>	p_rec.aei_information23	,
	p_aei_information24		=>	p_rec.aei_information24	,
	p_aei_information25		=>	p_rec.aei_information25	,
	p_aei_information26		=>	p_rec.aei_information26	,
	p_aei_information27		=>	p_rec.aei_information27	,
	p_aei_information28		=>	p_rec.aei_information28	,
	p_aei_information29		=>	p_rec.aei_information29	,
	p_aei_information30		=>	p_rec.aei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_ASSIGNMENT_EXTRA_INFO'
			,p_hook_type  => 'AI'
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
  p_rec        in out nocopy pe_aei_shd.g_rec_type,
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
    SAVEPOINT ins_pe_aei;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  pe_aei_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_pe_aei;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_assignment_extra_info_id     out nocopy number,
  p_assignment_id                in number,
  p_information_type             in varchar2,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_aei_attribute_category       in varchar2         default null,
  p_aei_attribute1               in varchar2         default null,
  p_aei_attribute2               in varchar2         default null,
  p_aei_attribute3               in varchar2         default null,
  p_aei_attribute4               in varchar2         default null,
  p_aei_attribute5               in varchar2         default null,
  p_aei_attribute6               in varchar2         default null,
  p_aei_attribute7               in varchar2         default null,
  p_aei_attribute8               in varchar2         default null,
  p_aei_attribute9               in varchar2         default null,
  p_aei_attribute10              in varchar2         default null,
  p_aei_attribute11              in varchar2         default null,
  p_aei_attribute12              in varchar2         default null,
  p_aei_attribute13              in varchar2         default null,
  p_aei_attribute14              in varchar2         default null,
  p_aei_attribute15              in varchar2         default null,
  p_aei_attribute16              in varchar2         default null,
  p_aei_attribute17              in varchar2         default null,
  p_aei_attribute18              in varchar2         default null,
  p_aei_attribute19              in varchar2         default null,
  p_aei_attribute20              in varchar2         default null,
  p_aei_information_category     in varchar2         default null,
  p_aei_information1             in varchar2         default null,
  p_aei_information2             in varchar2         default null,
  p_aei_information3             in varchar2         default null,
  p_aei_information4             in varchar2         default null,
  p_aei_information5             in varchar2         default null,
  p_aei_information6             in varchar2         default null,
  p_aei_information7             in varchar2         default null,
  p_aei_information8             in varchar2         default null,
  p_aei_information9             in varchar2         default null,
  p_aei_information10            in varchar2         default null,
  p_aei_information11            in varchar2         default null,
  p_aei_information12            in varchar2         default null,
  p_aei_information13            in varchar2         default null,
  p_aei_information14            in varchar2         default null,
  p_aei_information15            in varchar2         default null,
  p_aei_information16            in varchar2         default null,
  p_aei_information17            in varchar2         default null,
  p_aei_information18            in varchar2         default null,
  p_aei_information19            in varchar2         default null,
  p_aei_information20            in varchar2         default null,
  p_aei_information21            in varchar2         default null,
  p_aei_information22            in varchar2         default null,
  p_aei_information23            in varchar2         default null,
  p_aei_information24            in varchar2         default null,
  p_aei_information25            in varchar2         default null,
  p_aei_information26            in varchar2         default null,
  p_aei_information27            in varchar2         default null,
  p_aei_information28            in varchar2         default null,
  p_aei_information29            in varchar2         default null,
  p_aei_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  pe_aei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pe_aei_shd.convert_args
  (
  null,
  p_assignment_id,
  p_information_type,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_aei_attribute_category,
  p_aei_attribute1,
  p_aei_attribute2,
  p_aei_attribute3,
  p_aei_attribute4,
  p_aei_attribute5,
  p_aei_attribute6,
  p_aei_attribute7,
  p_aei_attribute8,
  p_aei_attribute9,
  p_aei_attribute10,
  p_aei_attribute11,
  p_aei_attribute12,
  p_aei_attribute13,
  p_aei_attribute14,
  p_aei_attribute15,
  p_aei_attribute16,
  p_aei_attribute17,
  p_aei_attribute18,
  p_aei_attribute19,
  p_aei_attribute20,
  p_aei_information_category,
  p_aei_information1,
  p_aei_information2,
  p_aei_information3,
  p_aei_information4,
  p_aei_information5,
  p_aei_information6,
  p_aei_information7,
  p_aei_information8,
  p_aei_information9,
  p_aei_information10,
  p_aei_information11,
  p_aei_information12,
  p_aei_information13,
  p_aei_information14,
  p_aei_information15,
  p_aei_information16,
  p_aei_information17,
  p_aei_information18,
  p_aei_information19,
  p_aei_information20,
  p_aei_information21,
  p_aei_information22,
  p_aei_information23,
  p_aei_information24,
  p_aei_information25,
  p_aei_information26,
  p_aei_information27,
  p_aei_information28,
  p_aei_information29,
  p_aei_information30,
  null
  );
  --
  -- Having converted the arguments into the pe_aei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_assignment_extra_info_id := l_rec.assignment_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pe_aei_ins;

/
