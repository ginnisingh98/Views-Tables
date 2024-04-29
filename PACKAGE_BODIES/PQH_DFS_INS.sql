--------------------------------------------------------
--  DDL for Package Body PQH_DFS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFS_INS" as
/* $Header: pqdfsrhi.pkb 115.11 2003/04/02 20:02:02 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_dfs_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_dfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_dflt_fund_srcs
  --
  insert into pqh_dflt_fund_srcs
  (	dflt_fund_src_id,
	dflt_budget_element_id,
	dflt_dist_percentage,
        project_id,
        award_id,
        task_id,
        expenditure_type,
        organization_id,
	object_version_number,
	cost_allocation_keyflex_id
  )
  Values
  (	p_rec.dflt_fund_src_id,
	p_rec.dflt_budget_element_id,
	p_rec.dflt_dist_percentage,
        p_rec.project_id,
        p_rec.award_id,
        p_rec.task_id,
        p_rec.expenditure_type,
        p_rec.organization_id,
	p_rec.object_version_number,
	p_rec.cost_allocation_keyflex_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_dfs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_dfs_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_dfs_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_dfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_dflt_fund_srcs_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.dflt_fund_src_id;
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
Procedure post_insert(p_rec in pqh_dfs_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
--
l_sum       number(15,2) := 0;

 cursor csr_element(p_dflt_budget_element_id in number) is
 select SUM(NVL(dflt_dist_percentage,0))
 from pqh_dflt_fund_srcs
 where dflt_budget_element_id = p_dflt_budget_element_id;


--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  open csr_element(p_dflt_budget_element_id  => p_rec.dflt_budget_element_id);
   fetch csr_element into l_sum;
  close csr_element;

   if l_sum > 100 then
     -- sum cannot be more then 100
     --
      hr_utility.set_message(8302,'PQH_WKS_INVALID_SRCS_SUM');
      hr_utility.raise_error;
    --
   end if;
  --

  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_dfs_rki.after_insert
      (
  p_dflt_fund_src_id              =>p_rec.dflt_fund_src_id
 ,p_dflt_budget_element_id        =>p_rec.dflt_budget_element_id
 ,p_dflt_dist_percentage          =>p_rec.dflt_dist_percentage
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_cost_allocation_keyflex_id    =>p_rec.cost_allocation_keyflex_id
 ,p_project_id                    =>p_rec.project_id
 ,p_award_id                      =>p_rec.award_id
 ,p_task_id                       =>p_rec.task_id
 ,p_expenditure_type              =>p_rec.expenditure_type
 ,p_organization_id               =>p_rec.organization_id
);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_dflt_fund_srcs'
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
  p_rec        in out nocopy pqh_dfs_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_dfs_bus.insert_validate(p_rec);
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
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_dflt_fund_src_id             out nocopy number,
  p_dflt_budget_element_id       in number,
  p_dflt_dist_percentage         in number           default null,
  p_project_id                   in number           default null,
  p_award_id                     in number           default null,
  p_task_id                      in number           default null,
  p_expenditure_type             in varchar2         default null,
  p_organization_id              in number           default null,
  p_object_version_number        out nocopy number,
  p_cost_allocation_keyflex_id   in number           default null
  ) is
--
  l_rec	  pqh_dfs_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_dfs_shd.convert_args
  (
  null,
  p_dflt_budget_element_id,
  p_dflt_dist_percentage,
  p_project_id,
  p_award_id,
  p_task_id,
  p_expenditure_type,
  p_organization_id,
  null,
  p_cost_allocation_keyflex_id
  );
  --
  -- Having converted the arguments into the pqh_dfs_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_dflt_fund_src_id := l_rec.dflt_fund_src_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_dfs_ins;

/
