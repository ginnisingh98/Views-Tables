--------------------------------------------------------
--  DDL for Package Body PQH_WDT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WDT_INS" as
/* $Header: pqwdtrhi.pkb 120.0.12000000.1 2007/01/17 00:29:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wdt_ins.';  -- Global package name
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
--   2) To insert the row into the schema.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_worksheet_details
  --
  insert into pqh_worksheet_details
  (	worksheet_detail_id,
	worksheet_id,
	organization_id,
	job_id,
	position_id,
	grade_id,
	position_transaction_id,
	budget_detail_id,
	parent_worksheet_detail_id,
	user_id,
	action_cd,
	budget_unit1_percent,
	budget_unit1_value,
	budget_unit2_percent,
	budget_unit2_value,
	budget_unit3_percent,
	budget_unit3_value,
	object_version_number,
	budget_unit1_value_type_cd,
	budget_unit2_value_type_cd,
	budget_unit3_value_type_cd,
	status,
	budget_unit1_available,
	budget_unit2_available,
	budget_unit3_available,
	old_unit1_value,
	old_unit2_value,
	old_unit3_value,
	defer_flag,
	propagation_method
  )
  Values
  (	p_rec.worksheet_detail_id,
	p_rec.worksheet_id,
	p_rec.organization_id,
	p_rec.job_id,
	p_rec.position_id,
	p_rec.grade_id,
	p_rec.position_transaction_id,
	p_rec.budget_detail_id,
	p_rec.parent_worksheet_detail_id,
	p_rec.user_id,
	p_rec.action_cd,
	p_rec.budget_unit1_percent,
	p_rec.budget_unit1_value,
	p_rec.budget_unit2_percent,
	p_rec.budget_unit2_value,
	p_rec.budget_unit3_percent,
	p_rec.budget_unit3_value,
	p_rec.object_version_number,
	p_rec.budget_unit1_value_type_cd,
	p_rec.budget_unit2_value_type_cd,
	p_rec.budget_unit3_value_type_cd,
	p_rec.status,
	p_rec.budget_unit1_available,
	p_rec.budget_unit2_available,
	p_rec.budget_unit3_available,
	p_rec.old_unit1_value,
	p_rec.old_unit2_value,
	p_rec.old_unit3_value,
	p_rec.defer_flag,
	p_rec.propagation_method
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_wdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_wdt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_wdt_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_wdt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_worksheet_details_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.worksheet_detail_id;
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
p_effective_date in date,p_rec in pqh_wdt_shd.g_rec_type) is
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
    pqh_wdt_rki.after_insert
      (
  p_worksheet_detail_id           =>p_rec.worksheet_detail_id
 ,p_worksheet_id                  =>p_rec.worksheet_id
 ,p_organization_id               =>p_rec.organization_id
 ,p_job_id                        =>p_rec.job_id
 ,p_position_id                   =>p_rec.position_id
 ,p_grade_id                      =>p_rec.grade_id
 ,p_position_transaction_id       =>p_rec.position_transaction_id
 ,p_budget_detail_id              =>p_rec.budget_detail_id
 ,p_parent_worksheet_detail_id    =>p_rec.parent_worksheet_detail_id
 ,p_user_id                       =>p_rec.user_id
 ,p_action_cd                     =>p_rec.action_cd
 ,p_budget_unit1_percent          =>p_rec.budget_unit1_percent
 ,p_budget_unit1_value            =>p_rec.budget_unit1_value
 ,p_budget_unit2_percent          =>p_rec.budget_unit2_percent
 ,p_budget_unit2_value            =>p_rec.budget_unit2_value
 ,p_budget_unit3_percent          =>p_rec.budget_unit3_percent
 ,p_budget_unit3_value            =>p_rec.budget_unit3_value
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_unit1_value_type_cd    =>p_rec.budget_unit1_value_type_cd
 ,p_budget_unit2_value_type_cd    =>p_rec.budget_unit2_value_type_cd
 ,p_budget_unit3_value_type_cd    =>p_rec.budget_unit3_value_type_cd
 ,p_status                        =>p_rec.status
 ,p_budget_unit1_available        =>p_rec.budget_unit1_available
 ,p_budget_unit2_available        =>p_rec.budget_unit2_available
 ,p_budget_unit3_available        =>p_rec.budget_unit3_available
 ,p_old_unit1_value               =>p_rec.old_unit1_value
 ,p_old_unit2_value               =>p_rec.old_unit2_value
 ,p_old_unit3_value               =>p_rec.old_unit3_value
 ,p_defer_flag                    =>p_rec.defer_flag
 ,p_propagation_method            =>p_rec.propagation_method
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheet_details'
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
  p_rec        in out nocopy pqh_wdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_wdt_bus.insert_validate(p_rec
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
  p_worksheet_detail_id          out nocopy number,
  p_worksheet_id                 in number,
  p_organization_id              in number           default null,
  p_job_id                       in number           default null,
  p_position_id                  in number           default null,
  p_grade_id                     in number           default null,
  p_position_transaction_id      in number           default null,
  p_budget_detail_id             in number           default null,
  p_parent_worksheet_detail_id   in number           default null,
  p_user_id                      in number           default null,
  p_action_cd                    in varchar2         default null,
  p_budget_unit1_percent         in number           default null,
  p_budget_unit1_value           in number           default null,
  p_budget_unit2_percent         in number           default null,
  p_budget_unit2_value           in number           default null,
  p_budget_unit3_percent         in number           default null,
  p_budget_unit3_value           in number           default null,
  p_object_version_number        out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default null,
  p_budget_unit2_value_type_cd   in varchar2         default null,
  p_budget_unit3_value_type_cd   in varchar2         default null,
  p_status                       in varchar2         default null,
  p_budget_unit1_available       in number           default null,
  p_budget_unit2_available       in number           default null,
  p_budget_unit3_available       in number           default null,
  p_old_unit1_value              in number           default null,
  p_old_unit2_value              in number           default null,
  p_old_unit3_value              in number           default null,
  p_defer_flag                   in varchar2         default null,
  p_propagation_method           in varchar2         default null
  ) is
--
  l_rec	  pqh_wdt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_wdt_shd.convert_args
  (
  null,
  p_worksheet_id,
  p_organization_id,
  p_job_id,
  p_position_id,
  p_grade_id,
  p_position_transaction_id,
  p_budget_detail_id,
  p_parent_worksheet_detail_id,
  p_user_id,
  p_action_cd,
  p_budget_unit1_percent,
  p_budget_unit1_value,
  p_budget_unit2_percent,
  p_budget_unit2_value,
  p_budget_unit3_percent,
  p_budget_unit3_value,
  null,
  p_budget_unit1_value_type_cd,
  p_budget_unit2_value_type_cd,
  p_budget_unit3_value_type_cd,
  p_status,
  p_budget_unit1_available,
  p_budget_unit2_available,
  p_budget_unit3_available,
  p_old_unit1_value,
  p_old_unit2_value,
  p_old_unit3_value,
  p_defer_flag,
  p_propagation_method
  );
  --
  -- Having converted the arguments into the pqh_wdt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_worksheet_detail_id := l_rec.worksheet_detail_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_wdt_ins;

/