--------------------------------------------------------
--  DDL for Package Body PQH_RMV_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RMV_DEL" as
/* $Header: pqrmvrhi.pkb 120.2 2005/06/23 03:41 srenukun noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rmv_del.';  -- Global package name
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
  (p_rec in pqh_rmv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pqh_rt_matrix_node_values row.
  --
  delete from pqh_rt_matrix_node_values
  where node_value_id = p_rec.node_value_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqh_rmv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_delete(p_rec in pqh_rmv_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqh_rmv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('NODE_VALUE_ID', p_rec.node_value_id
      );
    --
    pqh_rmv_rkd.after_delete
      (p_node_value_id
      => p_rec.node_value_id
      ,p_rate_matrix_node_id_o
      => pqh_rmv_shd.g_old_rec.rate_matrix_node_id
      ,p_short_code_o
      => pqh_rmv_shd.g_old_rec.short_code
      ,p_char_value1_o
      => pqh_rmv_shd.g_old_rec.char_value1
      ,p_char_value2_o
      => pqh_rmv_shd.g_old_rec.char_value2
      ,p_char_value3_o
      => pqh_rmv_shd.g_old_rec.char_value3
      ,p_char_value4_o
      => pqh_rmv_shd.g_old_rec.char_value4
      ,p_number_value1_o
      => pqh_rmv_shd.g_old_rec.number_value1
      ,p_number_value2_o
      => pqh_rmv_shd.g_old_rec.number_value2
      ,p_number_value3_o
      => pqh_rmv_shd.g_old_rec.number_value3
      ,p_number_value4_o
      => pqh_rmv_shd.g_old_rec.number_value4
      ,p_date_value1_o
      => pqh_rmv_shd.g_old_rec.date_value1
      ,p_date_value2_o
      => pqh_rmv_shd.g_old_rec.date_value2
      ,p_date_value3_o
      => pqh_rmv_shd.g_old_rec.date_value3
      ,p_date_value4_o
      => pqh_rmv_shd.g_old_rec.date_value4
      ,p_business_group_id_o
      => pqh_rmv_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pqh_rmv_shd.g_old_rec.legislation_code
      ,p_object_version_number_o
      => pqh_rmv_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RT_MATRIX_NODE_VALUES'
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
  (p_rec              in pqh_rmv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqh_rmv_shd.lck
    (p_rec.node_value_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_rmv_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_rmv_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_rmv_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_rmv_del.post_delete(p_rec);
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
  (p_node_value_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqh_rmv_shd.g_rec_type;
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
  l_rec.node_value_id := p_node_value_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_rmv_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_rmv_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqh_rmv_del;

/