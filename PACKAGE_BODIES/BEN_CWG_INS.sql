--------------------------------------------------------
--  DDL for Package Body BEN_CWG_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWG_INS" as
/* $Header: becwgrhi.pkb 120.0 2005/05/28 01:29:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cwg_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_cwb_wksht_grp_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_cwb_wksht_grp_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_cwg_ins.g_cwb_wksht_grp_id_i := p_cwb_wksht_grp_id;
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
  (p_rec in out nocopy ben_cwg_shd.g_rec_type
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
  -- Insert the row into: ben_cwb_wksht_grp
  --
  insert into ben_cwb_wksht_grp
      (cwb_wksht_grp_id
      ,business_group_id
      ,pl_id
      ,ordr_num
      ,wksht_grp_cd
      ,label
      ,cwg_attribute_category
      ,cwg_attribute1
      ,cwg_attribute2
      ,cwg_attribute3
      ,cwg_attribute4
      ,cwg_attribute5
      ,cwg_attribute6
      ,cwg_attribute7
      ,cwg_attribute8
      ,cwg_attribute9
      ,cwg_attribute10
      ,cwg_attribute11
      ,cwg_attribute12
      ,cwg_attribute13
      ,cwg_attribute14
      ,cwg_attribute15
      ,cwg_attribute16
      ,cwg_attribute17
      ,cwg_attribute18
      ,cwg_attribute19
      ,cwg_attribute20
      ,cwg_attribute21
      ,cwg_attribute22
      ,cwg_attribute23
      ,cwg_attribute24
      ,cwg_attribute25
      ,cwg_attribute26
      ,cwg_attribute27
      ,cwg_attribute28
      ,cwg_attribute29
      ,cwg_attribute30
      ,status_cd
      ,hidden_cd
      ,object_version_number
      )
  Values
    (p_rec.cwb_wksht_grp_id
    ,p_rec.business_group_id
    ,p_rec.pl_id
    ,p_rec.ordr_num
    ,p_rec.wksht_grp_cd
    ,p_rec.label
    ,p_rec.cwg_attribute_category
    ,p_rec.cwg_attribute1
    ,p_rec.cwg_attribute2
    ,p_rec.cwg_attribute3
    ,p_rec.cwg_attribute4
    ,p_rec.cwg_attribute5
    ,p_rec.cwg_attribute6
    ,p_rec.cwg_attribute7
    ,p_rec.cwg_attribute8
    ,p_rec.cwg_attribute9
    ,p_rec.cwg_attribute10
    ,p_rec.cwg_attribute11
    ,p_rec.cwg_attribute12
    ,p_rec.cwg_attribute13
    ,p_rec.cwg_attribute14
    ,p_rec.cwg_attribute15
    ,p_rec.cwg_attribute16
    ,p_rec.cwg_attribute17
    ,p_rec.cwg_attribute18
    ,p_rec.cwg_attribute19
    ,p_rec.cwg_attribute20
    ,p_rec.cwg_attribute21
    ,p_rec.cwg_attribute22
    ,p_rec.cwg_attribute23
    ,p_rec.cwg_attribute24
    ,p_rec.cwg_attribute25
    ,p_rec.cwg_attribute26
    ,p_rec.cwg_attribute27
    ,p_rec.cwg_attribute28
    ,p_rec.cwg_attribute29
    ,p_rec.cwg_attribute30
    ,p_rec.status_cd
    ,p_rec.hidden_cd
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
    ben_cwg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ben_cwg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ben_cwg_shd.constraint_error
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
  (p_rec  in out nocopy ben_cwg_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ben_cwb_wksht_grp_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from ben_cwb_wksht_grp
     where cwb_wksht_grp_id =
             ben_cwg_ins.g_cwb_wksht_grp_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (ben_cwg_ins.g_cwb_wksht_grp_id_i is not null) Then
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
       fnd_message.set_token('TABLE_NAME','ben_cwb_wksht_grp');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.cwb_wksht_grp_id :=
      ben_cwg_ins.g_cwb_wksht_grp_id_i;
    ben_cwg_ins.g_cwb_wksht_grp_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.cwb_wksht_grp_id;
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
  ,p_rec                          in ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_cwg_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_cwb_wksht_grp_id
      => p_rec.cwb_wksht_grp_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_pl_id
      => p_rec.pl_id
      ,p_ordr_num
      => p_rec.ordr_num
      ,p_wksht_grp_cd
      => p_rec.wksht_grp_cd
      ,p_label
      => p_rec.label
      ,p_cwg_attribute_category
      => p_rec.cwg_attribute_category
      ,p_cwg_attribute1
      => p_rec.cwg_attribute1
      ,p_cwg_attribute2
      => p_rec.cwg_attribute2
      ,p_cwg_attribute3
      => p_rec.cwg_attribute3
      ,p_cwg_attribute4
      => p_rec.cwg_attribute4
      ,p_cwg_attribute5
      => p_rec.cwg_attribute5
      ,p_cwg_attribute6
      => p_rec.cwg_attribute6
      ,p_cwg_attribute7
      => p_rec.cwg_attribute7
      ,p_cwg_attribute8
      => p_rec.cwg_attribute8
      ,p_cwg_attribute9
      => p_rec.cwg_attribute9
      ,p_cwg_attribute10
      => p_rec.cwg_attribute10
      ,p_cwg_attribute11
      => p_rec.cwg_attribute11
      ,p_cwg_attribute12
      => p_rec.cwg_attribute12
      ,p_cwg_attribute13
      => p_rec.cwg_attribute13
      ,p_cwg_attribute14
      => p_rec.cwg_attribute14
      ,p_cwg_attribute15
      => p_rec.cwg_attribute15
      ,p_cwg_attribute16
      => p_rec.cwg_attribute16
      ,p_cwg_attribute17
      => p_rec.cwg_attribute17
      ,p_cwg_attribute18
      => p_rec.cwg_attribute18
      ,p_cwg_attribute19
      => p_rec.cwg_attribute19
      ,p_cwg_attribute20
      => p_rec.cwg_attribute20
      ,p_cwg_attribute21
      => p_rec.cwg_attribute21
      ,p_cwg_attribute22
      => p_rec.cwg_attribute22
      ,p_cwg_attribute23
      => p_rec.cwg_attribute23
      ,p_cwg_attribute24
      => p_rec.cwg_attribute24
      ,p_cwg_attribute25
      => p_rec.cwg_attribute25
      ,p_cwg_attribute26
      => p_rec.cwg_attribute26
      ,p_cwg_attribute27
      => p_rec.cwg_attribute27
      ,p_cwg_attribute28
      => p_rec.cwg_attribute28
      ,p_cwg_attribute29
      => p_rec.cwg_attribute29
      ,p_cwg_attribute30
      => p_rec.cwg_attribute30
      ,p_status_cd  => p_rec.status_cd
      ,p_hidden_cd => p_rec.hidden_cd
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_WKSHT_GRP'
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
  ,p_rec                          in out nocopy ben_cwg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cwg_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  ben_cwg_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  ben_cwg_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_cwg_ins.post_insert
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
  ,p_business_group_id              in     number
  ,p_pl_id                          in     number
  ,p_ordr_num                       in     number
  ,p_wksht_grp_cd                   in     varchar2
  ,p_label                          in     varchar2
  ,p_cwg_attribute_category         in     varchar2 default null
  ,p_cwg_attribute1                 in     varchar2 default null
  ,p_cwg_attribute2                 in     varchar2 default null
  ,p_cwg_attribute3                 in     varchar2 default null
  ,p_cwg_attribute4                 in     varchar2 default null
  ,p_cwg_attribute5                 in     varchar2 default null
  ,p_cwg_attribute6                 in     varchar2 default null
  ,p_cwg_attribute7                 in     varchar2 default null
  ,p_cwg_attribute8                 in     varchar2 default null
  ,p_cwg_attribute9                 in     varchar2 default null
  ,p_cwg_attribute10                in     varchar2 default null
  ,p_cwg_attribute11                in     varchar2 default null
  ,p_cwg_attribute12                in     varchar2 default null
  ,p_cwg_attribute13                in     varchar2 default null
  ,p_cwg_attribute14                in     varchar2 default null
  ,p_cwg_attribute15                in     varchar2 default null
  ,p_cwg_attribute16                in     varchar2 default null
  ,p_cwg_attribute17                in     varchar2 default null
  ,p_cwg_attribute18                in     varchar2 default null
  ,p_cwg_attribute19                in     varchar2 default null
  ,p_cwg_attribute20                in     varchar2 default null
  ,p_cwg_attribute21                in     varchar2 default null
  ,p_cwg_attribute22                in     varchar2 default null
  ,p_cwg_attribute23                in     varchar2 default null
  ,p_cwg_attribute24                in     varchar2 default null
  ,p_cwg_attribute25                in     varchar2 default null
  ,p_cwg_attribute26                in     varchar2 default null
  ,p_cwg_attribute27                in     varchar2 default null
  ,p_cwg_attribute28                in     varchar2 default null
  ,p_cwg_attribute29                in     varchar2 default null
  ,p_cwg_attribute30                in     varchar2 default null
  ,p_status_cd                      in     varchar2 default null
  ,p_hidden_cd                    in     varchar2 default null
  ,p_cwb_wksht_grp_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_cwg_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cwg_shd.convert_args
    (null
    ,p_business_group_id
    ,p_pl_id
    ,p_ordr_num
    ,p_wksht_grp_cd
    ,p_label
    ,p_cwg_attribute_category
    ,p_cwg_attribute1
    ,p_cwg_attribute2
    ,p_cwg_attribute3
    ,p_cwg_attribute4
    ,p_cwg_attribute5
    ,p_cwg_attribute6
    ,p_cwg_attribute7
    ,p_cwg_attribute8
    ,p_cwg_attribute9
    ,p_cwg_attribute10
    ,p_cwg_attribute11
    ,p_cwg_attribute12
    ,p_cwg_attribute13
    ,p_cwg_attribute14
    ,p_cwg_attribute15
    ,p_cwg_attribute16
    ,p_cwg_attribute17
    ,p_cwg_attribute18
    ,p_cwg_attribute19
    ,p_cwg_attribute20
    ,p_cwg_attribute21
    ,p_cwg_attribute22
    ,p_cwg_attribute23
    ,p_cwg_attribute24
    ,p_cwg_attribute25
    ,p_cwg_attribute26
    ,p_cwg_attribute27
    ,p_cwg_attribute28
    ,p_cwg_attribute29
    ,p_cwg_attribute30
    ,p_status_cd
    ,p_hidden_cd
    ,null
    );
  --
  -- Having converted the arguments into the ben_cwg_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_cwg_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cwb_wksht_grp_id := l_rec.cwb_wksht_grp_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cwg_ins;

/
