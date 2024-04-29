--------------------------------------------------------
--  DDL for Package Body HR_LEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEI_INS" as
/* $Header: hrleirhi.pkb 120.1.12010000.2 2009/01/28 09:08:21 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_lei_ins.';  -- Global package name
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
--      Note : Dinesh Arora, 2/13/97 Removed the need for setting g_api_dml
--             as this is a new table and therfore there is no ovn trigger
--             to use it).
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
--   Note : Dinesh Arora, 2/13/97 Removed the need for setting g_api_dml
--          as this is a new table and therfore there is no ovn trigger
--          to use it).
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- hr_lei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_location_extra_info
  --
  insert into hr_location_extra_info
  (	location_extra_info_id,
	information_type,
	location_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	lei_attribute_category,
	lei_attribute1,
	lei_attribute2,
	lei_attribute3,
	lei_attribute4,
	lei_attribute5,
	lei_attribute6,
	lei_attribute7,
	lei_attribute8,
	lei_attribute9,
	lei_attribute10,
	lei_attribute11,
	lei_attribute12,
	lei_attribute13,
	lei_attribute14,
	lei_attribute15,
	lei_attribute16,
	lei_attribute17,
	lei_attribute18,
	lei_attribute19,
	lei_attribute20,
	lei_information_category,
	lei_information1,
	lei_information2,
	lei_information3,
	lei_information4,
	lei_information5,
	lei_information6,
	lei_information7,
	lei_information8,
	lei_information9,
	lei_information10,
	lei_information11,
	lei_information12,
	lei_information13,
	lei_information14,
	lei_information15,
	lei_information16,
	lei_information17,
	lei_information18,
	lei_information19,
	lei_information20,
	lei_information21,
	lei_information22,
	lei_information23,
	lei_information24,
	lei_information25,
	lei_information26,
	lei_information27,
	lei_information28,
	lei_information29,
	lei_information30,
	object_version_number
  )
  Values
  (	p_rec.location_extra_info_id,
	p_rec.information_type,
	p_rec.location_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.lei_attribute_category,
	p_rec.lei_attribute1,
	p_rec.lei_attribute2,
	p_rec.lei_attribute3,
	p_rec.lei_attribute4,
	p_rec.lei_attribute5,
	p_rec.lei_attribute6,
	p_rec.lei_attribute7,
	p_rec.lei_attribute8,
	p_rec.lei_attribute9,
	p_rec.lei_attribute10,
	p_rec.lei_attribute11,
	p_rec.lei_attribute12,
	p_rec.lei_attribute13,
	p_rec.lei_attribute14,
	p_rec.lei_attribute15,
	p_rec.lei_attribute16,
	p_rec.lei_attribute17,
	p_rec.lei_attribute18,
	p_rec.lei_attribute19,
	p_rec.lei_attribute20,
	p_rec.lei_information_category,
	p_rec.lei_information1,
	p_rec.lei_information2,
	p_rec.lei_information3,
	p_rec.lei_information4,
	p_rec.lei_information5,
	p_rec.lei_information6,
	p_rec.lei_information7,
	p_rec.lei_information8,
	p_rec.lei_information9,
	p_rec.lei_information10,
	p_rec.lei_information11,
	p_rec.lei_information12,
	p_rec.lei_information13,
	p_rec.lei_information14,
	p_rec.lei_information15,
	p_rec.lei_information16,
	p_rec.lei_information17,
	p_rec.lei_information18,
	p_rec.lei_information19,
	p_rec.lei_information20,
	p_rec.lei_information21,
	p_rec.lei_information22,
	p_rec.lei_information23,
	p_rec.lei_information24,
	p_rec.lei_information25,
	p_rec.lei_information26,
	p_rec.lei_information27,
	p_rec.lei_information28,
	p_rec.lei_information29,
	p_rec.lei_information30,
	p_rec.object_version_number
  );
  --
  --  hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
    hr_lei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    -- hr_lei_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_location_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.location_extra_info_id;
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
Procedure post_insert(p_rec in hr_lei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     hr_lei_rki.after_insert	(
	p_location_extra_info_id	=>	p_rec.location_extra_info_id,
	p_information_type		=>	p_rec.information_type,
	p_location_id			=>	p_rec.location_id,
	p_request_id			=>	p_rec.request_id,
	p_program_application_id	=>	p_rec.program_application_id,
	p_program_id			=>	p_rec.program_id,
	p_program_update_date		=>	p_rec.program_update_date,
	p_lei_attribute_category	=>	p_rec.lei_attribute_category,
	p_lei_attribute1		=>	p_rec.lei_attribute1,
	p_lei_attribute2		=>	p_rec.lei_attribute2,
	p_lei_attribute3		=>	p_rec.lei_attribute3,
	p_lei_attribute4		=>	p_rec.lei_attribute4,
	p_lei_attribute5		=>	p_rec.lei_attribute5,
	p_lei_attribute6		=>	p_rec.lei_attribute6,
	p_lei_attribute7		=>	p_rec.lei_attribute7,
	p_lei_attribute8		=>	p_rec.lei_attribute8,
	p_lei_attribute9		=>	p_rec.lei_attribute9,
	p_lei_attribute10		=>	p_rec.lei_attribute10,
	p_lei_attribute11		=>	p_rec.lei_attribute11,
	p_lei_attribute12		=>	p_rec.lei_attribute12,
	p_lei_attribute13		=>	p_rec.lei_attribute13,
	p_lei_attribute14		=>	p_rec.lei_attribute14,
	p_lei_attribute15		=>	p_rec.lei_attribute15,
	p_lei_attribute16		=>	p_rec.lei_attribute16,
	p_lei_attribute17		=>	p_rec.lei_attribute17,
	p_lei_attribute18		=>	p_rec.lei_attribute18,
	p_lei_attribute19		=>	p_rec.lei_attribute19,
	p_lei_attribute20		=>	p_rec.lei_attribute20,
	p_lei_information_category	=>	p_rec.lei_information_category,
	p_lei_information1		=>	p_rec.lei_information1,
	p_lei_information2		=>	p_rec.lei_information2,
	p_lei_information3		=>	p_rec.lei_information3,
	p_lei_information4		=>	p_rec.lei_information4,
	p_lei_information5		=>	p_rec.lei_information5,
	p_lei_information6		=>	p_rec.lei_information6,
	p_lei_information7		=>	p_rec.lei_information7,
	p_lei_information8		=>	p_rec.lei_information8,
	p_lei_information9		=>	p_rec.lei_information9,
	p_lei_information10		=>	p_rec.lei_information10,
	p_lei_information11		=>	p_rec.lei_information11,
	p_lei_information12		=>	p_rec.lei_information12,
	p_lei_information13		=>	p_rec.lei_information13,
	p_lei_information14		=>	p_rec.lei_information14,
	p_lei_information15		=>	p_rec.lei_information15,
	p_lei_information16		=>	p_rec.lei_information16,
	p_lei_information17		=>	p_rec.lei_information17,
	p_lei_information18		=>	p_rec.lei_information18,
	p_lei_information19		=>	p_rec.lei_information19,
	p_lei_information20		=>	p_rec.lei_information20,
	p_lei_information21		=>	p_rec.lei_information21,
	p_lei_information22		=>	p_rec.lei_information22,
	p_lei_information23		=>	p_rec.lei_information23,
	p_lei_information24		=>	p_rec.lei_information24,
	p_lei_information25		=>	p_rec.lei_information25,
	p_lei_information26		=>	p_rec.lei_information26,
	p_lei_information27		=>	p_rec.lei_information27,
	p_lei_information28		=>	p_rec.lei_information28,
	p_lei_information29		=>	p_rec.lei_information29,
	p_lei_information30		=>	p_rec.lei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'HR_LOCATION_EXTRA_INFO'
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
  p_rec        in out nocopy hr_lei_shd.g_rec_type,
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
    SAVEPOINT ins_hr_lei;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  hr_lei_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_hr_lei;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_location_extra_info_id       out nocopy number,
  p_information_type             in varchar2,
  p_location_id                  in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_lei_attribute_category       in varchar2         default null,
  p_lei_attribute1               in varchar2         default null,
  p_lei_attribute2               in varchar2         default null,
  p_lei_attribute3               in varchar2         default null,
  p_lei_attribute4               in varchar2         default null,
  p_lei_attribute5               in varchar2         default null,
  p_lei_attribute6               in varchar2         default null,
  p_lei_attribute7               in varchar2         default null,
  p_lei_attribute8               in varchar2         default null,
  p_lei_attribute9               in varchar2         default null,
  p_lei_attribute10              in varchar2         default null,
  p_lei_attribute11              in varchar2         default null,
  p_lei_attribute12              in varchar2         default null,
  p_lei_attribute13              in varchar2         default null,
  p_lei_attribute14              in varchar2         default null,
  p_lei_attribute15              in varchar2         default null,
  p_lei_attribute16              in varchar2         default null,
  p_lei_attribute17              in varchar2         default null,
  p_lei_attribute18              in varchar2         default null,
  p_lei_attribute19              in varchar2         default null,
  p_lei_attribute20              in varchar2         default null,
  p_lei_information_category     in varchar2         default null,
  p_lei_information1             in varchar2         default null,
  p_lei_information2             in varchar2         default null,
  p_lei_information3             in varchar2         default null,
  p_lei_information4             in varchar2         default null,
  p_lei_information5             in varchar2         default null,
  p_lei_information6             in varchar2         default null,
  p_lei_information7             in varchar2         default null,
  p_lei_information8             in varchar2         default null,
  p_lei_information9             in varchar2         default null,
  p_lei_information10            in varchar2         default null,
  p_lei_information11            in varchar2         default null,
  p_lei_information12            in varchar2         default null,
  p_lei_information13            in varchar2         default null,
  p_lei_information14            in varchar2         default null,
  p_lei_information15            in varchar2         default null,
  p_lei_information16            in varchar2         default null,
  p_lei_information17            in varchar2         default null,
  p_lei_information18            in varchar2         default null,
  p_lei_information19            in varchar2         default null,
  p_lei_information20            in varchar2         default null,
  p_lei_information21            in varchar2         default null,
  p_lei_information22            in varchar2         default null,
  p_lei_information23            in varchar2         default null,
  p_lei_information24            in varchar2         default null,
  p_lei_information25            in varchar2         default null,
  p_lei_information26            in varchar2         default null,
  p_lei_information27            in varchar2         default null,
  p_lei_information28            in varchar2         default null,
  p_lei_information29            in varchar2         default null,
  p_lei_information30            in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  hr_lei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_lei_shd.convert_args
  (
  null,
  p_information_type,
  p_location_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_lei_attribute_category,
  p_lei_attribute1,
  p_lei_attribute2,
  p_lei_attribute3,
  p_lei_attribute4,
  p_lei_attribute5,
  p_lei_attribute6,
  p_lei_attribute7,
  p_lei_attribute8,
  p_lei_attribute9,
  p_lei_attribute10,
  p_lei_attribute11,
  p_lei_attribute12,
  p_lei_attribute13,
  p_lei_attribute14,
  p_lei_attribute15,
  p_lei_attribute16,
  p_lei_attribute17,
  p_lei_attribute18,
  p_lei_attribute19,
  p_lei_attribute20,
  p_lei_information_category,
  p_lei_information1,
  p_lei_information2,
  p_lei_information3,
  p_lei_information4,
  p_lei_information5,
  p_lei_information6,
  p_lei_information7,
  p_lei_information8,
  p_lei_information9,
  p_lei_information10,
  p_lei_information11,
  p_lei_information12,
  p_lei_information13,
  p_lei_information14,
  p_lei_information15,
  p_lei_information16,
  p_lei_information17,
  p_lei_information18,
  p_lei_information19,
  p_lei_information20,
  p_lei_information21,
  p_lei_information22,
  p_lei_information23,
  p_lei_information24,
  p_lei_information25,
  p_lei_information26,
  p_lei_information27,
  p_lei_information28,
  p_lei_information29,
  p_lei_information30,
  null
  );
  --
  -- Having converted the arguments into the hr_lei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_location_extra_info_id := l_rec.location_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_lei_ins;

/
