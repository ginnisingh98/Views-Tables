--------------------------------------------------------
--  DDL for Package Body GHR_PDH_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDH_INS" as
/* $Header: ghpdhrhi.pkb 120.1 2006/01/17 06:21:22 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdh_ins.';  -- Global package name
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out NOCOPY ghr_pdh_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --

  -- Insert the row into: ghr_pd_routing_history
  --

  insert into ghr_pd_routing_history
     (pd_routing_history_id,
	position_description_id,
	initiator_flag,
	requester_flag,
	approver_flag,
	reviewer_flag,
      authorizer_flag,
      personnelist_flag,
	approved_flag,
    	user_name,
	user_name_employee_id,
     	user_name_emp_first_name,
	user_name_emp_last_name,
	user_name_emp_middle_names,
	action_taken,
	groupbox_id,
	routing_list_id,
      routing_seq_number,
 	date_notification_sent,
	object_version_number,
        item_key
  )
  Values
  (	p_rec.pd_routing_history_id,
	p_rec.position_description_id,
	p_rec.initiator_flag,
	p_rec.requester_flag,
	p_rec.approver_flag,
	p_rec.reviewer_flag,
      p_rec.authorizer_flag,
      p_rec.personnelist_flag,
	p_rec.approved_flag,
      p_rec.user_name,
	p_rec.user_name_employee_id,
     	p_rec.user_name_emp_first_name,
	p_rec.user_name_emp_last_name,
	p_rec.user_name_emp_middle_names,
	p_rec.action_taken,
	p_rec.groupbox_id,
	p_rec.routing_list_id,
      p_rec.routing_seq_number,
 	p_rec.date_notification_sent,
	p_rec.object_version_number,
        p_rec.item_key
  );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
      ghr_pdh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ghr_pdh_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
     ghr_pdh_shd.constraint_error
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
Procedure pre_insert
	(p_rec  			in out NOCOPY ghr_pdh_shd.g_rec_type)is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ghr_pd_routing_history_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
    open C_Sel1;
    Fetch C_Sel1 Into p_rec.pd_routing_history_id;
    Close C_Sel1;
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
Procedure post_insert(p_rec in ghr_pdh_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
 -- This is a hook point and the user hook for post_insert is called here.
  --
  begin
     ghr_pdh_rki.after_insert   (
      p_pd_routing_history_id       =>     p_rec.pd_routing_history_id,
      p_position_description_id     =>     p_rec.position_description_id,
      p_initiator_flag              =>     p_rec.initiator_flag,
      p_requester_flag              =>     p_rec.requester_flag,
      p_approver_flag               =>     p_rec.approver_flag,
      p_personnelist_flag           =>     p_rec.personnelist_flag,
      p_reviewer_flag               =>     p_rec.reviewer_flag,
      p_authorizer_flag             =>     p_rec.authorizer_flag,
      p_approved_flag               =>     p_rec.approved_flag,
      p_user_name                   =>     p_rec.user_name,
      p_user_name_employee_id       =>     p_rec.user_name_employee_id,
      p_user_name_emp_first_name    =>     p_rec.user_name_emp_first_name,
      p_user_name_emp_last_name     =>     p_rec.user_name_emp_last_name,
      p_user_name_emp_middle_names  =>     p_rec.user_name_emp_middle_names,
      p_action_taken                =>     p_rec.action_taken,
      p_groupbox_id                 =>     p_rec.groupbox_id,
      p_routing_list_id             =>     p_rec.routing_list_id,
      p_routing_seq_number          =>     p_rec.routing_seq_number,
      p_date_notification_sent      =>     p_rec.date_notification_sent,
      p_item_key                   =>     p_rec.item_key,
      p_object_version_number       =>     p_rec.object_version_number);

  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
                 (       p_module_name => 'GHR_PD_ROUTING_HISTORY'
                        ,p_hook_type   => 'AI'
                );
  end;
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out NOCOPY ghr_pdh_shd.g_rec_type,
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
    SAVEPOINT ins_ghr_pdh;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  ghr_pdh_bus.insert_validate(p_rec);
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
    ROLLBACK TO ins_ghr_pdh;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins>----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_pd_routing_history_id        out NOCOPY number,
  p_position_description_id      in number,
  p_initiator_flag               in varchar2         default null,
  p_requester_flag               in varchar2         default null,
  p_approver_flag                in varchar2         default null,
  p_reviewer_flag                in varchar2         default null,
  p_authorizer_flag              in varchar2         default null,
  p_personnelist_flag            in varchar2         default null,
  p_approved_flag                in varchar2         default null,
  p_user_name                    in varchar2         default null,
  p_user_name_employee_id        in number           default null,
  p_user_name_emp_first_name     in varchar2         default null,
  p_user_name_emp_last_name      in varchar2         default null,
  p_user_name_emp_middle_names   in varchar2         default null,
  p_action_taken                 in varchar2         default null,
  p_groupbox_id                  in number           default null,
  p_routing_list_id              in number           default null,
  p_routing_seq_number           in number           default null,
  p_date_notification_sent       in date             default sysdate,
  p_object_version_number        out NOCOPY number,
  p_validate                     in boolean   default false ,
  p_item_key                     in varchar2
  ) is
--
  l_rec	  ghr_pdh_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ghr_pdh_shd.convert_args
  (
  null,
  p_position_description_id,
  p_initiator_flag,
  p_requester_flag,
  p_approver_flag,
  p_reviewer_flag,
  p_authorizer_flag,
  p_personnelist_flag,
  p_approved_flag,
  p_user_name,
  p_user_name_employee_id,
  p_user_name_emp_first_name,
  p_user_name_emp_last_name,
  p_user_name_emp_middle_names,
  p_action_taken,
  p_groupbox_id,
  p_routing_list_id,
  p_routing_seq_number,
  p_date_notification_sent,
  null,
  p_item_key
  );

  --
  -- Having converted the arguments into the ghr_pdh_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec,p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pd_routing_history_id := l_rec.pd_routing_history_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ghr_pdh_ins;

/
