--------------------------------------------------------
--  DDL for Package Body BEN_PIL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_INS" as
/* $Header: bepilrhi.pkb 120.3 2006/09/26 10:56:35 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pil_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_pil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_pil_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_per_in_ler
  --
  insert into ben_per_in_ler
  (	per_in_ler_id,
	per_in_ler_stat_cd,
	prvs_stat_cd,
	lf_evt_ocrd_dt,
        trgr_table_pk_id,
	procd_dt,
	strtd_dt,
	voidd_dt,
	bckt_dt,
	clsd_dt,
	ntfn_dt,
	ptnl_ler_for_per_id,
	bckt_per_in_ler_id,
	ler_id,
	person_id,
	business_group_id,
        ASSIGNMENT_ID,
        WS_MGR_ID,
        GROUP_PL_ID,
        MGR_OVRID_PERSON_ID,
        MGR_OVRID_DT,
	pil_attribute_category,
	pil_attribute1,
	pil_attribute2,
	pil_attribute3,
	pil_attribute4,
	pil_attribute5,
	pil_attribute6,
	pil_attribute7,
	pil_attribute8,
	pil_attribute9,
	pil_attribute10,
	pil_attribute11,
	pil_attribute12,
	pil_attribute13,
	pil_attribute14,
	pil_attribute15,
	pil_attribute16,
	pil_attribute17,
	pil_attribute18,
	pil_attribute19,
	pil_attribute20,
	pil_attribute21,
	pil_attribute22,
	pil_attribute23,
	pil_attribute24,
	pil_attribute25,
	pil_attribute26,
	pil_attribute27,
	pil_attribute28,
	pil_attribute29,
	pil_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
  )
  Values
  (	p_rec.per_in_ler_id,
	p_rec.per_in_ler_stat_cd,
	p_rec.prvs_stat_cd,
	p_rec.lf_evt_ocrd_dt,
        p_rec.trgr_table_pk_id,
	p_rec.procd_dt,
	p_rec.strtd_dt,
	p_rec.voidd_dt,
	p_rec.bckt_dt,
	p_rec.clsd_dt,
	p_rec.ntfn_dt,
	p_rec.ptnl_ler_for_per_id,
	p_rec.bckt_per_in_ler_id,
	p_rec.ler_id,
	p_rec.person_id,
	p_rec.business_group_id,
        p_rec.ASSIGNMENT_ID,
        p_rec.WS_MGR_ID,
        p_rec.GROUP_PL_ID,
        p_rec.MGR_OVRID_PERSON_ID,
        p_rec.MGR_OVRID_DT,
	p_rec.pil_attribute_category,
	p_rec.pil_attribute1,
	p_rec.pil_attribute2,
	p_rec.pil_attribute3,
	p_rec.pil_attribute4,
	p_rec.pil_attribute5,
	p_rec.pil_attribute6,
	p_rec.pil_attribute7,
	p_rec.pil_attribute8,
	p_rec.pil_attribute9,
	p_rec.pil_attribute10,
	p_rec.pil_attribute11,
	p_rec.pil_attribute12,
	p_rec.pil_attribute13,
	p_rec.pil_attribute14,
	p_rec.pil_attribute15,
	p_rec.pil_attribute16,
	p_rec.pil_attribute17,
	p_rec.pil_attribute18,
	p_rec.pil_attribute19,
	p_rec.pil_attribute20,
	p_rec.pil_attribute21,
	p_rec.pil_attribute22,
	p_rec.pil_attribute23,
	p_rec.pil_attribute24,
	p_rec.pil_attribute25,
	p_rec.pil_attribute26,
	p_rec.pil_attribute27,
	p_rec.pil_attribute28,
	p_rec.pil_attribute29,
	p_rec.pil_attribute30,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.object_version_number
  );
  --
  ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pil_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pil_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_pil_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_per_in_ler_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.per_in_ler_id;
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
p_effective_date in date,p_rec in ben_pil_shd.g_rec_type) is
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
    ben_pil_rki.after_insert
      (
  p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_per_in_ler_stat_cd            =>p_rec.per_in_ler_stat_cd
 ,p_prvs_stat_cd                  =>p_rec.prvs_stat_cd
 ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id              =>p_rec.trgr_table_pk_id
 ,p_procd_dt                      =>p_rec.procd_dt
 ,p_strtd_dt                      =>p_rec.strtd_dt
 ,p_voidd_dt                      =>p_rec.voidd_dt
 ,p_bckt_dt                       =>p_rec.bckt_dt
 ,p_clsd_dt                       =>p_rec.clsd_dt
 ,p_ntfn_dt                       =>p_rec.ntfn_dt
 ,p_ptnl_ler_for_per_id           =>p_rec.ptnl_ler_for_per_id
 ,p_bckt_per_in_ler_id            =>p_rec.bckt_per_in_ler_id
 ,p_ler_id                        =>p_rec.ler_id
 ,p_person_id                     =>p_rec.person_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_ASSIGNMENT_ID                 =>  p_rec.ASSIGNMENT_ID
 ,p_WS_MGR_ID                     =>  p_rec.WS_MGR_ID
 ,p_GROUP_PL_ID                   =>  p_rec.GROUP_PL_ID
 ,p_MGR_OVRID_PERSON_ID           =>  p_rec.MGR_OVRID_PERSON_ID
 ,p_MGR_OVRID_DT                  =>  p_rec.MGR_OVRID_DT
 ,p_pil_attribute_category        =>p_rec.pil_attribute_category
 ,p_pil_attribute1                =>p_rec.pil_attribute1
 ,p_pil_attribute2                =>p_rec.pil_attribute2
 ,p_pil_attribute3                =>p_rec.pil_attribute3
 ,p_pil_attribute4                =>p_rec.pil_attribute4
 ,p_pil_attribute5                =>p_rec.pil_attribute5
 ,p_pil_attribute6                =>p_rec.pil_attribute6
 ,p_pil_attribute7                =>p_rec.pil_attribute7
 ,p_pil_attribute8                =>p_rec.pil_attribute8
 ,p_pil_attribute9                =>p_rec.pil_attribute9
 ,p_pil_attribute10               =>p_rec.pil_attribute10
 ,p_pil_attribute11               =>p_rec.pil_attribute11
 ,p_pil_attribute12               =>p_rec.pil_attribute12
 ,p_pil_attribute13               =>p_rec.pil_attribute13
 ,p_pil_attribute14               =>p_rec.pil_attribute14
 ,p_pil_attribute15               =>p_rec.pil_attribute15
 ,p_pil_attribute16               =>p_rec.pil_attribute16
 ,p_pil_attribute17               =>p_rec.pil_attribute17
 ,p_pil_attribute18               =>p_rec.pil_attribute18
 ,p_pil_attribute19               =>p_rec.pil_attribute19
 ,p_pil_attribute20               =>p_rec.pil_attribute20
 ,p_pil_attribute21               =>p_rec.pil_attribute21
 ,p_pil_attribute22               =>p_rec.pil_attribute22
 ,p_pil_attribute23               =>p_rec.pil_attribute23
 ,p_pil_attribute24               =>p_rec.pil_attribute24
 ,p_pil_attribute25               =>p_rec.pil_attribute25
 ,p_pil_attribute26               =>p_rec.pil_attribute26
 ,p_pil_attribute27               =>p_rec.pil_attribute27
 ,p_pil_attribute28               =>p_rec.pil_attribute28
 ,p_pil_attribute29               =>p_rec.pil_attribute29
 ,p_pil_attribute30               =>p_rec.pil_attribute30
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
        (p_module_name => 'ben_per_in_ler'
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
  p_rec        in out nocopy ben_pil_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_pil_bus.insert_validate(p_rec
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
  p_per_in_ler_id                out nocopy number,
  p_per_in_ler_stat_cd           in varchar2         default null,
  p_prvs_stat_cd                 in varchar2         default null,
  p_lf_evt_ocrd_dt               in date,
  p_trgr_table_pk_id             in number           default null,
  p_procd_dt                     in date             default null,
  p_strtd_dt                     in date             default null,
  p_voidd_dt                     in date             default null,
  p_bckt_dt                      in date             default null,
  p_clsd_dt                      in date             default null,
  p_ntfn_dt                      in date             default null,
  p_ptnl_ler_for_per_id          in number,
  p_bckt_per_in_ler_id           in number,
  p_ler_id                       in number,
  p_person_id                    in number,
  p_business_group_id            in number,
  p_ASSIGNMENT_ID                  in  number    default null,
  p_WS_MGR_ID                      in  number    default null,
  p_GROUP_PL_ID                    in  number    default null,
  p_MGR_OVRID_PERSON_ID            in  number    default null,
  p_MGR_OVRID_DT                   in  date      default null,
  p_pil_attribute_category       in varchar2         default null,
  p_pil_attribute1               in varchar2         default null,
  p_pil_attribute2               in varchar2         default null,
  p_pil_attribute3               in varchar2         default null,
  p_pil_attribute4               in varchar2         default null,
  p_pil_attribute5               in varchar2         default null,
  p_pil_attribute6               in varchar2         default null,
  p_pil_attribute7               in varchar2         default null,
  p_pil_attribute8               in varchar2         default null,
  p_pil_attribute9               in varchar2         default null,
  p_pil_attribute10              in varchar2         default null,
  p_pil_attribute11              in varchar2         default null,
  p_pil_attribute12              in varchar2         default null,
  p_pil_attribute13              in varchar2         default null,
  p_pil_attribute14              in varchar2         default null,
  p_pil_attribute15              in varchar2         default null,
  p_pil_attribute16              in varchar2         default null,
  p_pil_attribute17              in varchar2         default null,
  p_pil_attribute18              in varchar2         default null,
  p_pil_attribute19              in varchar2         default null,
  p_pil_attribute20              in varchar2         default null,
  p_pil_attribute21              in varchar2         default null,
  p_pil_attribute22              in varchar2         default null,
  p_pil_attribute23              in varchar2         default null,
  p_pil_attribute24              in varchar2         default null,
  p_pil_attribute25              in varchar2         default null,
  p_pil_attribute26              in varchar2         default null,
  p_pil_attribute27              in varchar2         default null,
  p_pil_attribute28              in varchar2         default null,
  p_pil_attribute29              in varchar2         default null,
  p_pil_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_pil_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pil_shd.convert_args
  (
  null,
  p_per_in_ler_stat_cd,
  p_prvs_stat_cd,
  p_lf_evt_ocrd_dt,
  p_trgr_table_pk_id,
  p_procd_dt,
  p_strtd_dt,
  p_voidd_dt,
  p_bckt_dt,
  p_clsd_dt,
  p_ntfn_dt,
  p_ptnl_ler_for_per_id,
  p_bckt_per_in_ler_id ,
  p_ler_id,
  p_person_id,
  p_business_group_id,
    p_ASSIGNMENT_ID,
    p_WS_MGR_ID,
    p_GROUP_PL_ID,
    p_MGR_OVRID_PERSON_ID,
    p_MGR_OVRID_DT,
  p_pil_attribute_category,
  p_pil_attribute1,
  p_pil_attribute2,
  p_pil_attribute3,
  p_pil_attribute4,
  p_pil_attribute5,
  p_pil_attribute6,
  p_pil_attribute7,
  p_pil_attribute8,
  p_pil_attribute9,
  p_pil_attribute10,
  p_pil_attribute11,
  p_pil_attribute12,
  p_pil_attribute13,
  p_pil_attribute14,
  p_pil_attribute15,
  p_pil_attribute16,
  p_pil_attribute17,
  p_pil_attribute18,
  p_pil_attribute19,
  p_pil_attribute20,
  p_pil_attribute21,
  p_pil_attribute22,
  p_pil_attribute23,
  p_pil_attribute24,
  p_pil_attribute25,
  p_pil_attribute26,
  p_pil_attribute27,
  p_pil_attribute28,
  p_pil_attribute29,
  p_pil_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_pil_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_per_in_ler_id := l_rec.per_in_ler_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pil_ins;

/
