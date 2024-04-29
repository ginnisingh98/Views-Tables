--------------------------------------------------------
--  DDL for Package Body PE_POI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_POI_INS" as
/* $Header: pepoirhi.pkb 120.0 2005/05/31 14:50:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_poi_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: per_position_extra_info
  --
  insert into per_position_extra_info
  (	position_extra_info_id,
	position_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	poei_attribute_category,
	poei_attribute1,
	poei_attribute2,
	poei_attribute3,
	poei_attribute4,
	poei_attribute5,
	poei_attribute6,
	poei_attribute7,
	poei_attribute8,
	poei_attribute9,
	poei_attribute10,
	poei_attribute11,
	poei_attribute12,
	poei_attribute13,
	poei_attribute14,
	poei_attribute15,
	poei_attribute16,
	poei_attribute17,
	poei_attribute18,
	poei_attribute19,
	poei_attribute20,
	poei_information_category,
	poei_information1,
	poei_information2,
	poei_information3,
	poei_information4,
	poei_information5,
	poei_information6,
	poei_information7,
	poei_information8,
	poei_information9,
	poei_information10,
	poei_information11,
	poei_information12,
	poei_information13,
	poei_information14,
	poei_information15,
	poei_information16,
	poei_information17,
	poei_information18,
	poei_information19,
	poei_information20,
	poei_information21,
	poei_information22,
	poei_information23,
	poei_information24,
	poei_information25,
	poei_information26,
	poei_information27,
	poei_information28,
	poei_information29,
	poei_information30,
	object_version_number
  )
  Values
  (	p_rec.position_extra_info_id,
	p_rec.position_id,
	p_rec.information_type,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.poei_attribute_category,
	p_rec.poei_attribute1,
	p_rec.poei_attribute2,
	p_rec.poei_attribute3,
	p_rec.poei_attribute4,
	p_rec.poei_attribute5,
	p_rec.poei_attribute6,
	p_rec.poei_attribute7,
	p_rec.poei_attribute8,
	p_rec.poei_attribute9,
	p_rec.poei_attribute10,
	p_rec.poei_attribute11,
	p_rec.poei_attribute12,
	p_rec.poei_attribute13,
	p_rec.poei_attribute14,
	p_rec.poei_attribute15,
	p_rec.poei_attribute16,
	p_rec.poei_attribute17,
	p_rec.poei_attribute18,
	p_rec.poei_attribute19,
	p_rec.poei_attribute20,
	p_rec.poei_information_category,
	p_rec.poei_information1,
	p_rec.poei_information2,
	p_rec.poei_information3,
	p_rec.poei_information4,
	p_rec.poei_information5,
	p_rec.poei_information6,
	p_rec.poei_information7,
	p_rec.poei_information8,
	p_rec.poei_information9,
	p_rec.poei_information10,
	p_rec.poei_information11,
	p_rec.poei_information12,
	p_rec.poei_information13,
	p_rec.poei_information14,
	p_rec.poei_information15,
	p_rec.poei_information16,
	p_rec.poei_information17,
	p_rec.poei_information18,
	p_rec.poei_information19,
	p_rec.poei_information20,
	p_rec.poei_information21,
	p_rec.poei_information22,
	p_rec.poei_information23,
	p_rec.poei_information24,
	p_rec.poei_information25,
	p_rec.poei_information26,
	p_rec.poei_information27,
	p_rec.poei_information28,
	p_rec.poei_information29,
	p_rec.poei_information30,
	p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pe_poi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pe_poi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pe_poi_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_position_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.position_extra_info_id;
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
Procedure post_insert(p_rec in pe_poi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     pe_poi_rki.after_insert	(
	p_position_extra_info_id	=>	p_rec.position_extra_info_id	,
	p_position_id			=>	p_rec.position_id			,
	p_information_type		=>	p_rec.information_type		,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_poei_attribute_category	=>	p_rec.poei_attribute_category	,
	p_poei_attribute1		=>	p_rec.poei_attribute1		,
	p_poei_attribute2		=>	p_rec.poei_attribute2		,
	p_poei_attribute3		=>	p_rec.poei_attribute3		,
	p_poei_attribute4		=>	p_rec.poei_attribute4		,
	p_poei_attribute5		=>	p_rec.poei_attribute5		,
	p_poei_attribute6		=>	p_rec.poei_attribute6		,
	p_poei_attribute7		=>	p_rec.poei_attribute7		,
	p_poei_attribute8		=>	p_rec.poei_attribute8		,
	p_poei_attribute9		=>	p_rec.poei_attribute9		,
	p_poei_attribute10		=>	p_rec.poei_attribute10		,
	p_poei_attribute11		=>	p_rec.poei_attribute11		,
	p_poei_attribute12		=>	p_rec.poei_attribute12		,
	p_poei_attribute13		=>	p_rec.poei_attribute13		,
	p_poei_attribute14		=>	p_rec.poei_attribute14		,
	p_poei_attribute15		=>	p_rec.poei_attribute15		,
	p_poei_attribute16		=>	p_rec.poei_attribute16		,
	p_poei_attribute17		=>	p_rec.poei_attribute17		,
	p_poei_attribute18		=>	p_rec.poei_attribute18		,
	p_poei_attribute19		=>	p_rec.poei_attribute19		,
	p_poei_attribute20		=>	p_rec.poei_attribute20		,
	p_poei_information_category	=>	p_rec.poei_information_category	,
	p_poei_information1		=>	p_rec.poei_information1		,
	p_poei_information2		=>	p_rec.poei_information2		,
	p_poei_information3		=>	p_rec.poei_information3		,
	p_poei_information4		=>	p_rec.poei_information4		,
	p_poei_information5		=>	p_rec.poei_information5		,
	p_poei_information6		=>	p_rec.poei_information6		,
	p_poei_information7		=>	p_rec.poei_information7		,
	p_poei_information8		=>	p_rec.poei_information8		,
	p_poei_information9		=>	p_rec.poei_information9		,
	p_poei_information10		=>	p_rec.poei_information10	,
	p_poei_information11		=>	p_rec.poei_information11	,
	p_poei_information12		=>	p_rec.poei_information12	,
	p_poei_information13		=>	p_rec.poei_information13	,
	p_poei_information14		=>	p_rec.poei_information14	,
	p_poei_information15		=>	p_rec.poei_information15	,
	p_poei_information16		=>	p_rec.poei_information16	,
	p_poei_information17		=>	p_rec.poei_information17	,
	p_poei_information18		=>	p_rec.poei_information18	,
	p_poei_information19		=>	p_rec.poei_information19	,
	p_poei_information20		=>	p_rec.poei_information20	,
	p_poei_information21		=>	p_rec.poei_information21	,
	p_poei_information22		=>	p_rec.poei_information22	,
	p_poei_information23		=>	p_rec.poei_information23	,
	p_poei_information24		=>	p_rec.poei_information24	,
	p_poei_information25		=>	p_rec.poei_information25	,
	p_poei_information26		=>	p_rec.poei_information26	,
	p_poei_information27		=>	p_rec.poei_information27	,
	p_poei_information28		=>	p_rec.poei_information28	,
	p_poei_information29		=>	p_rec.poei_information29	,
	p_poei_information30		=>	p_rec.poei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_POSITION_EXTRA_INFO'
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
  p_rec        in out nocopy pe_poi_shd.g_rec_type,
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
    SAVEPOINT ins_pe_poi;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  pe_poi_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_pe_poi;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_position_extra_info_id       out nocopy number,
  p_position_id                  in number,
  p_information_type             in varchar2,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_poei_attribute_category      in varchar2         default null,
  p_poei_attribute1              in varchar2         default null,
  p_poei_attribute2              in varchar2         default null,
  p_poei_attribute3              in varchar2         default null,
  p_poei_attribute4              in varchar2         default null,
  p_poei_attribute5              in varchar2         default null,
  p_poei_attribute6              in varchar2         default null,
  p_poei_attribute7              in varchar2         default null,
  p_poei_attribute8              in varchar2         default null,
  p_poei_attribute9              in varchar2         default null,
  p_poei_attribute10             in varchar2         default null,
  p_poei_attribute11             in varchar2         default null,
  p_poei_attribute12             in varchar2         default null,
  p_poei_attribute13             in varchar2         default null,
  p_poei_attribute14             in varchar2         default null,
  p_poei_attribute15             in varchar2         default null,
  p_poei_attribute16             in varchar2         default null,
  p_poei_attribute17             in varchar2         default null,
  p_poei_attribute18             in varchar2         default null,
  p_poei_attribute19             in varchar2         default null,
  p_poei_attribute20             in varchar2         default null,
  p_poei_information_category    in varchar2         default null,
  p_poei_information1            in varchar2         default null,
  p_poei_information2            in varchar2         default null,
  p_poei_information3            in varchar2         default null,
  p_poei_information4            in varchar2         default null,
  p_poei_information5            in varchar2         default null,
  p_poei_information6            in varchar2         default null,
  p_poei_information7            in varchar2         default null,
  p_poei_information8            in varchar2         default null,
  p_poei_information9            in varchar2         default null,
  p_poei_information10           in varchar2         default null,
  p_poei_information11           in varchar2         default null,
  p_poei_information12           in varchar2         default null,
  p_poei_information13           in varchar2         default null,
  p_poei_information14           in varchar2         default null,
  p_poei_information15           in varchar2         default null,
  p_poei_information16           in varchar2         default null,
  p_poei_information17           in varchar2         default null,
  p_poei_information18           in varchar2         default null,
  p_poei_information19           in varchar2         default null,
  p_poei_information20           in varchar2         default null,
  p_poei_information21           in varchar2         default null,
  p_poei_information22           in varchar2         default null,
  p_poei_information23           in varchar2         default null,
  p_poei_information24           in varchar2         default null,
  p_poei_information25           in varchar2         default null,
  p_poei_information26           in varchar2         default null,
  p_poei_information27           in varchar2         default null,
  p_poei_information28           in varchar2         default null,
  p_poei_information29           in varchar2         default null,
  p_poei_information30           in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  pe_poi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pe_poi_shd.convert_args
  (
  null,
  p_position_id,
  p_information_type,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_poei_attribute_category,
  p_poei_attribute1,
  p_poei_attribute2,
  p_poei_attribute3,
  p_poei_attribute4,
  p_poei_attribute5,
  p_poei_attribute6,
  p_poei_attribute7,
  p_poei_attribute8,
  p_poei_attribute9,
  p_poei_attribute10,
  p_poei_attribute11,
  p_poei_attribute12,
  p_poei_attribute13,
  p_poei_attribute14,
  p_poei_attribute15,
  p_poei_attribute16,
  p_poei_attribute17,
  p_poei_attribute18,
  p_poei_attribute19,
  p_poei_attribute20,
  p_poei_information_category,
  p_poei_information1,
  p_poei_information2,
  p_poei_information3,
  p_poei_information4,
  p_poei_information5,
  p_poei_information6,
  p_poei_information7,
  p_poei_information8,
  p_poei_information9,
  p_poei_information10,
  p_poei_information11,
  p_poei_information12,
  p_poei_information13,
  p_poei_information14,
  p_poei_information15,
  p_poei_information16,
  p_poei_information17,
  p_poei_information18,
  p_poei_information19,
  p_poei_information20,
  p_poei_information21,
  p_poei_information22,
  p_poei_information23,
  p_poei_information24,
  p_poei_information25,
  p_poei_information26,
  p_poei_information27,
  p_poei_information28,
  p_poei_information29,
  p_poei_information30,
  null
  );
  --
  -- Having converted the arguments into the pe_poi_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_position_extra_info_id := l_rec.position_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pe_poi_ins;

/
