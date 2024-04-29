--------------------------------------------------------
--  DDL for Package Body BEN_AGF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGF_INS" as
/* $Header: beagfrhi.pkb 120.0 2005/05/28 00:23:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_agf_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_agf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_agf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_age_fctr
  --
  insert into ben_age_fctr
  (	age_fctr_id,
	name,
	mx_age_num,
	mn_age_num,
	age_uom,
	no_mn_age_flag,
	no_mx_age_flag,
        age_to_use_cd,
	age_det_cd,
	age_det_rl,
	rndg_cd,
	rndg_rl,
	age_calc_rl,
	business_group_id,
	agf_attribute_category,
	agf_attribute1,
	agf_attribute2,
	agf_attribute3,
	agf_attribute4,
	agf_attribute5,
	agf_attribute6,
	agf_attribute7,
	agf_attribute8,
	agf_attribute9,
	agf_attribute10,
	agf_attribute11,
	agf_attribute12,
	agf_attribute13,
	agf_attribute14,
	agf_attribute15,
	agf_attribute16,
	agf_attribute17,
	agf_attribute18,
	agf_attribute19,
	agf_attribute20,
	agf_attribute21,
	agf_attribute22,
	agf_attribute23,
	agf_attribute24,
	agf_attribute25,
	agf_attribute26,
	agf_attribute27,
	agf_attribute28,
	agf_attribute29,
	agf_attribute30,
	object_version_number
  )
  Values
  (	p_rec.age_fctr_id,
	p_rec.name,
	p_rec.mx_age_num,
	p_rec.mn_age_num,
	p_rec.age_uom,
	p_rec.no_mn_age_flag,
	p_rec.no_mx_age_flag,
        p_rec.age_to_use_cd,
	p_rec.age_det_cd,
	p_rec.age_det_rl,
	p_rec.rndg_cd,
	p_rec.rndg_rl,
	p_rec.age_calc_rl,
	p_rec.business_group_id,
	p_rec.agf_attribute_category,
	p_rec.agf_attribute1,
	p_rec.agf_attribute2,
	p_rec.agf_attribute3,
	p_rec.agf_attribute4,
	p_rec.agf_attribute5,
	p_rec.agf_attribute6,
	p_rec.agf_attribute7,
	p_rec.agf_attribute8,
	p_rec.agf_attribute9,
	p_rec.agf_attribute10,
	p_rec.agf_attribute11,
	p_rec.agf_attribute12,
	p_rec.agf_attribute13,
	p_rec.agf_attribute14,
	p_rec.agf_attribute15,
	p_rec.agf_attribute16,
	p_rec.agf_attribute17,
	p_rec.agf_attribute18,
	p_rec.agf_attribute19,
	p_rec.agf_attribute20,
	p_rec.agf_attribute21,
	p_rec.agf_attribute22,
	p_rec.agf_attribute23,
	p_rec.agf_attribute24,
	p_rec.agf_attribute25,
	p_rec.agf_attribute26,
	p_rec.agf_attribute27,
	p_rec.agf_attribute28,
	p_rec.agf_attribute29,
	p_rec.agf_attribute30,
	p_rec.object_version_number
  );
  --
  ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_agf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_agf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_agf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_age_fctr_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.age_fctr_id;
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
Procedure post_insert(
p_effective_date in date,p_rec in ben_agf_shd.g_rec_type) is
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
    ben_agf_rki.after_insert
      (
  p_age_fctr_id                   =>p_rec.age_fctr_id
 ,p_name                          =>p_rec.name
 ,p_mx_age_num                    =>p_rec.mx_age_num
 ,p_mn_age_num                    =>p_rec.mn_age_num
 ,p_age_uom                       =>p_rec.age_uom
 ,p_no_mn_age_flag                =>p_rec.no_mn_age_flag
 ,p_no_mx_age_flag                =>p_rec.no_mx_age_flag
 ,p_age_to_use_cd                 =>p_rec.age_to_use_cd
 ,p_age_det_cd                    =>p_rec.age_det_cd
 ,p_age_det_rl                    =>p_rec.age_det_rl
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_age_calc_rl                   =>p_rec.age_calc_rl
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_agf_attribute_category        =>p_rec.agf_attribute_category
 ,p_agf_attribute1                =>p_rec.agf_attribute1
 ,p_agf_attribute2                =>p_rec.agf_attribute2
 ,p_agf_attribute3                =>p_rec.agf_attribute3
 ,p_agf_attribute4                =>p_rec.agf_attribute4
 ,p_agf_attribute5                =>p_rec.agf_attribute5
 ,p_agf_attribute6                =>p_rec.agf_attribute6
 ,p_agf_attribute7                =>p_rec.agf_attribute7
 ,p_agf_attribute8                =>p_rec.agf_attribute8
 ,p_agf_attribute9                =>p_rec.agf_attribute9
 ,p_agf_attribute10               =>p_rec.agf_attribute10
 ,p_agf_attribute11               =>p_rec.agf_attribute11
 ,p_agf_attribute12               =>p_rec.agf_attribute12
 ,p_agf_attribute13               =>p_rec.agf_attribute13
 ,p_agf_attribute14               =>p_rec.agf_attribute14
 ,p_agf_attribute15               =>p_rec.agf_attribute15
 ,p_agf_attribute16               =>p_rec.agf_attribute16
 ,p_agf_attribute17               =>p_rec.agf_attribute17
 ,p_agf_attribute18               =>p_rec.agf_attribute18
 ,p_agf_attribute19               =>p_rec.agf_attribute19
 ,p_agf_attribute20               =>p_rec.agf_attribute20
 ,p_agf_attribute21               =>p_rec.agf_attribute21
 ,p_agf_attribute22               =>p_rec.agf_attribute22
 ,p_agf_attribute23               =>p_rec.agf_attribute23
 ,p_agf_attribute24               =>p_rec.agf_attribute24
 ,p_agf_attribute25               =>p_rec.agf_attribute25
 ,p_agf_attribute26               =>p_rec.agf_attribute26
 ,p_agf_attribute27               =>p_rec.agf_attribute27
 ,p_agf_attribute28               =>p_rec.agf_attribute28
 ,p_agf_attribute29               =>p_rec.agf_attribute29
 ,p_agf_attribute30               =>p_rec.agf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_age_fctr'
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
  p_effective_date in date,
  p_rec        in out nocopy ben_agf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_agf_bus.insert_validate(p_rec
  ,p_effective_date);
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
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_age_fctr_id                  out nocopy number,
  p_name                         in varchar2,
  p_mx_age_num                   in number           default null,
  p_mn_age_num                   in number           default null,
  p_age_uom                      in varchar2         default null,
  p_no_mn_age_flag               in varchar2,
  p_no_mx_age_flag               in varchar2,
  p_age_to_use_cd                in varchar2         default null,
  p_age_det_cd                   in varchar2         default null,
  p_age_det_rl                   in number           default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_age_calc_rl                  in number           default null,
  p_business_group_id            in number           default null,
  p_agf_attribute_category       in varchar2         default null,
  p_agf_attribute1               in varchar2         default null,
  p_agf_attribute2               in varchar2         default null,
  p_agf_attribute3               in varchar2         default null,
  p_agf_attribute4               in varchar2         default null,
  p_agf_attribute5               in varchar2         default null,
  p_agf_attribute6               in varchar2         default null,
  p_agf_attribute7               in varchar2         default null,
  p_agf_attribute8               in varchar2         default null,
  p_agf_attribute9               in varchar2         default null,
  p_agf_attribute10              in varchar2         default null,
  p_agf_attribute11              in varchar2         default null,
  p_agf_attribute12              in varchar2         default null,
  p_agf_attribute13              in varchar2         default null,
  p_agf_attribute14              in varchar2         default null,
  p_agf_attribute15              in varchar2         default null,
  p_agf_attribute16              in varchar2         default null,
  p_agf_attribute17              in varchar2         default null,
  p_agf_attribute18              in varchar2         default null,
  p_agf_attribute19              in varchar2         default null,
  p_agf_attribute20              in varchar2         default null,
  p_agf_attribute21              in varchar2         default null,
  p_agf_attribute22              in varchar2         default null,
  p_agf_attribute23              in varchar2         default null,
  p_agf_attribute24              in varchar2         default null,
  p_agf_attribute25              in varchar2         default null,
  p_agf_attribute26              in varchar2         default null,
  p_agf_attribute27              in varchar2         default null,
  p_agf_attribute28              in varchar2         default null,
  p_agf_attribute29              in varchar2         default null,
  p_agf_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_agf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_agf_shd.convert_args
  (
  null,
  p_name,
  p_mx_age_num,
  p_mn_age_num,
  p_age_uom,
  p_no_mn_age_flag,
  p_no_mx_age_flag,
  p_age_to_use_cd,
  p_age_det_cd,
  p_age_det_rl,
  p_rndg_cd,
  p_rndg_rl,
  p_age_calc_rl,
  p_business_group_id,
  p_agf_attribute_category,
  p_agf_attribute1,
  p_agf_attribute2,
  p_agf_attribute3,
  p_agf_attribute4,
  p_agf_attribute5,
  p_agf_attribute6,
  p_agf_attribute7,
  p_agf_attribute8,
  p_agf_attribute9,
  p_agf_attribute10,
  p_agf_attribute11,
  p_agf_attribute12,
  p_agf_attribute13,
  p_agf_attribute14,
  p_agf_attribute15,
  p_agf_attribute16,
  p_agf_attribute17,
  p_agf_attribute18,
  p_agf_attribute19,
  p_agf_attribute20,
  p_agf_attribute21,
  p_agf_attribute22,
  p_agf_attribute23,
  p_agf_attribute24,
  p_agf_attribute25,
  p_agf_attribute26,
  p_agf_attribute27,
  p_agf_attribute28,
  p_agf_attribute29,
  p_agf_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_agf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_age_fctr_id := l_rec.age_fctr_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_agf_ins;

/
