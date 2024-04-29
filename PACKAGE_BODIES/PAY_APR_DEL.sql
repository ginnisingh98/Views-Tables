--------------------------------------------------------
--  DDL for Package Body PAY_APR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_APR_DEL" as
/* $Header: pyaprrhi.pkb 120.0.12000000.1 2007/01/17 15:39:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33);
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
  (p_rec in pay_apr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'delete_dml';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_apr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_au_processes row.
  --
  delete from pay_au_processes
  where process_id = p_rec.process_id;
  --
  pay_apr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_apr_shd.g_api_dml := false;   -- Unset the api dml status
    pay_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_apr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pay_apr_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'pre_delete';
  --
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
Procedure post_delete(p_rec in pay_apr_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'post_delete';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('PROCESS_ID', p_rec.process_id
      );
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
  (p_rec              in pay_apr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'post_delete';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_apr_shd.lck
    (p_rec.process_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_apr_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_apr_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_apr_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_apr_del.post_delete(p_rec);
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
  (p_process_id                           in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pay_apr_shd.g_rec_type;
  l_proc  varchar2(72);
--
Begin
  l_proc  := g_package||'del';
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.process_id := p_process_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_apr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_apr_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
begin
  g_package  := '  pay_apr_del.';  -- Global package name
end pay_apr_del;

/