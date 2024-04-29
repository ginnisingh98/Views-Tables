--------------------------------------------------------
--  DDL for Package Body BEN_EGD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGD_INS" as
/* $Header: beegdrhi.pkb 120.0.12010000.2 2008/08/05 14:24:02 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egd_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_egd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_egd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_elig_dpnt
  --
  insert into ben_elig_dpnt
  (	elig_dpnt_id,
	create_dt,
	elig_strt_dt,
	elig_thru_dt,
	ovrdn_flag,
	ovrdn_thru_dt,
	inelg_rsn_cd,
	dpnt_inelig_flag,
	elig_per_elctbl_chc_id,
	per_in_ler_id,
	elig_per_id,
	elig_per_opt_id,
	elig_cvrd_dpnt_id,
	dpnt_person_id,
	business_group_id,
	egd_attribute_category,
	egd_attribute1,
	egd_attribute2,
	egd_attribute3,
	egd_attribute4,
	egd_attribute5,
	egd_attribute6,
	egd_attribute7,
	egd_attribute8,
	egd_attribute9,
	egd_attribute10,
	egd_attribute11,
	egd_attribute12,
	egd_attribute13,
	egd_attribute14,
	egd_attribute15,
	egd_attribute16,
	egd_attribute17,
	egd_attribute18,
	egd_attribute19,
	egd_attribute20,
	egd_attribute21,
	egd_attribute22,
	egd_attribute23,
	egd_attribute24,
	egd_attribute25,
	egd_attribute26,
	egd_attribute27,
	egd_attribute28,
	egd_attribute29,
	egd_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
  )
  Values
  (	p_rec.elig_dpnt_id,
	p_rec.create_dt,
	p_rec.elig_strt_dt,
	p_rec.elig_thru_dt,
	p_rec.ovrdn_flag,
	p_rec.ovrdn_thru_dt,
	p_rec.inelg_rsn_cd,
	p_rec.dpnt_inelig_flag,
	p_rec.elig_per_elctbl_chc_id,
	p_rec.per_in_ler_id,
	p_rec.elig_per_id,
	p_rec.elig_per_opt_id,
	p_rec.elig_cvrd_dpnt_id,
	p_rec.dpnt_person_id,
	p_rec.business_group_id,
	p_rec.egd_attribute_category,
	p_rec.egd_attribute1,
	p_rec.egd_attribute2,
	p_rec.egd_attribute3,
	p_rec.egd_attribute4,
	p_rec.egd_attribute5,
	p_rec.egd_attribute6,
	p_rec.egd_attribute7,
	p_rec.egd_attribute8,
	p_rec.egd_attribute9,
	p_rec.egd_attribute10,
	p_rec.egd_attribute11,
	p_rec.egd_attribute12,
	p_rec.egd_attribute13,
	p_rec.egd_attribute14,
	p_rec.egd_attribute15,
	p_rec.egd_attribute16,
	p_rec.egd_attribute17,
	p_rec.egd_attribute18,
	p_rec.egd_attribute19,
	p_rec.egd_attribute20,
	p_rec.egd_attribute21,
	p_rec.egd_attribute22,
	p_rec.egd_attribute23,
	p_rec.egd_attribute24,
	p_rec.egd_attribute25,
	p_rec.egd_attribute26,
	p_rec.egd_attribute27,
	p_rec.egd_attribute28,
	p_rec.egd_attribute29,
	p_rec.egd_attribute30,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.object_version_number
  );
  --
  ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
    ben_egd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_egd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_egd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_elig_dpnt_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.elig_dpnt_id;
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
p_effective_date in date,p_rec in ben_egd_shd.g_rec_type) is
  --
  l_proc  varchar2(72) := g_package||'post_insert';
  --
  l_old_rec               ben_egd_ler.g_egd_ler_rec;
  l_new_rec               ben_egd_ler.g_egd_ler_rec;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Life event trigger
  --
  l_old_rec.business_group_id := null;
  l_old_rec.dpnt_person_id := null;
  l_old_rec.elig_strt_dt :=null;
  l_old_rec.elig_thru_dt := null;
  l_old_rec.dpnt_inelig_flag := null;
  l_old_rec.ovrdn_thru_dt := null;
  l_old_rec.ovrdn_flag := null;
  l_old_rec.create_dt := null;
  --
  l_new_rec.business_group_id := p_rec.business_group_id;
  l_new_rec.dpnt_person_id := p_rec.dpnt_person_id;
  l_new_rec.elig_strt_dt := p_rec.elig_strt_dt;
  l_new_rec.elig_thru_dt := p_rec.elig_thru_dt;
  l_new_rec.dpnt_inelig_flag := p_rec.dpnt_inelig_flag;
  l_new_rec.ovrdn_thru_dt := p_rec.ovrdn_thru_dt;
  l_new_rec.ovrdn_flag := p_rec.ovrdn_flag;
  l_new_rec.create_dt := p_rec.create_dt;
  l_new_rec.per_in_ler_id := p_rec.per_in_ler_id; --Bug 5630251
  --
  ben_egd_ler.ler_chk(l_old_rec,l_new_rec,p_effective_date);
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_egd_rki.after_insert
      (
  p_elig_dpnt_id                  =>p_rec.elig_dpnt_id
 ,p_create_dt                     =>p_rec.create_dt
 ,p_elig_strt_dt                  =>p_rec.elig_strt_dt
 ,p_elig_thru_dt                  =>p_rec.elig_thru_dt
 ,p_ovrdn_flag                    =>p_rec.ovrdn_flag
 ,p_ovrdn_thru_dt                 =>p_rec.ovrdn_thru_dt
 ,p_inelg_rsn_cd                  =>p_rec.inelg_rsn_cd
 ,p_dpnt_inelig_flag              =>p_rec.dpnt_inelig_flag
 ,p_elig_per_elctbl_chc_id        =>p_rec.elig_per_elctbl_chc_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_elig_per_id                   =>p_rec.elig_per_id
 ,p_elig_per_opt_id               =>p_rec.elig_per_opt_id
 ,p_elig_cvrd_dpnt_id             =>p_rec.elig_cvrd_dpnt_id
 ,p_dpnt_person_id                =>p_rec.dpnt_person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_egd_attribute_category        =>p_rec.egd_attribute_category
 ,p_egd_attribute1                =>p_rec.egd_attribute1
 ,p_egd_attribute2                =>p_rec.egd_attribute2
 ,p_egd_attribute3                =>p_rec.egd_attribute3
 ,p_egd_attribute4                =>p_rec.egd_attribute4
 ,p_egd_attribute5                =>p_rec.egd_attribute5
 ,p_egd_attribute6                =>p_rec.egd_attribute6
 ,p_egd_attribute7                =>p_rec.egd_attribute7
 ,p_egd_attribute8                =>p_rec.egd_attribute8
 ,p_egd_attribute9                =>p_rec.egd_attribute9
 ,p_egd_attribute10               =>p_rec.egd_attribute10
 ,p_egd_attribute11               =>p_rec.egd_attribute11
 ,p_egd_attribute12               =>p_rec.egd_attribute12
 ,p_egd_attribute13               =>p_rec.egd_attribute13
 ,p_egd_attribute14               =>p_rec.egd_attribute14
 ,p_egd_attribute15               =>p_rec.egd_attribute15
 ,p_egd_attribute16               =>p_rec.egd_attribute16
 ,p_egd_attribute17               =>p_rec.egd_attribute17
 ,p_egd_attribute18               =>p_rec.egd_attribute18
 ,p_egd_attribute19               =>p_rec.egd_attribute19
 ,p_egd_attribute20               =>p_rec.egd_attribute20
 ,p_egd_attribute21               =>p_rec.egd_attribute21
 ,p_egd_attribute22               =>p_rec.egd_attribute22
 ,p_egd_attribute23               =>p_rec.egd_attribute23
 ,p_egd_attribute24               =>p_rec.egd_attribute24
 ,p_egd_attribute25               =>p_rec.egd_attribute25
 ,p_egd_attribute26               =>p_rec.egd_attribute26
 ,p_egd_attribute27               =>p_rec.egd_attribute27
 ,p_egd_attribute28               =>p_rec.egd_attribute28
 ,p_egd_attribute29               =>p_rec.egd_attribute29
 ,p_egd_attribute30               =>p_rec.egd_attribute30
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
        (p_module_name => 'ben_elig_dpnt'
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
  p_rec        in out nocopy ben_egd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_egd_bus.insert_validate(p_rec
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
  p_elig_dpnt_id                 out nocopy number,
  p_create_dt                    in date,
  p_elig_strt_dt                 in date             default null,
  p_elig_thru_dt                 in date             default null,
  p_ovrdn_flag                   in varchar2,
  p_ovrdn_thru_dt                in date             default null,
  p_inelg_rsn_cd                 in varchar2         default null,
  p_dpnt_inelig_flag             in varchar2,
  p_elig_per_elctbl_chc_id       in number           default null,
  p_per_in_ler_id                in number           default null,
  p_elig_per_id                  in number           default null,
  p_elig_per_opt_id              in number           default null,
  p_elig_cvrd_dpnt_id            in number           default null,
  p_dpnt_person_id               in number,
  p_business_group_id            in number,
  p_egd_attribute_category       in varchar2         default null,
  p_egd_attribute1               in varchar2         default null,
  p_egd_attribute2               in varchar2         default null,
  p_egd_attribute3               in varchar2         default null,
  p_egd_attribute4               in varchar2         default null,
  p_egd_attribute5               in varchar2         default null,
  p_egd_attribute6               in varchar2         default null,
  p_egd_attribute7               in varchar2         default null,
  p_egd_attribute8               in varchar2         default null,
  p_egd_attribute9               in varchar2         default null,
  p_egd_attribute10              in varchar2         default null,
  p_egd_attribute11              in varchar2         default null,
  p_egd_attribute12              in varchar2         default null,
  p_egd_attribute13              in varchar2         default null,
  p_egd_attribute14              in varchar2         default null,
  p_egd_attribute15              in varchar2         default null,
  p_egd_attribute16              in varchar2         default null,
  p_egd_attribute17              in varchar2         default null,
  p_egd_attribute18              in varchar2         default null,
  p_egd_attribute19              in varchar2         default null,
  p_egd_attribute20              in varchar2         default null,
  p_egd_attribute21              in varchar2         default null,
  p_egd_attribute22              in varchar2         default null,
  p_egd_attribute23              in varchar2         default null,
  p_egd_attribute24              in varchar2         default null,
  p_egd_attribute25              in varchar2         default null,
  p_egd_attribute26              in varchar2         default null,
  p_egd_attribute27              in varchar2         default null,
  p_egd_attribute28              in varchar2         default null,
  p_egd_attribute29              in varchar2         default null,
  p_egd_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_egd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_egd_shd.convert_args
  (
  null,
  p_create_dt,
  p_elig_strt_dt,
  p_elig_thru_dt,
  p_ovrdn_flag,
  p_ovrdn_thru_dt,
  p_inelg_rsn_cd,
  p_dpnt_inelig_flag,
  p_elig_per_elctbl_chc_id,
  p_per_in_ler_id,
  p_elig_per_id,
  p_elig_per_opt_id,
  p_elig_cvrd_dpnt_id,
  p_dpnt_person_id,
  p_business_group_id,
  p_egd_attribute_category,
  p_egd_attribute1,
  p_egd_attribute2,
  p_egd_attribute3,
  p_egd_attribute4,
  p_egd_attribute5,
  p_egd_attribute6,
  p_egd_attribute7,
  p_egd_attribute8,
  p_egd_attribute9,
  p_egd_attribute10,
  p_egd_attribute11,
  p_egd_attribute12,
  p_egd_attribute13,
  p_egd_attribute14,
  p_egd_attribute15,
  p_egd_attribute16,
  p_egd_attribute17,
  p_egd_attribute18,
  p_egd_attribute19,
  p_egd_attribute20,
  p_egd_attribute21,
  p_egd_attribute22,
  p_egd_attribute23,
  p_egd_attribute24,
  p_egd_attribute25,
  p_egd_attribute26,
  p_egd_attribute27,
  p_egd_attribute28,
  p_egd_attribute29,
  p_egd_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_egd_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_elig_dpnt_id := l_rec.elig_dpnt_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_egd_ins;

/
