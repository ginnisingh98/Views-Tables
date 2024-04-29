--------------------------------------------------------
--  DDL for Package Body BEN_CRT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRT_INS" as
/* $Header: becrtrhi.pkb 115.11 2004/06/22 07:52:16 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crt_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_crt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_crt_ordr
  --
  insert into ben_crt_ordr
  (	crt_ordr_id,
	crt_ordr_typ_cd,
	apls_perd_endg_dt,
	apls_perd_strtg_dt,
	crt_ident,
	description,
	detd_qlfd_ordr_dt,
	issue_dt,
	qdro_amt,
	qdro_dstr_mthd_cd,
	qdro_pct,
	rcvd_dt,
	uom,
	crt_issng,
	pl_id,
	person_id,
	business_group_id,
	crt_attribute_category,
	crt_attribute1,
	crt_attribute2,
	crt_attribute3,
	crt_attribute4,
	crt_attribute5,
	crt_attribute6,
	crt_attribute7,
	crt_attribute8,
	crt_attribute9,
	crt_attribute10,
	crt_attribute11,
	crt_attribute12,
	crt_attribute13,
	crt_attribute14,
	crt_attribute15,
	crt_attribute16,
	crt_attribute17,
	crt_attribute18,
	crt_attribute19,
	crt_attribute20,
	crt_attribute21,
	crt_attribute22,
	crt_attribute23,
	crt_attribute24,
	crt_attribute25,
	crt_attribute26,
	crt_attribute27,
	crt_attribute28,
	crt_attribute29,
	crt_attribute30,
	object_version_number,
	qdro_num_pymt_val,
	qdro_per_perd_cd,
	pl_typ_id
  )
  Values
  (	p_rec.crt_ordr_id,
	p_rec.crt_ordr_typ_cd,
	p_rec.apls_perd_endg_dt,
	p_rec.apls_perd_strtg_dt,
	p_rec.crt_ident,
	p_rec.description,
	p_rec.detd_qlfd_ordr_dt,
	p_rec.issue_dt,
	p_rec.qdro_amt,
	p_rec.qdro_dstr_mthd_cd,
	p_rec.qdro_pct,
	p_rec.rcvd_dt,
	p_rec.uom,
	p_rec.crt_issng,
	p_rec.pl_id,
	p_rec.person_id,
	p_rec.business_group_id,
	p_rec.crt_attribute_category,
	p_rec.crt_attribute1,
	p_rec.crt_attribute2,
	p_rec.crt_attribute3,
	p_rec.crt_attribute4,
	p_rec.crt_attribute5,
	p_rec.crt_attribute6,
	p_rec.crt_attribute7,
	p_rec.crt_attribute8,
	p_rec.crt_attribute9,
	p_rec.crt_attribute10,
	p_rec.crt_attribute11,
	p_rec.crt_attribute12,
	p_rec.crt_attribute13,
	p_rec.crt_attribute14,
	p_rec.crt_attribute15,
	p_rec.crt_attribute16,
	p_rec.crt_attribute17,
	p_rec.crt_attribute18,
	p_rec.crt_attribute19,
	p_rec.crt_attribute20,
	p_rec.crt_attribute21,
	p_rec.crt_attribute22,
	p_rec.crt_attribute23,
	p_rec.crt_attribute24,
	p_rec.crt_attribute25,
	p_rec.crt_attribute26,
	p_rec.crt_attribute27,
	p_rec.crt_attribute28,
	p_rec.crt_attribute29,
	p_rec.crt_attribute30,
	p_rec.object_version_number,
	p_rec.qdro_num_pymt_val,
	p_rec.qdro_per_perd_cd,
	p_rec.pl_typ_id
  );
  --
  ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
    ben_crt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_crt_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_crt_ordr_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.crt_ordr_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< insert >------------------------------|
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
p_effective_date in date,p_rec in ben_crt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
  l_old_rec ben_crt_ler.g_crt_ler_rec  ;
  l_new_rec ben_crt_ler.g_crt_ler_rec  ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    -- Call the supporting insert validate operations
    --bug 1408379
    l_new_rec.business_group_id := p_rec.business_group_id;
    l_new_rec.person_id         := p_rec.person_id;
    l_new_rec.apls_perd_strtg_dt:= p_rec.apls_perd_strtg_dt;
    l_new_rec.apls_perd_endg_dt := p_rec.apls_perd_endg_dt;
    l_new_rec.crt_ordr_typ_cd   := p_rec.crt_ordr_typ_cd;
    l_new_rec.rcvd_dt           := p_rec.rcvd_dt;
    l_new_rec.pl_id             := p_rec.pl_id;
    l_new_rec.pl_typ_id         := p_rec.pl_typ_id;
    l_new_rec.crt_ordr_id       := p_rec.crt_ordr_id;
    --
    ben_crt_rki.after_insert
      (
  p_crt_ordr_id                   =>p_rec.crt_ordr_id
 ,p_crt_ordr_typ_cd               =>p_rec.crt_ordr_typ_cd
 ,p_apls_perd_endg_dt             =>p_rec.apls_perd_endg_dt
 ,p_apls_perd_strtg_dt            =>p_rec.apls_perd_strtg_dt
 ,p_crt_ident                     =>p_rec.crt_ident
 ,p_description                   =>p_rec.description
 ,p_detd_qlfd_ordr_dt             =>p_rec.detd_qlfd_ordr_dt
 ,p_issue_dt                      =>p_rec.issue_dt
 ,p_qdro_amt                      =>p_rec.qdro_amt
 ,p_qdro_dstr_mthd_cd             =>p_rec.qdro_dstr_mthd_cd
 ,p_qdro_pct                      =>p_rec.qdro_pct
 ,p_rcvd_dt                       =>p_rec.rcvd_dt
 ,p_uom                           =>p_rec.uom
 ,p_crt_issng                     =>p_rec.crt_issng
 ,p_pl_id                         =>p_rec.pl_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_crt_attribute_category        =>p_rec.crt_attribute_category
 ,p_crt_attribute1                =>p_rec.crt_attribute1
 ,p_crt_attribute2                =>p_rec.crt_attribute2
 ,p_crt_attribute3                =>p_rec.crt_attribute3
 ,p_crt_attribute4                =>p_rec.crt_attribute4
 ,p_crt_attribute5                =>p_rec.crt_attribute5
 ,p_crt_attribute6                =>p_rec.crt_attribute6
 ,p_crt_attribute7                =>p_rec.crt_attribute7
 ,p_crt_attribute8                =>p_rec.crt_attribute8
 ,p_crt_attribute9                =>p_rec.crt_attribute9
 ,p_crt_attribute10               =>p_rec.crt_attribute10
 ,p_crt_attribute11               =>p_rec.crt_attribute11
 ,p_crt_attribute12               =>p_rec.crt_attribute12
 ,p_crt_attribute13               =>p_rec.crt_attribute13
 ,p_crt_attribute14               =>p_rec.crt_attribute14
 ,p_crt_attribute15               =>p_rec.crt_attribute15
 ,p_crt_attribute16               =>p_rec.crt_attribute16
 ,p_crt_attribute17               =>p_rec.crt_attribute17
 ,p_crt_attribute18               =>p_rec.crt_attribute18
 ,p_crt_attribute19               =>p_rec.crt_attribute19
 ,p_crt_attribute20               =>p_rec.crt_attribute20
 ,p_crt_attribute21               =>p_rec.crt_attribute21
 ,p_crt_attribute22               =>p_rec.crt_attribute22
 ,p_crt_attribute23               =>p_rec.crt_attribute23
 ,p_crt_attribute24               =>p_rec.crt_attribute24
 ,p_crt_attribute25               =>p_rec.crt_attribute25
 ,p_crt_attribute26               =>p_rec.crt_attribute26
 ,p_crt_attribute27               =>p_rec.crt_attribute27
 ,p_crt_attribute28               =>p_rec.crt_attribute28
 ,p_crt_attribute29               =>p_rec.crt_attribute29
 ,p_crt_attribute30               =>p_rec.crt_attribute30
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_qdro_num_pymt_val             =>p_rec.qdro_num_pymt_val
 ,p_qdro_per_perd_cd              =>p_rec.qdro_per_perd_cd
 ,p_pl_typ_id                     =>p_rec.pl_typ_id
 ,p_effective_date                =>p_effective_date
      );
    --
  hr_utility.set_location('D M Modie crt ' ||hr_general.g_data_migrator_mode , 378);
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
     hr_utility.set_location(' calling ler check in iensert  ' , 1408379 );
     -- bug 1408379 the function calling moved from triiger to here
     ben_crt_ler.ler_chk(p_old => l_old_rec,
                      p_new => l_new_rec ,
                      p_effective_date => p_effective_date  );
   end if ;
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_crt_ordr'
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
  p_rec        in out nocopy ben_crt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  ben_crt_bus.insert_validate(p_rec => p_rec
  ,p_effective_date => p_effective_date);
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
  post_insert(p_rec =>  p_rec,p_effective_Date => p_effective_date);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_crt_ordr_id                  out nocopy number,
  p_crt_ordr_typ_cd              in varchar2,
  p_apls_perd_endg_dt            in date             default null,
  p_apls_perd_strtg_dt           in date             default null,
  p_crt_ident                    in varchar2         default null,
  p_description                  in varchar2         default null,
  p_detd_qlfd_ordr_dt            in date             default null,
  p_issue_dt                     in date             default null,
  p_qdro_amt                     in number           default null,
  p_qdro_dstr_mthd_cd            in varchar2         default null,
  p_qdro_pct                     in number           default null,
  p_rcvd_dt                      in date             default null,
  p_uom                          in varchar2         default null,
  p_crt_issng                    in varchar2         default null,
  p_pl_id                        in number           default null,
  p_person_id                    in number           default null,
  p_business_group_id            in number,
  p_crt_attribute_category       in varchar2         default null,
  p_crt_attribute1               in varchar2         default null,
  p_crt_attribute2               in varchar2         default null,
  p_crt_attribute3               in varchar2         default null,
  p_crt_attribute4               in varchar2         default null,
  p_crt_attribute5               in varchar2         default null,
  p_crt_attribute6               in varchar2         default null,
  p_crt_attribute7               in varchar2         default null,
  p_crt_attribute8               in varchar2         default null,
  p_crt_attribute9               in varchar2         default null,
  p_crt_attribute10              in varchar2         default null,
  p_crt_attribute11              in varchar2         default null,
  p_crt_attribute12              in varchar2         default null,
  p_crt_attribute13              in varchar2         default null,
  p_crt_attribute14              in varchar2         default null,
  p_crt_attribute15              in varchar2         default null,
  p_crt_attribute16              in varchar2         default null,
  p_crt_attribute17              in varchar2         default null,
  p_crt_attribute18              in varchar2         default null,
  p_crt_attribute19              in varchar2         default null,
  p_crt_attribute20              in varchar2         default null,
  p_crt_attribute21              in varchar2         default null,
  p_crt_attribute22              in varchar2         default null,
  p_crt_attribute23              in varchar2         default null,
  p_crt_attribute24              in varchar2         default null,
  p_crt_attribute25              in varchar2         default null,
  p_crt_attribute26              in varchar2         default null,
  p_crt_attribute27              in varchar2         default null,
  p_crt_attribute28              in varchar2         default null,
  p_crt_attribute29              in varchar2         default null,
  p_crt_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_qdro_num_pymt_val            in number           default null,
  p_qdro_per_perd_cd             in varchar2         default null,
  p_pl_typ_id                    in number           default null
  ) is
--
  l_rec	  ben_crt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_crt_shd.convert_args
  (
  null,
  p_crt_ordr_typ_cd,
  p_apls_perd_endg_dt,
  p_apls_perd_strtg_dt,
  p_crt_ident,
  p_description,
  p_detd_qlfd_ordr_dt,
  p_issue_dt,
  p_qdro_amt,
  p_qdro_dstr_mthd_cd,
  p_qdro_pct,
  p_rcvd_dt,
  p_uom,
  p_crt_issng,
  p_pl_id,
  p_person_id,
  p_business_group_id,
  p_crt_attribute_category,
  p_crt_attribute1,
  p_crt_attribute2,
  p_crt_attribute3,
  p_crt_attribute4,
  p_crt_attribute5,
  p_crt_attribute6,
  p_crt_attribute7,
  p_crt_attribute8,
  p_crt_attribute9,
  p_crt_attribute10,
  p_crt_attribute11,
  p_crt_attribute12,
  p_crt_attribute13,
  p_crt_attribute14,
  p_crt_attribute15,
  p_crt_attribute16,
  p_crt_attribute17,
  p_crt_attribute18,
  p_crt_attribute19,
  p_crt_attribute20,
  p_crt_attribute21,
  p_crt_attribute22,
  p_crt_attribute23,
  p_crt_attribute24,
  p_crt_attribute25,
  p_crt_attribute26,
  p_crt_attribute27,
  p_crt_attribute28,
  p_crt_attribute29,
  p_crt_attribute30,
  null,
  p_qdro_num_pymt_val,
  p_qdro_per_perd_cd,
  p_pl_typ_id
  );
  --
  -- Having converted the arguments into the ben_crt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_crt_ordr_id := l_rec.crt_ordr_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_crt_ins;

/
