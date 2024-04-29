--------------------------------------------------------
--  DDL for Package Body BEN_XRS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRS_INS" as
/* $Header: bexrsrhi.pkb 120.1 2005/06/08 14:21:35 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrs_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_xrs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_xrs_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_ext_rslt
  --
  insert into ben_ext_rslt
  (	ext_rslt_id,
	run_strt_dt,
	run_end_dt,
	ext_stat_cd,
	tot_rec_num,
	tot_per_num,
	tot_err_num,
	eff_dt,
	ext_strt_dt,
	ext_end_dt,
	output_name,
	drctry_name,
	ext_dfn_id,
	business_group_id,
	program_application_id,
	program_id,
	program_update_date,
	request_id,
        output_type      ,
        xdo_template_id ,
	object_version_number
  )
  Values
  (	p_rec.ext_rslt_id,
	p_rec.run_strt_dt,
	p_rec.run_end_dt,
	p_rec.ext_stat_cd,
	p_rec.tot_rec_num,
	p_rec.tot_per_num,
	p_rec.tot_err_num,
	p_rec.eff_dt,
	p_rec.ext_strt_dt,
	p_rec.ext_end_dt,
	p_rec.output_name,
	p_rec.drctry_name,
	p_rec.ext_dfn_id,
	p_rec.business_group_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.request_id,
        p_rec.output_type  ,
        p_rec.xdo_template_id ,
	p_rec.object_version_number
  );
  --
  ben_xrs_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_xrs_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_xrs_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_xrs_shd.g_api_dml := false;   -- Unset the api dml status
    ben_xrs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_xrs_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_xrs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
cursor c1 is
    select ben_ext_rslt_s.nextval
    from sys.dual;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into p_rec.ext_rslt_id;
  close c1;
  --
  --
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
p_effective_date in date,p_rec in ben_xrs_shd.g_rec_type) is
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
    ben_xrs_rki.after_insert
      (
  p_ext_rslt_id                   =>p_rec.ext_rslt_id
 ,p_run_strt_dt                   =>p_rec.run_strt_dt
 ,p_run_end_dt                    =>p_rec.run_end_dt
 ,p_ext_stat_cd                   =>p_rec.ext_stat_cd
 ,p_tot_rec_num                   =>p_rec.tot_rec_num
 ,p_tot_per_num                   =>p_rec.tot_per_num
 ,p_tot_err_num                   =>p_rec.tot_err_num
 ,p_eff_dt                        =>p_rec.eff_dt
 ,p_ext_strt_dt                   =>p_rec.ext_strt_dt
 ,p_ext_end_dt                    =>p_rec.ext_end_dt
 ,p_output_name                   =>p_rec.output_name
 ,p_drctry_name                   =>p_rec.drctry_name
 ,p_ext_dfn_id                    =>p_rec.ext_dfn_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_request_id                    =>p_rec.request_id
 ,p_output_type                   =>p_rec.output_type
 ,p_xdo_template_id               =>p_rec.xdo_template_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ext_rslt'
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
  p_rec        in out nocopy ben_xrs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_xrs_bus.insert_validate(p_rec
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
  p_ext_rslt_id                  out nocopy number,
  p_run_strt_dt                  in date             default null,
  p_run_end_dt                   in date             default null,
  p_ext_stat_cd                  in varchar2         default null,
  p_tot_rec_num                  in number           default null,
  p_tot_per_num                  in number           default null,
  p_tot_err_num                  in number           default null,
  p_eff_dt                       in date             default null,
  p_ext_strt_dt                  in date             default null,
  p_ext_end_dt                   in date             default null,
  p_output_name                  in varchar2         default null,
  p_drctry_name                  in varchar2         default null,
  p_ext_dfn_id                   in number,
  p_business_group_id            in number,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_request_id                   in number           default null,
  p_output_type                  in varchar2         default null,
  p_xdo_template_id              in number           default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_xrs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_xrs_shd.convert_args
  (
  null,
  p_run_strt_dt,
  p_run_end_dt,
  p_ext_stat_cd,
  p_tot_rec_num,
  p_tot_per_num,
  p_tot_err_num,
  p_eff_dt,
  p_ext_strt_dt,
  p_ext_end_dt,
  p_output_name,
  p_drctry_name,
  p_ext_dfn_id,
  p_business_group_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_request_id,
  p_output_type,
  p_xdo_template_id,
  null
  );
  --
  -- Having converted the arguments into the ben_xrs_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_ext_rslt_id := l_rec.ext_rslt_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_xrs_ins;

/
