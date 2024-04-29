--------------------------------------------------------
--  DDL for Package Body PAY_BLD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLD_DEL" as
/* $Header: pybldrhi.pkb 120.0 2005/05/29 03:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_bld_del.';  -- Global package name
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
  (p_rec in pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pay_balance_dimensions row.
  --
  delete from pay_balance_dimensions
  where balance_dimension_id = p_rec.balance_dimension_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pay_bld_shd.constraint_error
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
Procedure pre_delete(p_rec in pay_bld_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_bld_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('BALANCE_DIMENSION_ID', p_rec.balance_dimension_id
      );
    --
    pay_bld_rkd.after_delete
      (p_balance_dimension_id
      => p_rec.balance_dimension_id
      ,p_business_group_id_o
      => pay_bld_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_bld_shd.g_old_rec.legislation_code
      ,p_route_id_o
      => pay_bld_shd.g_old_rec.route_id
      ,p_database_item_suffix_o
      => pay_bld_shd.g_old_rec.database_item_suffix
      ,p_dimension_name_o
      => pay_bld_shd.g_old_rec.dimension_name
      ,p_dimension_type_o
      => pay_bld_shd.g_old_rec.dimension_type
      ,p_description_o
      => pay_bld_shd.g_old_rec.description
      ,p_feed_checking_code_o
      => pay_bld_shd.g_old_rec.feed_checking_code
      ,p_legislation_subgroup_o
      => pay_bld_shd.g_old_rec.legislation_subgroup
      ,p_payments_flag_o
      => pay_bld_shd.g_old_rec.payments_flag
      ,p_expiry_checking_code_o
      => pay_bld_shd.g_old_rec.expiry_checking_code
      ,p_expiry_checking_level_o
      => pay_bld_shd.g_old_rec.expiry_checking_level
      ,p_feed_checking_type_o
      => pay_bld_shd.g_old_rec.feed_checking_type
      ,p_dimension_level_o
      => pay_bld_shd.g_old_rec.dimension_level
      ,p_period_type_o
      => pay_bld_shd.g_old_rec.period_type
      ,p_asg_action_balance_dim_id_o
      => pay_bld_shd.g_old_rec.asg_action_balance_dim_id
      ,p_database_item_function_o
      => pay_bld_shd.g_old_rec.database_item_function
      ,p_save_run_balance_enabled_o
      => pay_bld_shd.g_old_rec.save_run_balance_enabled
      ,p_start_date_code_o
      => pay_bld_shd.g_old_rec.start_date_code
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_DIMENSIONS'
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
  (p_rec              in pay_bld_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_bld_shd.lck
    (p_rec.balance_dimension_id
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_bld_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_bld_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_bld_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_bld_del.post_delete(p_rec);
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
  (p_balance_dimension_id                 in     number
  ) is
--
  l_rec   pay_bld_shd.g_rec_type;
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
  l_rec.balance_dimension_id := p_balance_dimension_id;
  --
  --
  -- Having converted the arguments into the pay_bld_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_bld_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_bld_del;

/
