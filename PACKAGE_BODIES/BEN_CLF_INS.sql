--------------------------------------------------------
--  DDL for Package Body BEN_CLF_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLF_INS" as
/* $Header: beclfrhi.pkb 120.0 2005/05/28 01:04:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clf_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_clf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_clf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_comp_lvl_fctr
  --
  insert into ben_comp_lvl_fctr
  (	comp_lvl_fctr_id,
	business_group_id,
	name,
        comp_lvl_det_cd,
        comp_lvl_det_rl,
	comp_lvl_uom,
	comp_src_cd,
	defined_balance_id,
	no_mn_comp_flag,
	no_mx_comp_flag,
	mx_comp_val,
	mn_comp_val,
	rndg_cd,
	rndg_rl,
        bnfts_bal_id,
        comp_alt_val_to_use_cd,
        comp_calc_rl,
  proration_flag,
  start_day_mo,
  end_day_mo,
  start_year,
  end_year,
	clf_attribute_category,
	clf_attribute1,
	clf_attribute2,
	clf_attribute3,
	clf_attribute4,
	clf_attribute5,
	clf_attribute6,
	clf_attribute7,
	clf_attribute8,
	clf_attribute9,
	clf_attribute10,
	clf_attribute11,
	clf_attribute12,
	clf_attribute13,
	clf_attribute14,
	clf_attribute15,
	clf_attribute16,
	clf_attribute17,
	clf_attribute18,
	clf_attribute19,
	clf_attribute20,
	clf_attribute21,
	clf_attribute22,
	clf_attribute23,
	clf_attribute24,
	clf_attribute25,
	clf_attribute26,
	clf_attribute27,
	clf_attribute28,
	clf_attribute29,
	clf_attribute30,
	object_version_number,
    sttd_sal_prdcty_cd
  )
  Values
  (	p_rec.comp_lvl_fctr_id,
	p_rec.business_group_id,
	p_rec.name,
        p_rec.comp_lvl_det_cd,
        p_rec.comp_lvl_det_rl,
	p_rec.comp_lvl_uom,
	p_rec.comp_src_cd,
	p_rec.defined_balance_id,
	p_rec.no_mn_comp_flag,
	p_rec.no_mx_comp_flag,
	p_rec.mx_comp_val,
	p_rec.mn_comp_val,
	p_rec.rndg_cd,
	p_rec.rndg_rl,
        p_rec.bnfts_bal_id,
        p_rec.comp_alt_val_to_use_cd,
        p_rec.comp_calc_rl,
  p_rec.proration_flag,
  p_rec.start_day_mo,
  p_rec.end_day_mo,
  p_rec.start_year,
  p_rec.end_year,
	p_rec.clf_attribute_category,
	p_rec.clf_attribute1,
	p_rec.clf_attribute2,
	p_rec.clf_attribute3,
	p_rec.clf_attribute4,
	p_rec.clf_attribute5,
	p_rec.clf_attribute6,
	p_rec.clf_attribute7,
	p_rec.clf_attribute8,
	p_rec.clf_attribute9,
	p_rec.clf_attribute10,
	p_rec.clf_attribute11,
	p_rec.clf_attribute12,
	p_rec.clf_attribute13,
	p_rec.clf_attribute14,
	p_rec.clf_attribute15,
	p_rec.clf_attribute16,
	p_rec.clf_attribute17,
	p_rec.clf_attribute18,
	p_rec.clf_attribute19,
	p_rec.clf_attribute20,
	p_rec.clf_attribute21,
	p_rec.clf_attribute22,
	p_rec.clf_attribute23,
	p_rec.clf_attribute24,
	p_rec.clf_attribute25,
	p_rec.clf_attribute26,
	p_rec.clf_attribute27,
	p_rec.clf_attribute28,
	p_rec.clf_attribute29,
	p_rec.clf_attribute30,
	p_rec.object_version_number,
    p_rec.sttd_sal_prdcty_cd
  );
  --
  ben_clf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_clf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_clf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_clf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_clf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_clf_shd.g_api_dml := false;   -- Unset the api dml status
    ben_clf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_clf_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_clf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_comp_lvl_fctr_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.comp_lvl_fctr_id;
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
p_effective_date in date,p_rec in ben_clf_shd.g_rec_type) is
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
    ben_clf_rki.after_insert
      (
  p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_name                          =>p_rec.name
 ,p_comp_lvl_det_cd               =>p_rec.comp_lvl_det_cd
 ,p_comp_lvl_det_rl               =>p_rec.comp_lvl_det_rl
 ,p_comp_lvl_uom                  =>p_rec.comp_lvl_uom
 ,p_comp_src_cd                   =>p_rec.comp_src_cd
 ,p_defined_balance_id            =>p_rec.defined_balance_id
 ,p_no_mn_comp_flag               =>p_rec.no_mn_comp_flag
 ,p_no_mx_comp_flag               =>p_rec.no_mx_comp_flag
 ,p_mx_comp_val                   =>p_rec.mx_comp_val
 ,p_mn_comp_val                   =>p_rec.mn_comp_val
 ,p_rndg_cd                       =>p_rec.rndg_cd
 ,p_rndg_rl                       =>p_rec.rndg_rl
 ,p_bnfts_bal_id                  =>p_rec.bnfts_bal_id
 ,p_comp_alt_val_to_use_cd        =>p_rec.comp_alt_val_to_use_cd
 ,p_comp_calc_rl                  =>p_rec.comp_calc_rl
 ,p_proration_flag                =>p_rec.proration_flag
 , p_start_day_mo                 =>p_rec.start_day_mo
 , p_end_day_mo                   =>p_rec.end_day_mo
 , p_start_year                   =>p_rec.start_year
 , p_end_year                     =>p_rec.end_year
 ,p_clf_attribute_category        =>p_rec.clf_attribute_category
 ,p_clf_attribute1                =>p_rec.clf_attribute1
 ,p_clf_attribute2                =>p_rec.clf_attribute2
 ,p_clf_attribute3                =>p_rec.clf_attribute3
 ,p_clf_attribute4                =>p_rec.clf_attribute4
 ,p_clf_attribute5                =>p_rec.clf_attribute5
 ,p_clf_attribute6                =>p_rec.clf_attribute6
 ,p_clf_attribute7                =>p_rec.clf_attribute7
 ,p_clf_attribute8                =>p_rec.clf_attribute8
 ,p_clf_attribute9                =>p_rec.clf_attribute9
 ,p_clf_attribute10               =>p_rec.clf_attribute10
 ,p_clf_attribute11               =>p_rec.clf_attribute11
 ,p_clf_attribute12               =>p_rec.clf_attribute12
 ,p_clf_attribute13               =>p_rec.clf_attribute13
 ,p_clf_attribute14               =>p_rec.clf_attribute14
 ,p_clf_attribute15               =>p_rec.clf_attribute15
 ,p_clf_attribute16               =>p_rec.clf_attribute16
 ,p_clf_attribute17               =>p_rec.clf_attribute17
 ,p_clf_attribute18               =>p_rec.clf_attribute18
 ,p_clf_attribute19               =>p_rec.clf_attribute19
 ,p_clf_attribute20               =>p_rec.clf_attribute20
 ,p_clf_attribute21               =>p_rec.clf_attribute21
 ,p_clf_attribute22               =>p_rec.clf_attribute22
 ,p_clf_attribute23               =>p_rec.clf_attribute23
 ,p_clf_attribute24               =>p_rec.clf_attribute24
 ,p_clf_attribute25               =>p_rec.clf_attribute25
 ,p_clf_attribute26               =>p_rec.clf_attribute26
 ,p_clf_attribute27               =>p_rec.clf_attribute27
 ,p_clf_attribute28               =>p_rec.clf_attribute28
 ,p_clf_attribute29               =>p_rec.clf_attribute29
 ,p_clf_attribute30               =>p_rec.clf_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_sttd_sal_prdcty_cd            =>p_rec.sttd_sal_prdcty_cd
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_comp_lvl_fctr'
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
  p_rec        in out nocopy ben_clf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_clf_bus.insert_validate(p_rec
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
  p_comp_lvl_fctr_id             out nocopy number,
  p_business_group_id            in number,
  p_name                         in varchar2,
  p_comp_lvl_det_cd              in varchar2         default null,
  p_comp_lvl_det_rl              in number           default null,
  p_comp_lvl_uom                 in varchar2         default null,
  p_comp_src_cd                  in varchar2         default null,
  p_defined_balance_id              in number           default null,
  p_no_mn_comp_flag              in varchar2         default null,
  p_no_mx_comp_flag              in varchar2         default null,
  p_mx_comp_val                  in number           default null,
  p_mn_comp_val                  in number           default null,
  p_rndg_cd                      in varchar2         default null,
  p_rndg_rl                      in number           default null,
  p_bnfts_bal_id                 in number           default null,
  p_comp_alt_val_to_use_cd       in varchar2         default null,
  p_comp_calc_rl                 in number           default null,
  p_proration_flag               in Varchar2         default 'N',
  p_start_day_mo                 in Varchar2         default null,
  p_end_day_mo                   in Varchar2         default null,
  p_start_year                   in Varchar2         default null,
  p_end_year                     in Varchar2         default null,
  p_clf_attribute_category       in varchar2         default null,
  p_clf_attribute1               in varchar2         default null,
  p_clf_attribute2               in varchar2         default null,
  p_clf_attribute3               in varchar2         default null,
  p_clf_attribute4               in varchar2         default null,
  p_clf_attribute5               in varchar2         default null,
  p_clf_attribute6               in varchar2         default null,
  p_clf_attribute7               in varchar2         default null,
  p_clf_attribute8               in varchar2         default null,
  p_clf_attribute9               in varchar2         default null,
  p_clf_attribute10              in varchar2         default null,
  p_clf_attribute11              in varchar2         default null,
  p_clf_attribute12              in varchar2         default null,
  p_clf_attribute13              in varchar2         default null,
  p_clf_attribute14              in varchar2         default null,
  p_clf_attribute15              in varchar2         default null,
  p_clf_attribute16              in varchar2         default null,
  p_clf_attribute17              in varchar2         default null,
  p_clf_attribute18              in varchar2         default null,
  p_clf_attribute19              in varchar2         default null,
  p_clf_attribute20              in varchar2         default null,
  p_clf_attribute21              in varchar2         default null,
  p_clf_attribute22              in varchar2         default null,
  p_clf_attribute23              in varchar2         default null,
  p_clf_attribute24              in varchar2         default null,
  p_clf_attribute25              in varchar2         default null,
  p_clf_attribute26              in varchar2         default null,
  p_clf_attribute27              in varchar2         default null,
  p_clf_attribute28              in varchar2         default null,
  p_clf_attribute29              in varchar2         default null,
  p_clf_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_sttd_sal_prdcty_cd           in varchar2         default null

  ) is
--
  l_rec	  ben_clf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_clf_shd.convert_args
  (
  null,
  p_business_group_id,
  p_name,
  p_comp_lvl_det_cd,
  p_comp_lvl_det_rl,
  p_comp_lvl_uom,
  p_comp_src_cd,
  p_defined_balance_id,
  p_no_mn_comp_flag,
  p_no_mx_comp_flag,
  p_mx_comp_val,
  p_mn_comp_val,
  p_rndg_cd,
  p_rndg_rl,
  p_bnfts_bal_id,
  p_comp_alt_val_to_use_cd,
  p_comp_calc_rl,
  p_proration_flag ,
  p_start_day_mo ,
  p_end_day_mo ,
  p_start_year ,
  p_end_year ,
  p_clf_attribute_category,
  p_clf_attribute1,
  p_clf_attribute2,
  p_clf_attribute3,
  p_clf_attribute4,
  p_clf_attribute5,
  p_clf_attribute6,
  p_clf_attribute7,
  p_clf_attribute8,
  p_clf_attribute9,
  p_clf_attribute10,
  p_clf_attribute11,
  p_clf_attribute12,
  p_clf_attribute13,
  p_clf_attribute14,
  p_clf_attribute15,
  p_clf_attribute16,
  p_clf_attribute17,
  p_clf_attribute18,
  p_clf_attribute19,
  p_clf_attribute20,
  p_clf_attribute21,
  p_clf_attribute22,
  p_clf_attribute23,
  p_clf_attribute24,
  p_clf_attribute25,
  p_clf_attribute26,
  p_clf_attribute27,
  p_clf_attribute28,
  p_clf_attribute29,
  p_clf_attribute30,
  null,
  p_sttd_sal_prdcty_cd
  );
  --
  -- Having converted the arguments into the ben_clf_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_comp_lvl_fctr_id := l_rec.comp_lvl_fctr_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_clf_ins;

/
