--------------------------------------------------------
--  DDL for Package Body BEN_LSF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LSF_INS" as
/* $Header: belsfrhi.pkb 120.0 2005/05/28 03:37:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_lsf_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_lsf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_lsf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_los_fctr
  --
  insert into ben_los_fctr
  (	los_fctr_id,
	name,
	business_group_id,
	los_det_cd,
	los_det_rl,
	mn_los_num,
	mx_los_num,
	no_mx_los_num_apls_flag,
	no_mn_los_num_apls_flag,
	rndg_cd,
	rndg_rl,
	los_dt_to_use_cd,
	los_dt_to_use_rl,
	los_uom,
        los_calc_rl,
        los_alt_val_to_use_cd,
	lsf_attribute_category,
	lsf_attribute1,
	lsf_attribute2,
	lsf_attribute3,
	lsf_attribute4,
	lsf_attribute5,
	lsf_attribute6,
	lsf_attribute7,
	lsf_attribute8,
	lsf_attribute9,
	lsf_attribute10,
	lsf_attribute11,
	lsf_attribute12,
	lsf_attribute13,
	lsf_attribute14,
	lsf_attribute15,
	lsf_attribute16,
	lsf_attribute17,
	lsf_attribute18,
	lsf_attribute19,
	lsf_attribute20,
	lsf_attribute21,
	lsf_attribute22,
	lsf_attribute23,
	lsf_attribute24,
	lsf_attribute25,
	lsf_attribute26,
	lsf_attribute27,
	lsf_attribute28,
	lsf_attribute29,
	lsf_attribute30,
	object_version_number,
	use_overid_svc_dt_flag
  )
  Values
  (	p_rec.los_fctr_id,
	p_rec.name,
	p_rec.business_group_id,
	p_rec.los_det_cd,
	p_rec.los_det_rl,
	p_rec.mn_los_num,
	p_rec.mx_los_num,
	p_rec.no_mx_los_num_apls_flag,
	p_rec.no_mn_los_num_apls_flag,
	p_rec.rndg_cd,
	p_rec.rndg_rl,
	p_rec.los_dt_to_use_cd,
	p_rec.los_dt_to_use_rl,
	p_rec.los_uom,
        p_rec.los_calc_rl,
        p_rec.los_alt_val_to_use_cd,
	p_rec.lsf_attribute_category,
	p_rec.lsf_attribute1,
	p_rec.lsf_attribute2,
	p_rec.lsf_attribute3,
	p_rec.lsf_attribute4,
	p_rec.lsf_attribute5,
	p_rec.lsf_attribute6,
	p_rec.lsf_attribute7,
	p_rec.lsf_attribute8,
	p_rec.lsf_attribute9,
	p_rec.lsf_attribute10,
	p_rec.lsf_attribute11,
	p_rec.lsf_attribute12,
	p_rec.lsf_attribute13,
	p_rec.lsf_attribute14,
	p_rec.lsf_attribute15,
	p_rec.lsf_attribute16,
	p_rec.lsf_attribute17,
	p_rec.lsf_attribute18,
	p_rec.lsf_attribute19,
	p_rec.lsf_attribute20,
	p_rec.lsf_attribute21,
	p_rec.lsf_attribute22,
	p_rec.lsf_attribute23,
	p_rec.lsf_attribute24,
	p_rec.lsf_attribute25,
	p_rec.lsf_attribute26,
	p_rec.lsf_attribute27,
	p_rec.lsf_attribute28,
	p_rec.lsf_attribute29,
	p_rec.lsf_attribute30,
	p_rec.object_version_number,
	p_rec.use_overid_svc_dt_flag
  );
  --
  ben_lsf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_lsf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_lsf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_lsf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_lsf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_lsf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_lsf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_lsf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_lsf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_los_fctr_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.los_fctr_id;
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
p_effective_date in date,p_rec in ben_lsf_shd.g_rec_type) is
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
    ben_lsf_rki.after_insert
      (
  p_los_fctr_id                   =>p_rec.los_fctr_id
 ,p_name                          =>p_rec.name
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_los_det_cd                    =>p_rec.los_det_cd
 ,p_los_det_rl                    =>p_rec.los_det_rl
 ,p_mn_los_num                    =>p_rec.mn_los_num
 ,p_mx_los_num                    =>p_rec.mx_los_num
 ,p_no_mx_los_num_apls_flag       =>p_rec.no_mx_los_num_apls_flag
 ,p_no_mn_los_num_apls_flag       =>p_rec.no_mn_los_num_apls_flag
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_los_dt_to_use_cd              =>p_rec.los_dt_to_use_cd
 ,p_los_dt_to_use_rl              =>p_rec.los_dt_to_use_rl
 ,p_los_uom                       =>p_rec.los_uom
 ,p_los_calc_rl                   =>p_rec.los_calc_rl
 ,p_los_alt_val_to_use_cd         =>p_rec.los_alt_val_to_use_cd
 ,p_lsf_attribute_category        =>p_rec.lsf_attribute_category
 ,p_lsf_attribute1                =>p_rec.lsf_attribute1
 ,p_lsf_attribute2                =>p_rec.lsf_attribute2
 ,p_lsf_attribute3                =>p_rec.lsf_attribute3
 ,p_lsf_attribute4                =>p_rec.lsf_attribute4
 ,p_lsf_attribute5                =>p_rec.lsf_attribute5
 ,p_lsf_attribute6                =>p_rec.lsf_attribute6
 ,p_lsf_attribute7                =>p_rec.lsf_attribute7
 ,p_lsf_attribute8                =>p_rec.lsf_attribute8
 ,p_lsf_attribute9                =>p_rec.lsf_attribute9
 ,p_lsf_attribute10               =>p_rec.lsf_attribute10
 ,p_lsf_attribute11               =>p_rec.lsf_attribute11
 ,p_lsf_attribute12               =>p_rec.lsf_attribute12
 ,p_lsf_attribute13               =>p_rec.lsf_attribute13
 ,p_lsf_attribute14               =>p_rec.lsf_attribute14
 ,p_lsf_attribute15               =>p_rec.lsf_attribute15
 ,p_lsf_attribute16               =>p_rec.lsf_attribute16
 ,p_lsf_attribute17               =>p_rec.lsf_attribute17
 ,p_lsf_attribute18               =>p_rec.lsf_attribute18
 ,p_lsf_attribute19               =>p_rec.lsf_attribute19
 ,p_lsf_attribute20               =>p_rec.lsf_attribute20
 ,p_lsf_attribute21               =>p_rec.lsf_attribute21
 ,p_lsf_attribute22               =>p_rec.lsf_attribute22
 ,p_lsf_attribute23               =>p_rec.lsf_attribute23
 ,p_lsf_attribute24               =>p_rec.lsf_attribute24
 ,p_lsf_attribute25               =>p_rec.lsf_attribute25
 ,p_lsf_attribute26               =>p_rec.lsf_attribute26
 ,p_lsf_attribute27               =>p_rec.lsf_attribute27
 ,p_lsf_attribute28               =>p_rec.lsf_attribute28
 ,p_lsf_attribute29               =>p_rec.lsf_attribute29
 ,p_lsf_attribute30               =>p_rec.lsf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_use_overid_svc_dt_flag        =>p_rec.use_overid_svc_dt_flag
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_los_fctr'
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
  p_rec        in out nocopy ben_lsf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_lsf_bus.insert_validate(p_rec
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
  p_los_fctr_id                  out nocopy number,
  p_name                         in varchar2,
  p_business_group_id            in number,
  p_los_det_cd                   in varchar2         default null,
  p_los_det_rl                   in number           default null,
  p_mn_los_num                   in number           default null,
  p_mx_los_num                   in number           default null,
  p_no_mx_los_num_apls_flag      in varchar2         default null,
  p_no_mn_los_num_apls_flag      in varchar2         default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_los_dt_to_use_cd             in varchar2         default null,
  p_los_dt_to_use_rl             in number           default null,
  p_los_uom                      in varchar2         default null,
  p_los_calc_rl                  in number           default null,
  p_los_alt_val_to_use_cd        in varchar2         default null,
  p_lsf_attribute_category       in varchar2         default null,
  p_lsf_attribute1               in varchar2         default null,
  p_lsf_attribute2               in varchar2         default null,
  p_lsf_attribute3               in varchar2         default null,
  p_lsf_attribute4               in varchar2         default null,
  p_lsf_attribute5               in varchar2         default null,
  p_lsf_attribute6               in varchar2         default null,
  p_lsf_attribute7               in varchar2         default null,
  p_lsf_attribute8               in varchar2         default null,
  p_lsf_attribute9               in varchar2         default null,
  p_lsf_attribute10              in varchar2         default null,
  p_lsf_attribute11              in varchar2         default null,
  p_lsf_attribute12              in varchar2         default null,
  p_lsf_attribute13              in varchar2         default null,
  p_lsf_attribute14              in varchar2         default null,
  p_lsf_attribute15              in varchar2         default null,
  p_lsf_attribute16              in varchar2         default null,
  p_lsf_attribute17              in varchar2         default null,
  p_lsf_attribute18              in varchar2         default null,
  p_lsf_attribute19              in varchar2         default null,
  p_lsf_attribute20              in varchar2         default null,
  p_lsf_attribute21              in varchar2         default null,
  p_lsf_attribute22              in varchar2         default null,
  p_lsf_attribute23              in varchar2         default null,
  p_lsf_attribute24              in varchar2         default null,
  p_lsf_attribute25              in varchar2         default null,
  p_lsf_attribute26              in varchar2         default null,
  p_lsf_attribute27              in varchar2         default null,
  p_lsf_attribute28              in varchar2         default null,
  p_lsf_attribute29              in varchar2         default null,
  p_lsf_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_use_overid_svc_dt_flag       in varchar2         default null
  ) is
--
  l_rec	  ben_lsf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_lsf_shd.convert_args
  (
  null,
  p_name,
  p_business_group_id,
  p_los_det_cd,
  p_los_det_rl,
  p_mn_los_num,
  p_mx_los_num,
  p_no_mx_los_num_apls_flag,
  p_no_mn_los_num_apls_flag,
  p_rndg_cd,
  p_rndg_rl,
  p_los_dt_to_use_cd,
  p_los_dt_to_use_rl,
  p_los_uom,
  p_los_calc_rl,
  p_los_alt_val_to_use_cd,
  p_lsf_attribute_category,
  p_lsf_attribute1,
  p_lsf_attribute2,
  p_lsf_attribute3,
  p_lsf_attribute4,
  p_lsf_attribute5,
  p_lsf_attribute6,
  p_lsf_attribute7,
  p_lsf_attribute8,
  p_lsf_attribute9,
  p_lsf_attribute10,
  p_lsf_attribute11,
  p_lsf_attribute12,
  p_lsf_attribute13,
  p_lsf_attribute14,
  p_lsf_attribute15,
  p_lsf_attribute16,
  p_lsf_attribute17,
  p_lsf_attribute18,
  p_lsf_attribute19,
  p_lsf_attribute20,
  p_lsf_attribute21,
  p_lsf_attribute22,
  p_lsf_attribute23,
  p_lsf_attribute24,
  p_lsf_attribute25,
  p_lsf_attribute26,
  p_lsf_attribute27,
  p_lsf_attribute28,
  p_lsf_attribute29,
  p_lsf_attribute30,
  null,
  p_use_overid_svc_dt_flag
  );
  --
  -- Having converted the arguments into the ben_lsf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_los_fctr_id := l_rec.los_fctr_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_lsf_ins;

/
