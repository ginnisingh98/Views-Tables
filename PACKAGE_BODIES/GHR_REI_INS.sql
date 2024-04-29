--------------------------------------------------------
--  DDL for Package Body GHR_REI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_REI_INS" as
/* $Header: ghreirhi.pkb 120.2.12010000.2 2008/09/02 07:19:59 vmididho ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_rei_ins.';  -- Global package name
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
--      perform dml). Not required, changed by DARORA
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
--   g_api_dml status to false. Not required, changed by DARORA.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset. Not required, Changed by DARORA
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy  ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: ghr_pa_request_extra_info
  --
  insert into ghr_pa_request_extra_info
  (	pa_request_extra_info_id,
	pa_request_id,
	information_type,
	rei_attribute_category,
	rei_attribute1,
	rei_attribute2,
	rei_attribute3,
	rei_attribute4,
	rei_attribute5,
	rei_attribute6,
	rei_attribute7,
	rei_attribute8,
	rei_attribute9,
	rei_attribute10,
	rei_attribute11,
	rei_attribute12,
	rei_attribute13,
	rei_attribute14,
	rei_attribute15,
	rei_attribute16,
	rei_attribute17,
	rei_attribute18,
	rei_attribute19,
	rei_attribute20,
	rei_information_category,
	rei_information1,
	rei_information2,
	rei_information3,
	rei_information4,
	rei_information5,
	rei_information6,
	rei_information7,
	rei_information8,
	rei_information9,
	rei_information10,
	rei_information11,
	rei_information12,
	rei_information13,
	rei_information14,
	rei_information15,
	rei_information16,
	rei_information17,
	rei_information18,
	rei_information19,
	rei_information20,
	rei_information21,
	rei_information22,
	rei_information28,
	rei_information29,
	rei_information23,
	rei_information24,
	rei_information25,
	rei_information26,
	rei_information27,
	rei_information30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
  )
  Values
  (	p_rec.pa_request_extra_info_id,
	p_rec.pa_request_id,
	p_rec.information_type,
	p_rec.rei_attribute_category,
	p_rec.rei_attribute1,
	p_rec.rei_attribute2,
	p_rec.rei_attribute3,
	p_rec.rei_attribute4,
	p_rec.rei_attribute5,
	p_rec.rei_attribute6,
	p_rec.rei_attribute7,
	p_rec.rei_attribute8,
	p_rec.rei_attribute9,
	p_rec.rei_attribute10,
	p_rec.rei_attribute11,
	p_rec.rei_attribute12,
	p_rec.rei_attribute13,
	p_rec.rei_attribute14,
	p_rec.rei_attribute15,
	p_rec.rei_attribute16,
	p_rec.rei_attribute17,
	p_rec.rei_attribute18,
	p_rec.rei_attribute19,
	p_rec.rei_attribute20,
	p_rec.rei_information_category,
	p_rec.rei_information1,
	p_rec.rei_information2,
	p_rec.rei_information3,
	p_rec.rei_information4,
	p_rec.rei_information5,
	p_rec.rei_information6,
	p_rec.rei_information7,
	p_rec.rei_information8,
	p_rec.rei_information9,
	p_rec.rei_information10,
	p_rec.rei_information11,
	p_rec.rei_information12,
	p_rec.rei_information13,
	p_rec.rei_information14,
	p_rec.rei_information15,
	p_rec.rei_information16,
	p_rec.rei_information17,
	p_rec.rei_information18,
	p_rec.rei_information19,
	p_rec.rei_information20,
	p_rec.rei_information21,
	p_rec.rei_information22,
	p_rec.rei_information28,
	p_rec.rei_information29,
	p_rec.rei_information23,
	p_rec.rei_information24,
	p_rec.rei_information25,
	p_rec.rei_information26,
	p_rec.rei_information27,
	p_rec.rei_information30,
	p_rec.object_version_number,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ghr_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ghr_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ghr_rei_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy  ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  Cursor C_Sel1 is select ghr_pa_request_extra_info_s.nextval from sys.dual;
--
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pa_request_extra_info_id;
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
Procedure post_insert(p_rec in ghr_rei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_rei_rki.after_insert	(
		p_pa_request_extra_info_id 	=>	p_rec.pa_request_extra_info_id,
		p_pa_request_id 			=>	p_rec.pa_request_id 		,
		p_information_type 		=>	p_rec.information_type 		,
		p_rei_attribute_category	=>	p_rec.rei_attribute_category 	,
		p_rei_attribute1 			=>	p_rec.rei_attribute1	 	,
		p_rei_attribute2 			=>	p_rec.rei_attribute2 		,
		p_rei_attribute3 			=>	p_rec.rei_attribute3 		,
		p_rei_attribute4 			=>	p_rec.rei_attribute4 		,
		p_rei_attribute5 			=>	p_rec.rei_attribute5 		,
		p_rei_attribute6 			=>	p_rec.rei_attribute6 		,
		p_rei_attribute7 			=>	p_rec.rei_attribute7 		,
		p_rei_attribute8 			=>	p_rec.rei_attribute8 		,
		p_rei_attribute9 			=>	p_rec.rei_attribute9 		,
		p_rei_attribute10 		=>	p_rec.rei_attribute10 		,
		p_rei_attribute11 		=>	p_rec.rei_attribute11 		,
		p_rei_attribute12 		=>	p_rec.rei_attribute12 		,
		p_rei_attribute13 		=>	p_rec.rei_attribute13 		,
		p_rei_attribute14 		=>	p_rec.rei_attribute14 		,
		p_rei_attribute15 		=>	p_rec.rei_attribute15 		,
		p_rei_attribute16 		=>	p_rec.rei_attribute16 		,
		p_rei_attribute17 		=>	p_rec.rei_attribute17 		,
		p_rei_attribute18 		=>	p_rec.rei_attribute18 		,
		p_rei_attribute19		 	=>	p_rec.rei_attribute19 		,
		p_rei_attribute20	 		=>	p_rec.rei_attribute20 		,
		p_rei_information_category 	=>	p_rec.rei_information_category,
		p_rei_information1	 	=>	p_rec.rei_information1 		,
		p_rei_information2 		=>	p_rec.rei_information2 		,
		p_rei_information3 		=>	p_rec.rei_information3 		,
		p_rei_information4 		=>	p_rec.rei_information4 		,
		p_rei_information5 		=>	p_rec.rei_information5 		,
		p_rei_information6 		=>	p_rec.rei_information6 		,
		p_rei_information7 		=>	p_rec.rei_information7 		,
		p_rei_information8 		=>	p_rec.rei_information8 		,
		p_rei_information9 		=>	p_rec.rei_information9 		,
		p_rei_information10 		=>	p_rec.rei_information10 	,
		p_rei_information11 		=>	p_rec.rei_information11 	,
		p_rei_information12 		=>	p_rec.rei_information12 	,
		p_rei_information13 		=>	p_rec.rei_information13 	,
		p_rei_information14 		=>	p_rec.rei_information14 	,
		p_rei_information15	 	=>	p_rec.rei_information15 	,
		p_rei_information16 		=>	p_rec.rei_information16 	,
		p_rei_information17	 	=>	p_rec.rei_information17 	,
		p_rei_information18 		=>	p_rec.rei_information18 	,
		p_rei_information19 		=>	p_rec.rei_information19 	,
		p_rei_information20 		=>	p_rec.rei_information20 	,
		p_rei_information21 		=>	p_rec.rei_information21 	,
		p_rei_information22 		=>	p_rec.rei_information22 	,
		p_rei_information28 		=>	p_rec.rei_information28 	,
		p_rei_information29 		=>	p_rec.rei_information29 	,
		p_rei_information23 		=>	p_rec.rei_information23 	,
		p_rei_information24 		=>	p_rec.rei_information24 	,
		p_rei_information25 		=>	p_rec.rei_information25 	,
		p_rei_information26 		=>	p_rec.rei_information26 	,
		p_rei_information27 		=>	p_rec.rei_information27 	,
		p_rei_information30 		=>	p_rec.rei_information30 	,
		p_request_id 			=>	p_rec.request_id 			,
		p_program_application_id 	=>	p_rec.program_application_id 	,
		p_program_id 			=>	p_rec.program_id 			,
		p_program_update_date 		=>	p_rec.program_update_date
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'GHR_PA_REQUEST_EXTRA_INFO'
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
  p_rec        in out nocopy  ghr_rei_shd.g_rec_type,
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
    SAVEPOINT ins_ghr_rei;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ghr_rei_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ghr_rei;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pa_request_extra_info_id     out nocopy  number,
  p_pa_request_id                in number,
  p_information_type             in varchar2,
  p_rei_attribute_category       in varchar2         default null,
  p_rei_attribute1               in varchar2         default null,
  p_rei_attribute2               in varchar2         default null,
  p_rei_attribute3               in varchar2         default null,
  p_rei_attribute4               in varchar2         default null,
  p_rei_attribute5               in varchar2         default null,
  p_rei_attribute6               in varchar2         default null,
  p_rei_attribute7               in varchar2         default null,
  p_rei_attribute8               in varchar2         default null,
  p_rei_attribute9               in varchar2         default null,
  p_rei_attribute10              in varchar2         default null,
  p_rei_attribute11              in varchar2         default null,
  p_rei_attribute12              in varchar2         default null,
  p_rei_attribute13              in varchar2         default null,
  p_rei_attribute14              in varchar2         default null,
  p_rei_attribute15              in varchar2         default null,
  p_rei_attribute16              in varchar2         default null,
  p_rei_attribute17              in varchar2         default null,
  p_rei_attribute18              in varchar2         default null,
  p_rei_attribute19              in varchar2         default null,
  p_rei_attribute20              in varchar2         default null,
  p_rei_information_category     in varchar2         default null,
  p_rei_information1             in varchar2         default null,
  p_rei_information2             in varchar2         default null,
  p_rei_information3             in varchar2         default null,
  p_rei_information4             in varchar2         default null,
  p_rei_information5             in varchar2         default null,
  p_rei_information6             in varchar2         default null,
  p_rei_information7             in varchar2         default null,
  p_rei_information8             in varchar2         default null,
  p_rei_information9             in varchar2         default null,
  p_rei_information10            in varchar2         default null,
  p_rei_information11            in varchar2         default null,
  p_rei_information12            in varchar2         default null,
  p_rei_information13            in varchar2         default null,
  p_rei_information14            in varchar2         default null,
  p_rei_information15            in varchar2         default null,
  p_rei_information16            in varchar2         default null,
  p_rei_information17            in varchar2         default null,
  p_rei_information18            in varchar2         default null,
  p_rei_information19            in varchar2         default null,
  p_rei_information20            in varchar2         default null,
  p_rei_information21            in varchar2         default null,
  p_rei_information22            in varchar2         default null,
  p_rei_information28            in varchar2         default null,
  p_rei_information29            in varchar2         default null,
  p_rei_information23            in varchar2         default null,
  p_rei_information24            in varchar2         default null,
  p_rei_information25            in varchar2         default null,
  p_rei_information26            in varchar2         default null,
  p_rei_information27            in varchar2         default null,
  p_rei_information30            in varchar2         default null,
  p_object_version_number        out nocopy  number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  ghr_rei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_rei_shd.convert_args
  (
  null,
  p_pa_request_id,
  p_information_type,
  p_rei_attribute_category,
  p_rei_attribute1,
  p_rei_attribute2,
  p_rei_attribute3,
  p_rei_attribute4,
  p_rei_attribute5,
  p_rei_attribute6,
  p_rei_attribute7,
  p_rei_attribute8,
  p_rei_attribute9,
  p_rei_attribute10,
  p_rei_attribute11,
  p_rei_attribute12,
  p_rei_attribute13,
  p_rei_attribute14,
  p_rei_attribute15,
  p_rei_attribute16,
  p_rei_attribute17,
  p_rei_attribute18,
  p_rei_attribute19,
  p_rei_attribute20,
  p_rei_information_category,
  p_rei_information1,
  p_rei_information2,
  p_rei_information3,
  p_rei_information4,
  p_rei_information5,
  p_rei_information6,
  p_rei_information7,
  p_rei_information8,
  p_rei_information9,
  p_rei_information10,
  p_rei_information11,
  p_rei_information12,
  p_rei_information13,
  p_rei_information14,
  p_rei_information15,
  p_rei_information16,
  p_rei_information17,
  p_rei_information18,
  p_rei_information19,
  p_rei_information20,
  p_rei_information21,
  p_rei_information22,
  p_rei_information28,
  p_rei_information29,
  p_rei_information23,
  p_rei_information24,
  p_rei_information25,
  p_rei_information26,
  p_rei_information27,
  p_rei_information30,
  null,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date
  );
  --
  -- Having converted the arguments into the ghr_rei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pa_request_extra_info_id := l_rec.pa_request_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_rei_ins;

/
