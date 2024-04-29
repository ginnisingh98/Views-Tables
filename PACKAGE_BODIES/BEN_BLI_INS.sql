--------------------------------------------------------
--  DDL for Package Body BEN_BLI_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BLI_INS" as
/* $Header: beblirhi.pkb 115.7 2002/12/10 15:17:02 bmanyam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bli_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_bli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_bli_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_batch_ler_info
  --
  insert into ben_batch_ler_info
  (	batch_ler_id,
	benefit_action_id,
	person_id,
	ler_id,
	lf_evt_ocrd_dt,
	replcd_flag,
	crtd_flag,
	tmprl_flag,
	dltd_flag,
        open_and_clsd_flag,
        clsd_flag,
        not_crtd_flag,
        stl_actv_flag,
        clpsd_flag,
        clsn_flag,
        no_effect_flag,
        cvrge_rt_prem_flag,
	per_in_ler_id,
	business_group_id,
	object_version_number
  )
  Values
  (	p_rec.batch_ler_id,
	p_rec.benefit_action_id,
	p_rec.person_id,
	p_rec.ler_id,
	p_rec.lf_evt_ocrd_dt,
	p_rec.replcd_flag,
	p_rec.crtd_flag,
	p_rec.tmprl_flag,
	p_rec.dltd_flag,
        p_rec.open_and_clsd_flag,
        p_rec.clsd_flag,
        p_rec.not_crtd_flag,
        p_rec.stl_actv_flag,
        p_rec.clpsd_flag,
        p_rec.clsn_flag,
        p_rec.no_effect_flag,
        p_rec.cvrge_rt_prem_flag,
	p_rec.per_in_ler_id,
	p_rec.business_group_id,
	p_rec.object_version_number
  );
  --
  ben_bli_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_bli_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_bli_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_bli_shd.g_api_dml := false;   -- Unset the api dml status
    ben_bli_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_bli_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_bli_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_batch_ler_info_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.batch_ler_id;
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
p_effective_date in date,p_rec in ben_bli_shd.g_rec_type) is
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
    ben_bli_rki.after_insert
      (p_batch_ler_id                  =>p_rec.batch_ler_id
      ,p_benefit_action_id             =>p_rec.benefit_action_id
      ,p_person_id                     =>p_rec.person_id
      ,p_ler_id                        =>p_rec.ler_id
      ,p_lf_evt_ocrd_dt                =>p_rec.lf_evt_ocrd_dt
      ,p_replcd_flag                   =>p_rec.replcd_flag
      ,p_crtd_flag                     =>p_rec.crtd_flag
      ,p_tmprl_flag                    =>p_rec.tmprl_flag
      ,p_dltd_flag                     =>p_rec.dltd_flag
      ,p_open_and_clsd_flag            =>p_rec.open_and_clsd_flag
      ,p_clsd_flag                     =>p_rec.clsd_flag
      ,p_not_crtd_flag                 =>p_rec.not_crtd_flag
      ,p_stl_actv_flag                 =>p_rec.stl_actv_flag
      ,p_clpsd_flag                    =>p_rec.clpsd_flag
      ,p_clsn_flag                     =>p_rec.clsn_flag
      ,p_no_effect_flag                =>p_rec.no_effect_flag
      ,p_cvrge_rt_prem_flag            =>p_rec.cvrge_rt_prem_flag
      ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
      ,p_business_group_id             =>p_rec.business_group_id
      ,p_object_version_number         =>p_rec.object_version_number
      ,p_effective_date                =>p_effective_date);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_batch_ler_info'
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
  p_rec        in out nocopy ben_bli_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_bli_bus.insert_validate(p_rec,p_effective_date);
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
  p_batch_ler_id                 out nocopy number,
  p_benefit_action_id            in number,
  p_person_id                    in number,
  p_ler_id                       in number,
  p_lf_evt_ocrd_dt               in date,
  p_replcd_flag                  in varchar2,
  p_crtd_flag                    in varchar2,
  p_tmprl_flag                   in varchar2,
  p_dltd_flag                    in varchar2,
  p_open_and_clsd_flag           in varchar2,
  p_clsd_flag                    in varchar2,
  p_not_crtd_flag                in varchar2,
  p_stl_actv_flag                in varchar2,
  p_clpsd_flag                   in varchar2,
  p_clsn_flag                    in varchar2,
  p_no_effect_flag               in varchar2,
  p_cvrge_rt_prem_flag           in varchar2,
  p_per_in_ler_id                in number,
  p_business_group_id            in number,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_bli_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_bli_shd.convert_args
  (
  null,
  p_benefit_action_id,
  p_person_id,
  p_ler_id,
  p_lf_evt_ocrd_dt,
  p_replcd_flag,
  p_crtd_flag,
  p_tmprl_flag,
  p_dltd_flag,
  p_open_and_clsd_flag,
  p_clsd_flag,
  p_not_crtd_flag,
  p_stl_actv_flag,
  p_clpsd_flag,
  p_clsn_flag,
  p_no_effect_flag,
  p_cvrge_rt_prem_flag,
  p_per_in_ler_id,
  p_business_group_id,
  null
  );
  --
  -- Having converted the arguments into the ben_bli_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_batch_ler_id := l_rec.batch_ler_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_bli_ins;

/