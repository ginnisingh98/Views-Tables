--------------------------------------------------------
--  DDL for Package Body PQH_BGT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BGT_INS" as
/* $Header: pqbgtrhi.pkb 120.1 2005/09/21 03:11:10 hmehta noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_bgt_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_bgt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_budgets
  --
  insert into pqh_budgets
  (	budget_id,
	business_group_id,
	start_organization_id,
	org_structure_version_id,
	budgeted_entity_cd,
	budget_style_cd,
	budget_name,
	period_set_name,
	budget_start_date,
	budget_end_date,
	gl_budget_name,
	psb_budget_flag,
	transfer_to_gl_flag,
	transfer_to_grants_flag,
	status,
	object_version_number,
	budget_unit1_id,
	budget_unit2_id,
	budget_unit3_id,
        gl_set_of_books_id,
        budget_unit1_aggregate,
        budget_unit2_aggregate,
        budget_unit3_aggregate,
        position_control_flag,
        valid_grade_reqd_flag,
        currency_code,
        dflt_budget_set_id
  )
  Values
  (	p_rec.budget_id,
	p_rec.business_group_id,
	p_rec.start_organization_id,
	p_rec.org_structure_version_id,
	p_rec.budgeted_entity_cd,
	p_rec.budget_style_cd,
	p_rec.budget_name,
	p_rec.period_set_name,
	p_rec.budget_start_date,
	p_rec.budget_end_date,
	p_rec.gl_budget_name,
	p_rec.psb_budget_flag,
	p_rec.transfer_to_gl_flag,
	p_rec.transfer_to_grants_flag,
	p_rec.status,
	p_rec.object_version_number,
	p_rec.budget_unit1_id,
	p_rec.budget_unit2_id,
	p_rec.budget_unit3_id,
	p_rec.gl_set_of_books_id,
        p_rec.budget_unit1_aggregate,
        p_rec.budget_unit2_aggregate,
        p_rec.budget_unit3_aggregate,
        p_rec.position_control_flag,
        p_rec.valid_grade_reqd_flag,
        p_rec.currency_code,
        p_rec.dflt_budget_set_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_bgt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_bgt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_bgt_shd.constraint_error
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
-- Also If GL Budget Name is Not Nul then transfer_to_gl_flag will to set to 'Y'
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
Procedure pre_insert(p_rec  in out nocopy pqh_bgt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_budgets_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.budget_id;
  Close C_Sel1;
  --
  -- If gl_budget_name is not null set transfer_to_gl_flag to 'Y'
  IF(p_rec.gl_budget_name is not null)
  THEN
  p_rec.transfer_to_gl_flag :='Y';
  END IF;
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
p_effective_date in date,p_rec in pqh_bgt_shd.g_rec_type) is
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
    pqh_bgt_rki.after_insert
      (
  p_budget_id                     =>p_rec.budget_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_start_organization_id         =>p_rec.start_organization_id
 ,p_org_structure_version_id      =>p_rec.org_structure_version_id
 ,p_budgeted_entity_cd            =>p_rec.budgeted_entity_cd
 ,p_budget_style_cd               =>p_rec.budget_style_cd
 ,p_budget_name                   =>p_rec.budget_name
 ,p_period_set_name               =>p_rec.period_set_name
 ,p_budget_start_date             =>p_rec.budget_start_date
 ,p_budget_end_date               =>p_rec.budget_end_date
 ,p_gl_budget_name                =>p_rec.gl_budget_name
 ,p_psb_budget_flag               =>p_rec.psb_budget_flag
 ,p_transfer_to_gl_flag           =>p_rec.transfer_to_gl_flag
 ,p_transfer_to_grants_flag       =>p_rec.transfer_to_grants_flag
 ,p_status                        =>p_rec.status
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_unit1_id               =>p_rec.budget_unit1_id
 ,p_budget_unit2_id               =>p_rec.budget_unit2_id
 ,p_budget_unit3_id               =>p_rec.budget_unit3_id
 ,p_gl_set_of_books_id            =>p_rec.gl_set_of_books_id
 ,p_budget_unit1_aggregate        =>p_rec.budget_unit1_aggregate
 ,p_budget_unit2_aggregate        =>p_rec.budget_unit2_aggregate
 ,p_budget_unit3_aggregate        =>p_rec.budget_unit3_aggregate
 ,p_position_control_flag         =>p_rec.position_control_flag
 ,p_valid_grade_reqd_flag         =>p_rec.valid_grade_reqd_flag
 ,p_currency_code                 =>p_rec.currency_code
 ,p_dflt_budget_set_id            =>p_rec.dflt_budget_set_id
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_budgets'
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
  p_rec        in out nocopy pqh_bgt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_bgt_bus.insert_validate(p_rec
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
  p_budget_id                    out nocopy number,
  p_business_group_id            in number           default null,
  p_start_organization_id        in number           default null,
  p_org_structure_version_id     in number           default null,
  p_budgeted_entity_cd           in varchar2         default null,
  p_budget_style_cd              in varchar2,
  p_budget_name                  in varchar2,
  p_period_set_name              in varchar2,
  p_budget_start_date            in date,
  p_budget_end_date              in date,
  p_gl_budget_name               in varchar2         default null,
  p_psb_budget_flag              in varchar2         default 'N',
  p_transfer_to_gl_flag          in varchar2         default null,
  p_transfer_to_grants_flag      in varchar2         default null,
  p_status                       in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_budget_unit1_id              in number           default null,
  p_budget_unit2_id              in number           default null,
  p_budget_unit3_id              in number           default null,
  p_gl_set_of_books_id           in number           default null,
  p_budget_unit1_aggregate       in varchar2         default null,
  p_budget_unit2_aggregate       in varchar2         default null,
  p_budget_unit3_aggregate       in varchar2         default null,
  p_position_control_flag        in varchar2         default null,
  p_valid_grade_reqd_flag        in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_dflt_budget_set_id           in number           default null
  ) is
--
  l_rec	  pqh_bgt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_bgt_shd.convert_args
  (
  null,
  p_business_group_id,
  p_start_organization_id,
  p_org_structure_version_id,
  p_budgeted_entity_cd,
  p_budget_style_cd,
  p_budget_name,
  p_period_set_name,
  p_budget_start_date,
  p_budget_end_date,
  p_gl_budget_name,
  p_psb_budget_flag,
  p_transfer_to_gl_flag,
  p_transfer_to_grants_flag,
  p_status,
  null,
  p_budget_unit1_id,
  p_budget_unit2_id,
  p_budget_unit3_id,
  p_gl_set_of_books_id,
  p_budget_unit1_aggregate,
  p_budget_unit2_aggregate,
  p_budget_unit3_aggregate,
  p_position_control_flag,
  p_valid_grade_reqd_flag,
  p_currency_code,
  p_dflt_budget_set_id
  );
  --
  -- Having converted the arguments into the pqh_bgt_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_budget_id := l_rec.budget_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_bgt_ins;

/
