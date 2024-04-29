--------------------------------------------------------
--  DDL for Package Body BEN_EIV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EIV_INS" as
/* $Header: beeivrhi.pkb 115.4 2002/12/22 20:25:28 pabodla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_eiv_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_extra_input_value_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_extra_input_value_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  ben_eiv_ins.g_extra_input_value_id_i := p_extra_input_value_id;
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
  (p_rec in out nocopy ben_eiv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_eiv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_extra_input_values
  --
  insert into ben_extra_input_values
      (extra_input_value_id
      ,acty_base_rt_id
      ,input_value_id
      ,input_text
      ,upd_when_ele_ended_cd
      ,return_var_name
      ,business_group_id
      ,eiv_attribute_category
      ,eiv_attribute1
      ,eiv_attribute2
      ,eiv_attribute3
      ,eiv_attribute4
      ,eiv_attribute5
      ,eiv_attribute6
      ,eiv_attribute7
      ,eiv_attribute8
      ,eiv_attribute9
      ,eiv_attribute10
      ,eiv_attribute11
      ,eiv_attribute12
      ,eiv_attribute13
      ,eiv_attribute14
      ,eiv_attribute15
      ,eiv_attribute16
      ,eiv_attribute17
      ,eiv_attribute18
      ,eiv_attribute19
      ,eiv_attribute20
      ,eiv_attribute21
      ,eiv_attribute22
      ,eiv_attribute23
      ,eiv_attribute24
      ,eiv_attribute25
      ,eiv_attribute26
      ,eiv_attribute27
      ,eiv_attribute28
      ,eiv_attribute29
      ,eiv_attribute30
      ,object_version_number
      )
  Values
    (p_rec.extra_input_value_id
    ,p_rec.acty_base_rt_id
    ,p_rec.input_value_id
    ,p_rec.input_text
    ,p_rec.upd_when_ele_ended_cd
    ,p_rec.return_var_name
    ,p_rec.business_group_id
    ,p_rec.eiv_attribute_category
    ,p_rec.eiv_attribute1
    ,p_rec.eiv_attribute2
    ,p_rec.eiv_attribute3
    ,p_rec.eiv_attribute4
    ,p_rec.eiv_attribute5
    ,p_rec.eiv_attribute6
    ,p_rec.eiv_attribute7
    ,p_rec.eiv_attribute8
    ,p_rec.eiv_attribute9
    ,p_rec.eiv_attribute10
    ,p_rec.eiv_attribute11
    ,p_rec.eiv_attribute12
    ,p_rec.eiv_attribute13
    ,p_rec.eiv_attribute14
    ,p_rec.eiv_attribute15
    ,p_rec.eiv_attribute16
    ,p_rec.eiv_attribute17
    ,p_rec.eiv_attribute18
    ,p_rec.eiv_attribute19
    ,p_rec.eiv_attribute20
    ,p_rec.eiv_attribute21
    ,p_rec.eiv_attribute22
    ,p_rec.eiv_attribute23
    ,p_rec.eiv_attribute24
    ,p_rec.eiv_attribute25
    ,p_rec.eiv_attribute26
    ,p_rec.eiv_attribute27
    ,p_rec.eiv_attribute28
    ,p_rec.eiv_attribute29
    ,p_rec.eiv_attribute30
    ,p_rec.object_version_number
    );
  --
  ben_eiv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_eiv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eiv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_eiv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eiv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_eiv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_eiv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_eiv_shd.g_api_dml := false;   -- Unset the api dml status
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy ben_eiv_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select ben_extra_input_values_s.nextval from sys.dual;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.extra_input_value_id;
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
  ,p_rec                          in ben_eiv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    ben_eiv_rki.after_insert
      (p_extra_input_value_id
      => p_rec.extra_input_value_id
      ,p_acty_base_rt_id
      => p_rec.acty_base_rt_id
      ,p_input_value_id
      => p_rec.input_value_id
      ,p_input_text
      => p_rec.input_text
      ,p_upd_when_ele_ended_cd
      => p_rec.upd_when_ele_ended_cd
      ,p_return_var_name
      => p_rec.return_var_name
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_eiv_attribute_category
      => p_rec.eiv_attribute_category
      ,p_eiv_attribute1
      => p_rec.eiv_attribute1
      ,p_eiv_attribute2
      => p_rec.eiv_attribute2
      ,p_eiv_attribute3
      => p_rec.eiv_attribute3
      ,p_eiv_attribute4
      => p_rec.eiv_attribute4
      ,p_eiv_attribute5
      => p_rec.eiv_attribute5
      ,p_eiv_attribute6
      => p_rec.eiv_attribute6
      ,p_eiv_attribute7
      => p_rec.eiv_attribute7
      ,p_eiv_attribute8
      => p_rec.eiv_attribute8
      ,p_eiv_attribute9
      => p_rec.eiv_attribute9
      ,p_eiv_attribute10
      => p_rec.eiv_attribute10
      ,p_eiv_attribute11
      => p_rec.eiv_attribute11
      ,p_eiv_attribute12
      => p_rec.eiv_attribute12
      ,p_eiv_attribute13
      => p_rec.eiv_attribute13
      ,p_eiv_attribute14
      => p_rec.eiv_attribute14
      ,p_eiv_attribute15
      => p_rec.eiv_attribute15
      ,p_eiv_attribute16
      => p_rec.eiv_attribute16
      ,p_eiv_attribute17
      => p_rec.eiv_attribute17
      ,p_eiv_attribute18
      => p_rec.eiv_attribute18
      ,p_eiv_attribute19
      => p_rec.eiv_attribute19
      ,p_eiv_attribute20
      => p_rec.eiv_attribute20
      ,p_eiv_attribute21
      => p_rec.eiv_attribute21
      ,p_eiv_attribute22
      => p_rec.eiv_attribute22
      ,p_eiv_attribute23
      => p_rec.eiv_attribute23
      ,p_eiv_attribute24
      => p_rec.eiv_attribute24
      ,p_eiv_attribute25
      => p_rec.eiv_attribute25
      ,p_eiv_attribute26
      => p_rec.eiv_attribute26
      ,p_eiv_attribute27
      => p_rec.eiv_attribute27
      ,p_eiv_attribute28
      => p_rec.eiv_attribute28
      ,p_eiv_attribute29
      => p_rec.eiv_attribute29
      ,p_eiv_attribute30
      => p_rec.eiv_attribute30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_effective_date
      => p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_EXTRA_INPUT_VALUES'
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
  ,p_rec                          in out nocopy ben_eiv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_eiv_bus.insert_validate
     (p_rec
     ,p_effective_date
     );
  --
  -- Call the supporting pre-insert operation
  --
  ben_eiv_ins.pre_insert(p_effective_date
                        ,p_rec);
  --
  -- Insert the row
  --
  ben_eiv_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  ben_eiv_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date                 in     date
  ,p_acty_base_rt_id                in     number
  ,p_input_value_id                 in     number
  ,p_return_var_name                in     varchar2
  ,p_business_group_id              in     number
  ,p_input_text                     in     varchar2 default null
  ,p_upd_when_ele_ended_cd          in     varchar2 default null
  ,p_eiv_attribute_category         in     varchar2 default null
  ,p_eiv_attribute1                 in     varchar2 default null
  ,p_eiv_attribute2                 in     varchar2 default null
  ,p_eiv_attribute3                 in     varchar2 default null
  ,p_eiv_attribute4                 in     varchar2 default null
  ,p_eiv_attribute5                 in     varchar2 default null
  ,p_eiv_attribute6                 in     varchar2 default null
  ,p_eiv_attribute7                 in     varchar2 default null
  ,p_eiv_attribute8                 in     varchar2 default null
  ,p_eiv_attribute9                 in     varchar2 default null
  ,p_eiv_attribute10                in     varchar2 default null
  ,p_eiv_attribute11                in     varchar2 default null
  ,p_eiv_attribute12                in     varchar2 default null
  ,p_eiv_attribute13                in     varchar2 default null
  ,p_eiv_attribute14                in     varchar2 default null
  ,p_eiv_attribute15                in     varchar2 default null
  ,p_eiv_attribute16                in     varchar2 default null
  ,p_eiv_attribute17                in     varchar2 default null
  ,p_eiv_attribute18                in     varchar2 default null
  ,p_eiv_attribute19                in     varchar2 default null
  ,p_eiv_attribute20                in     varchar2 default null
  ,p_eiv_attribute21                in     varchar2 default null
  ,p_eiv_attribute22                in     varchar2 default null
  ,p_eiv_attribute23                in     varchar2 default null
  ,p_eiv_attribute24                in     varchar2 default null
  ,p_eiv_attribute25                in     varchar2 default null
  ,p_eiv_attribute26                in     varchar2 default null
  ,p_eiv_attribute27                in     varchar2 default null
  ,p_eiv_attribute28                in     varchar2 default null
  ,p_eiv_attribute29                in     varchar2 default null
  ,p_eiv_attribute30                in     varchar2 default null
  ,p_extra_input_value_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   ben_eiv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_eiv_shd.convert_args
    (null
    ,p_acty_base_rt_id
    ,p_input_value_id
    ,p_input_text
    ,p_upd_when_ele_ended_cd
    ,p_return_var_name
    ,p_business_group_id
    ,p_eiv_attribute_category
    ,p_eiv_attribute1
    ,p_eiv_attribute2
    ,p_eiv_attribute3
    ,p_eiv_attribute4
    ,p_eiv_attribute5
    ,p_eiv_attribute6
    ,p_eiv_attribute7
    ,p_eiv_attribute8
    ,p_eiv_attribute9
    ,p_eiv_attribute10
    ,p_eiv_attribute11
    ,p_eiv_attribute12
    ,p_eiv_attribute13
    ,p_eiv_attribute14
    ,p_eiv_attribute15
    ,p_eiv_attribute16
    ,p_eiv_attribute17
    ,p_eiv_attribute18
    ,p_eiv_attribute19
    ,p_eiv_attribute20
    ,p_eiv_attribute21
    ,p_eiv_attribute22
    ,p_eiv_attribute23
    ,p_eiv_attribute24
    ,p_eiv_attribute25
    ,p_eiv_attribute26
    ,p_eiv_attribute27
    ,p_eiv_attribute28
    ,p_eiv_attribute29
    ,p_eiv_attribute30
    ,null
    );
  --
  -- Having converted the arguments into the ben_eiv_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ben_eiv_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_extra_input_value_id := l_rec.extra_input_value_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_eiv_ins;

/
