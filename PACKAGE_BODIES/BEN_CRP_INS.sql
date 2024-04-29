--------------------------------------------------------
--  DDL for Package Body BEN_CRP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRP_INS" as
/* $Header: becrprhi.pkb 115.4 2002/12/16 11:04:00 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crp_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_crp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_crp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_cbr_per_in_ler
  --
  insert into ben_cbr_per_in_ler
  (	cbr_per_in_ler_id,
	init_evt_flag,
	cnt_num,
	per_in_ler_id,
	cbr_quald_bnf_id,
	prvs_elig_perd_end_dt,
	business_group_id,
	crp_attribute_category,
	crp_attribute1,
	crp_attribute2,
	crp_attribute3,
	crp_attribute4,
	crp_attribute5,
	crp_attribute6,
	crp_attribute7,
	crp_attribute8,
	crp_attribute9,
	crp_attribute10,
	crp_attribute11,
	crp_attribute12,
	crp_attribute13,
	crp_attribute14,
	crp_attribute15,
	crp_attribute16,
	crp_attribute17,
	crp_attribute18,
	crp_attribute19,
	crp_attribute20,
	crp_attribute21,
	crp_attribute22,
	crp_attribute23,
	crp_attribute24,
	crp_attribute25,
	crp_attribute26,
	crp_attribute27,
	crp_attribute28,
	crp_attribute29,
	crp_attribute30,
	object_version_number
  )
  Values
  (	p_rec.cbr_per_in_ler_id,
	p_rec.init_evt_flag,
	p_rec.cnt_num,
	p_rec.per_in_ler_id,
	p_rec.cbr_quald_bnf_id,
	p_rec.prvs_elig_perd_end_dt,
	p_rec.business_group_id,
	p_rec.crp_attribute_category,
	p_rec.crp_attribute1,
	p_rec.crp_attribute2,
	p_rec.crp_attribute3,
	p_rec.crp_attribute4,
	p_rec.crp_attribute5,
	p_rec.crp_attribute6,
	p_rec.crp_attribute7,
	p_rec.crp_attribute8,
	p_rec.crp_attribute9,
	p_rec.crp_attribute10,
	p_rec.crp_attribute11,
	p_rec.crp_attribute12,
	p_rec.crp_attribute13,
	p_rec.crp_attribute14,
	p_rec.crp_attribute15,
	p_rec.crp_attribute16,
	p_rec.crp_attribute17,
	p_rec.crp_attribute18,
	p_rec.crp_attribute19,
	p_rec.crp_attribute20,
	p_rec.crp_attribute21,
	p_rec.crp_attribute22,
	p_rec.crp_attribute23,
	p_rec.crp_attribute24,
	p_rec.crp_attribute25,
	p_rec.crp_attribute26,
	p_rec.crp_attribute27,
	p_rec.crp_attribute28,
	p_rec.crp_attribute29,
	p_rec.crp_attribute30,
	p_rec.object_version_number
  );
  --
  ben_crp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_crp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_crp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_crp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_crp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_crp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_cbr_per_in_ler_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cbr_per_in_ler_id;
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
p_effective_date in date,p_rec in ben_crp_shd.g_rec_type) is
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
    ben_crp_rki.after_insert
      (
  p_cbr_per_in_ler_id             =>p_rec.cbr_per_in_ler_id
 ,p_init_evt_flag                 =>p_rec.init_evt_flag
 ,p_cnt_num                       =>p_rec.cnt_num
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_cbr_quald_bnf_id              =>p_rec.cbr_quald_bnf_id
 ,p_prvs_elig_perd_end_dt         =>p_rec.prvs_elig_perd_end_dt
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_crp_attribute_category        =>p_rec.crp_attribute_category
 ,p_crp_attribute1                =>p_rec.crp_attribute1
 ,p_crp_attribute2                =>p_rec.crp_attribute2
 ,p_crp_attribute3                =>p_rec.crp_attribute3
 ,p_crp_attribute4                =>p_rec.crp_attribute4
 ,p_crp_attribute5                =>p_rec.crp_attribute5
 ,p_crp_attribute6                =>p_rec.crp_attribute6
 ,p_crp_attribute7                =>p_rec.crp_attribute7
 ,p_crp_attribute8                =>p_rec.crp_attribute8
 ,p_crp_attribute9                =>p_rec.crp_attribute9
 ,p_crp_attribute10               =>p_rec.crp_attribute10
 ,p_crp_attribute11               =>p_rec.crp_attribute11
 ,p_crp_attribute12               =>p_rec.crp_attribute12
 ,p_crp_attribute13               =>p_rec.crp_attribute13
 ,p_crp_attribute14               =>p_rec.crp_attribute14
 ,p_crp_attribute15               =>p_rec.crp_attribute15
 ,p_crp_attribute16               =>p_rec.crp_attribute16
 ,p_crp_attribute17               =>p_rec.crp_attribute17
 ,p_crp_attribute18               =>p_rec.crp_attribute18
 ,p_crp_attribute19               =>p_rec.crp_attribute19
 ,p_crp_attribute20               =>p_rec.crp_attribute20
 ,p_crp_attribute21               =>p_rec.crp_attribute21
 ,p_crp_attribute22               =>p_rec.crp_attribute22
 ,p_crp_attribute23               =>p_rec.crp_attribute23
 ,p_crp_attribute24               =>p_rec.crp_attribute24
 ,p_crp_attribute25               =>p_rec.crp_attribute25
 ,p_crp_attribute26               =>p_rec.crp_attribute26
 ,p_crp_attribute27               =>p_rec.crp_attribute27
 ,p_crp_attribute28               =>p_rec.crp_attribute28
 ,p_crp_attribute29               =>p_rec.crp_attribute29
 ,p_crp_attribute30               =>p_rec.crp_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_cbr_per_in_ler'
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
  p_rec        in out nocopy ben_crp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_crp_bus.insert_validate(p_rec
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
  p_cbr_per_in_ler_id            out nocopy number,
  p_init_evt_flag                in varchar2,
  p_cnt_num                      in number           default null,
  p_per_in_ler_id                in number,
  p_cbr_quald_bnf_id             in number,
  p_prvs_elig_perd_end_dt        in date             default null,
  p_business_group_id            in number,
  p_crp_attribute_category       in varchar2         default null,
  p_crp_attribute1               in varchar2         default null,
  p_crp_attribute2               in varchar2         default null,
  p_crp_attribute3               in varchar2         default null,
  p_crp_attribute4               in varchar2         default null,
  p_crp_attribute5               in varchar2         default null,
  p_crp_attribute6               in varchar2         default null,
  p_crp_attribute7               in varchar2         default null,
  p_crp_attribute8               in varchar2         default null,
  p_crp_attribute9               in varchar2         default null,
  p_crp_attribute10              in varchar2         default null,
  p_crp_attribute11              in varchar2         default null,
  p_crp_attribute12              in varchar2         default null,
  p_crp_attribute13              in varchar2         default null,
  p_crp_attribute14              in varchar2         default null,
  p_crp_attribute15              in varchar2         default null,
  p_crp_attribute16              in varchar2         default null,
  p_crp_attribute17              in varchar2         default null,
  p_crp_attribute18              in varchar2         default null,
  p_crp_attribute19              in varchar2         default null,
  p_crp_attribute20              in varchar2         default null,
  p_crp_attribute21              in varchar2         default null,
  p_crp_attribute22              in varchar2         default null,
  p_crp_attribute23              in varchar2         default null,
  p_crp_attribute24              in varchar2         default null,
  p_crp_attribute25              in varchar2         default null,
  p_crp_attribute26              in varchar2         default null,
  p_crp_attribute27              in varchar2         default null,
  p_crp_attribute28              in varchar2         default null,
  p_crp_attribute29              in varchar2         default null,
  p_crp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_crp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_crp_shd.convert_args
  (
  null,
  p_init_evt_flag,
  p_cnt_num,
  p_per_in_ler_id,
  p_cbr_quald_bnf_id,
  p_prvs_elig_perd_end_dt,
  p_business_group_id,
  p_crp_attribute_category,
  p_crp_attribute1,
  p_crp_attribute2,
  p_crp_attribute3,
  p_crp_attribute4,
  p_crp_attribute5,
  p_crp_attribute6,
  p_crp_attribute7,
  p_crp_attribute8,
  p_crp_attribute9,
  p_crp_attribute10,
  p_crp_attribute11,
  p_crp_attribute12,
  p_crp_attribute13,
  p_crp_attribute14,
  p_crp_attribute15,
  p_crp_attribute16,
  p_crp_attribute17,
  p_crp_attribute18,
  p_crp_attribute19,
  p_crp_attribute20,
  p_crp_attribute21,
  p_crp_attribute22,
  p_crp_attribute23,
  p_crp_attribute24,
  p_crp_attribute25,
  p_crp_attribute26,
  p_crp_attribute27,
  p_crp_attribute28,
  p_crp_attribute29,
  p_crp_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_crp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cbr_per_in_ler_id := l_rec.cbr_per_in_ler_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_crp_ins;

/
