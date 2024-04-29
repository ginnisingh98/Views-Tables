--------------------------------------------------------
--  DDL for Package Body PQH_WKS_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WKS_INS" as
/* $Header: pqwksrhi.pkb 120.0 2005/05/29 03:01:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_wks_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_wks_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_worksheets
  --
  insert into pqh_worksheets
  (	worksheet_id,
	budget_id,
	worksheet_name,
	version_number,
	action_date,
	date_from,
	date_to,
	worksheet_mode_cd,
	transaction_status,
	object_version_number,
	budget_version_id,
	propagation_method,
        wf_transaction_category_id
  )
  Values
  (	p_rec.worksheet_id,
	p_rec.budget_id,
	p_rec.worksheet_name,
	p_rec.version_number,
	p_rec.action_date,
	p_rec.date_from,
	p_rec.date_to,
	p_rec.worksheet_mode_cd,
	p_rec.transaction_status,
	p_rec.object_version_number,
	p_rec.budget_version_id,
	p_rec.propagation_method,
        p_rec.wf_transaction_category_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_wks_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_wks_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_wks_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_wks_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_worksheets_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.worksheet_id;
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
p_effective_date in date,p_rec in pqh_wks_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--

 l_budgets_rec   pqh_budgets%ROWTYPE;

 cursor csr_budget(p_budget_id IN number) is
 select *
 from pqh_budgets
 where budget_id = p_budget_id
   and nvl(status,'X') <> 'FROZEN';

 l_object_version_number   number(9);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
  /*
     Set the budget status to FROZEN . When budget is forzen, user cannot change UOM in budget
   */
    --
      OPEN csr_budget(p_budget_id =>  p_rec.budget_id);
        LOOP
          FETCH csr_budget INTO l_budgets_rec;
          EXIT WHEN csr_budget%NOTFOUND;

             hr_utility.set_location('Budget Status :'||l_budgets_rec.status, 6);

             -- call update API of budget to update the budget status to frozen

               l_object_version_number := l_budgets_rec.object_version_number;

               pqh_budgets_api.update_budget
               (
                p_budget_id               => l_budgets_rec.budget_id,
                p_object_version_number   => l_object_version_number,
                p_status                  => 'FROZEN',
                p_effective_date          => sysdate
               );
        END LOOP;
      CLOSE csr_budget;


    --
    pqh_wks_rki.after_insert
      (
  p_worksheet_id                  =>p_rec.worksheet_id
 ,p_budget_id                     =>p_rec.budget_id
 ,p_worksheet_name                =>p_rec.worksheet_name
 ,p_version_number                =>p_rec.version_number
 ,p_action_date                   =>p_rec.action_date
 ,p_date_from                     =>p_rec.date_from
 ,p_date_to                       =>p_rec.date_to
 ,p_worksheet_mode_cd             =>p_rec.worksheet_mode_cd
 ,p_transaction_status                        =>p_rec.transaction_status
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_budget_version_id             =>p_rec.budget_version_id
 ,p_propagation_method            =>p_rec.propagation_method
 ,p_effective_date                =>p_effective_date
 ,p_wf_transaction_category_id    =>p_rec.wf_transaction_category_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_worksheets'
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
  p_rec        in out nocopy pqh_wks_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_wks_bus.insert_validate(p_rec
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
  p_worksheet_id                 out nocopy number,
  p_budget_id                    in number,
  p_worksheet_name               in varchar2,
  p_version_number               in number,
  p_action_date                  in date,
  p_date_from                    in date             default null,
  p_date_to                      in date             default null,
  p_worksheet_mode_cd            in varchar2         default null,
  p_transaction_status                       in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_budget_version_id            in number,
  p_propagation_method           in varchar2         default null,
  p_wf_transaction_category_id   in number
  ) is
--
  l_rec	  pqh_wks_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_wks_shd.convert_args
  (
  null,
  p_budget_id,
  p_worksheet_name,
  p_version_number,
  p_action_date,
  p_date_from,
  p_date_to,
  p_worksheet_mode_cd,
  p_transaction_status,
  null,
  p_budget_version_id,
  p_propagation_method,
  p_wf_transaction_category_id
  );
  --
  -- Having converted the arguments into the pqh_wks_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_worksheet_id := l_rec.worksheet_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_wks_ins;

/
