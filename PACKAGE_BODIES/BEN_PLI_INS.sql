--------------------------------------------------------
--  DDL for Package Body BEN_PLI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLI_INS" as
/* $Header: beplirhi.pkb 115.1 2003/09/24 00:02:28 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pli_ins.';  -- Global package name
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
--   A pl/Sql record structre.
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_pli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: ben_pl_extra_info
  --
  insert into ben_pl_extra_info
  (	pl_extra_info_id,
	information_type,
	pl_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pli_attribute_category,
	pli_attribute1,
	pli_attribute2,
	pli_attribute3,
	pli_attribute4,
	pli_attribute5,
	pli_attribute6,
	pli_attribute7,
	pli_attribute8,
	pli_attribute9,
	pli_attribute10,
	pli_attribute11,
	pli_attribute12,
	pli_attribute13,
	pli_attribute14,
	pli_attribute15,
	pli_attribute16,
	pli_attribute17,
	pli_attribute18,
	pli_attribute19,
	pli_attribute20,
	pli_information_category,
	pli_information1,
	pli_information2,
	pli_information3,
	pli_information4,
	pli_information5,
	pli_information6,
	pli_information7,
	pli_information8,
	pli_information9,
	pli_information10,
	pli_information11,
	pli_information12,
	pli_information13,
	pli_information14,
	pli_information15,
	pli_information16,
	pli_information17,
	pli_information18,
	pli_information19,
	pli_information20,
	pli_information21,
	pli_information22,
	pli_information23,
	pli_information24,
	pli_information25,
	pli_information26,
	pli_information27,
	pli_information28,
	pli_information29,
	pli_information30,
	object_version_number
  )
  Values
  (	p_rec.pl_extra_info_id,
	p_rec.information_type,
	p_rec.pl_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.pli_attribute_category,
	p_rec.pli_attribute1,
	p_rec.pli_attribute2,
	p_rec.pli_attribute3,
	p_rec.pli_attribute4,
	p_rec.pli_attribute5,
	p_rec.pli_attribute6,
	p_rec.pli_attribute7,
	p_rec.pli_attribute8,
	p_rec.pli_attribute9,
	p_rec.pli_attribute10,
	p_rec.pli_attribute11,
	p_rec.pli_attribute12,
	p_rec.pli_attribute13,
	p_rec.pli_attribute14,
	p_rec.pli_attribute15,
	p_rec.pli_attribute16,
	p_rec.pli_attribute17,
	p_rec.pli_attribute18,
	p_rec.pli_attribute19,
	p_rec.pli_attribute20,
	p_rec.pli_information_category,
	p_rec.pli_information1,
	p_rec.pli_information2,
	p_rec.pli_information3,
	p_rec.pli_information4,
	p_rec.pli_information5,
	p_rec.pli_information6,
	p_rec.pli_information7,
	p_rec.pli_information8,
	p_rec.pli_information9,
	p_rec.pli_information10,
	p_rec.pli_information11,
	p_rec.pli_information12,
	p_rec.pli_information13,
	p_rec.pli_information14,
	p_rec.pli_information15,
	p_rec.pli_information16,
	p_rec.pli_information17,
	p_rec.pli_information18,
	p_rec.pli_information19,
	p_rec.pli_information20,
	p_rec.pli_information21,
	p_rec.pli_information22,
	p_rec.pli_information23,
	p_rec.pli_information24,
	p_rec.pli_information25,
	p_rec.pli_information26,
	p_rec.pli_information27,
	p_rec.pli_information28,
	p_rec.pli_information29,
	p_rec.pli_information30,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pli_shd.constraint_error
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
--   A pl/Sql record structre.
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_pli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pl_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pl_extra_info_id;
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
--   A pl/Sql record structre.
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
--   Internal Table Handpl Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_pli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ben_pli_rki.after_insert	(
	p_pl_extra_info_id		=>	p_rec.pl_extra_info_id		,
	p_information_type		=>	p_rec.information_type		,
	p_pl_id				=>	p_rec.pl_id			,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_pli_attribute_category	=>	p_rec.pli_attribute_category	,
	p_pli_attribute1			=>	p_rec.pli_attribute1	,
	p_pli_attribute2			=>	p_rec.pli_attribute2	,
	p_pli_attribute3			=>	p_rec.pli_attribute3	,
	p_pli_attribute4			=>	p_rec.pli_attribute4	,
	p_pli_attribute5			=>	p_rec.pli_attribute5	,
	p_pli_attribute6			=>	p_rec.pli_attribute6	,
	p_pli_attribute7			=>	p_rec.pli_attribute7	,
	p_pli_attribute8			=>	p_rec.pli_attribute8	,
	p_pli_attribute9			=>	p_rec.pli_attribute9	,
	p_pli_attribute10			=>	p_rec.pli_attribute10	,
	p_pli_attribute11			=>	p_rec.pli_attribute11	,
	p_pli_attribute12			=>	p_rec.pli_attribute12	,
	p_pli_attribute13			=>	p_rec.pli_attribute13	,
	p_pli_attribute14			=>	p_rec.pli_attribute14	,
	p_pli_attribute15			=>	p_rec.pli_attribute15	,
	p_pli_attribute16			=>	p_rec.pli_attribute16	,
	p_pli_attribute17			=>	p_rec.pli_attribute17	,
	p_pli_attribute18			=>	p_rec.pli_attribute18	,
	p_pli_attribute19			=>	p_rec.pli_attribute19	,
	p_pli_attribute20			=>	p_rec.pli_attribute20	,
	p_pli_information_category	=>	p_rec.pli_information_category	,
	p_pli_information1		=>	p_rec.pli_information1	,
	p_pli_information2		=>	p_rec.pli_information2	,
	p_pli_information3		=>	p_rec.pli_information3	,
	p_pli_information4		=>	p_rec.pli_information4	,
	p_pli_information5		=>	p_rec.pli_information5	,
	p_pli_information6		=>	p_rec.pli_information6	,
	p_pli_information7		=>	p_rec.pli_information7	,
	p_pli_information8		=>	p_rec.pli_information8	,
	p_pli_information9		=>	p_rec.pli_information9	,
	p_pli_information10		=>	p_rec.pli_information10	,
	p_pli_information11		=>	p_rec.pli_information11	,
	p_pli_information12		=>	p_rec.pli_information12	,
	p_pli_information13		=>	p_rec.pli_information13	,
	p_pli_information14		=>	p_rec.pli_information14	,
	p_pli_information15		=>	p_rec.pli_information15	,
	p_pli_information16		=>	p_rec.pli_information16	,
	p_pli_information17		=>	p_rec.pli_information17	,
	p_pli_information18		=>	p_rec.pli_information18	,
	p_pli_information19		=>	p_rec.pli_information19	,
	p_pli_information20		=>	p_rec.pli_information20	,
	p_pli_information21		=>	p_rec.pli_information21	,
	p_pli_information22		=>	p_rec.pli_information22	,
	p_pli_information23		=>	p_rec.pli_information23	,
	p_pli_information24		=>	p_rec.pli_information24	,
	p_pli_information25		=>	p_rec.pli_information25	,
	p_pli_information26		=>	p_rec.pli_information26	,
	p_pli_information27		=>	p_rec.pli_information27	,
	p_pli_information28		=>	p_rec.pli_information28	,
	p_pli_information29		=>	p_rec.pli_information29	,
	p_pli_information30		=>	p_rec.pli_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'BEN_PL_EXTRA_INFO'
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
  p_rec        in out nocopy ben_pli_shd.g_rec_type,
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
    SAVEPOINT ins_ben_pli;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ben_pli_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ben_pli;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pl_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_pl_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_pli_attribute_category       in varchar2         default null,
  p_pli_attribute1               in varchar2         default null,
  p_pli_attribute2               in varchar2         default null,
  p_pli_attribute3               in varchar2         default null,
  p_pli_attribute4               in varchar2         default null,
  p_pli_attribute5               in varchar2         default null,
  p_pli_attribute6               in varchar2         default null,
  p_pli_attribute7               in varchar2         default null,
  p_pli_attribute8               in varchar2         default null,
  p_pli_attribute9               in varchar2         default null,
  p_pli_attribute10              in varchar2         default null,
  p_pli_attribute11              in varchar2         default null,
  p_pli_attribute12              in varchar2         default null,
  p_pli_attribute13              in varchar2         default null,
  p_pli_attribute14              in varchar2         default null,
  p_pli_attribute15              in varchar2         default null,
  p_pli_attribute16              in varchar2         default null,
  p_pli_attribute17              in varchar2         default null,
  p_pli_attribute18              in varchar2         default null,
  p_pli_attribute19              in varchar2         default null,
  p_pli_attribute20              in varchar2         default null,
  p_pli_information_category     in varchar2         default null,
  p_pli_information1             in varchar2         default null,
  p_pli_information2             in varchar2         default null,
  p_pli_information3             in varchar2         default null,
  p_pli_information4             in varchar2         default null,
  p_pli_information5             in varchar2         default null,
  p_pli_information6             in varchar2         default null,
  p_pli_information7             in varchar2         default null,
  p_pli_information8             in varchar2         default null,
  p_pli_information9             in varchar2         default null,
  p_pli_information10            in varchar2         default null,
  p_pli_information11            in varchar2         default null,
  p_pli_information12            in varchar2         default null,
  p_pli_information13            in varchar2         default null,
  p_pli_information14            in varchar2         default null,
  p_pli_information15            in varchar2         default null,
  p_pli_information16            in varchar2         default null,
  p_pli_information17            in varchar2         default null,
  p_pli_information18            in varchar2         default null,
  p_pli_information19            in varchar2         default null,
  p_pli_information20            in varchar2         default null,
  p_pli_information21            in varchar2         default null,
  p_pli_information22            in varchar2         default null,
  p_pli_information23            in varchar2         default null,
  p_pli_information24            in varchar2         default null,
  p_pli_information25            in varchar2         default null,
  p_pli_information26            in varchar2         default null,
  p_pli_information27            in varchar2         default null,
  p_pli_information28            in varchar2         default null,
  p_pli_information29            in varchar2         default null,
  p_pli_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ben_pli_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pli_shd.convert_args
  (
  null,
  p_information_type,
  p_pl_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_pli_attribute_category,
  p_pli_attribute1,
  p_pli_attribute2,
  p_pli_attribute3,
  p_pli_attribute4,
  p_pli_attribute5,
  p_pli_attribute6,
  p_pli_attribute7,
  p_pli_attribute8,
  p_pli_attribute9,
  p_pli_attribute10,
  p_pli_attribute11,
  p_pli_attribute12,
  p_pli_attribute13,
  p_pli_attribute14,
  p_pli_attribute15,
  p_pli_attribute16,
  p_pli_attribute17,
  p_pli_attribute18,
  p_pli_attribute19,
  p_pli_attribute20,
  p_pli_information_category,
  p_pli_information1,
  p_pli_information2,
  p_pli_information3,
  p_pli_information4,
  p_pli_information5,
  p_pli_information6,
  p_pli_information7,
  p_pli_information8,
  p_pli_information9,
  p_pli_information10,
  p_pli_information11,
  p_pli_information12,
  p_pli_information13,
  p_pli_information14,
  p_pli_information15,
  p_pli_information16,
  p_pli_information17,
  p_pli_information18,
  p_pli_information19,
  p_pli_information20,
  p_pli_information21,
  p_pli_information22,
  p_pli_information23,
  p_pli_information24,
  p_pli_information25,
  p_pli_information26,
  p_pli_information27,
  p_pli_information28,
  p_pli_information29,
  p_pli_information30,
  null
  );
  --
  -- Having converted the arguments into the ben_pli_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pl_extra_info_id := l_rec.pl_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pli_ins;

/
