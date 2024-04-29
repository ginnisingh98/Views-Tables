--------------------------------------------------------
--  DDL for Package Body BEN_GOS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GOS_INS" as
/* $Header: begosrhi.pkb 120.0 2005/05/28 03:08:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_gos_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_gos_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_gos_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_gd_or_svc_typ
  --
  insert into ben_gd_or_svc_typ
  (	gd_or_svc_typ_id,
	business_group_id,
	name,
	typ_cd,
	description,
	gos_attribute_category,
	gos_attribute1,
	gos_attribute2,
	gos_attribute3,
	gos_attribute4,
	gos_attribute5,
	gos_attribute6,
	gos_attribute7,
	gos_attribute8,
	gos_attribute9,
	gos_attribute10,
	gos_attribute11,
	gos_attribute12,
	gos_attribute13,
	gos_attribute14,
	gos_attribute15,
	gos_attribute16,
	gos_attribute17,
	gos_attribute18,
	gos_attribute19,
	gos_attribute20,
	gos_attribute21,
	gos_attribute22,
	gos_attribute23,
	gos_attribute24,
	gos_attribute25,
	gos_attribute26,
	gos_attribute27,
	gos_attribute28,
	gos_attribute29,
	gos_attribute30,
	object_version_number
  )
  Values
  (	p_rec.gd_or_svc_typ_id,
	p_rec.business_group_id,
	p_rec.name,
	p_rec.typ_cd,
	p_rec.description,
	p_rec.gos_attribute_category,
	p_rec.gos_attribute1,
	p_rec.gos_attribute2,
	p_rec.gos_attribute3,
	p_rec.gos_attribute4,
	p_rec.gos_attribute5,
	p_rec.gos_attribute6,
	p_rec.gos_attribute7,
	p_rec.gos_attribute8,
	p_rec.gos_attribute9,
	p_rec.gos_attribute10,
	p_rec.gos_attribute11,
	p_rec.gos_attribute12,
	p_rec.gos_attribute13,
	p_rec.gos_attribute14,
	p_rec.gos_attribute15,
	p_rec.gos_attribute16,
	p_rec.gos_attribute17,
	p_rec.gos_attribute18,
	p_rec.gos_attribute19,
	p_rec.gos_attribute20,
	p_rec.gos_attribute21,
	p_rec.gos_attribute22,
	p_rec.gos_attribute23,
	p_rec.gos_attribute24,
	p_rec.gos_attribute25,
	p_rec.gos_attribute26,
	p_rec.gos_attribute27,
	p_rec.gos_attribute28,
	p_rec.gos_attribute29,
	p_rec.gos_attribute30,
	p_rec.object_version_number
  );
  --
  ben_gos_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_gos_shd.g_api_dml := false;   -- Unset the api dml status
    ben_gos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_gos_shd.g_api_dml := false;   -- Unset the api dml status
    ben_gos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_gos_shd.g_api_dml := false;   -- Unset the api dml status
    ben_gos_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_gos_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_gos_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_gd_or_svc_typ_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.gd_or_svc_typ_id;
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
p_effective_date in date,p_rec in ben_gos_shd.g_rec_type) is
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
    ben_gos_rki.after_insert
      (
  p_gd_or_svc_typ_id              =>p_rec.gd_or_svc_typ_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_name                          =>p_rec.name
 ,p_typ_cd                        =>p_rec.typ_cd
 ,p_description                   =>p_rec.description
 ,p_gos_attribute_category        =>p_rec.gos_attribute_category
 ,p_gos_attribute1                =>p_rec.gos_attribute1
 ,p_gos_attribute2                =>p_rec.gos_attribute2
 ,p_gos_attribute3                =>p_rec.gos_attribute3
 ,p_gos_attribute4                =>p_rec.gos_attribute4
 ,p_gos_attribute5                =>p_rec.gos_attribute5
 ,p_gos_attribute6                =>p_rec.gos_attribute6
 ,p_gos_attribute7                =>p_rec.gos_attribute7
 ,p_gos_attribute8                =>p_rec.gos_attribute8
 ,p_gos_attribute9                =>p_rec.gos_attribute9
 ,p_gos_attribute10               =>p_rec.gos_attribute10
 ,p_gos_attribute11               =>p_rec.gos_attribute11
 ,p_gos_attribute12               =>p_rec.gos_attribute12
 ,p_gos_attribute13               =>p_rec.gos_attribute13
 ,p_gos_attribute14               =>p_rec.gos_attribute14
 ,p_gos_attribute15               =>p_rec.gos_attribute15
 ,p_gos_attribute16               =>p_rec.gos_attribute16
 ,p_gos_attribute17               =>p_rec.gos_attribute17
 ,p_gos_attribute18               =>p_rec.gos_attribute18
 ,p_gos_attribute19               =>p_rec.gos_attribute19
 ,p_gos_attribute20               =>p_rec.gos_attribute20
 ,p_gos_attribute21               =>p_rec.gos_attribute21
 ,p_gos_attribute22               =>p_rec.gos_attribute22
 ,p_gos_attribute23               =>p_rec.gos_attribute23
 ,p_gos_attribute24               =>p_rec.gos_attribute24
 ,p_gos_attribute25               =>p_rec.gos_attribute25
 ,p_gos_attribute26               =>p_rec.gos_attribute26
 ,p_gos_attribute27               =>p_rec.gos_attribute27
 ,p_gos_attribute28               =>p_rec.gos_attribute28
 ,p_gos_attribute29               =>p_rec.gos_attribute29
 ,p_gos_attribute30               =>p_rec.gos_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_gd_or_svc_typ'
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
  p_rec        in out nocopy ben_gos_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_gos_bus.insert_validate(p_rec
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
  p_gd_or_svc_typ_id             out nocopy number,
  p_business_group_id            in number,
  p_name                         in varchar2,
  p_typ_cd                       in varchar2         default null,
  p_description                  in varchar2         default null,
  p_gos_attribute_category       in varchar2         default null,
  p_gos_attribute1               in varchar2         default null,
  p_gos_attribute2               in varchar2         default null,
  p_gos_attribute3               in varchar2         default null,
  p_gos_attribute4               in varchar2         default null,
  p_gos_attribute5               in varchar2         default null,
  p_gos_attribute6               in varchar2         default null,
  p_gos_attribute7               in varchar2         default null,
  p_gos_attribute8               in varchar2         default null,
  p_gos_attribute9               in varchar2         default null,
  p_gos_attribute10              in varchar2         default null,
  p_gos_attribute11              in varchar2         default null,
  p_gos_attribute12              in varchar2         default null,
  p_gos_attribute13              in varchar2         default null,
  p_gos_attribute14              in varchar2         default null,
  p_gos_attribute15              in varchar2         default null,
  p_gos_attribute16              in varchar2         default null,
  p_gos_attribute17              in varchar2         default null,
  p_gos_attribute18              in varchar2         default null,
  p_gos_attribute19              in varchar2         default null,
  p_gos_attribute20              in varchar2         default null,
  p_gos_attribute21              in varchar2         default null,
  p_gos_attribute22              in varchar2         default null,
  p_gos_attribute23              in varchar2         default null,
  p_gos_attribute24              in varchar2         default null,
  p_gos_attribute25              in varchar2         default null,
  p_gos_attribute26              in varchar2         default null,
  p_gos_attribute27              in varchar2         default null,
  p_gos_attribute28              in varchar2         default null,
  p_gos_attribute29              in varchar2         default null,
  p_gos_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_gos_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_gos_shd.convert_args
  (
  null,
  p_business_group_id,
  p_name,
  p_typ_cd,
  p_description,
  p_gos_attribute_category,
  p_gos_attribute1,
  p_gos_attribute2,
  p_gos_attribute3,
  p_gos_attribute4,
  p_gos_attribute5,
  p_gos_attribute6,
  p_gos_attribute7,
  p_gos_attribute8,
  p_gos_attribute9,
  p_gos_attribute10,
  p_gos_attribute11,
  p_gos_attribute12,
  p_gos_attribute13,
  p_gos_attribute14,
  p_gos_attribute15,
  p_gos_attribute16,
  p_gos_attribute17,
  p_gos_attribute18,
  p_gos_attribute19,
  p_gos_attribute20,
  p_gos_attribute21,
  p_gos_attribute22,
  p_gos_attribute23,
  p_gos_attribute24,
  p_gos_attribute25,
  p_gos_attribute26,
  p_gos_attribute27,
  p_gos_attribute28,
  p_gos_attribute29,
  p_gos_attribute30,
  null
  );
  --
  -- Having converted the arguments into the ben_gos_rec
  -- plsql record structure we call the corresponding record business process.
  --
hr_utility.set_location('In:'||l_proc, 7);
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_gd_or_svc_typ_id := l_rec.gd_or_svc_typ_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_gos_ins;

/
