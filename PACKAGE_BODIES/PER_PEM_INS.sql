--------------------------------------------------------
--  DDL for Package Body PER_PEM_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEM_INS" as
/* $Header: pepemrhi.pkb 120.1.12010000.3 2009/01/12 08:21:02 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pem_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_previous_employer_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_previous_employer_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_pem_ins.g_previous_employer_id_i := p_previous_employer_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
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
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
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
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_previous_employers
  --
  insert into per_previous_employers
      (previous_employer_id
      ,business_group_id
      ,person_id
      ,party_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,employer_name
      ,employer_country
      ,employer_address
      ,employer_type
      ,employer_subtype
      ,description
      ,pem_attribute_category
      ,pem_attribute1
      ,pem_attribute2
      ,pem_attribute3
      ,pem_attribute4
      ,pem_attribute5
      ,pem_attribute6
      ,pem_attribute7
      ,pem_attribute8
      ,pem_attribute9
      ,pem_attribute10
      ,pem_attribute11
      ,pem_attribute12
      ,pem_attribute13
      ,pem_attribute14
      ,pem_attribute15
      ,pem_attribute16
      ,pem_attribute17
      ,pem_attribute18
      ,pem_attribute19
      ,pem_attribute20
      ,pem_attribute21
      ,pem_attribute22
      ,pem_attribute23
      ,pem_attribute24
      ,pem_attribute25
      ,pem_attribute26
      ,pem_attribute27
      ,pem_attribute28
      ,pem_attribute29
      ,pem_attribute30
      ,pem_information_category
      ,pem_information1
      ,pem_information2
      ,pem_information3
      ,pem_information4
      ,pem_information5
      ,pem_information6
      ,pem_information7
      ,pem_information8
      ,pem_information9
      ,pem_information10
      ,pem_information11
      ,pem_information12
      ,pem_information13
      ,pem_information14
      ,pem_information15
      ,pem_information16
      ,pem_information17
      ,pem_information18
      ,pem_information19
      ,pem_information20
      ,pem_information21
      ,pem_information22
      ,pem_information23
      ,pem_information24
      ,pem_information25
      ,pem_information26
      ,pem_information27
      ,pem_information28
      ,pem_information29
      ,pem_information30
      ,object_version_number
      ,all_assignments
      ,period_months
      )
  Values
    (p_rec.previous_employer_id
    ,p_rec.business_group_id
    ,p_rec.person_id
    ,p_rec.party_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.period_years
    ,p_rec.period_days
    ,p_rec.employer_name
    ,p_rec.employer_country
    ,p_rec.employer_address
    ,p_rec.employer_type
    ,p_rec.employer_subtype
    ,p_rec.description
    ,p_rec.pem_attribute_category
    ,p_rec.pem_attribute1
    ,p_rec.pem_attribute2
    ,p_rec.pem_attribute3
    ,p_rec.pem_attribute4
    ,p_rec.pem_attribute5
    ,p_rec.pem_attribute6
    ,p_rec.pem_attribute7
    ,p_rec.pem_attribute8
    ,p_rec.pem_attribute9
    ,p_rec.pem_attribute10
    ,p_rec.pem_attribute11
    ,p_rec.pem_attribute12
    ,p_rec.pem_attribute13
    ,p_rec.pem_attribute14
    ,p_rec.pem_attribute15
    ,p_rec.pem_attribute16
    ,p_rec.pem_attribute17
    ,p_rec.pem_attribute18
    ,p_rec.pem_attribute19
    ,p_rec.pem_attribute20
    ,p_rec.pem_attribute21
    ,p_rec.pem_attribute22
    ,p_rec.pem_attribute23
    ,p_rec.pem_attribute24
    ,p_rec.pem_attribute25
    ,p_rec.pem_attribute26
    ,p_rec.pem_attribute27
    ,p_rec.pem_attribute28
    ,p_rec.pem_attribute29
    ,p_rec.pem_attribute30
    ,p_rec.pem_information_category
    ,p_rec.pem_information1
    ,p_rec.pem_information2
    ,p_rec.pem_information3
    ,p_rec.pem_information4
    ,p_rec.pem_information5
    ,p_rec.pem_information6
    ,p_rec.pem_information7
    ,p_rec.pem_information8
    ,p_rec.pem_information9
    ,p_rec.pem_information10
    ,p_rec.pem_information11
    ,p_rec.pem_information12
    ,p_rec.pem_information13
    ,p_rec.pem_information14
    ,p_rec.pem_information15
    ,p_rec.pem_information16
    ,p_rec.pem_information17
    ,p_rec.pem_information18
    ,p_rec.pem_information19
    ,p_rec.pem_information20
    ,p_rec.pem_information21
    ,p_rec.pem_information22
    ,p_rec.pem_information23
    ,p_rec.pem_information24
    ,p_rec.pem_information25
    ,p_rec.pem_information26
    ,p_rec.pem_information27
    ,p_rec.pem_information28
    ,p_rec.pem_information29
    ,p_rec.pem_information30
    ,p_rec.object_version_number
    ,p_rec.all_assignments
    ,p_rec.period_months
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pem_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pem_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pem_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
  (p_rec  in out nocopy per_pem_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_previous_employers_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_previous_employers
     where previous_employer_id =
             per_pem_ins.g_previous_employer_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_pem_ins.g_previous_employer_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_previous_employers');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.previous_employer_id :=
      per_pem_ins.g_previous_employer_id_i;
    per_pem_ins.g_previous_employer_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.previous_employer_id;
    Close C_Sel1;
  End If;
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
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pem_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_person_id
      => p_rec.person_id
      ,p_party_id
      => p_rec.party_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_employer_name
      => p_rec.employer_name
      ,p_employer_country
      => p_rec.employer_country
      ,p_employer_address
      => p_rec.employer_address
      ,p_employer_type
      => p_rec.employer_type
      ,p_employer_subtype
      => p_rec.employer_subtype
      ,p_description
      => p_rec.description
      ,p_pem_attribute_category
      => p_rec.pem_attribute_category
      ,p_pem_attribute1
      => p_rec.pem_attribute1
      ,p_pem_attribute2
      => p_rec.pem_attribute2
      ,p_pem_attribute3
      => p_rec.pem_attribute3
      ,p_pem_attribute4
      => p_rec.pem_attribute4
      ,p_pem_attribute5
      => p_rec.pem_attribute5
      ,p_pem_attribute6
      => p_rec.pem_attribute6
      ,p_pem_attribute7
      => p_rec.pem_attribute7
      ,p_pem_attribute8
      => p_rec.pem_attribute8
      ,p_pem_attribute9
      => p_rec.pem_attribute9
      ,p_pem_attribute10
      => p_rec.pem_attribute10
      ,p_pem_attribute11
      => p_rec.pem_attribute11
      ,p_pem_attribute12
      => p_rec.pem_attribute12
      ,p_pem_attribute13
      => p_rec.pem_attribute13
      ,p_pem_attribute14
      => p_rec.pem_attribute14
      ,p_pem_attribute15
      => p_rec.pem_attribute15
      ,p_pem_attribute16
      => p_rec.pem_attribute16
      ,p_pem_attribute17
      => p_rec.pem_attribute17
      ,p_pem_attribute18
      => p_rec.pem_attribute18
      ,p_pem_attribute19
      => p_rec.pem_attribute19
      ,p_pem_attribute20
      => p_rec.pem_attribute20
      ,p_pem_attribute21
      => p_rec.pem_attribute21
      ,p_pem_attribute22
      => p_rec.pem_attribute22
      ,p_pem_attribute23
      => p_rec.pem_attribute23
      ,p_pem_attribute24
      => p_rec.pem_attribute24
      ,p_pem_attribute25
      => p_rec.pem_attribute25
      ,p_pem_attribute26
      => p_rec.pem_attribute26
      ,p_pem_attribute27
      => p_rec.pem_attribute27
      ,p_pem_attribute28
      => p_rec.pem_attribute28
      ,p_pem_attribute29
      => p_rec.pem_attribute29
      ,p_pem_attribute30
      => p_rec.pem_attribute30
      ,p_pem_information_category
      => p_rec.pem_information_category
      ,p_pem_information1
      => p_rec.pem_information1
      ,p_pem_information2
      => p_rec.pem_information2
      ,p_pem_information3
      => p_rec.pem_information3
      ,p_pem_information4
      => p_rec.pem_information4
      ,p_pem_information5
      => p_rec.pem_information5
      ,p_pem_information6
      => p_rec.pem_information6
      ,p_pem_information7
      => p_rec.pem_information7
      ,p_pem_information8
      => p_rec.pem_information8
      ,p_pem_information9
      => p_rec.pem_information9
      ,p_pem_information10
      => p_rec.pem_information10
      ,p_pem_information11
      => p_rec.pem_information11
      ,p_pem_information12
      => p_rec.pem_information12
      ,p_pem_information13
      => p_rec.pem_information13
      ,p_pem_information14
      => p_rec.pem_information14
      ,p_pem_information15
      => p_rec.pem_information15
      ,p_pem_information16
      => p_rec.pem_information16
      ,p_pem_information17
      => p_rec.pem_information17
      ,p_pem_information18
      => p_rec.pem_information18
      ,p_pem_information19
      => p_rec.pem_information19
      ,p_pem_information20
      => p_rec.pem_information20
      ,p_pem_information21
      => p_rec.pem_information21
      ,p_pem_information22
      => p_rec.pem_information22
      ,p_pem_information23
      => p_rec.pem_information23
      ,p_pem_information24
      => p_rec.pem_information24
      ,p_pem_information25
      => p_rec.pem_information25
      ,p_pem_information26
      => p_rec.pem_information26
      ,p_pem_information27
      => p_rec.pem_information27
      ,p_pem_information28
      => p_rec.pem_information28
      ,p_pem_information29
      => p_rec.pem_information29
      ,p_pem_information30
      => p_rec.pem_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_all_assignments
      => p_rec.all_assignments
      ,p_period_months
      => p_rec.period_months
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREVIOUS_EMPLOYERS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_pem_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  per_pem_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_pem_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_pem_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_business_group_id              in     number   default null
  ,p_person_id                      in     number   default null
  ,p_party_id                       in     number   default null
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_days                    in     number   default null
  ,p_employer_name                  in     varchar2 default null
  ,p_employer_country               in     varchar2 default null
  ,p_employer_address               in     varchar2 default null
  ,p_employer_type                  in     varchar2 default null
  ,p_employer_subtype               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_pem_attribute_category         in     varchar2 default null
  ,p_pem_attribute1                 in     varchar2 default null
  ,p_pem_attribute2                 in     varchar2 default null
  ,p_pem_attribute3                 in     varchar2 default null
  ,p_pem_attribute4                 in     varchar2 default null
  ,p_pem_attribute5                 in     varchar2 default null
  ,p_pem_attribute6                 in     varchar2 default null
  ,p_pem_attribute7                 in     varchar2 default null
  ,p_pem_attribute8                 in     varchar2 default null
  ,p_pem_attribute9                 in     varchar2 default null
  ,p_pem_attribute10                in     varchar2 default null
  ,p_pem_attribute11                in     varchar2 default null
  ,p_pem_attribute12                in     varchar2 default null
  ,p_pem_attribute13                in     varchar2 default null
  ,p_pem_attribute14                in     varchar2 default null
  ,p_pem_attribute15                in     varchar2 default null
  ,p_pem_attribute16                in     varchar2 default null
  ,p_pem_attribute17                in     varchar2 default null
  ,p_pem_attribute18                in     varchar2 default null
  ,p_pem_attribute19                in     varchar2 default null
  ,p_pem_attribute20                in     varchar2 default null
  ,p_pem_attribute21                in     varchar2 default null
  ,p_pem_attribute22                in     varchar2 default null
  ,p_pem_attribute23                in     varchar2 default null
  ,p_pem_attribute24                in     varchar2 default null
  ,p_pem_attribute25                in     varchar2 default null
  ,p_pem_attribute26                in     varchar2 default null
  ,p_pem_attribute27                in     varchar2 default null
  ,p_pem_attribute28                in     varchar2 default null
  ,p_pem_attribute29                in     varchar2 default null
  ,p_pem_attribute30                in     varchar2 default null
  ,p_pem_information_category       in     varchar2 default null
  ,p_pem_information1               in     varchar2 default null
  ,p_pem_information2               in     varchar2 default null
  ,p_pem_information3               in     varchar2 default null
  ,p_pem_information4               in     varchar2 default null
  ,p_pem_information5               in     varchar2 default null
  ,p_pem_information6               in     varchar2 default null
  ,p_pem_information7               in     varchar2 default null
  ,p_pem_information8               in     varchar2 default null
  ,p_pem_information9               in     varchar2 default null
  ,p_pem_information10              in     varchar2 default null
  ,p_pem_information11              in     varchar2 default null
  ,p_pem_information12              in     varchar2 default null
  ,p_pem_information13              in     varchar2 default null
  ,p_pem_information14              in     varchar2 default null
  ,p_pem_information15              in     varchar2 default null
  ,p_pem_information16              in     varchar2 default null
  ,p_pem_information17              in     varchar2 default null
  ,p_pem_information18              in     varchar2 default null
  ,p_pem_information19              in     varchar2 default null
  ,p_pem_information20              in     varchar2 default null
  ,p_pem_information21              in     varchar2 default null
  ,p_pem_information22              in     varchar2 default null
  ,p_pem_information23              in     varchar2 default null
  ,p_pem_information24              in     varchar2 default null
  ,p_pem_information25              in     varchar2 default null
  ,p_pem_information26              in     varchar2 default null
  ,p_pem_information27              in     varchar2 default null
  ,p_pem_information28              in     varchar2 default null
  ,p_pem_information29              in     varchar2 default null
  ,p_pem_information30              in     varchar2 default null
  ,p_all_assignments                in     varchar2 default null
  ,p_period_months                  in     number   default null
  ,p_previous_employer_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  -- Bug Fix 3261422 Start
  cursor csr_get_party_id is
  select party_id
  from    per_all_people_f per
    where   per.person_id = p_person_id
    and     trunc(p_effective_date)
    between per.effective_start_date
    and     per.effective_end_date;
  -- Bug Fix 3261422 End
--
  l_rec   per_pem_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
  l_party_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Bug Fix 3261422 Start
  if p_party_id is null then
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
  else
    l_party_id := p_party_id;
  end if;
  -- Bug Fix 3261422 End

  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pem_shd.convert_args
    (null
    ,p_business_group_id
    ,p_person_id
    ,l_party_id
    ,p_start_date
    ,p_end_date
    ,p_period_years
    ,p_period_days
    ,p_employer_name
    ,p_employer_country
    ,p_employer_address
    ,p_employer_type
    ,p_employer_subtype
    ,p_description
    ,p_pem_attribute_category
    ,p_pem_attribute1
    ,p_pem_attribute2
    ,p_pem_attribute3
    ,p_pem_attribute4
    ,p_pem_attribute5
    ,p_pem_attribute6
    ,p_pem_attribute7
    ,p_pem_attribute8
    ,p_pem_attribute9
    ,p_pem_attribute10
    ,p_pem_attribute11
    ,p_pem_attribute12
    ,p_pem_attribute13
    ,p_pem_attribute14
    ,p_pem_attribute15
    ,p_pem_attribute16
    ,p_pem_attribute17
    ,p_pem_attribute18
    ,p_pem_attribute19
    ,p_pem_attribute20
    ,p_pem_attribute21
    ,p_pem_attribute22
    ,p_pem_attribute23
    ,p_pem_attribute24
    ,p_pem_attribute25
    ,p_pem_attribute26
    ,p_pem_attribute27
    ,p_pem_attribute28
    ,p_pem_attribute29
    ,p_pem_attribute30
    ,p_pem_information_category
    ,p_pem_information1
    ,p_pem_information2
    ,p_pem_information3
    ,p_pem_information4
    ,p_pem_information5
    ,p_pem_information6
    ,p_pem_information7
    ,p_pem_information8
    ,p_pem_information9
    ,p_pem_information10
    ,p_pem_information11
    ,p_pem_information12
    ,p_pem_information13
    ,p_pem_information14
    ,p_pem_information15
    ,p_pem_information16
    ,p_pem_information17
    ,p_pem_information18
    ,p_pem_information19
    ,p_pem_information20
    ,p_pem_information21
    ,p_pem_information22
    ,p_pem_information23
    ,p_pem_information24
    ,p_pem_information25
    ,p_pem_information26
    ,p_pem_information27
    ,p_pem_information28
    ,p_pem_information29
    ,p_pem_information30
    ,null
    ,p_all_assignments
    ,p_period_months
    );
  --
  -- Having converted the arguments into the per_pem_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_pem_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_previous_employer_id := l_rec.previous_employer_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pem_ins;

/
