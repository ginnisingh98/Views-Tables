--------------------------------------------------------
--  DDL for Package Body HR_DEI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEI_INS" as
/* $Header: hrdeirhi.pkb 120.1.12010000.3 2010/05/20 12:01:59 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_dei_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_document_extra_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_document_extra_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_dei_ins.g_document_extra_info_id_i := p_document_extra_info_id;
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
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
  (p_rec in out nocopy hr_dei_shd.g_rec_type
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
  -- Insert the row into: hr_document_extra_info
  --
  insert into hr_document_extra_info
      (document_extra_info_id
      ,person_id
      ,document_type_id
      ,document_number
      ,date_from
      ,date_to
      ,issued_by
      ,issued_at
      ,issued_date
      ,issuing_authority
      ,verified_by
      ,verified_date
      ,related_object_name
      ,related_object_id_col
      ,related_object_id
      ,dei_attribute_category
      ,dei_attribute1
      ,dei_attribute2
      ,dei_attribute3
      ,dei_attribute4
      ,dei_attribute5
      ,dei_attribute6
      ,dei_attribute7
      ,dei_attribute8
      ,dei_attribute9
      ,dei_attribute10
      ,dei_attribute11
      ,dei_attribute12
      ,dei_attribute13
      ,dei_attribute14
      ,dei_attribute15
      ,dei_attribute16
      ,dei_attribute17
      ,dei_attribute18
      ,dei_attribute19
      ,dei_attribute20
      ,dei_attribute21
      ,dei_attribute22
      ,dei_attribute23
      ,dei_attribute24
      ,dei_attribute25
      ,dei_attribute26
      ,dei_attribute27
      ,dei_attribute28
      ,dei_attribute29
      ,dei_attribute30
      ,dei_information_category
      ,dei_information1
      ,dei_information2
      ,dei_information3
      ,dei_information4
      ,dei_information5
      ,dei_information6
      ,dei_information7
      ,dei_information8
      ,dei_information9
      ,dei_information10
      ,dei_information11
      ,dei_information12
      ,dei_information13
      ,dei_information14
      ,dei_information15
      ,dei_information16
      ,dei_information17
      ,dei_information18
      ,dei_information19
      ,dei_information20
      ,dei_information21
      ,dei_information22
      ,dei_information23
      ,dei_information24
      ,dei_information25
      ,dei_information26
      ,dei_information27
      ,dei_information28
      ,dei_information29
      ,dei_information30
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,object_version_number
      )
  Values
    (p_rec.document_extra_info_id
    ,p_rec.person_id
    ,p_rec.document_type_id
    ,p_rec.document_number
    ,p_rec.date_from
    ,p_rec.date_to
    ,p_rec.issued_by
    ,p_rec.issued_at
    ,p_rec.issued_date
    ,p_rec.issuing_authority
    ,p_rec.verified_by
    ,p_rec.verified_date
    ,p_rec.related_object_name
    ,p_rec.related_object_id_col
    ,p_rec.related_object_id
    ,p_rec.dei_attribute_category
    ,p_rec.dei_attribute1
    ,p_rec.dei_attribute2
    ,p_rec.dei_attribute3
    ,p_rec.dei_attribute4
    ,p_rec.dei_attribute5
    ,p_rec.dei_attribute6
    ,p_rec.dei_attribute7
    ,p_rec.dei_attribute8
    ,p_rec.dei_attribute9
    ,p_rec.dei_attribute10
    ,p_rec.dei_attribute11
    ,p_rec.dei_attribute12
    ,p_rec.dei_attribute13
    ,p_rec.dei_attribute14
    ,p_rec.dei_attribute15
    ,p_rec.dei_attribute16
    ,p_rec.dei_attribute17
    ,p_rec.dei_attribute18
    ,p_rec.dei_attribute19
    ,p_rec.dei_attribute20
    ,p_rec.dei_attribute21
    ,p_rec.dei_attribute22
    ,p_rec.dei_attribute23
    ,p_rec.dei_attribute24
    ,p_rec.dei_attribute25
    ,p_rec.dei_attribute26
    ,p_rec.dei_attribute27
    ,p_rec.dei_attribute28
    ,p_rec.dei_attribute29
    ,p_rec.dei_attribute30
    ,p_rec.dei_information_category
    ,p_rec.dei_information1
    ,p_rec.dei_information2
    ,p_rec.dei_information3
    ,p_rec.dei_information4
    ,p_rec.dei_information5
    ,p_rec.dei_information6
    ,p_rec.dei_information7
    ,p_rec.dei_information8
    ,p_rec.dei_information9
    ,p_rec.dei_information10
    ,p_rec.dei_information11
    ,p_rec.dei_information12
    ,p_rec.dei_information13
    ,p_rec.dei_information14
    ,p_rec.dei_information15
    ,p_rec.dei_information16
    ,p_rec.dei_information17
    ,p_rec.dei_information18
    ,p_rec.dei_information19
    ,p_rec.dei_information20
    ,p_rec.dei_information21
    ,p_rec.dei_information22
    ,p_rec.dei_information23
    ,p_rec.dei_information24
    ,p_rec.dei_information25
    ,p_rec.dei_information26
    ,p_rec.dei_information27
    ,p_rec.dei_information28
    ,p_rec.dei_information29
    ,p_rec.dei_information30
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hr_dei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hr_dei_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hr_dei_shd.constraint_error
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
  (p_rec  in out nocopy hr_dei_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select hr_document_extra_info_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from hr_document_extra_info
     where document_extra_info_id =
             hr_dei_ins.g_document_extra_info_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (hr_dei_ins.g_document_extra_info_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','hr_document_extra_info');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.document_extra_info_id :=
      hr_dei_ins.g_document_extra_info_id_i;
    hr_dei_ins.g_document_extra_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.document_extra_info_id;
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
  (p_rec                          in hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_dei_rki.after_insert
      (p_document_extra_info_id
      => p_rec.document_extra_info_id
      ,p_person_id
      => p_rec.person_id
      ,p_document_type_id
      => p_rec.document_type_id
      ,p_document_number
      => p_rec.document_number
      ,p_date_from
      => p_rec.date_from
      ,p_date_to
      => p_rec.date_to
      ,p_issued_by
      => p_rec.issued_by
      ,p_issued_at
      => p_rec.issued_at
      ,p_issued_date
      => p_rec.issued_date
      ,p_issuing_authority
      => p_rec.issuing_authority
      ,p_verified_by
      => p_rec.verified_by
      ,p_verified_date
      => p_rec.verified_date
      ,p_related_object_name
      => p_rec.related_object_name
      ,p_related_object_id_col
      => p_rec.related_object_id_col
      ,p_related_object_id
      => p_rec.related_object_id
      ,p_dei_attribute_category
      => p_rec.dei_attribute_category
      ,p_dei_attribute1
      => p_rec.dei_attribute1
      ,p_dei_attribute2
      => p_rec.dei_attribute2
      ,p_dei_attribute3
      => p_rec.dei_attribute3
      ,p_dei_attribute4
      => p_rec.dei_attribute4
      ,p_dei_attribute5
      => p_rec.dei_attribute5
      ,p_dei_attribute6
      => p_rec.dei_attribute6
      ,p_dei_attribute7
      => p_rec.dei_attribute7
      ,p_dei_attribute8
      => p_rec.dei_attribute8
      ,p_dei_attribute9
      => p_rec.dei_attribute9
      ,p_dei_attribute10
      => p_rec.dei_attribute10
      ,p_dei_attribute11
      => p_rec.dei_attribute11
      ,p_dei_attribute12
      => p_rec.dei_attribute12
      ,p_dei_attribute13
      => p_rec.dei_attribute13
      ,p_dei_attribute14
      => p_rec.dei_attribute14
      ,p_dei_attribute15
      => p_rec.dei_attribute15
      ,p_dei_attribute16
      => p_rec.dei_attribute16
      ,p_dei_attribute17
      => p_rec.dei_attribute17
      ,p_dei_attribute18
      => p_rec.dei_attribute18
      ,p_dei_attribute19
      => p_rec.dei_attribute19
      ,p_dei_attribute20
      => p_rec.dei_attribute20
      ,p_dei_attribute21
      => p_rec.dei_attribute21
      ,p_dei_attribute22
      => p_rec.dei_attribute22
      ,p_dei_attribute23
      => p_rec.dei_attribute23
      ,p_dei_attribute24
      => p_rec.dei_attribute24
      ,p_dei_attribute25
      => p_rec.dei_attribute25
      ,p_dei_attribute26
      => p_rec.dei_attribute26
      ,p_dei_attribute27
      => p_rec.dei_attribute27
      ,p_dei_attribute28
      => p_rec.dei_attribute28
      ,p_dei_attribute29
      => p_rec.dei_attribute29
      ,p_dei_attribute30
      => p_rec.dei_attribute30
      ,p_dei_information_category
      => p_rec.dei_information_category
      ,p_dei_information1
      => p_rec.dei_information1
      ,p_dei_information2
      => p_rec.dei_information2
      ,p_dei_information3
      => p_rec.dei_information3
      ,p_dei_information4
      => p_rec.dei_information4
      ,p_dei_information5
      => p_rec.dei_information5
      ,p_dei_information6
      => p_rec.dei_information6
      ,p_dei_information7
      => p_rec.dei_information7
      ,p_dei_information8
      => p_rec.dei_information8
      ,p_dei_information9
      => p_rec.dei_information9
      ,p_dei_information10
      => p_rec.dei_information10
      ,p_dei_information11
      => p_rec.dei_information11
      ,p_dei_information12
      => p_rec.dei_information12
      ,p_dei_information13
      => p_rec.dei_information13
      ,p_dei_information14
      => p_rec.dei_information14
      ,p_dei_information15
      => p_rec.dei_information15
      ,p_dei_information16
      => p_rec.dei_information16
      ,p_dei_information17
      => p_rec.dei_information17
      ,p_dei_information18
      => p_rec.dei_information18
      ,p_dei_information19
      => p_rec.dei_information19
      ,p_dei_information20
      => p_rec.dei_information20
      ,p_dei_information21
      => p_rec.dei_information21
      ,p_dei_information22
      => p_rec.dei_information22
      ,p_dei_information23
      => p_rec.dei_information23
      ,p_dei_information24
      => p_rec.dei_information24
      ,p_dei_information25
      => p_rec.dei_information25
      ,p_dei_information26
      => p_rec.dei_information26
      ,p_dei_information27
      => p_rec.dei_information27
      ,p_dei_information28
      => p_rec.dei_information28
      ,p_dei_information29
      => p_rec.dei_information29
      ,p_dei_information30
      => p_rec.dei_information30
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_DOCUMENT_EXTRA_INFO'
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
  (p_rec                          in out nocopy hr_dei_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  hr_dei_bus.insert_validate
     (p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  hr_dei_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  hr_dei_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  hr_dei_ins.post_insert
     (p_rec
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
  (p_person_id                      in     number
  ,p_document_type_id               in     number
  ,p_date_from                      in     date
  ,p_date_to                        in     date
  ,p_document_number                in     varchar2 default null
  ,p_issued_by                      in     varchar2 default null
  ,p_issued_at                      in     varchar2 default null
  ,p_issued_date                    in     date     default null
  ,p_issuing_authority              in     varchar2 default null
  ,p_verified_by                    in     number   default null
  ,p_verified_date                  in     date     default null
  ,p_related_object_name            in     varchar2 default null
  ,p_related_object_id_col          in     varchar2 default null
  ,p_related_object_id              in     number   default null
  ,p_dei_attribute_category         in     varchar2 default null
  ,p_dei_attribute1                 in     varchar2 default null
  ,p_dei_attribute2                 in     varchar2 default null
  ,p_dei_attribute3                 in     varchar2 default null
  ,p_dei_attribute4                 in     varchar2 default null
  ,p_dei_attribute5                 in     varchar2 default null
  ,p_dei_attribute6                 in     varchar2 default null
  ,p_dei_attribute7                 in     varchar2 default null
  ,p_dei_attribute8                 in     varchar2 default null
  ,p_dei_attribute9                 in     varchar2 default null
  ,p_dei_attribute10                in     varchar2 default null
  ,p_dei_attribute11                in     varchar2 default null
  ,p_dei_attribute12                in     varchar2 default null
  ,p_dei_attribute13                in     varchar2 default null
  ,p_dei_attribute14                in     varchar2 default null
  ,p_dei_attribute15                in     varchar2 default null
  ,p_dei_attribute16                in     varchar2 default null
  ,p_dei_attribute17                in     varchar2 default null
  ,p_dei_attribute18                in     varchar2 default null
  ,p_dei_attribute19                in     varchar2 default null
  ,p_dei_attribute20                in     varchar2 default null
  ,p_dei_attribute21                in     varchar2 default null
  ,p_dei_attribute22                in     varchar2 default null
  ,p_dei_attribute23                in     varchar2 default null
  ,p_dei_attribute24                in     varchar2 default null
  ,p_dei_attribute25                in     varchar2 default null
  ,p_dei_attribute26                in     varchar2 default null
  ,p_dei_attribute27                in     varchar2 default null
  ,p_dei_attribute28                in     varchar2 default null
  ,p_dei_attribute29                in     varchar2 default null
  ,p_dei_attribute30                in     varchar2 default null
  ,p_dei_information_category       in     varchar2 default null
  ,p_dei_information1               in     varchar2 default null
  ,p_dei_information2               in     varchar2 default null
  ,p_dei_information3               in     varchar2 default null
  ,p_dei_information4               in     varchar2 default null
  ,p_dei_information5               in     varchar2 default null
  ,p_dei_information6               in     varchar2 default null
  ,p_dei_information7               in     varchar2 default null
  ,p_dei_information8               in     varchar2 default null
  ,p_dei_information9               in     varchar2 default null
  ,p_dei_information10              in     varchar2 default null
  ,p_dei_information11              in     varchar2 default null
  ,p_dei_information12              in     varchar2 default null
  ,p_dei_information13              in     varchar2 default null
  ,p_dei_information14              in     varchar2 default null
  ,p_dei_information15              in     varchar2 default null
  ,p_dei_information16              in     varchar2 default null
  ,p_dei_information17              in     varchar2 default null
  ,p_dei_information18              in     varchar2 default null
  ,p_dei_information19              in     varchar2 default null
  ,p_dei_information20              in     varchar2 default null
  ,p_dei_information21              in     varchar2 default null
  ,p_dei_information22              in     varchar2 default null
  ,p_dei_information23              in     varchar2 default null
  ,p_dei_information24              in     varchar2 default null
  ,p_dei_information25              in     varchar2 default null
  ,p_dei_information26              in     varchar2 default null
  ,p_dei_information27              in     varchar2 default null
  ,p_dei_information28              in     varchar2 default null
  ,p_dei_information29              in     varchar2 default null
  ,p_dei_information30              in     varchar2 default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_document_extra_info_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   hr_dei_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_dei_shd.convert_args
    (null
    ,p_person_id
    ,p_document_type_id
    ,p_document_number
    ,p_date_from
    ,p_date_to
    ,p_issued_by
    ,p_issued_at
    ,p_issued_date
    ,p_issuing_authority
    ,p_verified_by
    ,p_verified_date
    ,p_related_object_name
    ,p_related_object_id_col
    ,p_related_object_id
    ,p_dei_attribute_category
    ,p_dei_attribute1
    ,p_dei_attribute2
    ,p_dei_attribute3
    ,p_dei_attribute4
    ,p_dei_attribute5
    ,p_dei_attribute6
    ,p_dei_attribute7
    ,p_dei_attribute8
    ,p_dei_attribute9
    ,p_dei_attribute10
    ,p_dei_attribute11
    ,p_dei_attribute12
    ,p_dei_attribute13
    ,p_dei_attribute14
    ,p_dei_attribute15
    ,p_dei_attribute16
    ,p_dei_attribute17
    ,p_dei_attribute18
    ,p_dei_attribute19
    ,p_dei_attribute20
    ,p_dei_attribute21
    ,p_dei_attribute22
    ,p_dei_attribute23
    ,p_dei_attribute24
    ,p_dei_attribute25
    ,p_dei_attribute26
    ,p_dei_attribute27
    ,p_dei_attribute28
    ,p_dei_attribute29
    ,p_dei_attribute30
    ,p_dei_information_category
    ,p_dei_information1
    ,p_dei_information2
    ,p_dei_information3
    ,p_dei_information4
    ,p_dei_information5
    ,p_dei_information6
    ,p_dei_information7
    ,p_dei_information8
    ,p_dei_information9
    ,p_dei_information10
    ,p_dei_information11
    ,p_dei_information12
    ,p_dei_information13
    ,p_dei_information14
    ,p_dei_information15
    ,p_dei_information16
    ,p_dei_information17
    ,p_dei_information18
    ,p_dei_information19
    ,p_dei_information20
    ,p_dei_information21
    ,p_dei_information22
    ,p_dei_information23
    ,p_dei_information24
    ,p_dei_information25
    ,p_dei_information26
    ,p_dei_information27
    ,p_dei_information28
    ,p_dei_information29
    ,p_dei_information30
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,null
    );
  --
  -- Having converted the arguments into the hr_dei_rec
  -- plsql record structure we call the corresponding record business process.
  --
  hr_dei_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_document_extra_info_id := l_rec.document_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end hr_dei_ins;

/
