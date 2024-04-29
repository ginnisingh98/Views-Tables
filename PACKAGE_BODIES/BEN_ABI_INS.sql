--------------------------------------------------------
--  DDL for Package Body BEN_ABI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ABI_INS" as
/* $Header: beabirhi.pkb 115.0 2003/09/23 10:13:59 hmani noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_abi_ins.';  -- Global package name
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
--   A abr/Sql record structre.
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
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: ben_abr_extra_info
  --
  insert into ben_abr_extra_info
  (	abr_extra_info_id,
	information_type,
	acty_base_rt_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	abi_attribute_category,
	abi_attribute1,
	abi_attribute2,
	abi_attribute3,
	abi_attribute4,
	abi_attribute5,
	abi_attribute6,
	abi_attribute7,
	abi_attribute8,
	abi_attribute9,
	abi_attribute10,
	abi_attribute11,
	abi_attribute12,
	abi_attribute13,
	abi_attribute14,
	abi_attribute15,
	abi_attribute16,
	abi_attribute17,
	abi_attribute18,
	abi_attribute19,
	abi_attribute20,
	abi_information_category,
	abi_information1,
	abi_information2,
	abi_information3,
	abi_information4,
	abi_information5,
	abi_information6,
	abi_information7,
	abi_information8,
	abi_information9,
	abi_information10,
	abi_information11,
	abi_information12,
	abi_information13,
	abi_information14,
	abi_information15,
	abi_information16,
	abi_information17,
	abi_information18,
	abi_information19,
	abi_information20,
	abi_information21,
	abi_information22,
	abi_information23,
	abi_information24,
	abi_information25,
	abi_information26,
	abi_information27,
	abi_information28,
	abi_information29,
	abi_information30,
	object_version_number
  )
  Values
  (	p_rec.abr_extra_info_id,
	p_rec.information_type,
	p_rec.acty_base_rt_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.abi_attribute_category,
	p_rec.abi_attribute1,
	p_rec.abi_attribute2,
	p_rec.abi_attribute3,
	p_rec.abi_attribute4,
	p_rec.abi_attribute5,
	p_rec.abi_attribute6,
	p_rec.abi_attribute7,
	p_rec.abi_attribute8,
	p_rec.abi_attribute9,
	p_rec.abi_attribute10,
	p_rec.abi_attribute11,
	p_rec.abi_attribute12,
	p_rec.abi_attribute13,
	p_rec.abi_attribute14,
	p_rec.abi_attribute15,
	p_rec.abi_attribute16,
	p_rec.abi_attribute17,
	p_rec.abi_attribute18,
	p_rec.abi_attribute19,
	p_rec.abi_attribute20,
	p_rec.abi_information_category,
	p_rec.abi_information1,
	p_rec.abi_information2,
	p_rec.abi_information3,
	p_rec.abi_information4,
	p_rec.abi_information5,
	p_rec.abi_information6,
	p_rec.abi_information7,
	p_rec.abi_information8,
	p_rec.abi_information9,
	p_rec.abi_information10,
	p_rec.abi_information11,
	p_rec.abi_information12,
	p_rec.abi_information13,
	p_rec.abi_information14,
	p_rec.abi_information15,
	p_rec.abi_information16,
	p_rec.abi_information17,
	p_rec.abi_information18,
	p_rec.abi_information19,
	p_rec.abi_information20,
	p_rec.abi_information21,
	p_rec.abi_information22,
	p_rec.abi_information23,
	p_rec.abi_information24,
	p_rec.abi_information25,
	p_rec.abi_information26,
	p_rec.abi_information27,
	p_rec.abi_information28,
	p_rec.abi_information29,
	p_rec.abi_information30,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_abi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_abi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_abi_shd.constraint_error
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
--   A abr/Sql record structre.
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
--   before abracing in this procedure.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_abr_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.abr_extra_info_id;
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
--   A abr/Sql record structre.
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
--   maintenance should be reviewed before abracing in this procedure.
--
-- Access Status:
--   Internal Table Handabr Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_abi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ben_abi_rki.after_insert	(
	p_abr_extra_info_id		=>	p_rec.abr_extra_info_id		,
	p_information_type		=>	p_rec.information_type		,
	p_acty_base_rt_id				=>	p_rec.acty_base_rt_id			,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_abi_attribute_category	=>	p_rec.abi_attribute_category	,
	p_abi_attribute1			=>	p_rec.abi_attribute1	,
	p_abi_attribute2			=>	p_rec.abi_attribute2	,
	p_abi_attribute3			=>	p_rec.abi_attribute3	,
	p_abi_attribute4			=>	p_rec.abi_attribute4	,
	p_abi_attribute5			=>	p_rec.abi_attribute5	,
	p_abi_attribute6			=>	p_rec.abi_attribute6	,
	p_abi_attribute7			=>	p_rec.abi_attribute7	,
	p_abi_attribute8			=>	p_rec.abi_attribute8	,
	p_abi_attribute9			=>	p_rec.abi_attribute9	,
	p_abi_attribute10			=>	p_rec.abi_attribute10	,
	p_abi_attribute11			=>	p_rec.abi_attribute11	,
	p_abi_attribute12			=>	p_rec.abi_attribute12	,
	p_abi_attribute13			=>	p_rec.abi_attribute13	,
	p_abi_attribute14			=>	p_rec.abi_attribute14	,
	p_abi_attribute15			=>	p_rec.abi_attribute15	,
	p_abi_attribute16			=>	p_rec.abi_attribute16	,
	p_abi_attribute17			=>	p_rec.abi_attribute17	,
	p_abi_attribute18			=>	p_rec.abi_attribute18	,
	p_abi_attribute19			=>	p_rec.abi_attribute19	,
	p_abi_attribute20			=>	p_rec.abi_attribute20	,
	p_abi_information_category	=>	p_rec.abi_information_category	,
	p_abi_information1		=>	p_rec.abi_information1	,
	p_abi_information2		=>	p_rec.abi_information2	,
	p_abi_information3		=>	p_rec.abi_information3	,
	p_abi_information4		=>	p_rec.abi_information4	,
	p_abi_information5		=>	p_rec.abi_information5	,
	p_abi_information6		=>	p_rec.abi_information6	,
	p_abi_information7		=>	p_rec.abi_information7	,
	p_abi_information8		=>	p_rec.abi_information8	,
	p_abi_information9		=>	p_rec.abi_information9	,
	p_abi_information10		=>	p_rec.abi_information10	,
	p_abi_information11		=>	p_rec.abi_information11	,
	p_abi_information12		=>	p_rec.abi_information12	,
	p_abi_information13		=>	p_rec.abi_information13	,
	p_abi_information14		=>	p_rec.abi_information14	,
	p_abi_information15		=>	p_rec.abi_information15	,
	p_abi_information16		=>	p_rec.abi_information16	,
	p_abi_information17		=>	p_rec.abi_information17	,
	p_abi_information18		=>	p_rec.abi_information18	,
	p_abi_information19		=>	p_rec.abi_information19	,
	p_abi_information20		=>	p_rec.abi_information20	,
	p_abi_information21		=>	p_rec.abi_information21	,
	p_abi_information22		=>	p_rec.abi_information22	,
	p_abi_information23		=>	p_rec.abi_information23	,
	p_abi_information24		=>	p_rec.abi_information24	,
	p_abi_information25		=>	p_rec.abi_information25	,
	p_abi_information26		=>	p_rec.abi_information26	,
	p_abi_information27		=>	p_rec.abi_information27	,
	p_abi_information28		=>	p_rec.abi_information28	,
	p_abi_information29		=>	p_rec.abi_information29	,
	p_abi_information30		=>	p_rec.abi_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'BEN_LER_EXTRA_INFO'
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
  p_rec        in out nocopy ben_abi_shd.g_rec_type,
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
    SAVEPOINT ins_ben_abi;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ben_abi_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ben_abi;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_abr_extra_info_id            out nocopy number,
  p_information_type             in varchar2,
  p_acty_base_rt_id                       in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_abi_attribute_category       in varchar2         default null,
  p_abi_attribute1               in varchar2         default null,
  p_abi_attribute2               in varchar2         default null,
  p_abi_attribute3               in varchar2         default null,
  p_abi_attribute4               in varchar2         default null,
  p_abi_attribute5               in varchar2         default null,
  p_abi_attribute6               in varchar2         default null,
  p_abi_attribute7               in varchar2         default null,
  p_abi_attribute8               in varchar2         default null,
  p_abi_attribute9               in varchar2         default null,
  p_abi_attribute10              in varchar2         default null,
  p_abi_attribute11              in varchar2         default null,
  p_abi_attribute12              in varchar2         default null,
  p_abi_attribute13              in varchar2         default null,
  p_abi_attribute14              in varchar2         default null,
  p_abi_attribute15              in varchar2         default null,
  p_abi_attribute16              in varchar2         default null,
  p_abi_attribute17              in varchar2         default null,
  p_abi_attribute18              in varchar2         default null,
  p_abi_attribute19              in varchar2         default null,
  p_abi_attribute20              in varchar2         default null,
  p_abi_information_category     in varchar2         default null,
  p_abi_information1             in varchar2         default null,
  p_abi_information2             in varchar2         default null,
  p_abi_information3             in varchar2         default null,
  p_abi_information4             in varchar2         default null,
  p_abi_information5             in varchar2         default null,
  p_abi_information6             in varchar2         default null,
  p_abi_information7             in varchar2         default null,
  p_abi_information8             in varchar2         default null,
  p_abi_information9             in varchar2         default null,
  p_abi_information10            in varchar2         default null,
  p_abi_information11            in varchar2         default null,
  p_abi_information12            in varchar2         default null,
  p_abi_information13            in varchar2         default null,
  p_abi_information14            in varchar2         default null,
  p_abi_information15            in varchar2         default null,
  p_abi_information16            in varchar2         default null,
  p_abi_information17            in varchar2         default null,
  p_abi_information18            in varchar2         default null,
  p_abi_information19            in varchar2         default null,
  p_abi_information20            in varchar2         default null,
  p_abi_information21            in varchar2         default null,
  p_abi_information22            in varchar2         default null,
  p_abi_information23            in varchar2         default null,
  p_abi_information24            in varchar2         default null,
  p_abi_information25            in varchar2         default null,
  p_abi_information26            in varchar2         default null,
  p_abi_information27            in varchar2         default null,
  p_abi_information28            in varchar2         default null,
  p_abi_information29            in varchar2         default null,
  p_abi_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ben_abi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_abi_shd.convert_args
  (
  null,
  p_information_type,
  p_acty_base_rt_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_abi_attribute_category,
  p_abi_attribute1,
  p_abi_attribute2,
  p_abi_attribute3,
  p_abi_attribute4,
  p_abi_attribute5,
  p_abi_attribute6,
  p_abi_attribute7,
  p_abi_attribute8,
  p_abi_attribute9,
  p_abi_attribute10,
  p_abi_attribute11,
  p_abi_attribute12,
  p_abi_attribute13,
  p_abi_attribute14,
  p_abi_attribute15,
  p_abi_attribute16,
  p_abi_attribute17,
  p_abi_attribute18,
  p_abi_attribute19,
  p_abi_attribute20,
  p_abi_information_category,
  p_abi_information1,
  p_abi_information2,
  p_abi_information3,
  p_abi_information4,
  p_abi_information5,
  p_abi_information6,
  p_abi_information7,
  p_abi_information8,
  p_abi_information9,
  p_abi_information10,
  p_abi_information11,
  p_abi_information12,
  p_abi_information13,
  p_abi_information14,
  p_abi_information15,
  p_abi_information16,
  p_abi_information17,
  p_abi_information18,
  p_abi_information19,
  p_abi_information20,
  p_abi_information21,
  p_abi_information22,
  p_abi_information23,
  p_abi_information24,
  p_abi_information25,
  p_abi_information26,
  p_abi_information27,
  p_abi_information28,
  p_abi_information29,
  p_abi_information30,
  null
  );
  --
  -- Having converted the arguments into the ben_abi_rec
  -- abrsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_abr_extra_info_id := l_rec.abr_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_abi_ins;

/
