--------------------------------------------------------
--  DDL for Package Body PER_PJO_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJO_INS" as
/* $Header: pepjorhi.pkb 120.0.12010000.2 2008/08/06 09:28:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pjo_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_previous_job_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_previous_job_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  per_pjo_ins.g_previous_job_id_i := p_previous_job_id;
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
  (p_rec in out nocopy per_pjo_shd.g_rec_type
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
  -- Insert the row into: per_previous_jobs
  --
  insert into per_previous_jobs
      (previous_job_id
      ,previous_employer_id
      ,start_date
      ,end_date
      ,period_years
      ,period_days
      ,job_name
      ,employment_category
      ,description
      ,pjo_attribute_category
      ,pjo_attribute1
      ,pjo_attribute2
      ,pjo_attribute3
      ,pjo_attribute4
      ,pjo_attribute5
      ,pjo_attribute6
      ,pjo_attribute7
      ,pjo_attribute8
      ,pjo_attribute9
      ,pjo_attribute10
      ,pjo_attribute11
      ,pjo_attribute12
      ,pjo_attribute13
      ,pjo_attribute14
      ,pjo_attribute15
      ,pjo_attribute16
      ,pjo_attribute17
      ,pjo_attribute18
      ,pjo_attribute19
      ,pjo_attribute20
      ,pjo_attribute21
      ,pjo_attribute22
      ,pjo_attribute23
      ,pjo_attribute24
      ,pjo_attribute25
      ,pjo_attribute26
      ,pjo_attribute27
      ,pjo_attribute28
      ,pjo_attribute29
      ,pjo_attribute30
      ,pjo_information_category
      ,pjo_information1
      ,pjo_information2
      ,pjo_information3
      ,pjo_information4
      ,pjo_information5
      ,pjo_information6
      ,pjo_information7
      ,pjo_information8
      ,pjo_information9
      ,pjo_information10
      ,pjo_information11
      ,pjo_information12
      ,pjo_information13
      ,pjo_information14
      ,pjo_information15
      ,pjo_information16
      ,pjo_information17
      ,pjo_information18
      ,pjo_information19
      ,pjo_information20
      ,pjo_information21
      ,pjo_information22
      ,pjo_information23
      ,pjo_information24
      ,pjo_information25
      ,pjo_information26
      ,pjo_information27
      ,pjo_information28
      ,pjo_information29
      ,pjo_information30
      ,object_version_number
      ,all_assignments
      ,period_months
      )
  Values
    (p_rec.previous_job_id
    ,p_rec.previous_employer_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.period_years
    ,p_rec.period_days
    ,p_rec.job_name
    ,p_rec.employment_category
    ,p_rec.description
    ,p_rec.pjo_attribute_category
    ,p_rec.pjo_attribute1
    ,p_rec.pjo_attribute2
    ,p_rec.pjo_attribute3
    ,p_rec.pjo_attribute4
    ,p_rec.pjo_attribute5
    ,p_rec.pjo_attribute6
    ,p_rec.pjo_attribute7
    ,p_rec.pjo_attribute8
    ,p_rec.pjo_attribute9
    ,p_rec.pjo_attribute10
    ,p_rec.pjo_attribute11
    ,p_rec.pjo_attribute12
    ,p_rec.pjo_attribute13
    ,p_rec.pjo_attribute14
    ,p_rec.pjo_attribute15
    ,p_rec.pjo_attribute16
    ,p_rec.pjo_attribute17
    ,p_rec.pjo_attribute18
    ,p_rec.pjo_attribute19
    ,p_rec.pjo_attribute20
    ,p_rec.pjo_attribute21
    ,p_rec.pjo_attribute22
    ,p_rec.pjo_attribute23
    ,p_rec.pjo_attribute24
    ,p_rec.pjo_attribute25
    ,p_rec.pjo_attribute26
    ,p_rec.pjo_attribute27
    ,p_rec.pjo_attribute28
    ,p_rec.pjo_attribute29
    ,p_rec.pjo_attribute30
    ,p_rec.pjo_information_category
    ,p_rec.pjo_information1
    ,p_rec.pjo_information2
    ,p_rec.pjo_information3
    ,p_rec.pjo_information4
    ,p_rec.pjo_information5
    ,p_rec.pjo_information6
    ,p_rec.pjo_information7
    ,p_rec.pjo_information8
    ,p_rec.pjo_information9
    ,p_rec.pjo_information10
    ,p_rec.pjo_information11
    ,p_rec.pjo_information12
    ,p_rec.pjo_information13
    ,p_rec.pjo_information14
    ,p_rec.pjo_information15
    ,p_rec.pjo_information16
    ,p_rec.pjo_information17
    ,p_rec.pjo_information18
    ,p_rec.pjo_information19
    ,p_rec.pjo_information20
    ,p_rec.pjo_information21
    ,p_rec.pjo_information22
    ,p_rec.pjo_information23
    ,p_rec.pjo_information24
    ,p_rec.pjo_information25
    ,p_rec.pjo_information26
    ,p_rec.pjo_information27
    ,p_rec.pjo_information28
    ,p_rec.pjo_information29
    ,p_rec.pjo_information30
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
    per_pjo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    per_pjo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    per_pjo_shd.constraint_error
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
  (p_rec  in out nocopy per_pjo_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select per_previous_jobs_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from per_previous_jobs
     where previous_job_id =
             per_pjo_ins.g_previous_job_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (per_pjo_ins.g_previous_job_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','per_previous_jobs');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.previous_job_id :=
      per_pjo_ins.g_previous_job_id_i;
    per_pjo_ins.g_previous_job_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.previous_job_id;
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
  ,p_rec                          in per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pjo_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_previous_job_id
      => p_rec.previous_job_id
      ,p_previous_employer_id
      => p_rec.previous_employer_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_period_years
      => p_rec.period_years
      ,p_period_days
      => p_rec.period_days
      ,p_job_name
      => p_rec.job_name
      ,p_employment_category
      => p_rec.employment_category
      ,p_description
      => p_rec.description
      ,p_pjo_attribute_category
      => p_rec.pjo_attribute_category
      ,p_pjo_attribute1
      => p_rec.pjo_attribute1
      ,p_pjo_attribute2
      => p_rec.pjo_attribute2
      ,p_pjo_attribute3
      => p_rec.pjo_attribute3
      ,p_pjo_attribute4
      => p_rec.pjo_attribute4
      ,p_pjo_attribute5
      => p_rec.pjo_attribute5
      ,p_pjo_attribute6
      => p_rec.pjo_attribute6
      ,p_pjo_attribute7
      => p_rec.pjo_attribute7
      ,p_pjo_attribute8
      => p_rec.pjo_attribute8
      ,p_pjo_attribute9
      => p_rec.pjo_attribute9
      ,p_pjo_attribute10
      => p_rec.pjo_attribute10
      ,p_pjo_attribute11
      => p_rec.pjo_attribute11
      ,p_pjo_attribute12
      => p_rec.pjo_attribute12
      ,p_pjo_attribute13
      => p_rec.pjo_attribute13
      ,p_pjo_attribute14
      => p_rec.pjo_attribute14
      ,p_pjo_attribute15
      => p_rec.pjo_attribute15
      ,p_pjo_attribute16
      => p_rec.pjo_attribute16
      ,p_pjo_attribute17
      => p_rec.pjo_attribute17
      ,p_pjo_attribute18
      => p_rec.pjo_attribute18
      ,p_pjo_attribute19
      => p_rec.pjo_attribute19
      ,p_pjo_attribute20
      => p_rec.pjo_attribute20
      ,p_pjo_attribute21
      => p_rec.pjo_attribute21
      ,p_pjo_attribute22
      => p_rec.pjo_attribute22
      ,p_pjo_attribute23
      => p_rec.pjo_attribute23
      ,p_pjo_attribute24
      => p_rec.pjo_attribute24
      ,p_pjo_attribute25
      => p_rec.pjo_attribute25
      ,p_pjo_attribute26
      => p_rec.pjo_attribute26
      ,p_pjo_attribute27
      => p_rec.pjo_attribute27
      ,p_pjo_attribute28
      => p_rec.pjo_attribute28
      ,p_pjo_attribute29
      => p_rec.pjo_attribute29
      ,p_pjo_attribute30
      => p_rec.pjo_attribute30
      ,p_pjo_information_category
      => p_rec.pjo_information_category
      ,p_pjo_information1
      => p_rec.pjo_information1
      ,p_pjo_information2
      => p_rec.pjo_information2
      ,p_pjo_information3
      => p_rec.pjo_information3
      ,p_pjo_information4
      => p_rec.pjo_information4
      ,p_pjo_information5
      => p_rec.pjo_information5
      ,p_pjo_information6
      => p_rec.pjo_information6
      ,p_pjo_information7
      => p_rec.pjo_information7
      ,p_pjo_information8
      => p_rec.pjo_information8
      ,p_pjo_information9
      => p_rec.pjo_information9
      ,p_pjo_information10
      => p_rec.pjo_information10
      ,p_pjo_information11
      => p_rec.pjo_information11
      ,p_pjo_information12
      => p_rec.pjo_information12
      ,p_pjo_information13
      => p_rec.pjo_information13
      ,p_pjo_information14
      => p_rec.pjo_information14
      ,p_pjo_information15
      => p_rec.pjo_information15
      ,p_pjo_information16
      => p_rec.pjo_information16
      ,p_pjo_information17
      => p_rec.pjo_information17
      ,p_pjo_information18
      => p_rec.pjo_information18
      ,p_pjo_information19
      => p_rec.pjo_information19
      ,p_pjo_information20
      => p_rec.pjo_information20
      ,p_pjo_information21
      => p_rec.pjo_information21
      ,p_pjo_information22
      => p_rec.pjo_information22
      ,p_pjo_information23
      => p_rec.pjo_information23
      ,p_pjo_information24
      => p_rec.pjo_information24
      ,p_pjo_information25
      => p_rec.pjo_information25
      ,p_pjo_information26
      => p_rec.pjo_information26
      ,p_pjo_information27
      => p_rec.pjo_information27
      ,p_pjo_information28
      => p_rec.pjo_information28
      ,p_pjo_information29
      => p_rec.pjo_information29
      ,p_pjo_information30
      => p_rec.pjo_information30
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
        (p_module_name => 'PER_PREVIOUS_JOBS'
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
  ,p_rec                          in out nocopy per_pjo_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_pjo_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-insert operation
  --
  per_pjo_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_pjo_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_pjo_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_previous_employer_id           in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_days                    in     number   default null
  ,p_job_name                       in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_pjo_attribute_category         in     varchar2 default null
  ,p_pjo_attribute1                 in     varchar2 default null
  ,p_pjo_attribute2                 in     varchar2 default null
  ,p_pjo_attribute3                 in     varchar2 default null
  ,p_pjo_attribute4                 in     varchar2 default null
  ,p_pjo_attribute5                 in     varchar2 default null
  ,p_pjo_attribute6                 in     varchar2 default null
  ,p_pjo_attribute7                 in     varchar2 default null
  ,p_pjo_attribute8                 in     varchar2 default null
  ,p_pjo_attribute9                 in     varchar2 default null
  ,p_pjo_attribute10                in     varchar2 default null
  ,p_pjo_attribute11                in     varchar2 default null
  ,p_pjo_attribute12                in     varchar2 default null
  ,p_pjo_attribute13                in     varchar2 default null
  ,p_pjo_attribute14                in     varchar2 default null
  ,p_pjo_attribute15                in     varchar2 default null
  ,p_pjo_attribute16                in     varchar2 default null
  ,p_pjo_attribute17                in     varchar2 default null
  ,p_pjo_attribute18                in     varchar2 default null
  ,p_pjo_attribute19                in     varchar2 default null
  ,p_pjo_attribute20                in     varchar2 default null
  ,p_pjo_attribute21                in     varchar2 default null
  ,p_pjo_attribute22                in     varchar2 default null
  ,p_pjo_attribute23                in     varchar2 default null
  ,p_pjo_attribute24                in     varchar2 default null
  ,p_pjo_attribute25                in     varchar2 default null
  ,p_pjo_attribute26                in     varchar2 default null
  ,p_pjo_attribute27                in     varchar2 default null
  ,p_pjo_attribute28                in     varchar2 default null
  ,p_pjo_attribute29                in     varchar2 default null
  ,p_pjo_attribute30                in     varchar2 default null
  ,p_pjo_information_category       in     varchar2 default null
  ,p_pjo_information1               in     varchar2 default null
  ,p_pjo_information2               in     varchar2 default null
  ,p_pjo_information3               in     varchar2 default null
  ,p_pjo_information4               in     varchar2 default null
  ,p_pjo_information5               in     varchar2 default null
  ,p_pjo_information6               in     varchar2 default null
  ,p_pjo_information7               in     varchar2 default null
  ,p_pjo_information8               in     varchar2 default null
  ,p_pjo_information9               in     varchar2 default null
  ,p_pjo_information10              in     varchar2 default null
  ,p_pjo_information11              in     varchar2 default null
  ,p_pjo_information12              in     varchar2 default null
  ,p_pjo_information13              in     varchar2 default null
  ,p_pjo_information14              in     varchar2 default null
  ,p_pjo_information15              in     varchar2 default null
  ,p_pjo_information16              in     varchar2 default null
  ,p_pjo_information17              in     varchar2 default null
  ,p_pjo_information18              in     varchar2 default null
  ,p_pjo_information19              in     varchar2 default null
  ,p_pjo_information20              in     varchar2 default null
  ,p_pjo_information21              in     varchar2 default null
  ,p_pjo_information22              in     varchar2 default null
  ,p_pjo_information23              in     varchar2 default null
  ,p_pjo_information24              in     varchar2 default null
  ,p_pjo_information25              in     varchar2 default null
  ,p_pjo_information26              in     varchar2 default null
  ,p_pjo_information27              in     varchar2 default null
  ,p_pjo_information28              in     varchar2 default null
  ,p_pjo_information29              in     varchar2 default null
  ,p_pjo_information30              in     varchar2 default null
  ,p_all_assignments                in     varchar2 default null
  ,p_period_months                  in     number   default null
  ,p_previous_job_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   per_pjo_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pjo_shd.convert_args
    (null
    ,p_previous_employer_id
    ,p_start_date
    ,p_end_date
    ,p_period_years
    ,p_period_days
    ,p_job_name
    ,p_employment_category
    ,p_description
    ,p_pjo_attribute_category
    ,p_pjo_attribute1
    ,p_pjo_attribute2
    ,p_pjo_attribute3
    ,p_pjo_attribute4
    ,p_pjo_attribute5
    ,p_pjo_attribute6
    ,p_pjo_attribute7
    ,p_pjo_attribute8
    ,p_pjo_attribute9
    ,p_pjo_attribute10
    ,p_pjo_attribute11
    ,p_pjo_attribute12
    ,p_pjo_attribute13
    ,p_pjo_attribute14
    ,p_pjo_attribute15
    ,p_pjo_attribute16
    ,p_pjo_attribute17
    ,p_pjo_attribute18
    ,p_pjo_attribute19
    ,p_pjo_attribute20
    ,p_pjo_attribute21
    ,p_pjo_attribute22
    ,p_pjo_attribute23
    ,p_pjo_attribute24
    ,p_pjo_attribute25
    ,p_pjo_attribute26
    ,p_pjo_attribute27
    ,p_pjo_attribute28
    ,p_pjo_attribute29
    ,p_pjo_attribute30
    ,p_pjo_information_category
    ,p_pjo_information1
    ,p_pjo_information2
    ,p_pjo_information3
    ,p_pjo_information4
    ,p_pjo_information5
    ,p_pjo_information6
    ,p_pjo_information7
    ,p_pjo_information8
    ,p_pjo_information9
    ,p_pjo_information10
    ,p_pjo_information11
    ,p_pjo_information12
    ,p_pjo_information13
    ,p_pjo_information14
    ,p_pjo_information15
    ,p_pjo_information16
    ,p_pjo_information17
    ,p_pjo_information18
    ,p_pjo_information19
    ,p_pjo_information20
    ,p_pjo_information21
    ,p_pjo_information22
    ,p_pjo_information23
    ,p_pjo_information24
    ,p_pjo_information25
    ,p_pjo_information26
    ,p_pjo_information27
    ,p_pjo_information28
    ,p_pjo_information29
    ,p_pjo_information30
    ,null
    ,p_all_assignments
    ,p_period_months
    );
  --
  -- Having converted the arguments into the per_pjo_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_pjo_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_previous_job_id := l_rec.previous_job_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end per_pjo_ins;

/