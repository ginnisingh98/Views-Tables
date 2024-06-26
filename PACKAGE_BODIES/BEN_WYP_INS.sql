--------------------------------------------------------
--  DDL for Package Body BEN_WYP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WYP_INS" as
/* $Header: bewyprhi.pkb 115.12 2003/01/01 00:03:22 mmudigon ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_wyp_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_wyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_wyp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_wthn_yr_perd
  --
  insert into ben_wthn_yr_perd
  ( wthn_yr_perd_id,
    strt_day,
    end_day,
    strt_mo,
    end_mo,
        tm_uom,
    yr_perd_id,
    business_group_id,
    wyp_attribute_category,
    wyp_attribute1,
    wyp_attribute2,
    wyp_attribute3,
    wyp_attribute4,
    wyp_attribute5,
    wyp_attribute6,
    wyp_attribute7,
    wyp_attribute8,
    wyp_attribute9,
    wyp_attribute10,
    wyp_attribute11,
    wyp_attribute12,
    wyp_attribute13,
    wyp_attribute14,
    wyp_attribute15,
    wyp_attribute16,
    wyp_attribute17,
    wyp_attribute18,
    wyp_attribute19,
    wyp_attribute20,
    wyp_attribute21,
    wyp_attribute22,
    wyp_attribute23,
    wyp_attribute24,
    wyp_attribute25,
    wyp_attribute26,
    wyp_attribute27,
    wyp_attribute28,
    wyp_attribute29,
    wyp_attribute30,
    object_version_number
  )
  Values
  ( p_rec.wthn_yr_perd_id,
    p_rec.strt_day,
    p_rec.end_day,
    p_rec.strt_mo,
    p_rec.end_mo,
        p_rec.tm_uom,
    p_rec.yr_perd_id,
    p_rec.business_group_id,
    p_rec.wyp_attribute_category,
    p_rec.wyp_attribute1,
    p_rec.wyp_attribute2,
    p_rec.wyp_attribute3,
    p_rec.wyp_attribute4,
    p_rec.wyp_attribute5,
    p_rec.wyp_attribute6,
    p_rec.wyp_attribute7,
    p_rec.wyp_attribute8,
    p_rec.wyp_attribute9,
    p_rec.wyp_attribute10,
    p_rec.wyp_attribute11,
    p_rec.wyp_attribute12,
    p_rec.wyp_attribute13,
    p_rec.wyp_attribute14,
    p_rec.wyp_attribute15,
    p_rec.wyp_attribute16,
    p_rec.wyp_attribute17,
    p_rec.wyp_attribute18,
    p_rec.wyp_attribute19,
    p_rec.wyp_attribute20,
    p_rec.wyp_attribute21,
    p_rec.wyp_attribute22,
    p_rec.wyp_attribute23,
    p_rec.wyp_attribute24,
    p_rec.wyp_attribute25,
    p_rec.wyp_attribute26,
    p_rec.wyp_attribute27,
    p_rec.wyp_attribute28,
    p_rec.wyp_attribute29,
    p_rec.wyp_attribute30,
    p_rec.object_version_number
  );
  --
  ben_wyp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_wyp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_wyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_wyp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_wyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_wyp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_wyp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_wyp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_wyp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_wthn_yr_perd_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.wthn_yr_perd_id;
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
Procedure post_insert(p_effective_date in date,
                      p_rec in ben_wyp_shd.g_rec_type) is
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
    ben_wyp_rki.after_insert
      (
  p_wthn_yr_perd_id               =>p_rec.wthn_yr_perd_id
 ,p_strt_day                      =>p_rec.strt_day
 ,p_end_day                       =>p_rec.end_day
 ,p_strt_mo                       =>p_rec.strt_mo
 ,p_end_mo                        =>p_rec.end_mo
 ,p_tm_uom                        =>p_rec.tm_uom
 ,p_yr_perd_id                    =>p_rec.yr_perd_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_wyp_attribute_category        =>p_rec.wyp_attribute_category
 ,p_wyp_attribute1                =>p_rec.wyp_attribute1
 ,p_wyp_attribute2                =>p_rec.wyp_attribute2
 ,p_wyp_attribute3                =>p_rec.wyp_attribute3
 ,p_wyp_attribute4                =>p_rec.wyp_attribute4
 ,p_wyp_attribute5                =>p_rec.wyp_attribute5
 ,p_wyp_attribute6                =>p_rec.wyp_attribute6
 ,p_wyp_attribute7                =>p_rec.wyp_attribute7
 ,p_wyp_attribute8                =>p_rec.wyp_attribute8
 ,p_wyp_attribute9                =>p_rec.wyp_attribute9
 ,p_wyp_attribute10               =>p_rec.wyp_attribute10
 ,p_wyp_attribute11               =>p_rec.wyp_attribute11
 ,p_wyp_attribute12               =>p_rec.wyp_attribute12
 ,p_wyp_attribute13               =>p_rec.wyp_attribute13
 ,p_wyp_attribute14               =>p_rec.wyp_attribute14
 ,p_wyp_attribute15               =>p_rec.wyp_attribute15
 ,p_wyp_attribute16               =>p_rec.wyp_attribute16
 ,p_wyp_attribute17               =>p_rec.wyp_attribute17
 ,p_wyp_attribute18               =>p_rec.wyp_attribute18
 ,p_wyp_attribute19               =>p_rec.wyp_attribute19
 ,p_wyp_attribute20               =>p_rec.wyp_attribute20
 ,p_wyp_attribute21               =>p_rec.wyp_attribute21
 ,p_wyp_attribute22               =>p_rec.wyp_attribute22
 ,p_wyp_attribute23               =>p_rec.wyp_attribute23
 ,p_wyp_attribute24               =>p_rec.wyp_attribute24
 ,p_wyp_attribute25               =>p_rec.wyp_attribute25
 ,p_wyp_attribute26               =>p_rec.wyp_attribute26
 ,p_wyp_attribute27               =>p_rec.wyp_attribute27
 ,p_wyp_attribute28               =>p_rec.wyp_attribute28
 ,p_wyp_attribute29               =>p_rec.wyp_attribute29
 ,p_wyp_attribute30               =>p_rec.wyp_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_wthn_yr_perd'
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
  p_rec        in out nocopy ben_wyp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_wyp_bus.insert_validate(p_rec
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
  post_insert(p_effective_date,
              p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date               in date,
  p_wthn_yr_perd_id              out nocopy number,
  p_strt_day                     in number           default null,
  p_end_day                      in number           default null,
  p_strt_mo                      in number           default null,
  p_end_mo                       in number           default null,
  p_tm_uom                       in varchar2         default null,
  p_yr_perd_id                   in number           default null,
  p_business_group_id            in number           default null,
  p_wyp_attribute_category       in varchar2         default null,
  p_wyp_attribute1               in varchar2         default null,
  p_wyp_attribute2               in varchar2         default null,
  p_wyp_attribute3               in varchar2         default null,
  p_wyp_attribute4               in varchar2         default null,
  p_wyp_attribute5               in varchar2         default null,
  p_wyp_attribute6               in varchar2         default null,
  p_wyp_attribute7               in varchar2         default null,
  p_wyp_attribute8               in varchar2         default null,
  p_wyp_attribute9               in varchar2         default null,
  p_wyp_attribute10              in varchar2         default null,
  p_wyp_attribute11              in varchar2         default null,
  p_wyp_attribute12              in varchar2         default null,
  p_wyp_attribute13              in varchar2         default null,
  p_wyp_attribute14              in varchar2         default null,
  p_wyp_attribute15              in varchar2         default null,
  p_wyp_attribute16              in varchar2         default null,
  p_wyp_attribute17              in varchar2         default null,
  p_wyp_attribute18              in varchar2         default null,
  p_wyp_attribute19              in varchar2         default null,
  p_wyp_attribute20              in varchar2         default null,
  p_wyp_attribute21              in varchar2         default null,
  p_wyp_attribute22              in varchar2         default null,
  p_wyp_attribute23              in varchar2         default null,
  p_wyp_attribute24              in varchar2         default null,
  p_wyp_attribute25              in varchar2         default null,
  p_wyp_attribute26              in varchar2         default null,
  p_wyp_attribute27              in varchar2         default null,
  p_wyp_attribute28              in varchar2         default null,
  p_wyp_attribute29              in varchar2         default null,
  p_wyp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec   ben_wyp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_wyp_shd.convert_args
  (
  null,
  p_strt_day,
  p_end_day,
  p_strt_mo,
  p_end_mo,
  p_tm_uom,
  p_yr_perd_id,
  p_business_group_id,
  p_wyp_attribute_category,
  p_wyp_attribute1,
  p_wyp_attribute2,
  p_wyp_attribute3,
  p_wyp_attribute4,
  p_wyp_attribute5,
  p_wyp_attribute6,
  p_wyp_attribute7,
  p_wyp_attribute8,
  p_wyp_attribute9,
  p_wyp_attribute10,
  p_wyp_attribute11,
  p_wyp_attribute12,
  p_wyp_attribute13,
  p_wyp_attribute14,
  p_wyp_attribute15,
  p_wyp_attribute16,
  p_wyp_attribute17,
  p_wyp_attribute18,
  p_wyp_attribute19,
  p_wyp_attribute20,
  p_wyp_attribute21,
  p_wyp_attribute22,
  p_wyp_attribute23,
  p_wyp_attribute24,
  p_wyp_attribute25,
  p_wyp_attribute26,
  p_wyp_attribute27,
  p_wyp_attribute28,
  p_wyp_attribute29,
  p_wyp_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_wyp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,
      l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_wthn_yr_perd_id := l_rec.wthn_yr_perd_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_wyp_ins;

/
