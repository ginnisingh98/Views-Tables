--------------------------------------------------------
--  DDL for Package Body BEN_PPL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_INS" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppl_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_ppl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ptnl_ler_for_per
  --
  insert into ben_ptnl_ler_for_per
  (	ptnl_ler_for_per_id,
   	csd_by_ptnl_ler_for_per_id,
	lf_evt_ocrd_dt,
        trgr_table_pk_id,
	ptnl_ler_for_per_stat_cd,
	ptnl_ler_for_per_src_cd,
        mnl_dt,
        enrt_perd_id,
	ntfn_dt,
	dtctd_dt,
	procd_dt,
	unprocd_dt,
	voidd_dt,
	mnlo_dt,
	ler_id,
	person_id,
	business_group_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
  )
  Values
  (	p_rec.ptnl_ler_for_per_id,
   	p_rec.csd_by_ptnl_ler_for_per_id,
	p_rec.lf_evt_ocrd_dt,
        p_rec.trgr_table_pk_id,
	p_rec.ptnl_ler_for_per_stat_cd,
	p_rec.ptnl_ler_for_per_src_cd,
        p_rec.mnl_dt,
        p_rec.enrt_perd_id,
	p_rec.ntfn_dt,
	p_rec.dtctd_dt,
	p_rec.procd_dt,
	p_rec.unprocd_dt,
	p_rec.voidd_dt,
	p_rec.mnlo_dt,
	p_rec.ler_id,
	p_rec.person_id,
	p_rec.business_group_id,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.object_version_number
  );
  --
  ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_ptnl_ler_for_per_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.ptnl_ler_for_per_id;
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
                      p_rec in ben_ppl_shd.g_rec_type) is
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
    null;
    --
    ben_ppl_rki.after_insert
      (p_ptnl_ler_for_per_id           =>p_rec.ptnl_ler_for_per_id
      ,p_csd_by_ptnl_ler_for_per_id    =>p_rec.csd_by_ptnl_ler_for_per_id
      ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
      ,p_trgr_table_pk_id              =>p_rec.trgr_table_pk_id
      ,p_ptnl_ler_for_per_stat_cd      =>p_rec.ptnl_ler_for_per_stat_cd
      ,p_ptnl_ler_for_per_src_cd       =>p_rec.ptnl_ler_for_per_src_cd
      ,p_mnl_dt                        =>p_rec.mnl_dt
      ,p_enrt_perd_id                  =>p_rec.enrt_perd_id
      ,p_ntfn_dt                       =>p_rec.ntfn_dt
      ,p_dtctd_dt                      =>p_rec.dtctd_dt
      ,p_procd_dt                      =>p_rec.procd_dt
      ,p_unprocd_dt                    =>p_rec.unprocd_dt
      ,p_voidd_dt                      =>p_rec.voidd_dt
      ,p_mnlo_dt                       =>p_rec.mnlo_dt
      ,p_ler_id                        =>p_rec.ler_id
      ,p_person_id                     =>p_rec.person_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_request_id                    =>p_rec.request_id
      ,p_program_application_id        =>p_rec.program_application_id
      ,p_program_id                    =>p_rec.program_id
      ,p_program_update_date           =>p_rec.program_update_date
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_effective_date                =>p_effective_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ptnl_ler_for_per'
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
  p_rec        in out nocopy ben_ppl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_ppl_bus.insert_validate(p_rec,p_effective_date);
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
  --
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_ptnl_ler_for_per_id          out nocopy number,
  p_csd_by_ptnl_ler_for_per_id   in number,
  p_lf_evt_ocrd_dt               in date,
  p_trgr_table_pk_id             in number           default null,
  p_ptnl_ler_for_per_stat_cd     in varchar2,
  p_ptnl_ler_for_per_src_cd      in varchar2         default null,
  p_mnl_dt                       in date             default null,
  p_enrt_perd_id                 in number,
  p_ntfn_dt                      in date             default null,
  p_dtctd_dt                     in date             default null,
  p_procd_dt                     in date             default null,
  p_unprocd_dt                   in date             default null,
  p_voidd_dt                     in date             default null,
  p_mnlo_dt                      in date             default null,
  p_ler_id                       in number,
  p_person_id                    in number,
  p_business_group_id            in number,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_ppl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_ppl_shd.convert_args
  (
  null,
  p_csd_by_ptnl_ler_for_per_id,
  p_lf_evt_ocrd_dt,
  p_trgr_table_pk_id,
  p_ptnl_ler_for_per_stat_cd,
  p_ptnl_ler_for_per_src_cd,
  p_mnl_dt,
  p_enrt_perd_id,
  p_ntfn_dt,
  p_dtctd_dt,
  p_procd_dt,
  p_unprocd_dt,
  p_voidd_dt,
  p_mnlo_dt,
  p_ler_id,
  p_person_id,
  p_business_group_id,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_ppl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ptnl_ler_for_per_id := l_rec.ptnl_ler_for_per_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_ppl_ins;

/
