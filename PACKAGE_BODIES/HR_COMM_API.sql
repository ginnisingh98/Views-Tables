--------------------------------------------------------
--  DDL for Package Body HR_COMM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COMM_API" as
/* $Header: hrcomrhi.pkb 115.1 2002/12/18 13:22:35 hjonnala ship $ */
--
-- Private package current record structure definition
--
g_old_rec		g_rec_type;
--
-- Global package name
--
g_package		varchar2(33)	:= '  hr_comm_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Base table hr_comments insert dml.
--
Procedure insert_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Insert the row into: hr_comments
  --
  insert into hr_comments
  (	comment_id,
	source_table_name,
	comment_text
  )
  Values
  (	p_rec.comment_id,
	p_rec.source_table_name,
	p_rec.comment_text
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Base table hr_comments update dml.
--
Procedure update_dml(p_rec in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Update the hr_comments Row
  --
  update hr_comments
  set
  comment_id                        = p_rec.comment_id,
  source_table_name                 = p_rec.source_table_name,
  comment_text                      = p_rec.comment_text
  where comment_id = p_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Base table dml.
--
Procedure delete_dml(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the hr_comments row.
  --
  delete from hr_comments
  where comment_id = p_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Pre insert
--
Procedure pre_insert(p_rec  in out nocopy g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select hr_comments_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.comment_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Pre update
--
Procedure pre_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Pre delete
--
Procedure pre_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Post insert
--
Procedure post_insert(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Post update
--
Procedure post_update(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Post delete
--
Procedure post_delete(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Locks the required rows. If the object version attribute
--              is specified then the object version control also is checked.
--
Procedure lck
  (
  p_comment_id                         in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select comment_id,
	   source_table_name,
	   comment_text
    from   hr_comments
    where  comment_id = p_comment_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- The primary key exists therefore we must now attempt to lock the
  -- row.
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    --
    -- If the row wasn't returned then:
    -- a) The row does NOT exist.
    --
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'hr_comments');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'hr_comments');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Convert the attribute arguments which have been
--              passed through the attribute interface to the
--              record structure.
--
Function convert_args
	(
	p_comment_id                    in number,
	p_source_table_name             in varchar2,
	p_comment_text                  in varchar2
	)
	Return g_rec_type is
--
  l_rec	g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.comment_id                       := p_comment_id;
  l_rec.source_table_name                := p_source_table_name;
  l_rec.comment_text                     := p_comment_text;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Converts system defaulted values into corresponding row
--              attribute values.
--
Function convert_defs(p_rec in out nocopy g_rec_type)
         Return g_rec_type is
--
  l_proc	  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.source_table_name = hr_api.g_varchar2) then
    p_rec.source_table_name := g_old_rec.source_table_name;
  End If;
  If (p_rec.comment_text = hr_api.g_varchar2) then
    p_rec.comment_text := g_old_rec.comment_text;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Controls the validation execution on insert.
--
Procedure insert_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Controls the validation execution on update.
--
Procedure update_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Controls the validation execution on delete.
--
Procedure delete_validate(p_rec in g_rec_type) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Insert entity interface
--
-- hr_comm_api.ins entity business process model
-- --------------------------------------------------------------------------
--
-- ins
--   |
--   |-- insert_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_insert
--   |-- insert_dml
--   |-- post_insert
--
-- --------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'ins';
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
    SAVEPOINT ins_hr_comm;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate(p_rec);
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
    ROLLBACK TO ins_hr_comm;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Insert attribute interface
--
-- hr_comm_api.ins attribute business process model
-- --------------------------------------------------------------------------
--
-- ins
--  |
--  |-- convert_args
--  |-- ins
--        |
--        |-- insert_validate
--        |     |-- <validation operations>
--        |
--        |-- pre_insert
--        |-- insert_dml
--        |-- post_insert
--
-- --------------------------------------------------------------------------
Procedure ins
  (
  p_comment_id                   out nocopy number,
  p_source_table_name            in varchar2,
  p_comment_text                 in varchar2  default null,
  p_validate                     in boolean   default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  convert_args
  (
  null,
  p_source_table_name,
  p_comment_text
  );
  --
  -- Having converted the arguments into the hr_comm_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_validate);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_comment_id := l_rec.comment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Update entity interface
--
-- hr_comm_api.upd entity business process model
-- --------------------------------------------------------------------------
--
-- upd
--   |
--   |-- lck
--   |-- convert_defs
--   |-- update_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_update
--   |-- update_dml
--   |-- post_update
--
-- --------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy g_rec_type,
  p_validate   in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We are updating using the primary key therefore
  -- we must ensure that the argument value is NOT null.
  --
  If (p_rec.comment_id is null) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    --
    -- Determine if the business process is to be validated.
    --
    If p_validate then
      --
      -- Issue the savepoint.
      --
      SAVEPOINT upd_hr_comm;
    End If;
    --
    -- We must lock the row which we need to update.
    --
    lck(p_rec.comment_id);
    --
    -- 1. During an update system defaults are used to determine if
    --    arguments have been defaulted or not. We must therefore
    --    derive the full record structure values to be updated.
    --
    -- 2. Call the supporting update validate operations.
    --
    update_validate(convert_defs(p_rec));
    --
    -- Call the supporting pre-update operation
    --
    pre_update(p_rec);
    --
    -- Update the row.
    --
    update_dml(p_rec);
    --
    -- Call the supporting post-update operation
    --
    post_update(p_rec);
    --
    -- If we are validating then raise the Validate_Enabled exception
    --
    If p_validate then
      Raise HR_Api.Validate_Enabled;
    End If;
  --
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_hr_comm;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Update attribute interface
--
-- hr_comm_api.upd attribute business process model
-- --------------------------------------------------------------------------
--
-- upd
--   |
--   |-- convert_args
--   |-- upd
--         |
--         |-- lck
--         |-- convert_defs
--         |-- update_validate
--         |     |-- <validation operations>
--         |
--         |-- pre_update
--         |-- update_dml
--         |-- post_update
--
-- --------------------------------------------------------------------------
Procedure upd
  (
  p_comment_id                   in out nocopy number,
  p_source_table_name            in varchar2     default hr_api.g_varchar2,
  p_comment_text                 in varchar2     default hr_api.g_varchar2,
  p_validate                     in boolean      default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  convert_args
  (
  p_comment_id,
  p_source_table_name,
  p_comment_text
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Delete entity interface
--
-- hr_comm_api.del entity business process model
-- --------------------------------------------------------------------------
--
-- del
--   |
--   |-- lck
--   |-- delete_validate
--   |     |-- <validation operations>
--   |
--   |-- pre_delete
--   |-- delete_dml
--   |-- post_delete
--
-- --------------------------------------------------------------------------
Procedure del
  (
  p_rec    	in g_rec_type,
  p_validate    in boolean default false
  ) is
--
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We are deleting using the primary key therefore
  -- we must ensure that the argument value is NOT null.
  --
  If (p_rec.comment_id is null) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  Else
    --
    -- Determine if the business process is to be validated.
    --
    If p_validate then
      --
      -- Issue the savepoint.
      --
      SAVEPOINT del_hr_comm;
    End If;
    --
    -- We must lock the row which we need to delete.
    --
    lck(p_rec.comment_id);
    --
    -- Call the supporting delete validate operation
    --
    delete_validate(p_rec);
    --
    -- Call the supporting pre-delete operation
    --
    pre_delete(p_rec);
    --
    -- Delete the row.
    --
    delete_dml(p_rec);
    --
    -- Call the supporting post-delete operation
    --
    post_delete(p_rec);
    --
    -- If we are validating then raise the Validate_Enabled exception
    --
    If p_validate then
      Raise HR_Api.Validate_Enabled;
    End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_hr_comm;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Delete attribute interface
--
-- hr_comm_api.del attribute business process model
-- --------------------------------------------------------------------------
--
-- del
--  |
--  |-- del
--        |
--        |-- lck
--        |-- delete_validate
--        |     |-- <validation operations>
--        |
--        |-- pre_delete
--        |-- delete_dml
--        |-- post_delete
--
-- --------------------------------------------------------------------------
Procedure del
  (
  p_comment_id                         in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec		g_rec_type;
  l_proc	varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.comment_id := p_comment_id;
  --
  --
  -- Having converted the arguments into the hr_comm_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_comm_api;

/
