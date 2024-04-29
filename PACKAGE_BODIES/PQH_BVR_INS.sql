--------------------------------------------------------
--  DDL for Package Body PQH_BVR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BVR_INS" as
/* $Header: pqbvrrhi.pkb 115.10 2002/12/05 19:30:27 rpasapul ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bvr_ins.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_bvr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_budget_versions
  --
  insert into pqh_budget_versions
  (	budget_version_id,
	budget_id,
	version_number,
	date_from,
	date_to,
	transfered_to_gl_flag,
	gl_status,
	xfer_to_other_apps_cd,
	object_version_number,
	budget_unit1_value,
	budget_unit2_value,
	budget_unit3_value,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available
  )
  Values
  (	p_rec.budget_version_id,
	p_rec.budget_id,
	p_rec.version_number,
	p_rec.date_from,
	p_rec.date_to,
	p_rec.transfered_to_gl_flag,
	p_rec.gl_status,
	p_rec.xfer_to_other_apps_cd,
	p_rec.object_version_number,
	p_rec.budget_unit1_value,
	p_rec.budget_unit2_value,
	p_rec.budget_unit3_value,
	p_rec.budget_unit1_available,
	p_rec.budget_unit2_available,
	p_rec.budget_unit3_available
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_bvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_bvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_bvr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
Procedure pre_insert(p_rec  in out nocopy pqh_bvr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_budget_versions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.budget_version_id;
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
p_effective_date in date,p_rec in pqh_bvr_shd.g_rec_type) is
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
    pqh_bvr_rki.after_insert
      (
  p_budget_version_id             =>p_rec.budget_version_id
 ,p_budget_id                     =>p_rec.budget_id
 ,p_version_number                =>p_rec.version_number
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_transfered_to_gl_flag         =>p_rec.transfered_to_gl_flag
 ,p_gl_status                     =>p_rec.gl_status
 ,p_xfer_to_other_apps_cd         =>p_rec.xfer_to_other_apps_cd
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_unit1_value            =>p_rec.budget_unit1_value
 ,p_budget_unit2_value            =>p_rec.budget_unit2_value
 ,p_budget_unit3_value            =>p_rec.budget_unit3_value
 ,p_budget_unit1_available        =>p_rec.budget_unit1_available
 ,p_budget_unit2_available        =>p_rec.budget_unit2_available
 ,p_budget_unit3_available        =>p_rec.budget_unit3_available
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_budget_versions'
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
  p_rec        in out nocopy pqh_bvr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_bvr_bus.insert_validate(p_rec
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
  p_budget_version_id            out nocopy number,
  p_budget_id                    in number           default null,
  p_version_number               in number,
  p_date_from                    in date             default null,
  p_date_to                      in date             default null,
  p_transfered_to_gl_flag        in varchar2         default null,
  p_gl_status                    in varchar2         default null,
  p_xfer_to_other_apps_cd        in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_budget_unit1_value           in number           default null,
  p_budget_unit2_value           in number           default null,
  p_budget_unit3_value           in number           default null,
  p_budget_unit1_available       in number           default null,
  p_budget_unit2_available       in number           default null,
  p_budget_unit3_available       in number           default null
  ) is
--
  l_rec	  pqh_bvr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_bvr_shd.convert_args
  (
  null,
  p_budget_id,
  p_version_number,
  p_date_from,
  p_date_to,
  p_transfered_to_gl_flag,
  p_gl_status,
  p_xfer_to_other_apps_cd,
  null,
  p_budget_unit1_value,
  p_budget_unit2_value,
  p_budget_unit3_value,
  p_budget_unit1_available,
  p_budget_unit2_available,
  p_budget_unit3_available
  );
  --
  -- Having converted the arguments into the pqh_bvr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_budget_version_id := l_rec.budget_version_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_bvr_ins;

/