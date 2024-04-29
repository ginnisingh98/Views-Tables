--------------------------------------------------------
--  DDL for Package Body BEN_ERC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERC_INS" as
/* $Header: beercrhi.pkb 115.2 2002/12/11 11:16:15 hnarayan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_erc_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_erc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_erc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_enrt_rt_ctfn
  --
  insert into ben_enrt_rt_ctfn
  (	enrt_rt_ctfn_id,
	enrt_ctfn_typ_cd,
	rqd_flag,
	enrt_rt_id,
	business_group_id,
	erc_attribute_category,
	erc_attribute1,
	erc_attribute2,
	erc_attribute3,
	erc_attribute4,
	erc_attribute5,
	erc_attribute6,
	erc_attribute7,
	erc_attribute8,
	erc_attribute9,
	erc_attribute10,
	erc_attribute11,
	erc_attribute12,
	erc_attribute13,
	erc_attribute14,
	erc_attribute15,
	erc_attribute16,
	erc_attribute17,
	erc_attribute18,
	erc_attribute19,
	erc_attribute20,
	erc_attribute21,
	erc_attribute22,
	erc_attribute23,
	erc_attribute24,
	erc_attribute25,
	erc_attribute26,
	erc_attribute27,
	erc_attribute28,
	erc_attribute29,
	erc_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
  )
  Values
  (	p_rec.enrt_rt_ctfn_id,
	p_rec.enrt_ctfn_typ_cd,
	p_rec.rqd_flag,
	p_rec.enrt_rt_id,
	p_rec.business_group_id,
	p_rec.erc_attribute_category,
	p_rec.erc_attribute1,
	p_rec.erc_attribute2,
	p_rec.erc_attribute3,
	p_rec.erc_attribute4,
	p_rec.erc_attribute5,
	p_rec.erc_attribute6,
	p_rec.erc_attribute7,
	p_rec.erc_attribute8,
	p_rec.erc_attribute9,
	p_rec.erc_attribute10,
	p_rec.erc_attribute11,
	p_rec.erc_attribute12,
	p_rec.erc_attribute13,
	p_rec.erc_attribute14,
	p_rec.erc_attribute15,
	p_rec.erc_attribute16,
	p_rec.erc_attribute17,
	p_rec.erc_attribute18,
	p_rec.erc_attribute19,
	p_rec.erc_attribute20,
	p_rec.erc_attribute21,
	p_rec.erc_attribute22,
	p_rec.erc_attribute23,
	p_rec.erc_attribute24,
	p_rec.erc_attribute25,
	p_rec.erc_attribute26,
	p_rec.erc_attribute27,
	p_rec.erc_attribute28,
	p_rec.erc_attribute29,
	p_rec.erc_attribute30,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.object_version_number
  );
  --
  ben_erc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_erc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_erc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_erc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_erc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_erc_shd.g_api_dml := false;   -- Unset the api dml status
    ben_erc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_erc_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_erc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_enrt_rt_ctfn_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.enrt_rt_ctfn_id;
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
p_effective_date in date,p_rec in ben_erc_shd.g_rec_type) is
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
    ben_erc_rki.after_insert
      (
  p_enrt_rt_ctfn_id            =>p_rec.enrt_rt_ctfn_id
 ,p_enrt_ctfn_typ_cd              =>p_rec.enrt_ctfn_typ_cd
 ,p_rqd_flag                      =>p_rec.rqd_flag
 ,p_enrt_rt_id        =>p_rec.enrt_rt_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_erc_attribute_category        =>p_rec.erc_attribute_category
 ,p_erc_attribute1                =>p_rec.erc_attribute1
 ,p_erc_attribute2                =>p_rec.erc_attribute2
 ,p_erc_attribute3                =>p_rec.erc_attribute3
 ,p_erc_attribute4                =>p_rec.erc_attribute4
 ,p_erc_attribute5                =>p_rec.erc_attribute5
 ,p_erc_attribute6                =>p_rec.erc_attribute6
 ,p_erc_attribute7                =>p_rec.erc_attribute7
 ,p_erc_attribute8                =>p_rec.erc_attribute8
 ,p_erc_attribute9                =>p_rec.erc_attribute9
 ,p_erc_attribute10               =>p_rec.erc_attribute10
 ,p_erc_attribute11               =>p_rec.erc_attribute11
 ,p_erc_attribute12               =>p_rec.erc_attribute12
 ,p_erc_attribute13               =>p_rec.erc_attribute13
 ,p_erc_attribute14               =>p_rec.erc_attribute14
 ,p_erc_attribute15               =>p_rec.erc_attribute15
 ,p_erc_attribute16               =>p_rec.erc_attribute16
 ,p_erc_attribute17               =>p_rec.erc_attribute17
 ,p_erc_attribute18               =>p_rec.erc_attribute18
 ,p_erc_attribute19               =>p_rec.erc_attribute19
 ,p_erc_attribute20               =>p_rec.erc_attribute20
 ,p_erc_attribute21               =>p_rec.erc_attribute21
 ,p_erc_attribute22               =>p_rec.erc_attribute22
 ,p_erc_attribute23               =>p_rec.erc_attribute23
 ,p_erc_attribute24               =>p_rec.erc_attribute24
 ,p_erc_attribute25               =>p_rec.erc_attribute25
 ,p_erc_attribute26               =>p_rec.erc_attribute26
 ,p_erc_attribute27               =>p_rec.erc_attribute27
 ,p_erc_attribute28               =>p_rec.erc_attribute28
 ,p_erc_attribute29               =>p_rec.erc_attribute29
 ,p_erc_attribute30               =>p_rec.erc_attribute30
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_rt_ctfn'
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
  p_rec        in out nocopy ben_erc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_erc_bus.insert_validate(p_rec
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
  p_enrt_rt_ctfn_id           out nocopy number,
  p_enrt_ctfn_typ_cd             in varchar2,
  p_rqd_flag                     in varchar2,
  p_enrt_rt_id       in number           default null,
  p_business_group_id            in number,
  p_erc_attribute_category       in varchar2         default null,
  p_erc_attribute1               in varchar2         default null,
  p_erc_attribute2               in varchar2         default null,
  p_erc_attribute3               in varchar2         default null,
  p_erc_attribute4               in varchar2         default null,
  p_erc_attribute5               in varchar2         default null,
  p_erc_attribute6               in varchar2         default null,
  p_erc_attribute7               in varchar2         default null,
  p_erc_attribute8               in varchar2         default null,
  p_erc_attribute9               in varchar2         default null,
  p_erc_attribute10              in varchar2         default null,
  p_erc_attribute11              in varchar2         default null,
  p_erc_attribute12              in varchar2         default null,
  p_erc_attribute13              in varchar2         default null,
  p_erc_attribute14              in varchar2         default null,
  p_erc_attribute15              in varchar2         default null,
  p_erc_attribute16              in varchar2         default null,
  p_erc_attribute17              in varchar2         default null,
  p_erc_attribute18              in varchar2         default null,
  p_erc_attribute19              in varchar2         default null,
  p_erc_attribute20              in varchar2         default null,
  p_erc_attribute21              in varchar2         default null,
  p_erc_attribute22              in varchar2         default null,
  p_erc_attribute23              in varchar2         default null,
  p_erc_attribute24              in varchar2         default null,
  p_erc_attribute25              in varchar2         default null,
  p_erc_attribute26              in varchar2         default null,
  p_erc_attribute27              in varchar2         default null,
  p_erc_attribute28              in varchar2         default null,
  p_erc_attribute29              in varchar2         default null,
  p_erc_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_erc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_erc_shd.convert_args
  (
  null,
  p_enrt_ctfn_typ_cd,
  p_rqd_flag,
  p_enrt_rt_id,
  p_business_group_id,
  p_erc_attribute_category,
  p_erc_attribute1,
  p_erc_attribute2,
  p_erc_attribute3,
  p_erc_attribute4,
  p_erc_attribute5,
  p_erc_attribute6,
  p_erc_attribute7,
  p_erc_attribute8,
  p_erc_attribute9,
  p_erc_attribute10,
  p_erc_attribute11,
  p_erc_attribute12,
  p_erc_attribute13,
  p_erc_attribute14,
  p_erc_attribute15,
  p_erc_attribute16,
  p_erc_attribute17,
  p_erc_attribute18,
  p_erc_attribute19,
  p_erc_attribute20,
  p_erc_attribute21,
  p_erc_attribute22,
  p_erc_attribute23,
  p_erc_attribute24,
  p_erc_attribute25,
  p_erc_attribute26,
  p_erc_attribute27,
  p_erc_attribute28,
  p_erc_attribute29,
  p_erc_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_erc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_enrt_rt_ctfn_id := l_rec.enrt_rt_ctfn_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_erc_ins;

/
