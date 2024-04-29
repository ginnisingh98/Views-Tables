--------------------------------------------------------
--  DDL for Package Body BEN_BDI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BDI_INS" as
/* $Header: bebdirhi.pkb 120.0.12000000.2 2007/09/11 12:48:32 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bdi_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_bdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_bdi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_batch_dpnt_info
  --
  insert into ben_batch_dpnt_info
  (	batch_dpnt_id,
	benefit_action_id,
	person_id,
	pgm_id,
	pl_id,
	oipl_id,
	contact_typ_cd,
	dpnt_person_id,
	business_group_id,
	object_version_number,
	enrt_cvg_strt_dt,
	enrt_cvg_thru_dt,
	actn_cd
  )
  Values
  (	p_rec.batch_dpnt_id,
	p_rec.benefit_action_id,
	p_rec.person_id,
	p_rec.pgm_id,
	p_rec.pl_id,
	p_rec.oipl_id,
	p_rec.contact_typ_cd,
	p_rec.dpnt_person_id,
	p_rec.business_group_id,
	p_rec.object_version_number,
	p_rec.enrt_cvg_strt_dt,
	p_rec.enrt_cvg_thru_dt,
	p_rec.actn_cd
  );
  --
  ben_bdi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bdi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_bdi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bdi_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bdi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_bdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_batch_dpnt_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.batch_dpnt_id;
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
                      p_rec            in ben_bdi_shd.g_rec_type) is
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
    ben_bdi_rki.after_insert
      (p_batch_dpnt_id                 =>p_rec.batch_dpnt_id
      ,p_benefit_action_id             =>p_rec.benefit_action_id
      ,p_person_id                     =>p_rec.person_id
      ,p_pgm_id                        =>p_rec.pgm_id
      ,p_pl_id                         =>p_rec.pl_id
      ,p_oipl_id                       =>p_rec.oipl_id
      ,p_contact_typ_cd                =>p_rec.contact_typ_cd
      ,p_dpnt_person_id                =>p_rec.dpnt_person_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_enrt_cvg_strt_dt              =>p_rec.enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt              =>p_rec.enrt_cvg_thru_dt
      ,p_actn_cd                       =>p_rec.actn_cd
      ,p_effective_date                =>p_effective_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_batch_dpnt_info'
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
  p_rec        in out nocopy ben_bdi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_bdi_bus.insert_validate(p_rec,p_effective_date);
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
  post_insert(p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_batch_dpnt_id                out nocopy number,
  p_benefit_action_id            in number,
  p_person_id                    in number,
  p_pgm_id                       in number           default null,
  p_pl_id                        in number           default null,
  p_oipl_id                      in number           default null,
  p_contact_typ_cd               in varchar2         default null,
  p_dpnt_person_id               in number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy varchar2,
  p_enrt_cvg_strt_dt             in date             default null,
  p_enrt_cvg_thru_dt             in date             default null,
  p_actn_cd                      in varchar2         default null
  ) is
--
  l_rec	  ben_bdi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_bdi_shd.convert_args
  (
  null,
  p_benefit_action_id,
  p_person_id,
  p_pgm_id,
  p_pl_id,
  p_oipl_id,
  p_contact_typ_cd,
  p_dpnt_person_id,
  p_business_group_id,
  null,
  p_enrt_cvg_strt_dt,
  p_enrt_cvg_thru_dt,
  p_actn_cd
  );
  --
  -- Having converted the arguments into the ben_bdi_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_batch_dpnt_id := l_rec.batch_dpnt_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_bdi_ins;

/
