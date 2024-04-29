--------------------------------------------------------
--  DDL for Package Body PER_PJI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJI_INS" as
/* $Header: pepjirhi.pkb 115.8 2002/12/03 15:41:52 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pji_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_previous_job_extra_info_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_previous_job_extra_info_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_pji_ins.g_previous_job_extra_info_id_i := p_previous_job_extra_info_id;
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
  (p_rec in out nocopy per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  -- Insert the row into: per_prev_job_extra_info
  --
  insert into per_prev_job_extra_info
      (previous_job_extra_info_id
      ,previous_job_id
      ,information_type
      ,pji_attribute_category
      ,pji_attribute1
      ,pji_attribute2
      ,pji_attribute3
      ,pji_attribute4
      ,pji_attribute5
      ,pji_attribute6
      ,pji_attribute7
      ,pji_attribute8
      ,pji_attribute9
      ,pji_attribute10
      ,pji_attribute11
      ,pji_attribute12
      ,pji_attribute13
      ,pji_attribute14
      ,pji_attribute15
      ,pji_attribute16
      ,pji_attribute17
      ,pji_attribute18
      ,pji_attribute19
      ,pji_attribute20
      ,pji_attribute21
      ,pji_attribute22
      ,pji_attribute23
      ,pji_attribute24
      ,pji_attribute25
      ,pji_attribute26
      ,pji_attribute27
      ,pji_attribute28
      ,pji_attribute29
      ,pji_attribute30
      ,pji_information_category
      ,pji_information1
      ,pji_information2
      ,pji_information3
      ,pji_information4
      ,pji_information5
      ,pji_information6
      ,pji_information7
      ,pji_information8
      ,pji_information9
      ,pji_information10
      ,pji_information11
      ,pji_information12
      ,pji_information13
      ,pji_information14
      ,pji_information15
      ,pji_information16
      ,pji_information17
      ,pji_information18
      ,pji_information19
      ,pji_information20
      ,pji_information21
      ,pji_information22
      ,pji_information23
      ,pji_information24
      ,pji_information25
      ,pji_information26
      ,pji_information27
      ,pji_information28
      ,pji_information29
      ,pji_information30
      ,object_version_number
      )
  Values
    (p_rec.previous_job_extra_info_id
    ,p_rec.previous_job_id
    ,p_rec.information_type
    ,p_rec.pji_attribute_category
    ,p_rec.pji_attribute1
    ,p_rec.pji_attribute2
    ,p_rec.pji_attribute3
    ,p_rec.pji_attribute4
    ,p_rec.pji_attribute5
    ,p_rec.pji_attribute6
    ,p_rec.pji_attribute7
    ,p_rec.pji_attribute8
    ,p_rec.pji_attribute9
    ,p_rec.pji_attribute10
    ,p_rec.pji_attribute11
    ,p_rec.pji_attribute12
    ,p_rec.pji_attribute13
    ,p_rec.pji_attribute14
    ,p_rec.pji_attribute15
    ,p_rec.pji_attribute16
    ,p_rec.pji_attribute17
    ,p_rec.pji_attribute18
    ,p_rec.pji_attribute19
    ,p_rec.pji_attribute20
    ,p_rec.pji_attribute21
    ,p_rec.pji_attribute22
    ,p_rec.pji_attribute23
    ,p_rec.pji_attribute24
    ,p_rec.pji_attribute25
    ,p_rec.pji_attribute26
    ,p_rec.pji_attribute27
    ,p_rec.pji_attribute28
    ,p_rec.pji_attribute29
    ,p_rec.pji_attribute30
    ,p_rec.pji_information_category
    ,p_rec.pji_information1
    ,p_rec.pji_information2
    ,p_rec.pji_information3
    ,p_rec.pji_information4
    ,p_rec.pji_information5
    ,p_rec.pji_information6
    ,p_rec.pji_information7
    ,p_rec.pji_information8
    ,p_rec.pji_information9
    ,p_rec.pji_information10
    ,p_rec.pji_information11
    ,p_rec.pji_information12
    ,p_rec.pji_information13
    ,p_rec.pji_information14
    ,p_rec.pji_information15
    ,p_rec.pji_information16
    ,p_rec.pji_information17
    ,p_rec.pji_information18
    ,p_rec.pji_information19
    ,p_rec.pji_information20
    ,p_rec.pji_information21
    ,p_rec.pji_information22
    ,p_rec.pji_information23
    ,p_rec.pji_information24
    ,p_rec.pji_information25
    ,p_rec.pji_information26
    ,p_rec.pji_information27
    ,p_rec.pji_information28
    ,p_rec.pji_information29
    ,p_rec.pji_information30
    ,p_rec.object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    per_pji_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pji_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pji_shd.constraint_error
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
  (p_rec  in out nocopy per_pji_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_prev_job_extra_info_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_prev_job_extra_info
     where previous_job_extra_info_id =
             per_pji_ins.g_previous_job_extra_info_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_pji_ins.g_previous_job_extra_info_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_prev_job_extra_info');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.previous_job_extra_info_id :=
      per_pji_ins.g_previous_job_extra_info_id_i;
    per_pji_ins.g_previous_job_extra_info_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.previous_job_extra_info_id;
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
  (p_rec                          in per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pji_rki.after_insert
      (p_previous_job_extra_info_id
      => p_rec.previous_job_extra_info_id
      ,p_previous_job_id
      => p_rec.previous_job_id
      ,p_information_type
      => p_rec.information_type
      ,p_pji_attribute_category
      => p_rec.pji_attribute_category
      ,p_pji_attribute1
      => p_rec.pji_attribute1
      ,p_pji_attribute2
      => p_rec.pji_attribute2
      ,p_pji_attribute3
      => p_rec.pji_attribute3
      ,p_pji_attribute4
      => p_rec.pji_attribute4
      ,p_pji_attribute5
      => p_rec.pji_attribute5
      ,p_pji_attribute6
      => p_rec.pji_attribute6
      ,p_pji_attribute7
      => p_rec.pji_attribute7
      ,p_pji_attribute8
      => p_rec.pji_attribute8
      ,p_pji_attribute9
      => p_rec.pji_attribute9
      ,p_pji_attribute10
      => p_rec.pji_attribute10
      ,p_pji_attribute11
      => p_rec.pji_attribute11
      ,p_pji_attribute12
      => p_rec.pji_attribute12
      ,p_pji_attribute13
      => p_rec.pji_attribute13
      ,p_pji_attribute14
      => p_rec.pji_attribute14
      ,p_pji_attribute15
      => p_rec.pji_attribute15
      ,p_pji_attribute16
      => p_rec.pji_attribute16
      ,p_pji_attribute17
      => p_rec.pji_attribute17
      ,p_pji_attribute18
      => p_rec.pji_attribute18
      ,p_pji_attribute19
      => p_rec.pji_attribute19
      ,p_pji_attribute20
      => p_rec.pji_attribute20
      ,p_pji_attribute21
      => p_rec.pji_attribute21
      ,p_pji_attribute22
      => p_rec.pji_attribute22
      ,p_pji_attribute23
      => p_rec.pji_attribute23
      ,p_pji_attribute24
      => p_rec.pji_attribute24
      ,p_pji_attribute25
      => p_rec.pji_attribute25
      ,p_pji_attribute26
      => p_rec.pji_attribute26
      ,p_pji_attribute27
      => p_rec.pji_attribute27
      ,p_pji_attribute28
      => p_rec.pji_attribute28
      ,p_pji_attribute29
      => p_rec.pji_attribute29
      ,p_pji_attribute30
      => p_rec.pji_attribute30
      ,p_pji_information_category
      => p_rec.pji_information_category
      ,p_pji_information1
      => p_rec.pji_information1
      ,p_pji_information2
      => p_rec.pji_information2
      ,p_pji_information3
      => p_rec.pji_information3
      ,p_pji_information4
      => p_rec.pji_information4
      ,p_pji_information5
      => p_rec.pji_information5
      ,p_pji_information6
      => p_rec.pji_information6
      ,p_pji_information7
      => p_rec.pji_information7
      ,p_pji_information8
      => p_rec.pji_information8
      ,p_pji_information9
      => p_rec.pji_information9
      ,p_pji_information10
      => p_rec.pji_information10
      ,p_pji_information11
      => p_rec.pji_information11
      ,p_pji_information12
      => p_rec.pji_information12
      ,p_pji_information13
      => p_rec.pji_information13
      ,p_pji_information14
      => p_rec.pji_information14
      ,p_pji_information15
      => p_rec.pji_information15
      ,p_pji_information16
      => p_rec.pji_information16
      ,p_pji_information17
      => p_rec.pji_information17
      ,p_pji_information18
      => p_rec.pji_information18
      ,p_pji_information19
      => p_rec.pji_information19
      ,p_pji_information20
      => p_rec.pji_information20
      ,p_pji_information21
      => p_rec.pji_information21
      ,p_pji_information22
      => p_rec.pji_information22
      ,p_pji_information23
      => p_rec.pji_information23
      ,p_pji_information24
      => p_rec.pji_information24
      ,p_pji_information25
      => p_rec.pji_information25
      ,p_pji_information26
      => p_rec.pji_information26
      ,p_pji_information27
      => p_rec.pji_information27
      ,p_pji_information28
      => p_rec.pji_information28
      ,p_pji_information29
      => p_rec.pji_information29
      ,p_pji_information30
      => p_rec.pji_information30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PREV_JOB_EXTRA_INFO'
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
  (p_rec                          in out nocopy per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_pji_bus.insert_validate
     (p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_pji_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_pji_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_pji_ins.post_insert
     (p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_previous_job_id                in     number
  ,p_information_type               in     varchar2
  ,p_pji_attribute_category         in     varchar2 default null
  ,p_pji_attribute1                 in     varchar2 default null
  ,p_pji_attribute2                 in     varchar2 default null
  ,p_pji_attribute3                 in     varchar2 default null
  ,p_pji_attribute4                 in     varchar2 default null
  ,p_pji_attribute5                 in     varchar2 default null
  ,p_pji_attribute6                 in     varchar2 default null
  ,p_pji_attribute7                 in     varchar2 default null
  ,p_pji_attribute8                 in     varchar2 default null
  ,p_pji_attribute9                 in     varchar2 default null
  ,p_pji_attribute10                in     varchar2 default null
  ,p_pji_attribute11                in     varchar2 default null
  ,p_pji_attribute12                in     varchar2 default null
  ,p_pji_attribute13                in     varchar2 default null
  ,p_pji_attribute14                in     varchar2 default null
  ,p_pji_attribute15                in     varchar2 default null
  ,p_pji_attribute16                in     varchar2 default null
  ,p_pji_attribute17                in     varchar2 default null
  ,p_pji_attribute18                in     varchar2 default null
  ,p_pji_attribute19                in     varchar2 default null
  ,p_pji_attribute20                in     varchar2 default null
  ,p_pji_attribute21                in     varchar2 default null
  ,p_pji_attribute22                in     varchar2 default null
  ,p_pji_attribute23                in     varchar2 default null
  ,p_pji_attribute24                in     varchar2 default null
  ,p_pji_attribute25                in     varchar2 default null
  ,p_pji_attribute26                in     varchar2 default null
  ,p_pji_attribute27                in     varchar2 default null
  ,p_pji_attribute28                in     varchar2 default null
  ,p_pji_attribute29                in     varchar2 default null
  ,p_pji_attribute30                in     varchar2 default null
  ,p_pji_information_category       in     varchar2 default null
  ,p_pji_information1               in     varchar2 default null
  ,p_pji_information2               in     varchar2 default null
  ,p_pji_information3               in     varchar2 default null
  ,p_pji_information4               in     varchar2 default null
  ,p_pji_information5               in     varchar2 default null
  ,p_pji_information6               in     varchar2 default null
  ,p_pji_information7               in     varchar2 default null
  ,p_pji_information8               in     varchar2 default null
  ,p_pji_information9               in     varchar2 default null
  ,p_pji_information10              in     varchar2 default null
  ,p_pji_information11              in     varchar2 default null
  ,p_pji_information12              in     varchar2 default null
  ,p_pji_information13              in     varchar2 default null
  ,p_pji_information14              in     varchar2 default null
  ,p_pji_information15              in     varchar2 default null
  ,p_pji_information16              in     varchar2 default null
  ,p_pji_information17              in     varchar2 default null
  ,p_pji_information18              in     varchar2 default null
  ,p_pji_information19              in     varchar2 default null
  ,p_pji_information20              in     varchar2 default null
  ,p_pji_information21              in     varchar2 default null
  ,p_pji_information22              in     varchar2 default null
  ,p_pji_information23              in     varchar2 default null
  ,p_pji_information24              in     varchar2 default null
  ,p_pji_information25              in     varchar2 default null
  ,p_pji_information26              in     varchar2 default null
  ,p_pji_information27              in     varchar2 default null
  ,p_pji_information28              in     varchar2 default null
  ,p_pji_information29              in     varchar2 default null
  ,p_pji_information30              in     varchar2 default null
  ,p_previous_job_extra_info_id     out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
--
  l_rec   per_pji_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pji_shd.convert_args
    (null
    ,p_previous_job_id
    ,p_information_type
    ,p_pji_attribute_category
    ,p_pji_attribute1
    ,p_pji_attribute2
    ,p_pji_attribute3
    ,p_pji_attribute4
    ,p_pji_attribute5
    ,p_pji_attribute6
    ,p_pji_attribute7
    ,p_pji_attribute8
    ,p_pji_attribute9
    ,p_pji_attribute10
    ,p_pji_attribute11
    ,p_pji_attribute12
    ,p_pji_attribute13
    ,p_pji_attribute14
    ,p_pji_attribute15
    ,p_pji_attribute16
    ,p_pji_attribute17
    ,p_pji_attribute18
    ,p_pji_attribute19
    ,p_pji_attribute20
    ,p_pji_attribute21
    ,p_pji_attribute22
    ,p_pji_attribute23
    ,p_pji_attribute24
    ,p_pji_attribute25
    ,p_pji_attribute26
    ,p_pji_attribute27
    ,p_pji_attribute28
    ,p_pji_attribute29
    ,p_pji_attribute30
    ,p_pji_information_category
    ,p_pji_information1
    ,p_pji_information2
    ,p_pji_information3
    ,p_pji_information4
    ,p_pji_information5
    ,p_pji_information6
    ,p_pji_information7
    ,p_pji_information8
    ,p_pji_information9
    ,p_pji_information10
    ,p_pji_information11
    ,p_pji_information12
    ,p_pji_information13
    ,p_pji_information14
    ,p_pji_information15
    ,p_pji_information16
    ,p_pji_information17
    ,p_pji_information18
    ,p_pji_information19
    ,p_pji_information20
    ,p_pji_information21
    ,p_pji_information22
    ,p_pji_information23
    ,p_pji_information24
    ,p_pji_information25
    ,p_pji_information26
    ,p_pji_information27
    ,p_pji_information28
    ,p_pji_information29
    ,p_pji_information30
    ,null
    );
  --
  -- Having converted the arguments into the per_pji_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_pji_ins.ins
     (l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_previous_job_extra_info_id := l_rec.previous_job_extra_info_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pji_ins;

/
