--------------------------------------------------------
--  DDL for Package Body PE_PEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_PEI_INS" as
/* $Header: pepeirhi.pkb 120.1 2005/07/25 05:01:42 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_pei_ins.';  -- Global package name
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
--      perform dml)
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therfore there is no ovn trigger to use it).
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
--   g_api_dml status is reset
--   (Note: Sue 1/29/97 Removed the need for setting g_api_dml as this is a new
--    table and therfore there is no ovn trigger to use it).
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out NOCOPY pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: per_people_extra_info
  --
  insert into per_people_extra_info
  (	person_extra_info_id,
	person_id,
	information_type,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	pei_attribute_category,
	pei_attribute1,
	pei_attribute2,
	pei_attribute3,
	pei_attribute4,
	pei_attribute5,
	pei_attribute6,
	pei_attribute7,
	pei_attribute8,
	pei_attribute9,
	pei_attribute10,
	pei_attribute11,
	pei_attribute12,
	pei_attribute13,
	pei_attribute14,
	pei_attribute15,
	pei_attribute16,
	pei_attribute17,
	pei_attribute18,
	pei_attribute19,
	pei_attribute20,
	pei_information_category,
	pei_information1,
	pei_information2,
	pei_information3,
	pei_information4,
	pei_information5,
	pei_information6,
	pei_information7,
	pei_information8,
	pei_information9,
	pei_information10,
	pei_information11,
	pei_information12,
	pei_information13,
	pei_information14,
	pei_information15,
	pei_information16,
	pei_information17,
	pei_information18,
	pei_information19,
	pei_information20,
	pei_information21,
	pei_information22,
	pei_information23,
	pei_information24,
	pei_information25,
	pei_information26,
	pei_information27,
	pei_information28,
	pei_information29,
	pei_information30,
	object_version_number
  )
  Values
  (	p_rec.person_extra_info_id,
	p_rec.person_id,
	p_rec.information_type,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.pei_attribute_category,
	p_rec.pei_attribute1,
	p_rec.pei_attribute2,
	p_rec.pei_attribute3,
	p_rec.pei_attribute4,
	p_rec.pei_attribute5,
	p_rec.pei_attribute6,
	p_rec.pei_attribute7,
	p_rec.pei_attribute8,
	p_rec.pei_attribute9,
	p_rec.pei_attribute10,
	p_rec.pei_attribute11,
	p_rec.pei_attribute12,
	p_rec.pei_attribute13,
	p_rec.pei_attribute14,
	p_rec.pei_attribute15,
	p_rec.pei_attribute16,
	p_rec.pei_attribute17,
	p_rec.pei_attribute18,
	p_rec.pei_attribute19,
	p_rec.pei_attribute20,
	p_rec.pei_information_category,
	p_rec.pei_information1,
	p_rec.pei_information2,
	p_rec.pei_information3,
	p_rec.pei_information4,
	p_rec.pei_information5,
	p_rec.pei_information6,
	p_rec.pei_information7,
	p_rec.pei_information8,
	p_rec.pei_information9,
	p_rec.pei_information10,
	p_rec.pei_information11,
	p_rec.pei_information12,
	p_rec.pei_information13,
	p_rec.pei_information14,
	p_rec.pei_information15,
	p_rec.pei_information16,
	p_rec.pei_information17,
	p_rec.pei_information18,
	p_rec.pei_information19,
	p_rec.pei_information20,
	p_rec.pei_information21,
	p_rec.pei_information22,
	p_rec.pei_information23,
	p_rec.pei_information24,
	p_rec.pei_information25,
	p_rec.pei_information26,
	p_rec.pei_information27,
	p_rec.pei_information28,
	p_rec.pei_information29,
	p_rec.pei_information30,
	p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pe_pei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pe_pei_shd.constraint_error
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
Procedure pre_insert(p_rec  in out NOCOPY pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_people_extra_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.person_extra_info_id;
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
Procedure post_insert(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     pe_pei_rki.after_insert	(
	p_person_extra_info_id		=>	p_rec.person_extra_info_id	,
	p_person_id			=>	p_rec.person_id			,
	p_information_type		=>	p_rec.information_type		,
	p_request_id			=>	p_rec.request_id			,
	p_program_application_id	=>	p_rec.program_application_id	,
	p_program_id			=>	p_rec.program_id			,
	p_program_update_date		=>	p_rec.program_update_date	,
	p_pei_attribute_category	=>	p_rec.pei_attribute_category	,
	p_pei_attribute1		=>	p_rec.pei_attribute1		,
	p_pei_attribute2		=>	p_rec.pei_attribute2		,
	p_pei_attribute3		=>	p_rec.pei_attribute3		,
	p_pei_attribute4		=>	p_rec.pei_attribute4		,
	p_pei_attribute5		=>	p_rec.pei_attribute5		,
	p_pei_attribute6		=>	p_rec.pei_attribute6		,
	p_pei_attribute7		=>	p_rec.pei_attribute7		,
	p_pei_attribute8		=>	p_rec.pei_attribute8		,
	p_pei_attribute9		=>	p_rec.pei_attribute9		,
	p_pei_attribute10		=>	p_rec.pei_attribute10		,
	p_pei_attribute11		=>	p_rec.pei_attribute11		,
	p_pei_attribute12		=>	p_rec.pei_attribute12		,
	p_pei_attribute13		=>	p_rec.pei_attribute13		,
	p_pei_attribute14		=>	p_rec.pei_attribute14		,
	p_pei_attribute15		=>	p_rec.pei_attribute15		,
	p_pei_attribute16		=>	p_rec.pei_attribute16		,
	p_pei_attribute17		=>	p_rec.pei_attribute17		,
	p_pei_attribute18		=>	p_rec.pei_attribute18		,
	p_pei_attribute19		=>	p_rec.pei_attribute19		,
	p_pei_attribute20		=>	p_rec.pei_attribute20		,
	p_pei_information_category	=>	p_rec.pei_information_category,
	p_pei_information1		=>	p_rec.pei_information1		,
	p_pei_information2		=>	p_rec.pei_information2		,
	p_pei_information3		=>	p_rec.pei_information3		,
	p_pei_information4		=>	p_rec.pei_information4		,
	p_pei_information5		=>	p_rec.pei_information5		,
	p_pei_information6		=>	p_rec.pei_information6		,
	p_pei_information7		=>	p_rec.pei_information7		,
	p_pei_information8		=>	p_rec.pei_information8		,
	p_pei_information9		=>	p_rec.pei_information9		,
	p_pei_information10		=>	p_rec.pei_information10		,
	p_pei_information11		=>	p_rec.pei_information11		,
	p_pei_information12		=>	p_rec.pei_information12		,
	p_pei_information13		=>	p_rec.pei_information13		,
	p_pei_information14		=>	p_rec.pei_information14		,
	p_pei_information15		=>	p_rec.pei_information15		,
	p_pei_information16		=>	p_rec.pei_information16		,
	p_pei_information17		=>	p_rec.pei_information17		,
	p_pei_information18		=>	p_rec.pei_information18		,
	p_pei_information19		=>	p_rec.pei_information19		,
	p_pei_information20		=>	p_rec.pei_information20		,
	p_pei_information21		=>	p_rec.pei_information21		,
	p_pei_information22		=>	p_rec.pei_information22		,
	p_pei_information23		=>	p_rec.pei_information23		,
	p_pei_information24		=>	p_rec.pei_information24		,
	p_pei_information25		=>	p_rec.pei_information25		,
	p_pei_information26		=>	p_rec.pei_information26		,
	p_pei_information27		=>	p_rec.pei_information27		,
	p_pei_information28		=>	p_rec.pei_information28		,
	p_pei_information29		=>	p_rec.pei_information29		,
	p_pei_information30		=>	p_rec.pei_information30
	);
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_PEOPLE_EXTRA_INFO'
			,p_hook_type  => 'AI'
	        );
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  if p_rec.INFORMATION_TYPE = 'PQH_ROLE_USERS'  then
   if nvl(p_rec.PEI_INFORMATION5,'N') = 'Y' then
    declare
      l_user_name varchar2(50);
      l_start_date date;
      l_expiration_date date;
      cursor c1 is
      select usr.user_name, usr.start_date, nvl(usr.end_date, hr_general.end_of_time)
      from fnd_user usr
      where usr.employee_id = p_rec.person_id;
    begin
      open c1;
      fetch c1 into l_user_name, l_start_date, l_expiration_date;
      if c1%found then
        close c1;
        WF_LOCAL_SYNCH.propagate_user_role(p_user_orig_system      => 'PER',
                              p_user_orig_system_id   => p_rec.person_id,
                              p_role_orig_system      => 'PQH_ROLE',
                              p_role_orig_system_id   => p_rec.pei_information3,
                              p_start_date            => l_start_date,
                              p_expiration_date       => l_expiration_date);
      else
        close c1;
      end if;
    end;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out NOCOPY pe_pei_shd.g_rec_type,
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
    SAVEPOINT ins_pe_pei;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  pe_pei_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_pe_pei;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_person_extra_info_id         out NOCOPY number,
  p_person_id                    in number,
  p_information_type             in varchar2,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_pei_attribute_category       in varchar2         default null,
  p_pei_attribute1               in varchar2         default null,
  p_pei_attribute2               in varchar2         default null,
  p_pei_attribute3               in varchar2         default null,
  p_pei_attribute4               in varchar2         default null,
  p_pei_attribute5               in varchar2         default null,
  p_pei_attribute6               in varchar2         default null,
  p_pei_attribute7               in varchar2         default null,
  p_pei_attribute8               in varchar2         default null,
  p_pei_attribute9               in varchar2         default null,
  p_pei_attribute10              in varchar2         default null,
  p_pei_attribute11              in varchar2         default null,
  p_pei_attribute12              in varchar2         default null,
  p_pei_attribute13              in varchar2         default null,
  p_pei_attribute14              in varchar2         default null,
  p_pei_attribute15              in varchar2         default null,
  p_pei_attribute16              in varchar2         default null,
  p_pei_attribute17              in varchar2         default null,
  p_pei_attribute18              in varchar2         default null,
  p_pei_attribute19              in varchar2         default null,
  p_pei_attribute20              in varchar2         default null,
  p_pei_information_category     in varchar2         default null,
  p_pei_information1             in varchar2         default null,
  p_pei_information2             in varchar2         default null,
  p_pei_information3             in varchar2         default null,
  p_pei_information4             in varchar2         default null,
  p_pei_information5             in varchar2         default null,
  p_pei_information6             in varchar2         default null,
  p_pei_information7             in varchar2         default null,
  p_pei_information8             in varchar2         default null,
  p_pei_information9             in varchar2         default null,
  p_pei_information10            in varchar2         default null,
  p_pei_information11            in varchar2         default null,
  p_pei_information12            in varchar2         default null,
  p_pei_information13            in varchar2         default null,
  p_pei_information14            in varchar2         default null,
  p_pei_information15            in varchar2         default null,
  p_pei_information16            in varchar2         default null,
  p_pei_information17            in varchar2         default null,
  p_pei_information18            in varchar2         default null,
  p_pei_information19            in varchar2         default null,
  p_pei_information20            in varchar2         default null,
  p_pei_information21            in varchar2         default null,
  p_pei_information22            in varchar2         default null,
  p_pei_information23            in varchar2         default null,
  p_pei_information24            in varchar2         default null,
  p_pei_information25            in varchar2         default null,
  p_pei_information26            in varchar2         default null,
  p_pei_information27            in varchar2         default null,
  p_pei_information28            in varchar2         default null,
  p_pei_information29            in varchar2         default null,
  p_pei_information30            in varchar2         default null,
  p_object_version_number        out NOCOPY number,
  p_validate                     in boolean   default false
  ) is
--
  l_rec	  pe_pei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pe_pei_shd.convert_args
  (
  null,
  p_person_id,
  p_information_type,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_pei_attribute_category,
  p_pei_attribute1,
  p_pei_attribute2,
  p_pei_attribute3,
  p_pei_attribute4,
  p_pei_attribute5,
  p_pei_attribute6,
  p_pei_attribute7,
  p_pei_attribute8,
  p_pei_attribute9,
  p_pei_attribute10,
  p_pei_attribute11,
  p_pei_attribute12,
  p_pei_attribute13,
  p_pei_attribute14,
  p_pei_attribute15,
  p_pei_attribute16,
  p_pei_attribute17,
  p_pei_attribute18,
  p_pei_attribute19,
  p_pei_attribute20,
  p_pei_information_category,
  p_pei_information1,
  p_pei_information2,
  p_pei_information3,
  p_pei_information4,
  p_pei_information5,
  p_pei_information6,
  p_pei_information7,
  p_pei_information8,
  p_pei_information9,
  p_pei_information10,
  p_pei_information11,
  p_pei_information12,
  p_pei_information13,
  p_pei_information14,
  p_pei_information15,
  p_pei_information16,
  p_pei_information17,
  p_pei_information18,
  p_pei_information19,
  p_pei_information20,
  p_pei_information21,
  p_pei_information22,
  p_pei_information23,
  p_pei_information24,
  p_pei_information25,
  p_pei_information26,
  p_pei_information27,
  p_pei_information28,
  p_pei_information29,
  p_pei_information30,
  null
  );
  --
  -- Having converted the arguments into the pe_pei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_person_extra_info_id := l_rec.person_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pe_pei_ins;

/
