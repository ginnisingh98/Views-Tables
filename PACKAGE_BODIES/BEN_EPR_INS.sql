--------------------------------------------------------
--  DDL for Package Body BEN_EPR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPR_INS" as
/* $Header: beeprrhi.pkb 115.5 2002/12/09 12:52:58 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epr_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_epr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_epr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_enrt_prem
  --
  insert into ben_enrt_prem
  (	enrt_prem_id,
	val,
	uom,
	elig_per_elctbl_chc_id,
	enrt_bnft_id,
	actl_prem_id,
	business_group_id,
	epr_attribute_category,
	epr_attribute1,
	epr_attribute2,
	epr_attribute3,
	epr_attribute4,
	epr_attribute5,
	epr_attribute6,
	epr_attribute7,
	epr_attribute8,
	epr_attribute9,
	epr_attribute10,
	epr_attribute11,
	epr_attribute12,
	epr_attribute13,
	epr_attribute14,
	epr_attribute15,
	epr_attribute16,
	epr_attribute17,
	epr_attribute18,
	epr_attribute19,
	epr_attribute20,
	epr_attribute21,
	epr_attribute22,
	epr_attribute23,
	epr_attribute24,
	epr_attribute25,
	epr_attribute26,
	epr_attribute27,
	epr_attribute28,
	epr_attribute29,
	epr_attribute30,
	object_version_number,
	request_id,
	program_application_id,
	program_id,
	program_update_date
  )
  Values
  (	p_rec.enrt_prem_id,
	p_rec.val,
	p_rec.uom,
	p_rec.elig_per_elctbl_chc_id,
	p_rec.enrt_bnft_id,
	p_rec.actl_prem_id,
	p_rec.business_group_id,
	p_rec.epr_attribute_category,
	p_rec.epr_attribute1,
	p_rec.epr_attribute2,
	p_rec.epr_attribute3,
	p_rec.epr_attribute4,
	p_rec.epr_attribute5,
	p_rec.epr_attribute6,
	p_rec.epr_attribute7,
	p_rec.epr_attribute8,
	p_rec.epr_attribute9,
	p_rec.epr_attribute10,
	p_rec.epr_attribute11,
	p_rec.epr_attribute12,
	p_rec.epr_attribute13,
	p_rec.epr_attribute14,
	p_rec.epr_attribute15,
	p_rec.epr_attribute16,
	p_rec.epr_attribute17,
	p_rec.epr_attribute18,
	p_rec.epr_attribute19,
	p_rec.epr_attribute20,
	p_rec.epr_attribute21,
	p_rec.epr_attribute22,
	p_rec.epr_attribute23,
	p_rec.epr_attribute24,
	p_rec.epr_attribute25,
	p_rec.epr_attribute26,
	p_rec.epr_attribute27,
	p_rec.epr_attribute28,
	p_rec.epr_attribute29,
	p_rec.epr_attribute30,
	p_rec.object_version_number,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date
  );
  --
  ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_epr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_enrt_prem_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.enrt_prem_id;
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
Procedure post_insert(p_rec in ben_epr_shd.g_rec_type) is
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
    ben_epr_rki.after_insert
      (
  p_enrt_prem_id                  =>p_rec.enrt_prem_id
 ,p_val                           =>p_rec.val
 ,p_uom                           =>p_rec.uom
 ,p_elig_per_elctbl_chc_id        =>p_rec.elig_per_elctbl_chc_id
 ,p_enrt_bnft_id                  =>p_rec.enrt_bnft_id
 ,p_actl_prem_id                  =>p_rec.actl_prem_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_epr_attribute_category        =>p_rec.epr_attribute_category
 ,p_epr_attribute1                =>p_rec.epr_attribute1
 ,p_epr_attribute2                =>p_rec.epr_attribute2
 ,p_epr_attribute3                =>p_rec.epr_attribute3
 ,p_epr_attribute4                =>p_rec.epr_attribute4
 ,p_epr_attribute5                =>p_rec.epr_attribute5
 ,p_epr_attribute6                =>p_rec.epr_attribute6
 ,p_epr_attribute7                =>p_rec.epr_attribute7
 ,p_epr_attribute8                =>p_rec.epr_attribute8
 ,p_epr_attribute9                =>p_rec.epr_attribute9
 ,p_epr_attribute10               =>p_rec.epr_attribute10
 ,p_epr_attribute11               =>p_rec.epr_attribute11
 ,p_epr_attribute12               =>p_rec.epr_attribute12
 ,p_epr_attribute13               =>p_rec.epr_attribute13
 ,p_epr_attribute14               =>p_rec.epr_attribute14
 ,p_epr_attribute15               =>p_rec.epr_attribute15
 ,p_epr_attribute16               =>p_rec.epr_attribute16
 ,p_epr_attribute17               =>p_rec.epr_attribute17
 ,p_epr_attribute18               =>p_rec.epr_attribute18
 ,p_epr_attribute19               =>p_rec.epr_attribute19
 ,p_epr_attribute20               =>p_rec.epr_attribute20
 ,p_epr_attribute21               =>p_rec.epr_attribute21
 ,p_epr_attribute22               =>p_rec.epr_attribute22
 ,p_epr_attribute23               =>p_rec.epr_attribute23
 ,p_epr_attribute24               =>p_rec.epr_attribute24
 ,p_epr_attribute25               =>p_rec.epr_attribute25
 ,p_epr_attribute26               =>p_rec.epr_attribute26
 ,p_epr_attribute27               =>p_rec.epr_attribute27
 ,p_epr_attribute28               =>p_rec.epr_attribute28
 ,p_epr_attribute29               =>p_rec.epr_attribute29
 ,p_epr_attribute30               =>p_rec.epr_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_prem'
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
  p_rec        in out nocopy ben_epr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_epr_bus.insert_validate(p_rec);
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
  p_enrt_prem_id                 out nocopy number,
  p_val                          in number           default null,
  p_uom                          in varchar2         default null,
  p_elig_per_elctbl_chc_id       in number           default null,
  p_enrt_bnft_id                 in number           default null,
  p_actl_prem_id                 in number,
  p_business_group_id            in number,
  p_epr_attribute_category       in varchar2         default null,
  p_epr_attribute1               in varchar2         default null,
  p_epr_attribute2               in varchar2         default null,
  p_epr_attribute3               in varchar2         default null,
  p_epr_attribute4               in varchar2         default null,
  p_epr_attribute5               in varchar2         default null,
  p_epr_attribute6               in varchar2         default null,
  p_epr_attribute7               in varchar2         default null,
  p_epr_attribute8               in varchar2         default null,
  p_epr_attribute9               in varchar2         default null,
  p_epr_attribute10              in varchar2         default null,
  p_epr_attribute11              in varchar2         default null,
  p_epr_attribute12              in varchar2         default null,
  p_epr_attribute13              in varchar2         default null,
  p_epr_attribute14              in varchar2         default null,
  p_epr_attribute15              in varchar2         default null,
  p_epr_attribute16              in varchar2         default null,
  p_epr_attribute17              in varchar2         default null,
  p_epr_attribute18              in varchar2         default null,
  p_epr_attribute19              in varchar2         default null,
  p_epr_attribute20              in varchar2         default null,
  p_epr_attribute21              in varchar2         default null,
  p_epr_attribute22              in varchar2         default null,
  p_epr_attribute23              in varchar2         default null,
  p_epr_attribute24              in varchar2         default null,
  p_epr_attribute25              in varchar2         default null,
  p_epr_attribute26              in varchar2         default null,
  p_epr_attribute27              in varchar2         default null,
  p_epr_attribute28              in varchar2         default null,
  p_epr_attribute29              in varchar2         default null,
  p_epr_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null
  ) is
--
  l_rec	  ben_epr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_epr_shd.convert_args
  (
  null,
  p_val,
  p_uom,
  p_elig_per_elctbl_chc_id,
  p_enrt_bnft_id,
  p_actl_prem_id,
  p_business_group_id,
  p_epr_attribute_category,
  p_epr_attribute1,
  p_epr_attribute2,
  p_epr_attribute3,
  p_epr_attribute4,
  p_epr_attribute5,
  p_epr_attribute6,
  p_epr_attribute7,
  p_epr_attribute8,
  p_epr_attribute9,
  p_epr_attribute10,
  p_epr_attribute11,
  p_epr_attribute12,
  p_epr_attribute13,
  p_epr_attribute14,
  p_epr_attribute15,
  p_epr_attribute16,
  p_epr_attribute17,
  p_epr_attribute18,
  p_epr_attribute19,
  p_epr_attribute20,
  p_epr_attribute21,
  p_epr_attribute22,
  p_epr_attribute23,
  p_epr_attribute24,
  p_epr_attribute25,
  p_epr_attribute26,
  p_epr_attribute27,
  p_epr_attribute28,
  p_epr_attribute29,
  p_epr_attribute30,
  null,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date
  );
  --
  -- Having converted the arguments into the ben_epr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_enrt_prem_id := l_rec.enrt_prem_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_epr_ins;

/
