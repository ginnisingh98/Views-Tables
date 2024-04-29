--------------------------------------------------------
--  DDL for Package Body BEN_PDT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_INS" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 rpillay noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pdt_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_pymt_check_det_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_pymt_check_det_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_pdt_ins.g_pymt_check_det_id_i := p_pymt_check_det_id;
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
  (p_rec in out nocopy ben_pdt_shd.g_rec_type
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
  -- Insert the row into: ben_pymt_check_det
  --
  insert into ben_pymt_check_det
      (pymt_check_det_id
      ,person_id
      ,business_group_id
      ,check_num
      ,pymt_dt
      ,pymt_amt
      ,pdt_attribute_category
      ,pdt_attribute1
      ,pdt_attribute2
      ,pdt_attribute3
      ,pdt_attribute4
      ,pdt_attribute5
      ,pdt_attribute6
      ,pdt_attribute7
      ,pdt_attribute8
      ,pdt_attribute9
      ,pdt_attribute10
      ,pdt_attribute11
      ,pdt_attribute12
      ,pdt_attribute13
      ,pdt_attribute14
      ,pdt_attribute15
      ,pdt_attribute16
      ,pdt_attribute17
      ,pdt_attribute18
      ,pdt_attribute19
      ,pdt_attribute20
      ,pdt_attribute21
      ,pdt_attribute22
      ,pdt_attribute23
      ,pdt_attribute24
      ,pdt_attribute25
      ,pdt_attribute26
      ,pdt_attribute27
      ,pdt_attribute28
      ,pdt_attribute29
      ,pdt_attribute30
      ,object_version_number
      )
  Values
    (p_rec.pymt_check_det_id
    ,p_rec.person_id
    ,p_rec.business_group_id
    ,p_rec.check_num
    ,p_rec.pymt_dt
    ,p_rec.pymt_amt
    ,p_rec.pdt_attribute_category
    ,p_rec.pdt_attribute1
    ,p_rec.pdt_attribute2
    ,p_rec.pdt_attribute3
    ,p_rec.pdt_attribute4
    ,p_rec.pdt_attribute5
    ,p_rec.pdt_attribute6
    ,p_rec.pdt_attribute7
    ,p_rec.pdt_attribute8
    ,p_rec.pdt_attribute9
    ,p_rec.pdt_attribute10
    ,p_rec.pdt_attribute11
    ,p_rec.pdt_attribute12
    ,p_rec.pdt_attribute13
    ,p_rec.pdt_attribute14
    ,p_rec.pdt_attribute15
    ,p_rec.pdt_attribute16
    ,p_rec.pdt_attribute17
    ,p_rec.pdt_attribute18
    ,p_rec.pdt_attribute19
    ,p_rec.pdt_attribute20
    ,p_rec.pdt_attribute21
    ,p_rec.pdt_attribute22
    ,p_rec.pdt_attribute23
    ,p_rec.pdt_attribute24
    ,p_rec.pdt_attribute25
    ,p_rec.pdt_attribute26
    ,p_rec.pdt_attribute27
    ,p_rec.pdt_attribute28
    ,p_rec.pdt_attribute29
    ,p_rec.pdt_attribute30
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
    ben_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_pdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_pdt_shd.constraint_error
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
  (p_rec  in out nocopy ben_pdt_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ben_pymt_check_det_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ben_pymt_check_det
     where pymt_check_det_id =
             ben_pdt_ins.g_pymt_check_det_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ben_pdt_ins.g_pymt_check_det_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ben_pymt_check_det');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.pymt_check_det_id :=
      ben_pdt_ins.g_pymt_check_det_id_i;
    ben_pdt_ins.g_pymt_check_det_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.pymt_check_det_id;
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
  ,p_rec                          in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_pdt_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_pymt_check_det_id
      => p_rec.pymt_check_det_id
      ,p_person_id
      => p_rec.person_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_check_num
      => p_rec.check_num
      ,p_pymt_dt
      => p_rec.pymt_dt
      ,p_pymt_amt
      => p_rec.pymt_amt
      ,p_pdt_attribute_category
      => p_rec.pdt_attribute_category
      ,p_pdt_attribute1
      => p_rec.pdt_attribute1
      ,p_pdt_attribute2
      => p_rec.pdt_attribute2
      ,p_pdt_attribute3
      => p_rec.pdt_attribute3
      ,p_pdt_attribute4
      => p_rec.pdt_attribute4
      ,p_pdt_attribute5
      => p_rec.pdt_attribute5
      ,p_pdt_attribute6
      => p_rec.pdt_attribute6
      ,p_pdt_attribute7
      => p_rec.pdt_attribute7
      ,p_pdt_attribute8
      => p_rec.pdt_attribute8
      ,p_pdt_attribute9
      => p_rec.pdt_attribute9
      ,p_pdt_attribute10
      => p_rec.pdt_attribute10
      ,p_pdt_attribute11
      => p_rec.pdt_attribute11
      ,p_pdt_attribute12
      => p_rec.pdt_attribute12
      ,p_pdt_attribute13
      => p_rec.pdt_attribute13
      ,p_pdt_attribute14
      => p_rec.pdt_attribute14
      ,p_pdt_attribute15
      => p_rec.pdt_attribute15
      ,p_pdt_attribute16
      => p_rec.pdt_attribute16
      ,p_pdt_attribute17
      => p_rec.pdt_attribute17
      ,p_pdt_attribute18
      => p_rec.pdt_attribute18
      ,p_pdt_attribute19
      => p_rec.pdt_attribute19
      ,p_pdt_attribute20
      => p_rec.pdt_attribute20
      ,p_pdt_attribute21
      => p_rec.pdt_attribute21
      ,p_pdt_attribute22
      => p_rec.pdt_attribute22
      ,p_pdt_attribute23
      => p_rec.pdt_attribute23
      ,p_pdt_attribute24
      => p_rec.pdt_attribute24
      ,p_pdt_attribute25
      => p_rec.pdt_attribute25
      ,p_pdt_attribute26
      => p_rec.pdt_attribute26
      ,p_pdt_attribute27
      => p_rec.pdt_attribute27
      ,p_pdt_attribute28
      => p_rec.pdt_attribute28
      ,p_pdt_attribute29
      => p_rec.pdt_attribute29
      ,p_pdt_attribute30
      => p_rec.pdt_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_PYMT_CHECK_DET'
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
  ,p_rec                          in out nocopy ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_pdt_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_pdt_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_pdt_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_pdt_ins.post_insert
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
  (p_effective_date               in     date
  ,p_person_id                      in     number
  ,p_business_group_id              in     number
  ,p_check_num                      in     varchar2 default null
  ,p_pymt_dt                        in     date     default null
  ,p_pymt_amt                       in     number   default null
  ,p_pdt_attribute_category         in     varchar2 default null
  ,p_pdt_attribute1                 in     varchar2 default null
  ,p_pdt_attribute2                 in     varchar2 default null
  ,p_pdt_attribute3                 in     varchar2 default null
  ,p_pdt_attribute4                 in     varchar2 default null
  ,p_pdt_attribute5                 in     varchar2 default null
  ,p_pdt_attribute6                 in     varchar2 default null
  ,p_pdt_attribute7                 in     varchar2 default null
  ,p_pdt_attribute8                 in     varchar2 default null
  ,p_pdt_attribute9                 in     varchar2 default null
  ,p_pdt_attribute10                in     varchar2 default null
  ,p_pdt_attribute11                in     varchar2 default null
  ,p_pdt_attribute12                in     varchar2 default null
  ,p_pdt_attribute13                in     varchar2 default null
  ,p_pdt_attribute14                in     varchar2 default null
  ,p_pdt_attribute15                in     varchar2 default null
  ,p_pdt_attribute16                in     varchar2 default null
  ,p_pdt_attribute17                in     varchar2 default null
  ,p_pdt_attribute18                in     varchar2 default null
  ,p_pdt_attribute19                in     varchar2 default null
  ,p_pdt_attribute20                in     varchar2 default null
  ,p_pdt_attribute21                in     varchar2 default null
  ,p_pdt_attribute22                in     varchar2 default null
  ,p_pdt_attribute23                in     varchar2 default null
  ,p_pdt_attribute24                in     varchar2 default null
  ,p_pdt_attribute25                in     varchar2 default null
  ,p_pdt_attribute26                in     varchar2 default null
  ,p_pdt_attribute27                in     varchar2 default null
  ,p_pdt_attribute28                in     varchar2 default null
  ,p_pdt_attribute29                in     varchar2 default null
  ,p_pdt_attribute30                in     varchar2 default null
  ,p_pymt_check_det_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_pdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pdt_shd.convert_args
    (null
    ,p_person_id
    ,p_business_group_id
    ,p_check_num
    ,p_pymt_dt
    ,p_pymt_amt
    ,p_pdt_attribute_category
    ,p_pdt_attribute1
    ,p_pdt_attribute2
    ,p_pdt_attribute3
    ,p_pdt_attribute4
    ,p_pdt_attribute5
    ,p_pdt_attribute6
    ,p_pdt_attribute7
    ,p_pdt_attribute8
    ,p_pdt_attribute9
    ,p_pdt_attribute10
    ,p_pdt_attribute11
    ,p_pdt_attribute12
    ,p_pdt_attribute13
    ,p_pdt_attribute14
    ,p_pdt_attribute15
    ,p_pdt_attribute16
    ,p_pdt_attribute17
    ,p_pdt_attribute18
    ,p_pdt_attribute19
    ,p_pdt_attribute20
    ,p_pdt_attribute21
    ,p_pdt_attribute22
    ,p_pdt_attribute23
    ,p_pdt_attribute24
    ,p_pdt_attribute25
    ,p_pdt_attribute26
    ,p_pdt_attribute27
    ,p_pdt_attribute28
    ,p_pdt_attribute29
    ,p_pdt_attribute30
    ,null
    );
  --
  -- Having converted the arguments into the ben_pdt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_pdt_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pymt_check_det_id := l_rec.pymt_check_det_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pdt_ins;

/
