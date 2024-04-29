--------------------------------------------------------
--  DDL for Package Body PER_REI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REI_INS" as
/* $Header: pereirhi.pkb 115.6 2003/10/07 19:01:25 ttagawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rei_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_contact_extra_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_contact_extra_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_rei_ins.g_contact_extra_info_id_i := p_contact_extra_info_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_insert_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic for datetrack. The
--   functions of this procedure are as follows:
--   1) Get the object_version_number.
--   2) To set the effective start and end dates to the corresponding
--      validation start and end dates. Also, the object version number
--      record attribute is set.
--   3) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   4) To insert the row into the schema with the derived effective start
--      and end dates and the object version number.
--   5) To trap any constraint violations that may have occurred.
--   6) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   insert_dml and pre_update (logic permitting) procedure and must have
--   all mandatory arguments set.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   This is an internal datetrack maintenance procedure which should
--   not be modified in anyway.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_insert_dml
  (p_rec                     in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
-- Cursor to select 'old' created AOL who column values
--
  Cursor C_Sel1 Is
    select t.created_by,
           t.creation_date
    from   per_contact_extra_info_f t
    where  t.contact_extra_info_id       = p_rec.contact_extra_info_id
    and    t.effective_start_date =
             per_rei_shd.g_old_rec.effective_start_date
    and    t.effective_end_date   = (p_validation_start_date - 1);
--
  l_proc                varchar2(72) := g_package||'dt_insert_dml';
  l_created_by          per_contact_extra_info_f.created_by%TYPE;
  l_creation_date       per_contact_extra_info_f.creation_date%TYPE;
  l_last_update_date    per_contact_extra_info_f.last_update_date%TYPE;
  l_last_updated_by     per_contact_extra_info_f.last_updated_by%TYPE;
  l_last_update_login   per_contact_extra_info_f.last_update_login%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the object version number for the insert
  --
  p_rec.object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name => 'per_contact_extra_info_f'
      ,p_base_key_column => 'contact_extra_info_id'
      ,p_base_key_value  => p_rec.contact_extra_info_id
      );
  --
  -- Set the effective start and end dates to the corresponding
  -- validation start and end dates
  --
  p_rec.effective_start_date := p_validation_start_date;
  p_rec.effective_end_date   := p_validation_end_date;
  --
  -- If the datetrack_mode is not INSERT then we must populate the WHO
  -- columns with the 'old' creation values and 'new' updated values.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    hr_utility.set_location(l_proc, 10);
    --
    -- Select the 'old' created values
    --
    Open C_Sel1;
    Fetch C_Sel1 Into l_created_by, l_creation_date;
    If C_Sel1%notfound Then
      --
      -- The previous 'old' created row has not been found. We need
      -- to error as an internal datetrack problem exists.
      --
      Close C_Sel1;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    --
    -- Set the AOL updated WHO values
    --
    l_last_update_date   := sysdate;
    l_last_updated_by    := fnd_global.user_id;
    l_last_update_login  := fnd_global.login_id;
  End If;
  --
  per_rei_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: per_contact_extra_info_f
  --
  insert into per_contact_extra_info_f
      (contact_extra_info_id
      ,effective_start_date
      ,effective_end_date
      ,contact_relationship_id
      ,information_type
      ,cei_information_category
      ,cei_information1
      ,cei_information2
      ,cei_information3
      ,cei_information4
      ,cei_information5
      ,cei_information6
      ,cei_information7
      ,cei_information8
      ,cei_information9
      ,cei_information10
      ,cei_information11
      ,cei_information12
      ,cei_information13
      ,cei_information14
      ,cei_information15
      ,cei_information16
      ,cei_information17
      ,cei_information18
      ,cei_information19
      ,cei_information20
      ,cei_information21
      ,cei_information22
      ,cei_information23
      ,cei_information24
      ,cei_information25
      ,cei_information26
      ,cei_information27
      ,cei_information28
      ,cei_information29
      ,cei_information30
      ,cei_attribute_category
      ,cei_attribute1
      ,cei_attribute2
      ,cei_attribute3
      ,cei_attribute4
      ,cei_attribute5
      ,cei_attribute6
      ,cei_attribute7
      ,cei_attribute8
      ,cei_attribute9
      ,cei_attribute10
      ,cei_attribute11
      ,cei_attribute12
      ,cei_attribute13
      ,cei_attribute14
      ,cei_attribute15
      ,cei_attribute16
      ,cei_attribute17
      ,cei_attribute18
      ,cei_attribute19
      ,cei_attribute20
      ,object_version_number
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,created_by
      ,creation_date
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      )
  Values
    (p_rec.contact_extra_info_id
    ,p_rec.effective_start_date
    ,p_rec.effective_end_date
    ,p_rec.contact_relationship_id
    ,p_rec.information_type
    ,p_rec.cei_information_category
    ,p_rec.cei_information1
    ,p_rec.cei_information2
    ,p_rec.cei_information3
    ,p_rec.cei_information4
    ,p_rec.cei_information5
    ,p_rec.cei_information6
    ,p_rec.cei_information7
    ,p_rec.cei_information8
    ,p_rec.cei_information9
    ,p_rec.cei_information10
    ,p_rec.cei_information11
    ,p_rec.cei_information12
    ,p_rec.cei_information13
    ,p_rec.cei_information14
    ,p_rec.cei_information15
    ,p_rec.cei_information16
    ,p_rec.cei_information17
    ,p_rec.cei_information18
    ,p_rec.cei_information19
    ,p_rec.cei_information20
    ,p_rec.cei_information21
    ,p_rec.cei_information22
    ,p_rec.cei_information23
    ,p_rec.cei_information24
    ,p_rec.cei_information25
    ,p_rec.cei_information26
    ,p_rec.cei_information27
    ,p_rec.cei_information28
    ,p_rec.cei_information29
    ,p_rec.cei_information30
    ,p_rec.cei_attribute_category
    ,p_rec.cei_attribute1
    ,p_rec.cei_attribute2
    ,p_rec.cei_attribute3
    ,p_rec.cei_attribute4
    ,p_rec.cei_attribute5
    ,p_rec.cei_attribute6
    ,p_rec.cei_attribute7
    ,p_rec.cei_attribute8
    ,p_rec.cei_attribute9
    ,p_rec.cei_attribute10
    ,p_rec.cei_attribute11
    ,p_rec.cei_attribute12
    ,p_rec.cei_attribute13
    ,p_rec.cei_attribute14
    ,p_rec.cei_attribute15
    ,p_rec.cei_attribute16
    ,p_rec.cei_attribute17
    ,p_rec.cei_attribute18
    ,p_rec.cei_attribute19
    ,p_rec.cei_attribute20
    ,p_rec.object_version_number
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,l_created_by
    ,l_creation_date
    ,l_last_update_date
    ,l_last_updated_by
    ,l_last_update_login
    );
  --
  per_rei_shd.g_api_dml := false;   -- Unset the api dml status
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    per_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    per_rei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_rei_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec                   in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_rei_ins.dt_insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
--   Also, if comments are defined for this entity, the comments insert
--   logic will also be called, generating a comment_id if required.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec                   in out nocopy per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor C_Sel1 is select per_contact_extra_info_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_contact_extra_info_f
     where contact_extra_info_id =
             per_rei_ins.g_contact_extra_info_id_i;
--
  l_proc        varchar2(72) := g_package||'pre_insert';
  l_exists      varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_rei_ins.g_contact_extra_info_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','per_contact_extra_info_f');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.contact_extra_info_id :=
      per_rei_ins.g_contact_extra_info_id_i;
    per_rei_ins.g_contact_extra_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.contact_extra_info_id;
    Close C_Sel1;
  End If;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< post_insert >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_rec                   in per_rei_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_rei_rki.after_insert
      (p_effective_date
      => p_effective_date
      ,p_validation_start_date
      => p_validation_start_date
      ,p_validation_end_date
      => p_validation_end_date
      ,p_contact_extra_info_id
      => p_rec.contact_extra_info_id
      ,p_effective_start_date
      => p_rec.effective_start_date
      ,p_effective_end_date
      => p_rec.effective_end_date
      ,p_contact_relationship_id
      => p_rec.contact_relationship_id
      ,p_information_type
      => p_rec.information_type
      ,p_cei_information_category
      => p_rec.cei_information_category
      ,p_cei_information1
      => p_rec.cei_information1
      ,p_cei_information2
      => p_rec.cei_information2
      ,p_cei_information3
      => p_rec.cei_information3
      ,p_cei_information4
      => p_rec.cei_information4
      ,p_cei_information5
      => p_rec.cei_information5
      ,p_cei_information6
      => p_rec.cei_information6
      ,p_cei_information7
      => p_rec.cei_information7
      ,p_cei_information8
      => p_rec.cei_information8
      ,p_cei_information9
      => p_rec.cei_information9
      ,p_cei_information10
      => p_rec.cei_information10
      ,p_cei_information11
      => p_rec.cei_information11
      ,p_cei_information12
      => p_rec.cei_information12
      ,p_cei_information13
      => p_rec.cei_information13
      ,p_cei_information14
      => p_rec.cei_information14
      ,p_cei_information15
      => p_rec.cei_information15
      ,p_cei_information16
      => p_rec.cei_information16
      ,p_cei_information17
      => p_rec.cei_information17
      ,p_cei_information18
      => p_rec.cei_information18
      ,p_cei_information19
      => p_rec.cei_information19
      ,p_cei_information20
      => p_rec.cei_information20
      ,p_cei_information21
      => p_rec.cei_information21
      ,p_cei_information22
      => p_rec.cei_information22
      ,p_cei_information23
      => p_rec.cei_information23
      ,p_cei_information24
      => p_rec.cei_information24
      ,p_cei_information25
      => p_rec.cei_information25
      ,p_cei_information26
      => p_rec.cei_information26
      ,p_cei_information27
      => p_rec.cei_information27
      ,p_cei_information28
      => p_rec.cei_information28
      ,p_cei_information29
      => p_rec.cei_information29
      ,p_cei_information30
      => p_rec.cei_information30
      ,p_cei_attribute_category
      => p_rec.cei_attribute_category
      ,p_cei_attribute1
      => p_rec.cei_attribute1
      ,p_cei_attribute2
      => p_rec.cei_attribute2
      ,p_cei_attribute3
      => p_rec.cei_attribute3
      ,p_cei_attribute4
      => p_rec.cei_attribute4
      ,p_cei_attribute5
      => p_rec.cei_attribute5
      ,p_cei_attribute6
      => p_rec.cei_attribute6
      ,p_cei_attribute7
      => p_rec.cei_attribute7
      ,p_cei_attribute8
      => p_rec.cei_attribute8
      ,p_cei_attribute9
      => p_rec.cei_attribute9
      ,p_cei_attribute10
      => p_rec.cei_attribute10
      ,p_cei_attribute11
      => p_rec.cei_attribute11
      ,p_cei_attribute12
      => p_rec.cei_attribute12
      ,p_cei_attribute13
      => p_rec.cei_attribute13
      ,p_cei_attribute14
      => p_rec.cei_attribute14
      ,p_cei_attribute15
      => p_rec.cei_attribute15
      ,p_cei_attribute16
      => p_rec.cei_attribute16
      ,p_cei_attribute17
      => p_rec.cei_attribute17
      ,p_cei_attribute18
      => p_rec.cei_attribute18
      ,p_cei_attribute19
      => p_rec.cei_attribute19
      ,p_cei_attribute20
      => p_rec.cei_attribute20
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CONTACT_EXTRA_INFO_F'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< ins_lck >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The ins_lck process has one main function to perform. When inserting
--   a datetracked row, we must validate the DT mode.
--
-- Prerequisites:
--   This procedure can only be called for the datetrack mode of INSERT.
--
-- In Parameters:
--
-- Post Success:
--   On successful completion of the ins_lck process the parental
--   datetracked rows will be locked providing the p_enforce_foreign_locking
--   argument value is TRUE.
--   If the p_enforce_foreign_locking argument value is FALSE then the
--   parential rows are not locked.
--
-- Post Failure:
--   The Lck process can fail for:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) When attempting to the lock the parent which doesn't exist.
--      For the entity to be locked the parent must exist!
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins_lck
  (p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_rec                   in per_rei_shd.g_rec_type
  ,p_validation_start_date out nocopy date
  ,p_validation_end_date   out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'ins_lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_person_id             number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  select  person_id
  into    l_person_id
  from    per_contact_relationships
  where   contact_relationship_id = p_rec.contact_relationship_id;
  --
  -- Validate the datetrack mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode
    (p_effective_date          => p_effective_date
    ,p_datetrack_mode          => p_datetrack_mode
    ,p_base_table_name         => 'per_contact_extra_info_f'
    ,p_base_key_column         => 'contact_extra_info_id'
    ,p_base_key_value          => p_rec.contact_extra_info_id
    ,p_parent_table_name1      => 'per_all_people_f'
    ,p_parent_key_column1      => 'person_id'
    ,p_parent_key_value1       => l_person_id
    ,p_enforce_foreign_locking => true
    ,p_validation_start_date   => l_validation_start_date
    ,p_validation_end_date     => l_validation_end_date
    );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End ins_lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date in     date
  ,p_rec            in out nocopy per_rei_shd.g_rec_type
  ) is
--
  l_proc                        varchar2(72) := g_package||'ins';
  l_datetrack_mode              varchar2(30) := hr_api.g_insert;
  l_validation_start_date       date;
  l_validation_end_date         date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the lock operation
  --
  per_rei_ins.ins_lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_rec                   => p_rec
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting insert validate operations
  --
  per_rei_bus.insert_validate
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  per_rei_ins.pre_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Insert the row
  --
  per_rei_ins.insert_dml
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call the supporting post-insert operation
  --
  per_rei_ins.post_insert
    (p_rec                   => p_rec
    ,p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_datetrack_mode
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_contact_relationship_id        in     number
  ,p_information_type               in     varchar2
  ,p_cei_information_category       in     varchar2 default null
  ,p_cei_information1               in     varchar2 default null
  ,p_cei_information2               in     varchar2 default null
  ,p_cei_information3               in     varchar2 default null
  ,p_cei_information4               in     varchar2 default null
  ,p_cei_information5               in     varchar2 default null
  ,p_cei_information6               in     varchar2 default null
  ,p_cei_information7               in     varchar2 default null
  ,p_cei_information8               in     varchar2 default null
  ,p_cei_information9               in     varchar2 default null
  ,p_cei_information10              in     varchar2 default null
  ,p_cei_information11              in     varchar2 default null
  ,p_cei_information12              in     varchar2 default null
  ,p_cei_information13              in     varchar2 default null
  ,p_cei_information14              in     varchar2 default null
  ,p_cei_information15              in     varchar2 default null
  ,p_cei_information16              in     varchar2 default null
  ,p_cei_information17              in     varchar2 default null
  ,p_cei_information18              in     varchar2 default null
  ,p_cei_information19              in     varchar2 default null
  ,p_cei_information20              in     varchar2 default null
  ,p_cei_information21              in     varchar2 default null
  ,p_cei_information22              in     varchar2 default null
  ,p_cei_information23              in     varchar2 default null
  ,p_cei_information24              in     varchar2 default null
  ,p_cei_information25              in     varchar2 default null
  ,p_cei_information26              in     varchar2 default null
  ,p_cei_information27              in     varchar2 default null
  ,p_cei_information28              in     varchar2 default null
  ,p_cei_information29              in     varchar2 default null
  ,p_cei_information30              in     varchar2 default null
  ,p_cei_attribute_category         in     varchar2 default null
  ,p_cei_attribute1                 in     varchar2 default null
  ,p_cei_attribute2                 in     varchar2 default null
  ,p_cei_attribute3                 in     varchar2 default null
  ,p_cei_attribute4                 in     varchar2 default null
  ,p_cei_attribute5                 in     varchar2 default null
  ,p_cei_attribute6                 in     varchar2 default null
  ,p_cei_attribute7                 in     varchar2 default null
  ,p_cei_attribute8                 in     varchar2 default null
  ,p_cei_attribute9                 in     varchar2 default null
  ,p_cei_attribute10                in     varchar2 default null
  ,p_cei_attribute11                in     varchar2 default null
  ,p_cei_attribute12                in     varchar2 default null
  ,p_cei_attribute13                in     varchar2 default null
  ,p_cei_attribute14                in     varchar2 default null
  ,p_cei_attribute15                in     varchar2 default null
  ,p_cei_attribute16                in     varchar2 default null
  ,p_cei_attribute17                in     varchar2 default null
  ,p_cei_attribute18                in     varchar2 default null
  ,p_cei_attribute19                in     varchar2 default null
  ,p_cei_attribute20                in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_contact_extra_info_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) is
--
  l_rec         per_rei_shd.g_rec_type;
  l_proc        varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_rei_shd.convert_args
    (null
    ,null
    ,null
    ,p_contact_relationship_id
    ,p_information_type
    ,p_cei_information_category
    ,p_cei_information1
    ,p_cei_information2
    ,p_cei_information3
    ,p_cei_information4
    ,p_cei_information5
    ,p_cei_information6
    ,p_cei_information7
    ,p_cei_information8
    ,p_cei_information9
    ,p_cei_information10
    ,p_cei_information11
    ,p_cei_information12
    ,p_cei_information13
    ,p_cei_information14
    ,p_cei_information15
    ,p_cei_information16
    ,p_cei_information17
    ,p_cei_information18
    ,p_cei_information19
    ,p_cei_information20
    ,p_cei_information21
    ,p_cei_information22
    ,p_cei_information23
    ,p_cei_information24
    ,p_cei_information25
    ,p_cei_information26
    ,p_cei_information27
    ,p_cei_information28
    ,p_cei_information29
    ,p_cei_information30
    ,p_cei_attribute_category
    ,p_cei_attribute1
    ,p_cei_attribute2
    ,p_cei_attribute3
    ,p_cei_attribute4
    ,p_cei_attribute5
    ,p_cei_attribute6
    ,p_cei_attribute7
    ,p_cei_attribute8
    ,p_cei_attribute9
    ,p_cei_attribute10
    ,p_cei_attribute11
    ,p_cei_attribute12
    ,p_cei_attribute13
    ,p_cei_attribute14
    ,p_cei_attribute15
    ,p_cei_attribute16
    ,p_cei_attribute17
    ,p_cei_attribute18
    ,p_cei_attribute19
    ,p_cei_attribute20
    ,null
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    );
  --
  -- Having converted the arguments into the per_rei_rec
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_rei_ins.ins
    (p_effective_date
    ,l_rec
    );
  --
  -- Set the OUT arguments.
  --
  p_contact_extra_info_id            := l_rec.contact_extra_info_id;
  p_effective_start_date             := l_rec.effective_start_date;
  p_effective_end_date               := l_rec.effective_end_date;
  p_object_version_number            := l_rec.object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_rei_ins;

/
