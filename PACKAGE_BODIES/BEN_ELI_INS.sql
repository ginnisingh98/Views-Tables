--------------------------------------------------------
--  DDL for Package Body BEN_ELI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELI_INS" as
/* $Header: beelirhi.pkb 115.1 2004/04/14 02:40:36 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_eli_ins.';  -- Global package name
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
--   A elp/Sql record structre.
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
--   Internal Table Handelp Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_eli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: ben_elp_extra_info
  --
  insert into ben_elp_extra_info
  (	elp_extra_info_id,
	information_type,
	eligy_prfl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	eli_attribute_category,
	eli_attribute1,
	eli_attribute2,
	eli_attribute3,
	eli_attribute4,
	eli_attribute5,
	eli_attribute6,
	eli_attribute7,
	eli_attribute8,
	eli_attribute9,
	eli_attribute10,
	eli_attribute11,
	eli_attribute12,
	eli_attribute13,
	eli_attribute14,
	eli_attribute15,
	eli_attribute16,
	eli_attribute17,
	eli_attribute18,
	eli_attribute19,
	eli_attribute20,
	eli_information_category,
	eli_information1,
	eli_information2,
	eli_information3,
	eli_information4,
	eli_information5,
	eli_information6,
	eli_information7,
	eli_information8,
	eli_information9,
	eli_information10,
	eli_information11,
	eli_information12,
	eli_information13,
	eli_information14,
	eli_information15,
	eli_information16,
	eli_information17,
	eli_information18,
	eli_information19,
	eli_information20,
	eli_information21,
	eli_information22,
	eli_information23,
	eli_information24,
	eli_information25,
	eli_information26,
	eli_information27,
	eli_information28,
	eli_information29,
	eli_information30,
	object_version_number
  )
  Values
  (	p_rec.elp_extra_info_id,
	p_rec.information_type,
	p_rec.eligy_prfl_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.eli_attribute_category,
	p_rec.eli_attribute1,
	p_rec.eli_attribute2,
	p_rec.eli_attribute3,
	p_rec.eli_attribute4,
	p_rec.eli_attribute5,
	p_rec.eli_attribute6,
	p_rec.eli_attribute7,
	p_rec.eli_attribute8,
	p_rec.eli_attribute9,
	p_rec.eli_attribute10,
	p_rec.eli_attribute11,
	p_rec.eli_attribute12,
	p_rec.eli_attribute13,
	p_rec.eli_attribute14,
	p_rec.eli_attribute15,
	p_rec.eli_attribute16,
	p_rec.eli_attribute17,
	p_rec.eli_attribute18,
	p_rec.eli_attribute19,
	p_rec.eli_attribute20,
	p_rec.eli_information_category,
	p_rec.eli_information1,
	p_rec.eli_information2,
	p_rec.eli_information3,
	p_rec.eli_information4,
	p_rec.eli_information5,
	p_rec.eli_information6,
	p_rec.eli_information7,
	p_rec.eli_information8,
	p_rec.eli_information9,
	p_rec.eli_information10,
	p_rec.eli_information11,
	p_rec.eli_information12,
	p_rec.eli_information13,
	p_rec.eli_information14,
	p_rec.eli_information15,
	p_rec.eli_information16,
	p_rec.eli_information17,
	p_rec.eli_information18,
	p_rec.eli_information19,
	p_rec.eli_information20,
	p_rec.eli_information21,
	p_rec.eli_information22,
	p_rec.eli_information23,
	p_rec.eli_information24,
	p_rec.eli_information25,
	p_rec.eli_information26,
	p_rec.eli_information27,
	p_rec.eli_information28,
	p_rec.eli_information29,
	p_rec.eli_information30,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_eli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_eli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_eli_shd.constraint_error
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
--   A elp/Sql record structre.
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
--   before elpacing in this procedure.
--
-- Access Status:
--   Internal Table Handelp Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_eli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_elp_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.elp_extra_info_id;
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
--   A elp/Sql record structre.
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
--   maintenance should be reviewed before elpacing in this procedure.
--
-- Access Status:
--   Internal Table Handelp Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_eli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ben_eli_rki.after_insert	(
	p_elp_extra_info_id		=>	p_rec.elp_extra_info_id		,
	p_information_type		=>	p_rec.information_type		,
	p_eligy_prfl_id				=>	p_rec.eligy_prfl_id			,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_eli_attribute_category	=>	p_rec.eli_attribute_category	,
	p_eli_attribute1			=>	p_rec.eli_attribute1	,
	p_eli_attribute2			=>	p_rec.eli_attribute2	,
	p_eli_attribute3			=>	p_rec.eli_attribute3	,
	p_eli_attribute4			=>	p_rec.eli_attribute4	,
	p_eli_attribute5			=>	p_rec.eli_attribute5	,
	p_eli_attribute6			=>	p_rec.eli_attribute6	,
	p_eli_attribute7			=>	p_rec.eli_attribute7	,
	p_eli_attribute8			=>	p_rec.eli_attribute8	,
	p_eli_attribute9			=>	p_rec.eli_attribute9	,
	p_eli_attribute10			=>	p_rec.eli_attribute10	,
	p_eli_attribute11			=>	p_rec.eli_attribute11	,
	p_eli_attribute12			=>	p_rec.eli_attribute12	,
	p_eli_attribute13			=>	p_rec.eli_attribute13	,
	p_eli_attribute14			=>	p_rec.eli_attribute14	,
	p_eli_attribute15			=>	p_rec.eli_attribute15	,
	p_eli_attribute16			=>	p_rec.eli_attribute16	,
	p_eli_attribute17			=>	p_rec.eli_attribute17	,
	p_eli_attribute18			=>	p_rec.eli_attribute18	,
	p_eli_attribute19			=>	p_rec.eli_attribute19	,
	p_eli_attribute20			=>	p_rec.eli_attribute20	,
	p_eli_information_category	=>	p_rec.eli_information_category	,
	p_eli_information1		=>	p_rec.eli_information1	,
	p_eli_information2		=>	p_rec.eli_information2	,
	p_eli_information3		=>	p_rec.eli_information3	,
	p_eli_information4		=>	p_rec.eli_information4	,
	p_eli_information5		=>	p_rec.eli_information5	,
	p_eli_information6		=>	p_rec.eli_information6	,
	p_eli_information7		=>	p_rec.eli_information7	,
	p_eli_information8		=>	p_rec.eli_information8	,
	p_eli_information9		=>	p_rec.eli_information9	,
	p_eli_information10		=>	p_rec.eli_information10	,
	p_eli_information11		=>	p_rec.eli_information11	,
	p_eli_information12		=>	p_rec.eli_information12	,
	p_eli_information13		=>	p_rec.eli_information13	,
	p_eli_information14		=>	p_rec.eli_information14	,
	p_eli_information15		=>	p_rec.eli_information15	,
	p_eli_information16		=>	p_rec.eli_information16	,
	p_eli_information17		=>	p_rec.eli_information17	,
	p_eli_information18		=>	p_rec.eli_information18	,
	p_eli_information19		=>	p_rec.eli_information19	,
	p_eli_information20		=>	p_rec.eli_information20	,
	p_eli_information21		=>	p_rec.eli_information21	,
	p_eli_information22		=>	p_rec.eli_information22	,
	p_eli_information23		=>	p_rec.eli_information23	,
	p_eli_information24		=>	p_rec.eli_information24	,
	p_eli_information25		=>	p_rec.eli_information25	,
	p_eli_information26		=>	p_rec.eli_information26	,
	p_eli_information27		=>	p_rec.eli_information27	,
	p_eli_information28		=>	p_rec.eli_information28	,
	p_eli_information29		=>	p_rec.eli_information29	,
	p_eli_information30		=>	p_rec.eli_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'BEN_ELP_EXTRA_INFO'
			,p_hook_type  => 'AI'
	        );
  end;
  -- End of API User Hook for post_insert.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ben_eli_shd.g_rec_type,
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
    SAVEPOINT ins_ben_eli;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ben_eli_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ben_eli;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_elp_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_eligy_prfl_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_eli_attribute_category       in varchar2         default null,
  p_eli_attribute1               in varchar2         default null,
  p_eli_attribute2               in varchar2         default null,
  p_eli_attribute3               in varchar2         default null,
  p_eli_attribute4               in varchar2         default null,
  p_eli_attribute5               in varchar2         default null,
  p_eli_attribute6               in varchar2         default null,
  p_eli_attribute7               in varchar2         default null,
  p_eli_attribute8               in varchar2         default null,
  p_eli_attribute9               in varchar2         default null,
  p_eli_attribute10              in varchar2         default null,
  p_eli_attribute11              in varchar2         default null,
  p_eli_attribute12              in varchar2         default null,
  p_eli_attribute13              in varchar2         default null,
  p_eli_attribute14              in varchar2         default null,
  p_eli_attribute15              in varchar2         default null,
  p_eli_attribute16              in varchar2         default null,
  p_eli_attribute17              in varchar2         default null,
  p_eli_attribute18              in varchar2         default null,
  p_eli_attribute19              in varchar2         default null,
  p_eli_attribute20              in varchar2         default null,
  p_eli_information_category     in varchar2         default null,
  p_eli_information1             in varchar2         default null,
  p_eli_information2             in varchar2         default null,
  p_eli_information3             in varchar2         default null,
  p_eli_information4             in varchar2         default null,
  p_eli_information5             in varchar2         default null,
  p_eli_information6             in varchar2         default null,
  p_eli_information7             in varchar2         default null,
  p_eli_information8             in varchar2         default null,
  p_eli_information9             in varchar2         default null,
  p_eli_information10            in varchar2         default null,
  p_eli_information11            in varchar2         default null,
  p_eli_information12            in varchar2         default null,
  p_eli_information13            in varchar2         default null,
  p_eli_information14            in varchar2         default null,
  p_eli_information15            in varchar2         default null,
  p_eli_information16            in varchar2         default null,
  p_eli_information17            in varchar2         default null,
  p_eli_information18            in varchar2         default null,
  p_eli_information19            in varchar2         default null,
  p_eli_information20            in varchar2         default null,
  p_eli_information21            in varchar2         default null,
  p_eli_information22            in varchar2         default null,
  p_eli_information23            in varchar2         default null,
  p_eli_information24            in varchar2         default null,
  p_eli_information25            in varchar2         default null,
  p_eli_information26            in varchar2         default null,
  p_eli_information27            in varchar2         default null,
  p_eli_information28            in varchar2         default null,
  p_eli_information29            in varchar2         default null,
  p_eli_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ben_eli_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_eli_shd.convert_args
  (
  null,
  p_information_type,
  p_eligy_prfl_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_eli_attribute_category,
  p_eli_attribute1,
  p_eli_attribute2,
  p_eli_attribute3,
  p_eli_attribute4,
  p_eli_attribute5,
  p_eli_attribute6,
  p_eli_attribute7,
  p_eli_attribute8,
  p_eli_attribute9,
  p_eli_attribute10,
  p_eli_attribute11,
  p_eli_attribute12,
  p_eli_attribute13,
  p_eli_attribute14,
  p_eli_attribute15,
  p_eli_attribute16,
  p_eli_attribute17,
  p_eli_attribute18,
  p_eli_attribute19,
  p_eli_attribute20,
  p_eli_information_category,
  p_eli_information1,
  p_eli_information2,
  p_eli_information3,
  p_eli_information4,
  p_eli_information5,
  p_eli_information6,
  p_eli_information7,
  p_eli_information8,
  p_eli_information9,
  p_eli_information10,
  p_eli_information11,
  p_eli_information12,
  p_eli_information13,
  p_eli_information14,
  p_eli_information15,
  p_eli_information16,
  p_eli_information17,
  p_eli_information18,
  p_eli_information19,
  p_eli_information20,
  p_eli_information21,
  p_eli_information22,
  p_eli_information23,
  p_eli_information24,
  p_eli_information25,
  p_eli_information26,
  p_eli_information27,
  p_eli_information28,
  p_eli_information29,
  p_eli_information30,
  null
  );
  --
  -- Having converted the arguments into the ben_eli_rec
  -- elpsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_elp_extra_info_id := l_rec.elp_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_eli_ins;

/
