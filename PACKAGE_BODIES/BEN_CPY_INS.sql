--------------------------------------------------------
--  DDL for Package Body BEN_CPY_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPY_INS" as
/* $Header: becpyrhi.pkb 120.2 2005/12/19 12:34:35 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cpy_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_cpy_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_cpy_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_popl_yr_perd
  --
  insert into ben_popl_yr_perd
  (	popl_yr_perd_id,
	yr_perd_id,
	business_group_id,
	pl_id,
	pgm_id,
	ordr_num,
	acpt_clm_rqsts_thru_dt,
	py_clms_thru_dt,
	cpy_attribute_category,
	cpy_attribute1,
	cpy_attribute2,
	cpy_attribute3,
	cpy_attribute4,
	cpy_attribute5,
	cpy_attribute6,
	cpy_attribute7,
	cpy_attribute8,
	cpy_attribute9,
	cpy_attribute10,
	cpy_attribute11,
	cpy_attribute12,
	cpy_attribute13,
	cpy_attribute14,
	cpy_attribute15,
	cpy_attribute16,
	cpy_attribute17,
	cpy_attribute18,
	cpy_attribute19,
	cpy_attribute20,
	cpy_attribute21,
	cpy_attribute22,
	cpy_attribute23,
	cpy_attribute24,
	cpy_attribute25,
	cpy_attribute26,
	cpy_attribute27,
	cpy_attribute28,
	cpy_attribute29,
	cpy_attribute30,
	object_version_number
  )
  Values
  (	p_rec.popl_yr_perd_id,
	p_rec.yr_perd_id,
	p_rec.business_group_id,
	p_rec.pl_id,
	p_rec.pgm_id,
	p_rec.ordr_num,
	p_rec.acpt_clm_rqsts_thru_dt,
	p_rec.py_clms_thru_dt,
	p_rec.cpy_attribute_category,
	p_rec.cpy_attribute1,
	p_rec.cpy_attribute2,
	p_rec.cpy_attribute3,
	p_rec.cpy_attribute4,
	p_rec.cpy_attribute5,
	p_rec.cpy_attribute6,
	p_rec.cpy_attribute7,
	p_rec.cpy_attribute8,
	p_rec.cpy_attribute9,
	p_rec.cpy_attribute10,
	p_rec.cpy_attribute11,
	p_rec.cpy_attribute12,
	p_rec.cpy_attribute13,
	p_rec.cpy_attribute14,
	p_rec.cpy_attribute15,
	p_rec.cpy_attribute16,
	p_rec.cpy_attribute17,
	p_rec.cpy_attribute18,
	p_rec.cpy_attribute19,
	p_rec.cpy_attribute20,
	p_rec.cpy_attribute21,
	p_rec.cpy_attribute22,
	p_rec.cpy_attribute23,
	p_rec.cpy_attribute24,
	p_rec.cpy_attribute25,
	p_rec.cpy_attribute26,
	p_rec.cpy_attribute27,
	p_rec.cpy_attribute28,
	p_rec.cpy_attribute29,
	p_rec.cpy_attribute30,
	p_rec.object_version_number
  );
  --
  ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpy_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpy_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpy_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpy_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_cpy_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_popl_yr_perd_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.popl_yr_perd_id;
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
Procedure post_insert(p_rec in ben_cpy_shd.g_rec_type) is
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
    ben_cpy_rki.after_insert
      (
       p_popl_yr_perd_id               =>p_rec.popl_yr_perd_id
      ,p_yr_perd_id                    =>p_rec.yr_perd_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_pl_id                         =>p_rec.pl_id
      ,p_pgm_id                        =>p_rec.pgm_id
      ,p_ordr_num                      =>p_rec.ordr_num
      ,p_acpt_clm_rqsts_thru_dt        =>p_rec.acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt               =>p_rec.py_clms_thru_dt
      ,p_cpy_attribute_category        =>p_rec.cpy_attribute_category
      ,p_cpy_attribute1                =>p_rec.cpy_attribute1
      ,p_cpy_attribute2                =>p_rec.cpy_attribute2
      ,p_cpy_attribute3                =>p_rec.cpy_attribute3
      ,p_cpy_attribute4                =>p_rec.cpy_attribute4
      ,p_cpy_attribute5                =>p_rec.cpy_attribute5
      ,p_cpy_attribute6                =>p_rec.cpy_attribute6
      ,p_cpy_attribute7                =>p_rec.cpy_attribute7
      ,p_cpy_attribute8                =>p_rec.cpy_attribute8
      ,p_cpy_attribute9                =>p_rec.cpy_attribute9
      ,p_cpy_attribute10               =>p_rec.cpy_attribute10
      ,p_cpy_attribute11               =>p_rec.cpy_attribute11
      ,p_cpy_attribute12               =>p_rec.cpy_attribute12
      ,p_cpy_attribute13               =>p_rec.cpy_attribute13
      ,p_cpy_attribute14               =>p_rec.cpy_attribute14
      ,p_cpy_attribute15               =>p_rec.cpy_attribute15
      ,p_cpy_attribute16               =>p_rec.cpy_attribute16
      ,p_cpy_attribute17               =>p_rec.cpy_attribute17
      ,p_cpy_attribute18               =>p_rec.cpy_attribute18
      ,p_cpy_attribute19               =>p_rec.cpy_attribute19
      ,p_cpy_attribute20               =>p_rec.cpy_attribute20
      ,p_cpy_attribute21               =>p_rec.cpy_attribute21
      ,p_cpy_attribute22               =>p_rec.cpy_attribute22
      ,p_cpy_attribute23               =>p_rec.cpy_attribute23
      ,p_cpy_attribute24               =>p_rec.cpy_attribute24
      ,p_cpy_attribute25               =>p_rec.cpy_attribute25
      ,p_cpy_attribute26               =>p_rec.cpy_attribute26
      ,p_cpy_attribute27               =>p_rec.cpy_attribute27
      ,p_cpy_attribute28               =>p_rec.cpy_attribute28
      ,p_cpy_attribute29               =>p_rec.cpy_attribute29
      ,p_cpy_attribute30               =>p_rec.cpy_attribute30
      ,p_object_version_number         =>p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_popl_yr_perd'
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
  p_rec        in out nocopy ben_cpy_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_cpy_bus.insert_validate(p_rec);
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
  p_popl_yr_perd_id              out nocopy number,
  p_yr_perd_id                   in number,
  p_business_group_id            in number,
  p_pl_id                        in number           default null,
  p_pgm_id                       in number           default null,
  p_ordr_num                     in number           default null,
  p_acpt_clm_rqsts_thru_dt       in date             default null,
  p_py_clms_thru_dt              in date             default null,
  p_cpy_attribute_category       in varchar2         default null,
  p_cpy_attribute1               in varchar2         default null,
  p_cpy_attribute2               in varchar2         default null,
  p_cpy_attribute3               in varchar2         default null,
  p_cpy_attribute4               in varchar2         default null,
  p_cpy_attribute5               in varchar2         default null,
  p_cpy_attribute6               in varchar2         default null,
  p_cpy_attribute7               in varchar2         default null,
  p_cpy_attribute8               in varchar2         default null,
  p_cpy_attribute9               in varchar2         default null,
  p_cpy_attribute10              in varchar2         default null,
  p_cpy_attribute11              in varchar2         default null,
  p_cpy_attribute12              in varchar2         default null,
  p_cpy_attribute13              in varchar2         default null,
  p_cpy_attribute14              in varchar2         default null,
  p_cpy_attribute15              in varchar2         default null,
  p_cpy_attribute16              in varchar2         default null,
  p_cpy_attribute17              in varchar2         default null,
  p_cpy_attribute18              in varchar2         default null,
  p_cpy_attribute19              in varchar2         default null,
  p_cpy_attribute20              in varchar2         default null,
  p_cpy_attribute21              in varchar2         default null,
  p_cpy_attribute22              in varchar2         default null,
  p_cpy_attribute23              in varchar2         default null,
  p_cpy_attribute24              in varchar2         default null,
  p_cpy_attribute25              in varchar2         default null,
  p_cpy_attribute26              in varchar2         default null,
  p_cpy_attribute27              in varchar2         default null,
  p_cpy_attribute28              in varchar2         default null,
  p_cpy_attribute29              in varchar2         default null,
  p_cpy_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_cpy_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_cpy_shd.convert_args
  (
  null,
  p_yr_perd_id,
  p_business_group_id,
  p_pl_id,
  p_pgm_id,
  p_ordr_num,
  p_acpt_clm_rqsts_thru_dt,
  p_py_clms_thru_dt,
  p_cpy_attribute_category,
  p_cpy_attribute1,
  p_cpy_attribute2,
  p_cpy_attribute3,
  p_cpy_attribute4,
  p_cpy_attribute5,
  p_cpy_attribute6,
  p_cpy_attribute7,
  p_cpy_attribute8,
  p_cpy_attribute9,
  p_cpy_attribute10,
  p_cpy_attribute11,
  p_cpy_attribute12,
  p_cpy_attribute13,
  p_cpy_attribute14,
  p_cpy_attribute15,
  p_cpy_attribute16,
  p_cpy_attribute17,
  p_cpy_attribute18,
  p_cpy_attribute19,
  p_cpy_attribute20,
  p_cpy_attribute21,
  p_cpy_attribute22,
  p_cpy_attribute23,
  p_cpy_attribute24,
  p_cpy_attribute25,
  p_cpy_attribute26,
  p_cpy_attribute27,
  p_cpy_attribute28,
  p_cpy_attribute29,
  p_cpy_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_cpy_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_popl_yr_perd_id := l_rec.popl_yr_perd_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_cpy_ins;

/
