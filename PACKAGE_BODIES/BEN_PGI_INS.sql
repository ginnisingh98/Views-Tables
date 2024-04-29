--------------------------------------------------------
--  DDL for Package Body BEN_PGI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGI_INS" as
/* $Header: bepgirhi.pkb 115.0 2003/09/23 10:19:40 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pgi_ins.';  -- Global package name
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
--   A pgm/Sql record structre.
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
--   Internal Table Handpgm Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_pgi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: ben_pgm_extra_info
  --
  insert into ben_pgm_extra_info
  (	pgm_extra_info_id,
	information_type,
	pgm_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pgi_attribute_category,
	pgi_attribute1,
	pgi_attribute2,
	pgi_attribute3,
	pgi_attribute4,
	pgi_attribute5,
	pgi_attribute6,
	pgi_attribute7,
	pgi_attribute8,
	pgi_attribute9,
	pgi_attribute10,
	pgi_attribute11,
	pgi_attribute12,
	pgi_attribute13,
	pgi_attribute14,
	pgi_attribute15,
	pgi_attribute16,
	pgi_attribute17,
	pgi_attribute18,
	pgi_attribute19,
	pgi_attribute20,
	pgi_information_category,
	pgi_information1,
	pgi_information2,
	pgi_information3,
	pgi_information4,
	pgi_information5,
	pgi_information6,
	pgi_information7,
	pgi_information8,
	pgi_information9,
	pgi_information10,
	pgi_information11,
	pgi_information12,
	pgi_information13,
	pgi_information14,
	pgi_information15,
	pgi_information16,
	pgi_information17,
	pgi_information18,
	pgi_information19,
	pgi_information20,
	pgi_information21,
	pgi_information22,
	pgi_information23,
	pgi_information24,
	pgi_information25,
	pgi_information26,
	pgi_information27,
	pgi_information28,
	pgi_information29,
	pgi_information30,
	object_version_number
  )
  Values
  (	p_rec.pgm_extra_info_id,
	p_rec.information_type,
	p_rec.pgm_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.pgi_attribute_category,
	p_rec.pgi_attribute1,
	p_rec.pgi_attribute2,
	p_rec.pgi_attribute3,
	p_rec.pgi_attribute4,
	p_rec.pgi_attribute5,
	p_rec.pgi_attribute6,
	p_rec.pgi_attribute7,
	p_rec.pgi_attribute8,
	p_rec.pgi_attribute9,
	p_rec.pgi_attribute10,
	p_rec.pgi_attribute11,
	p_rec.pgi_attribute12,
	p_rec.pgi_attribute13,
	p_rec.pgi_attribute14,
	p_rec.pgi_attribute15,
	p_rec.pgi_attribute16,
	p_rec.pgi_attribute17,
	p_rec.pgi_attribute18,
	p_rec.pgi_attribute19,
	p_rec.pgi_attribute20,
	p_rec.pgi_information_category,
	p_rec.pgi_information1,
	p_rec.pgi_information2,
	p_rec.pgi_information3,
	p_rec.pgi_information4,
	p_rec.pgi_information5,
	p_rec.pgi_information6,
	p_rec.pgi_information7,
	p_rec.pgi_information8,
	p_rec.pgi_information9,
	p_rec.pgi_information10,
	p_rec.pgi_information11,
	p_rec.pgi_information12,
	p_rec.pgi_information13,
	p_rec.pgi_information14,
	p_rec.pgi_information15,
	p_rec.pgi_information16,
	p_rec.pgi_information17,
	p_rec.pgi_information18,
	p_rec.pgi_information19,
	p_rec.pgi_information20,
	p_rec.pgi_information21,
	p_rec.pgi_information22,
	p_rec.pgi_information23,
	p_rec.pgi_information24,
	p_rec.pgi_information25,
	p_rec.pgi_information26,
	p_rec.pgi_information27,
	p_rec.pgi_information28,
	p_rec.pgi_information29,
	p_rec.pgi_information30,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pgi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQlERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pgi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQlERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pgi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQlERRM));
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
--   A pgm/Sql record structre.
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
--   before pgmacing in this procedure.
--
-- Access Status:
--   Internal Table Handpgm Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_pgi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pgm_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pgm_extra_info_id;
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
--   A pgm/Sql record structre.
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
--   maintenance should be reviewed before pgmacing in this procedure.
--
-- Access Status:
--   Internal Table Handpgm Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_pgi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ben_pgi_rki.after_insert	(
	p_pgm_extra_info_id		=>	p_rec.pgm_extra_info_id		,
	p_information_type		=>	p_rec.information_type		,
	p_pgm_id				=>	p_rec.pgm_id			,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_pgi_attribute_category	=>	p_rec.pgi_attribute_category	,
	p_pgi_attribute1			=>	p_rec.pgi_attribute1	,
	p_pgi_attribute2			=>	p_rec.pgi_attribute2	,
	p_pgi_attribute3			=>	p_rec.pgi_attribute3	,
	p_pgi_attribute4			=>	p_rec.pgi_attribute4	,
	p_pgi_attribute5			=>	p_rec.pgi_attribute5	,
	p_pgi_attribute6			=>	p_rec.pgi_attribute6	,
	p_pgi_attribute7			=>	p_rec.pgi_attribute7	,
	p_pgi_attribute8			=>	p_rec.pgi_attribute8	,
	p_pgi_attribute9			=>	p_rec.pgi_attribute9	,
	p_pgi_attribute10			=>	p_rec.pgi_attribute10	,
	p_pgi_attribute11			=>	p_rec.pgi_attribute11	,
	p_pgi_attribute12			=>	p_rec.pgi_attribute12	,
	p_pgi_attribute13			=>	p_rec.pgi_attribute13	,
	p_pgi_attribute14			=>	p_rec.pgi_attribute14	,
	p_pgi_attribute15			=>	p_rec.pgi_attribute15	,
	p_pgi_attribute16			=>	p_rec.pgi_attribute16	,
	p_pgi_attribute17			=>	p_rec.pgi_attribute17	,
	p_pgi_attribute18			=>	p_rec.pgi_attribute18	,
	p_pgi_attribute19			=>	p_rec.pgi_attribute19	,
	p_pgi_attribute20			=>	p_rec.pgi_attribute20	,
	p_pgi_information_category	=>	p_rec.pgi_information_category	,
	p_pgi_information1		=>	p_rec.pgi_information1	,
	p_pgi_information2		=>	p_rec.pgi_information2	,
	p_pgi_information3		=>	p_rec.pgi_information3	,
	p_pgi_information4		=>	p_rec.pgi_information4	,
	p_pgi_information5		=>	p_rec.pgi_information5	,
	p_pgi_information6		=>	p_rec.pgi_information6	,
	p_pgi_information7		=>	p_rec.pgi_information7	,
	p_pgi_information8		=>	p_rec.pgi_information8	,
	p_pgi_information9		=>	p_rec.pgi_information9	,
	p_pgi_information10		=>	p_rec.pgi_information10	,
	p_pgi_information11		=>	p_rec.pgi_information11	,
	p_pgi_information12		=>	p_rec.pgi_information12	,
	p_pgi_information13		=>	p_rec.pgi_information13	,
	p_pgi_information14		=>	p_rec.pgi_information14	,
	p_pgi_information15		=>	p_rec.pgi_information15	,
	p_pgi_information16		=>	p_rec.pgi_information16	,
	p_pgi_information17		=>	p_rec.pgi_information17	,
	p_pgi_information18		=>	p_rec.pgi_information18	,
	p_pgi_information19		=>	p_rec.pgi_information19	,
	p_pgi_information20		=>	p_rec.pgi_information20	,
	p_pgi_information21		=>	p_rec.pgi_information21	,
	p_pgi_information22		=>	p_rec.pgi_information22	,
	p_pgi_information23		=>	p_rec.pgi_information23	,
	p_pgi_information24		=>	p_rec.pgi_information24	,
	p_pgi_information25		=>	p_rec.pgi_information25	,
	p_pgi_information26		=>	p_rec.pgi_information26	,
	p_pgi_information27		=>	p_rec.pgi_information27	,
	p_pgi_information28		=>	p_rec.pgi_information28	,
	p_pgi_information29		=>	p_rec.pgi_information29	,
	p_pgi_information30		=>	p_rec.pgi_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'BEN_pgm_EXTRA_INFO'
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
  p_rec        in out nocopy ben_pgi_shd.g_rec_type,
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
    SAVEPOINT ins_ben_pgi;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ben_pgi_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ben_pgi;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pgm_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_pgm_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_pgi_attribute_category       in varchar2         default null,
  p_pgi_attribute1               in varchar2         default null,
  p_pgi_attribute2               in varchar2         default null,
  p_pgi_attribute3               in varchar2         default null,
  p_pgi_attribute4               in varchar2         default null,
  p_pgi_attribute5               in varchar2         default null,
  p_pgi_attribute6               in varchar2         default null,
  p_pgi_attribute7               in varchar2         default null,
  p_pgi_attribute8               in varchar2         default null,
  p_pgi_attribute9               in varchar2         default null,
  p_pgi_attribute10              in varchar2         default null,
  p_pgi_attribute11              in varchar2         default null,
  p_pgi_attribute12              in varchar2         default null,
  p_pgi_attribute13              in varchar2         default null,
  p_pgi_attribute14              in varchar2         default null,
  p_pgi_attribute15              in varchar2         default null,
  p_pgi_attribute16              in varchar2         default null,
  p_pgi_attribute17              in varchar2         default null,
  p_pgi_attribute18              in varchar2         default null,
  p_pgi_attribute19              in varchar2         default null,
  p_pgi_attribute20              in varchar2         default null,
  p_pgi_information_category     in varchar2         default null,
  p_pgi_information1             in varchar2         default null,
  p_pgi_information2             in varchar2         default null,
  p_pgi_information3             in varchar2         default null,
  p_pgi_information4             in varchar2         default null,
  p_pgi_information5             in varchar2         default null,
  p_pgi_information6             in varchar2         default null,
  p_pgi_information7             in varchar2         default null,
  p_pgi_information8             in varchar2         default null,
  p_pgi_information9             in varchar2         default null,
  p_pgi_information10            in varchar2         default null,
  p_pgi_information11            in varchar2         default null,
  p_pgi_information12            in varchar2         default null,
  p_pgi_information13            in varchar2         default null,
  p_pgi_information14            in varchar2         default null,
  p_pgi_information15            in varchar2         default null,
  p_pgi_information16            in varchar2         default null,
  p_pgi_information17            in varchar2         default null,
  p_pgi_information18            in varchar2         default null,
  p_pgi_information19            in varchar2         default null,
  p_pgi_information20            in varchar2         default null,
  p_pgi_information21            in varchar2         default null,
  p_pgi_information22            in varchar2         default null,
  p_pgi_information23            in varchar2         default null,
  p_pgi_information24            in varchar2         default null,
  p_pgi_information25            in varchar2         default null,
  p_pgi_information26            in varchar2         default null,
  p_pgi_information27            in varchar2         default null,
  p_pgi_information28            in varchar2         default null,
  p_pgi_information29            in varchar2         default null,
  p_pgi_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ben_pgi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pgi_shd.convert_args
  (
  null,
  p_information_type,
  p_pgm_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_pgi_attribute_category,
  p_pgi_attribute1,
  p_pgi_attribute2,
  p_pgi_attribute3,
  p_pgi_attribute4,
  p_pgi_attribute5,
  p_pgi_attribute6,
  p_pgi_attribute7,
  p_pgi_attribute8,
  p_pgi_attribute9,
  p_pgi_attribute10,
  p_pgi_attribute11,
  p_pgi_attribute12,
  p_pgi_attribute13,
  p_pgi_attribute14,
  p_pgi_attribute15,
  p_pgi_attribute16,
  p_pgi_attribute17,
  p_pgi_attribute18,
  p_pgi_attribute19,
  p_pgi_attribute20,
  p_pgi_information_category,
  p_pgi_information1,
  p_pgi_information2,
  p_pgi_information3,
  p_pgi_information4,
  p_pgi_information5,
  p_pgi_information6,
  p_pgi_information7,
  p_pgi_information8,
  p_pgi_information9,
  p_pgi_information10,
  p_pgi_information11,
  p_pgi_information12,
  p_pgi_information13,
  p_pgi_information14,
  p_pgi_information15,
  p_pgi_information16,
  p_pgi_information17,
  p_pgi_information18,
  p_pgi_information19,
  p_pgi_information20,
  p_pgi_information21,
  p_pgi_information22,
  p_pgi_information23,
  p_pgi_information24,
  p_pgi_information25,
  p_pgi_information26,
  p_pgi_information27,
  p_pgi_information28,
  p_pgi_information29,
  p_pgi_information30,
  null
  );
  --
  -- Having converted the arguments into the ben_pgi_rec
  -- pgmsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pgm_extra_info_id := l_rec.pgm_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pgi_ins;

/
