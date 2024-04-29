--------------------------------------------------------
--  DDL for Package Body PQH_RHT_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RHT_INS" as
/* $Header: pqrhtrhi.pkb 115.7 2002/12/06 18:08:02 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rht_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy pqh_rht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: pqh_routing_history
  --
  insert into pqh_routing_history
  (	routing_history_id,
	approval_cd,
	comments,
	forwarded_by_assignment_id,
	forwarded_by_member_id,
	forwarded_by_position_id,
	forwarded_by_user_id,
	forwarded_by_role_id,
	forwarded_to_assignment_id,
	forwarded_to_member_id,
	forwarded_to_position_id,
	forwarded_to_user_id,
	forwarded_to_role_id,
	notification_date,
	pos_structure_version_id,
	routing_category_id,
	transaction_category_id,
	transaction_id,
	user_action_cd,
        from_range_name,
        to_range_name,
        list_range_name,
	object_version_number
  )
  Values
  (	p_rec.routing_history_id,
	p_rec.approval_cd,
	p_rec.comments,
	p_rec.forwarded_by_assignment_id,
	p_rec.forwarded_by_member_id,
	p_rec.forwarded_by_position_id,
	p_rec.forwarded_by_user_id,
	p_rec.forwarded_by_role_id,
	p_rec.forwarded_to_assignment_id,
	p_rec.forwarded_to_member_id,
	p_rec.forwarded_to_position_id,
	p_rec.forwarded_to_user_id,
	p_rec.forwarded_to_role_id,
	p_rec.notification_date,
	p_rec.pos_structure_version_id,
	p_rec.routing_category_id,
	p_rec.transaction_category_id,
	p_rec.transaction_id,
	p_rec.user_action_cd,
        p_rec.from_range_name,
        p_rec.to_range_name,
        p_rec.list_range_name,
	p_rec.object_version_number
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    pqh_rht_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    pqh_rht_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    pqh_rht_shd.constraint_error
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
Procedure pre_insert(p_rec  in out nocopy pqh_rht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pqh_routing_history_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.routing_history_id;
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
p_effective_date in date,p_rec in pqh_rht_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
--
--

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    pqh_rht_rki.after_insert
      (
  p_routing_history_id            =>p_rec.routing_history_id
 ,p_approval_cd                   =>p_rec.approval_cd
 ,p_comments                      =>p_rec.comments
 ,p_forwarded_by_assignment_id    =>p_rec.forwarded_by_assignment_id
 ,p_forwarded_by_member_id        =>p_rec.forwarded_by_member_id
 ,p_forwarded_by_position_id      =>p_rec.forwarded_by_position_id
 ,p_forwarded_by_user_id          =>p_rec.forwarded_by_user_id
 ,p_forwarded_by_role_id          =>p_rec.forwarded_by_role_id
 ,p_forwarded_to_assignment_id    =>p_rec.forwarded_to_assignment_id
 ,p_forwarded_to_member_id        =>p_rec.forwarded_to_member_id
 ,p_forwarded_to_position_id      =>p_rec.forwarded_to_position_id
 ,p_forwarded_to_user_id          =>p_rec.forwarded_to_user_id
 ,p_forwarded_to_role_id          =>p_rec.forwarded_to_role_id
 ,p_notification_date             =>p_rec.notification_date
 ,p_pos_structure_version_id      =>p_rec.pos_structure_version_id
 ,p_routing_category_id           =>p_rec.routing_category_id
 ,p_transaction_category_id       =>p_rec.transaction_category_id
 ,p_transaction_id                =>p_rec.transaction_id
 ,p_user_action_cd                =>p_rec.user_action_cd
 ,p_from_range_name               =>p_rec.from_range_name
 ,p_to_range_name                 =>p_rec.to_range_name
 ,p_list_range_name               =>p_rec.list_range_name
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
      );
    --
   --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'pqh_routing_history'
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
  p_rec        in out nocopy pqh_rht_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pqh_rht_bus.insert_validate(p_rec
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
       p_effective_date,
       p_rec
       );
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_routing_history_id           out nocopy number,
  p_approval_cd                  in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_forwarded_by_assignment_id   in number           default null,
  p_forwarded_by_member_id       in number           default null,
  p_forwarded_by_position_id     in number           default null,
  p_forwarded_by_user_id         in number           default null,
  p_forwarded_by_role_id         in number           default null,
  p_forwarded_to_assignment_id   in number           default null,
  p_forwarded_to_member_id       in number           default null,
  p_forwarded_to_position_id     in number           default null,
  p_forwarded_to_user_id         in number           default null,
  p_forwarded_to_role_id         in number           default null,
  p_notification_date            in date,
  p_pos_structure_version_id     in number           default null,
  p_routing_category_id          in number,
  p_transaction_category_id      in number,
  p_transaction_id               in number,
  p_user_action_cd               in varchar2,
  p_from_range_name               in varchar2,
  p_to_range_name                 in varchar2,
  p_list_range_name               in varchar2,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  pqh_rht_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  pqh_rht_shd.convert_args
  (
  null,
  p_approval_cd,
  p_comments,
  p_forwarded_by_assignment_id,
  p_forwarded_by_member_id,
  p_forwarded_by_position_id,
  p_forwarded_by_user_id,
  p_forwarded_by_role_id,
  p_forwarded_to_assignment_id,
  p_forwarded_to_member_id,
  p_forwarded_to_position_id,
  p_forwarded_to_user_id,
  p_forwarded_to_role_id,
  p_notification_date,
  p_pos_structure_version_id,
  p_routing_category_id,
  p_transaction_category_id,
  p_transaction_id,
  p_user_action_cd,
  p_from_range_name,
  p_to_range_name,
  p_list_range_name,
  null
  );
  --
  -- Having converted the arguments into the pqh_rht_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,
    l_rec
    );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_routing_history_id := l_rec.routing_history_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end pqh_rht_ins;

/
