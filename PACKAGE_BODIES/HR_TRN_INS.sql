--------------------------------------------------------
--  DDL for Package Body HR_TRN_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRN_INS" as
/* $Header: hrtrnrhi.pkb 120.2 2005/09/21 04:59:16 hpandya noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_trn_ins.';  -- Global package name

-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_transaction_id_i  number   default null;

--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_transaction_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_trn_ins.g_transaction_id_i := p_transaction_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;

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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy hr_trn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_trn_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: hr_api_transactions
  --
  insert into hr_api_transactions
  ( transaction_id,
    creator_person_id,
    transaction_privilege,
    product_code,
    url,
    status,
    section_display_name,
    function_id,
    transaction_ref_table,
    transaction_ref_id,
    transaction_type,
    assignment_id,
    api_addtnl_info,
    selected_person_id,
    item_type,
    item_key,
    transaction_effective_date,
    process_name,
    plan_id ,
    rptg_grp_id,
    effective_date_option,
    creator_role,
    last_update_role,
    parent_Transaction_id,
    relaunch_function,
    transaction_group,
    transaction_identifier,
    transaction_document
  )
  Values
  ( p_rec.transaction_id,
    p_rec.creator_person_id,
    p_rec.transaction_privilege,
    p_rec.product_code,
    p_rec.url,
    p_rec.status,
    p_rec.section_display_name,
    p_rec.function_id,
    p_rec.transaction_ref_table,
    p_rec.transaction_ref_id,
    p_rec.transaction_type,
    p_rec.assignment_id,
    p_rec.api_addtnl_info,
    p_rec.selected_person_id,
    p_rec.item_type,
    p_rec.item_key,
    p_rec.transaction_effective_date,
    p_rec.process_name,
    p_rec.plan_id ,
    p_rec.rptg_grp_id,
    p_rec.effective_date_option,
    p_rec.creator_role,
    p_rec.last_update_role,
    p_rec.parent_Transaction_id,
    p_rec.relaunch_function,
    p_rec.transaction_group,
    p_rec.transaction_identifier,
    p_rec.transaction_document
  );
  --
  -- plan_id, rptg_grp_id, effective_date_option added by sanej
  --
  hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
    hr_trn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hr_trn_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy hr_trn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
  Cursor C_Sel1 is select hr_api_transactions_s.nextval from sys.dual;

  Cursor C_Sel2 is
         select null
                from hr_api_transactions
                where transaction_id = hr_trn_ins.g_transaction_id_i;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  If hr_trn_ins.g_transaction_id_i is not null then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found then
      Close C_Sel2;
      --
      -- The primary key values are already in use.
      --
      fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
      fnd_message.set_token('TABLE_NAME','hr_questionnaires');
      fnd_message.raise_error;
    end if;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.transaction_id := hr_trn_ins.g_transaction_id_i;
    hr_trn_ins.g_transaction_id_i := null;
    --
  else
    --
    --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.transaction_id;
  Close C_Sel1;
  --
  End If;
  If p_rec.transaction_ref_id is null Then
    p_rec.transaction_ref_id := p_rec.transaction_id;
  End If;

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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in hr_trn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy hr_trn_shd.g_rec_type,
  p_validate   in     boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_hr_trn;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  hr_trn_bus.insert_validate(p_rec);
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
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_hr_trn;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_transaction_id               out nocopy number,
  p_creator_person_id            in number,
  p_transaction_privilege        in varchar2,
  p_validate                     in boolean   default false
  ) is
--
  l_rec   hr_trn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
/*
  l_rec :=
  hr_trn_shd.convert_args
  (
  null,
  p_creator_person_id,
  p_transaction_privilege
  );
  --
  -- Having converted the arguments into the hr_trn_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_transaction_id := l_rec.transaction_id;
*/
  --
  --
  ins(
    p_transaction_id => p_transaction_id,
    p_creator_person_id  =>  p_creator_person_id,
    p_transaction_privilege => p_transaction_privilege,
    p_product_code => -1,
    p_url => null,
    p_status  =>null,
    p_section_display_name => null,
    p_function_id => null,
    p_transaction_ref_table => null,
    p_transaction_ref_id => null,
    p_transaction_type => null,
    p_assignment_id => null,
    p_api_addtnl_info => null,
    p_selected_person_id => null,
    p_item_type => null,
    p_item_key => null,
    p_transaction_effective_date => null,
    p_process_name => null,
    p_plan_id => null,
    p_rptg_grp_id => null,
    p_effective_date_option => null,
    p_validate => p_validate,
    p_relaunch_function  => null,
    p_transaction_group    => null,
    p_transaction_identifier => null,
    p_transaction_document => null

  );
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- Overloaded ins procedure
Procedure ins
  (
  p_transaction_id               out nocopy number,
  p_creator_person_id            in number,
  p_transaction_privilege        in varchar2,
  p_product_code                 in varchar2 default null,
  p_url                          in varchar2 default null,
  p_status                       in varchar2 default null,
  p_section_display_name         in varchar2 default null,
  p_function_id                  in number,
  p_transaction_ref_table        in varchar2 default null,
  p_transaction_ref_id           in number default null,
  p_transaction_type             in varchar2 default null,
  p_assignment_id                in number default null,
  p_api_addtnl_info              in varchar2 default null,
  p_selected_person_id           in number default null,
  p_item_type                    in varchar2 default null,
  p_item_key                     in varchar2 default null,
  p_transaction_effective_date   in date default null,
  p_process_name                 in varchar2 default null,
  p_plan_id                      in number default null,
  p_rptg_grp_id                  in number default null,
  p_effective_date_option        in varchar2 default null,
  p_validate                     in boolean  default false,
  p_creator_role                 in varchar2 default null,
  p_last_update_role             in varchar2 default null,
  p_parent_transaction_id        in number   default null,
  p_relaunch_function            in varchar2 default null,
  p_transaction_group            in varchar2 default null,
  p_transaction_identifier       in varchar2 default null,
  p_transaction_document         in CLOB     default null
  ) is
--
-- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
--
  l_rec   hr_trn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  hr_trn_shd.convert_args
  (
  null,
  p_creator_person_id,
  p_transaction_privilege,
  p_product_code,
  p_url,
  p_status,
  null,  --ns for transaction_state
  p_section_display_name,
  p_function_id,
  p_transaction_ref_table,
  p_transaction_ref_id,
  p_transaction_type,
  p_assignment_id,
  p_api_addtnl_info,
  p_selected_person_id,
  p_item_type,
  p_item_key,
  p_transaction_effective_date,
  p_process_name,
  p_plan_id,
  p_rptg_grp_id,
  p_effective_date_option,
  p_creator_role,
  p_last_update_role,
  p_parent_transaction_id,
  p_relaunch_function,
  p_transaction_group,
  p_transaction_identifier,
  p_transaction_document
  );
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej
  --
  -- Having converted the arguments into the hr_trn_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_transaction_id := l_rec.transaction_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;

end hr_trn_ins;

/
