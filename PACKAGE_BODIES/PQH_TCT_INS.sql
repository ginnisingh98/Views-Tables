--------------------------------------------------------
--  DDL for Package Body PQH_TCT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TCT_INS" as
/* $Header: pqtctrhi.pkb 120.4.12000000.2 2007/04/19 12:48:04 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_tct_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_transaction_categories
  --
  insert into pqh_transaction_categories
  (	transaction_category_id,
	custom_wf_process_name,
	custom_workflow_name,
	form_name,
	freeze_status_cd,
	future_action_cd,
	member_cd,
	name,
        short_name,
	post_style_cd,
	post_txn_function,
	route_validated_txn_flag,
	prevent_approver_skip,
        workflow_enable_flag,
        enable_flag,
	timeout_days,
	object_version_number,
	consolidated_table_route_id ,
        business_group_id,
        setup_type_cd,
	Master_table_route_id
  )
  Values
  (	p_rec.transaction_category_id,
	p_rec.custom_wf_process_name,
	p_rec.custom_workflow_name,
	p_rec.form_name,
	p_rec.freeze_status_cd,
	p_rec.future_action_cd,
	p_rec.member_cd,
	p_rec.name,
        p_rec.short_name,
	p_rec.post_style_cd,
	p_rec.post_txn_function,
	p_rec.route_validated_txn_flag,
	p_rec.prevent_approver_skip,
        p_rec.workflow_enable_flag,
        p_rec.enable_flag,
	p_rec.timeout_days,
	p_rec.object_version_number,
	p_rec.consolidated_table_route_id ,
        p_rec.business_group_id,
        p_rec.setup_type_cd,
	p_rec.master_table_route_id
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_tct_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_tct_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_tct_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_transaction_categories_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.transaction_category_id;
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
p_effective_date in date,p_rec in pqh_tct_shd.g_rec_type) is
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
    pqh_tct_rki.after_insert
      (
  p_transaction_category_id       =>p_rec.transaction_category_id
 ,p_custom_wf_process_name        =>p_rec.custom_wf_process_name
 ,p_custom_workflow_name          =>p_rec.custom_workflow_name
 ,p_form_name                     =>p_rec.form_name
 ,p_freeze_status_cd              =>p_rec.freeze_status_cd
 ,p_future_action_cd              =>p_rec.future_action_cd
 ,p_member_cd                     =>p_rec.member_cd
 ,p_name                          =>p_rec.name
 ,p_short_name                          =>p_rec.short_name
 ,p_post_style_cd                 =>p_rec.post_style_cd
 ,p_post_txn_function             =>p_rec.post_txn_function
 ,p_route_validated_txn_flag      =>p_rec.route_validated_txn_flag
 ,p_prevent_approver_skip         =>p_rec.prevent_approver_skip
 ,p_workflow_enable_flag      =>p_rec.workflow_enable_flag
 ,p_enable_flag      =>p_rec.enable_flag
 ,p_timeout_days                  =>p_rec.timeout_days
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_consolidated_table_route_id   =>p_rec.consolidated_table_route_id
 ,p_business_group_id             => p_rec.business_group_id
 ,p_setup_type_cd                 => p_rec.setup_type_cd
 ,p_master_table_route_id   =>p_rec.master_table_route_id
 ,p_effective_date                =>p_effective_date
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_transaction_categories'
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
  p_rec        in out nocopy pqh_tct_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_tct_bus.insert_validate(p_rec
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
  p_transaction_category_id      out nocopy number,
  p_custom_wf_process_name       in varchar2         default null,
  p_custom_workflow_name         in varchar2         default null,
  p_form_name                    in varchar2,
  p_freeze_status_cd             in varchar2         default null,
  p_future_action_cd             in varchar2,
  p_member_cd                    in varchar2,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_post_style_cd                in varchar2,
  p_post_txn_function            in varchar2,
  p_route_validated_txn_flag     in varchar2,
  p_prevent_approver_skip        in varchar2,
  p_workflow_enable_flag         in varchar2,
  p_enable_flag         in varchar2,
  p_timeout_days                 in number           default null,
  p_object_version_number        out nocopy number,
  p_consolidated_table_route_id  in number,
  p_business_group_id            in number           ,
  p_setup_type_cd                in varchar2         ,
  p_master_table_route_id  in number
  ) is
--
  l_rec	  pqh_tct_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_tct_shd.convert_args
  (
  null,
  p_custom_wf_process_name,
  p_custom_workflow_name,
  p_form_name,
  p_freeze_status_cd,
  p_future_action_cd,
  p_member_cd,
  p_name,
  p_short_name,
  p_post_style_cd,
  p_post_txn_function,
  p_route_validated_txn_flag,
  p_prevent_approver_skip,
  p_workflow_enable_flag,
  p_enable_flag,
  p_timeout_days,
  null,
  p_consolidated_table_route_id,
  p_business_group_id,
  p_setup_type_cd,
  p_master_table_route_id
  );
  --
  -- Having converted the arguments into the pqh_tct_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_transaction_category_id := l_rec.transaction_category_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_tct_ins;

/
