--------------------------------------------------------
--  DDL for Package Body BEN_CLA_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLA_INS" as
/* $Header: beclarhi.pkb 120.0 2005/05/28 01:03:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cla_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_cla_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cla_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cmbn_age_los_fctr
  --
  insert into ben_cmbn_age_los_fctr
  (	cmbn_age_los_fctr_id,
	business_group_id,
	los_fctr_id,
	age_fctr_id,
	cmbnd_min_val,
	cmbnd_max_val,
	ordr_num,
	cla_attribute_category,
	cla_attribute1,
	cla_attribute2,
	cla_attribute3,
	cla_attribute4,
	cla_attribute5,
	cla_attribute6,
	cla_attribute7,
	cla_attribute8,
	cla_attribute9,
	cla_attribute10,
	cla_attribute11,
	cla_attribute12,
	cla_attribute13,
	cla_attribute14,
	cla_attribute15,
	cla_attribute16,
	cla_attribute17,
	cla_attribute18,
	cla_attribute19,
	cla_attribute20,
	cla_attribute21,
	cla_attribute22,
	cla_attribute23,
	cla_attribute24,
	cla_attribute25,
	cla_attribute26,
	cla_attribute27,
	cla_attribute28,
	cla_attribute29,
	cla_attribute30,
	object_version_number ,
	name
  )
  Values
  (	p_rec.cmbn_age_los_fctr_id,
	p_rec.business_group_id,
	p_rec.los_fctr_id,
	p_rec.age_fctr_id,
	p_rec.cmbnd_min_val,
	p_rec.cmbnd_max_val,
	p_rec.ordr_num,
	p_rec.cla_attribute_category,
	p_rec.cla_attribute1,
	p_rec.cla_attribute2,
	p_rec.cla_attribute3,
	p_rec.cla_attribute4,
	p_rec.cla_attribute5,
	p_rec.cla_attribute6,
	p_rec.cla_attribute7,
	p_rec.cla_attribute8,
	p_rec.cla_attribute9,
	p_rec.cla_attribute10,
	p_rec.cla_attribute11,
	p_rec.cla_attribute12,
	p_rec.cla_attribute13,
	p_rec.cla_attribute14,
	p_rec.cla_attribute15,
	p_rec.cla_attribute16,
	p_rec.cla_attribute17,
	p_rec.cla_attribute18,
	p_rec.cla_attribute19,
	p_rec.cla_attribute20,
	p_rec.cla_attribute21,
	p_rec.cla_attribute22,
	p_rec.cla_attribute23,
	p_rec.cla_attribute24,
	p_rec.cla_attribute25,
	p_rec.cla_attribute26,
	p_rec.cla_attribute27,
	p_rec.cla_attribute28,
	p_rec.cla_attribute29,
	p_rec.cla_attribute30,
	p_rec.object_version_number ,
	p_rec.name
  );
  --
  ben_cla_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cla_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cla_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cla_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cla_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cla_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_cla_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_cmbn_age_los_fctr_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cmbn_age_los_fctr_id;
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
Procedure post_insert(p_rec in ben_cla_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_cla_rki.after_insert
      (
  p_cmbn_age_los_fctr_id          =>p_rec.cmbn_age_los_fctr_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_los_fctr_id                   =>p_rec.los_fctr_id
 ,p_age_fctr_id                   =>p_rec.age_fctr_id
 ,p_cmbnd_min_val                 =>p_rec.cmbnd_min_val
 ,p_cmbnd_max_val                 =>p_rec.cmbnd_max_val
 ,p_ordr_num                      =>p_rec.ordr_num
 ,p_cla_attribute_category        =>p_rec.cla_attribute_category
 ,p_cla_attribute1                =>p_rec.cla_attribute1
 ,p_cla_attribute2                =>p_rec.cla_attribute2
 ,p_cla_attribute3                =>p_rec.cla_attribute3
 ,p_cla_attribute4                =>p_rec.cla_attribute4
 ,p_cla_attribute5                =>p_rec.cla_attribute5
 ,p_cla_attribute6                =>p_rec.cla_attribute6
 ,p_cla_attribute7                =>p_rec.cla_attribute7
 ,p_cla_attribute8                =>p_rec.cla_attribute8
 ,p_cla_attribute9                =>p_rec.cla_attribute9
 ,p_cla_attribute10               =>p_rec.cla_attribute10
 ,p_cla_attribute11               =>p_rec.cla_attribute11
 ,p_cla_attribute12               =>p_rec.cla_attribute12
 ,p_cla_attribute13               =>p_rec.cla_attribute13
 ,p_cla_attribute14               =>p_rec.cla_attribute14
 ,p_cla_attribute15               =>p_rec.cla_attribute15
 ,p_cla_attribute16               =>p_rec.cla_attribute16
 ,p_cla_attribute17               =>p_rec.cla_attribute17
 ,p_cla_attribute18               =>p_rec.cla_attribute18
 ,p_cla_attribute19               =>p_rec.cla_attribute19
 ,p_cla_attribute20               =>p_rec.cla_attribute20
 ,p_cla_attribute21               =>p_rec.cla_attribute21
 ,p_cla_attribute22               =>p_rec.cla_attribute22
 ,p_cla_attribute23               =>p_rec.cla_attribute23
 ,p_cla_attribute24               =>p_rec.cla_attribute24
 ,p_cla_attribute25               =>p_rec.cla_attribute25
 ,p_cla_attribute26               =>p_rec.cla_attribute26
 ,p_cla_attribute27               =>p_rec.cla_attribute27
 ,p_cla_attribute28               =>p_rec.cla_attribute28
 ,p_cla_attribute29               =>p_rec.cla_attribute29
 ,p_cla_attribute30               =>p_rec.cla_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_name                          =>p_rec.name
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_cmbn_age_los_fctr'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ben_cla_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cla_bus.insert_validate(p_rec);
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
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_cmbn_age_los_fctr_id         out nocopy number,
  p_business_group_id            in number,
  p_los_fctr_id                  in number,
  p_age_fctr_id                  in number,
  p_cmbnd_min_val                in number           default null,
  p_cmbnd_max_val                in number           default null,
  p_ordr_num                     in number           default null,
  p_cla_attribute_category       in varchar2         default null,
  p_cla_attribute1               in varchar2         default null,
  p_cla_attribute2               in varchar2         default null,
  p_cla_attribute3               in varchar2         default null,
  p_cla_attribute4               in varchar2         default null,
  p_cla_attribute5               in varchar2         default null,
  p_cla_attribute6               in varchar2         default null,
  p_cla_attribute7               in varchar2         default null,
  p_cla_attribute8               in varchar2         default null,
  p_cla_attribute9               in varchar2         default null,
  p_cla_attribute10              in varchar2         default null,
  p_cla_attribute11              in varchar2         default null,
  p_cla_attribute12              in varchar2         default null,
  p_cla_attribute13              in varchar2         default null,
  p_cla_attribute14              in varchar2         default null,
  p_cla_attribute15              in varchar2         default null,
  p_cla_attribute16              in varchar2         default null,
  p_cla_attribute17              in varchar2         default null,
  p_cla_attribute18              in varchar2         default null,
  p_cla_attribute19              in varchar2         default null,
  p_cla_attribute20              in varchar2         default null,
  p_cla_attribute21              in varchar2         default null,
  p_cla_attribute22              in varchar2         default null,
  p_cla_attribute23              in varchar2         default null,
  p_cla_attribute24              in varchar2         default null,
  p_cla_attribute25              in varchar2         default null,
  p_cla_attribute26              in varchar2         default null,
  p_cla_attribute27              in varchar2         default null,
  p_cla_attribute28              in varchar2         default null,
  p_cla_attribute29              in varchar2         default null,
  p_cla_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number ,
  p_name                         in varchar2
  ) is
--
  l_rec	  ben_cla_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cla_shd.convert_args
  (
  null,
  p_business_group_id,
  p_los_fctr_id,
  p_age_fctr_id,
  p_cmbnd_min_val,
  p_cmbnd_max_val,
  p_ordr_num,
  p_cla_attribute_category,
  p_cla_attribute1,
  p_cla_attribute2,
  p_cla_attribute3,
  p_cla_attribute4,
  p_cla_attribute5,
  p_cla_attribute6,
  p_cla_attribute7,
  p_cla_attribute8,
  p_cla_attribute9,
  p_cla_attribute10,
  p_cla_attribute11,
  p_cla_attribute12,
  p_cla_attribute13,
  p_cla_attribute14,
  p_cla_attribute15,
  p_cla_attribute16,
  p_cla_attribute17,
  p_cla_attribute18,
  p_cla_attribute19,
  p_cla_attribute20,
  p_cla_attribute21,
  p_cla_attribute22,
  p_cla_attribute23,
  p_cla_attribute24,
  p_cla_attribute25,
  p_cla_attribute26,
  p_cla_attribute27,
  p_cla_attribute28,
  p_cla_attribute29,
  p_cla_attribute30,
  null ,
  p_name
  );
  --
  -- Having converted the arguments into the ben_cla_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cmbn_age_los_fctr_id := l_rec.cmbn_age_los_fctr_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cla_ins;

/
