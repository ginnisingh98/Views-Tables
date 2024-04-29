--------------------------------------------------------
--  DDL for Package Body PQH_STR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_STR_DEL" as
/* $Header: pqstrrhi.pkb 115.10 2004/04/06 05:49 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_str_del.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;

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
  (p_rec in pqh_str_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin

 if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;


  --
  --
  --
  -- Delete the pqh_fr_stat_situation_rules row.
  --
  delete from pqh_fr_stat_situation_rules
  where stat_situation_rule_id = p_rec.stat_situation_rule_id;
  --
  --
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqh_str_shd.constraint_error
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
Procedure pre_delete(p_rec in pqh_str_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
 if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

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
Procedure post_delete(p_rec in pqh_str_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
 if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;

  begin
    --
    pqh_str_rkd.after_delete
      (p_stat_situation_rule_id
      => p_rec.stat_situation_rule_id
      ,p_statutory_situation_id_o
      => pqh_str_shd.g_old_rec.statutory_situation_id
      ,p_processing_sequence_o
      => pqh_str_shd.g_old_rec.processing_sequence
      ,p_txn_category_attribute_id_o
      => pqh_str_shd.g_old_rec.txn_category_attribute_id
      ,p_from_value_o
      => pqh_str_shd.g_old_rec.from_value
      ,p_to_value_o
      => pqh_str_shd.g_old_rec.to_value
      ,p_enabled_flag_o
      => pqh_str_shd.g_old_rec.enabled_flag
      ,p_required_flag_o
      => pqh_str_shd.g_old_rec.required_flag
      ,p_exclude_flag_o
      => pqh_str_shd.g_old_rec.exclude_flag
      ,p_object_version_number_o
      => pqh_str_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_FR_STAT_SITUATION_RULES'
        ,p_hook_type   => 'AD');
      --
  end;
  --
   if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;

End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in pqh_str_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin

  g_debug := hr_utility.debug_enabled;

 if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;

  --
  -- We must lock the row which we need to delete.
  --
  pqh_str_shd.lck
    (p_rec.stat_situation_rule_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_str_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_str_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_str_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_str_del.post_delete(p_rec);
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
  (p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqh_str_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  End if;

  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.stat_situation_rule_id := p_stat_situation_rule_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_str_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_str_del.del(l_rec);
  --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  End if;
End del;
--
end pqh_str_del;

/
