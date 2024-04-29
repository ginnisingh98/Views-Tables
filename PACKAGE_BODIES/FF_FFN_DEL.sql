--------------------------------------------------------
--  DDL for Package Body FF_FFN_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFN_DEL" as
/* $Header: ffffnrhi.pkb 120.1 2005/10/05 01:50 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_ffn_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column  IN  varchar2
                               ,p_pk_value   IN  varchar2) IS
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value));
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml
  (p_rec in ff_ffn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ff_ffn_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ff_functions row.
  --
  delete from ff_functions
  where function_id = p_rec.function_id;
  --
  ff_ffn_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ff_ffn_shd.g_api_dml := false;   -- Unset the api dml status
    ff_ffn_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ff_ffn_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ff_ffn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ff_ffn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('FUNCTION_ID', p_rec.function_id
      );
    --
    ff_ffn_rkd.after_delete
      (p_function_id
      => p_rec.function_id
      ,p_business_group_id_o
      => ff_ffn_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => ff_ffn_shd.g_old_rec.legislation_code
      ,p_class_o
      => ff_ffn_shd.g_old_rec.class
      ,p_name_o
      => ff_ffn_shd.g_old_rec.name
      ,p_alias_name_o
      => ff_ffn_shd.g_old_rec.alias_name
      ,p_data_type_o
      => ff_ffn_shd.g_old_rec.data_type
      ,p_definition_o
      => ff_ffn_shd.g_old_rec.definition
      ,p_description_o
      => ff_ffn_shd.g_old_rec.description
      ,p_object_version_number_o
      => ff_ffn_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'FF_FUNCTIONS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ff_ffn_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
  l_object_version_number     ff_functions.object_version_number%type;
--
  Cursor c_ff_function_context
    is
      select sequence_number, object_version_number
      from ff_function_context_usages
      where function_id = p_rec.function_id
      for update nowait;

  Cursor c_ff_parameters
    is
      select sequence_number, object_version_number
      from ff_function_parameters
      where function_id = p_rec.function_id
      for update nowait;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Cascade delete the child entities for FF_FUNCTION_CONTEXT_USAGES
  --
  For l_function_context in c_ff_function_context
  Loop
    l_object_version_number := l_function_context.object_version_number;
    --
	--
  End Loop;

  --
  -- Cascade delete the child entities for FF_FUNCTION_PARAMETERS
  --
  For l_function_params in c_ff_parameters
  Loop
    l_object_version_number := l_function_params.object_version_number;
    --
	--
  End Loop;
  --
  -- We must lock the row which we need to delete.
  --
  ff_ffn_shd.lck
    (p_rec.function_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ff_ffn_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ff_ffn_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ff_ffn_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ff_ffn_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_function_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ff_ffn_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.function_id := p_function_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ff_ffn_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ff_ffn_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ff_ffn_del;

/
