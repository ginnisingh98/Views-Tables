--------------------------------------------------------
--  DDL for Package Body IRC_CMP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMP_DEL" as
/* $Header: ircmprhi.pkb 120.0 2007/11/19 11:38:55 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmp_del.';  -- Global package name
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
  (p_rec in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the irc_comm_properties row.
  --
  delete from irc_comm_properties
  where communication_property_id = p_rec.communication_property_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    irc_cmp_shd.constraint_error
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
Procedure pre_delete(p_rec in irc_cmp_shd.g_rec_type) is
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
Procedure post_delete(p_rec in irc_cmp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_cmp_rkd.after_delete
      (p_communication_property_id
      => p_rec.communication_property_id
      ,p_object_type_o
      => irc_cmp_shd.g_old_rec.object_type
      ,p_object_id_o
      => irc_cmp_shd.g_old_rec.object_id
      ,p_default_comm_status_o
      => irc_cmp_shd.g_old_rec.default_comm_status
      ,p_allow_attachment_flag_o
      => irc_cmp_shd.g_old_rec.allow_attachment_flag
      ,p_auto_notification_flag_o
      => irc_cmp_shd.g_old_rec.auto_notification_flag
      ,p_allow_add_recipients_o
      => irc_cmp_shd.g_old_rec.allow_add_recipients
      ,p_default_moderator_o
      => irc_cmp_shd.g_old_rec.default_moderator
      ,p_attribute_category_o
      => irc_cmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_cmp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_cmp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_cmp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_cmp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_cmp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_cmp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_cmp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_cmp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_cmp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_cmp_shd.g_old_rec.attribute10
      ,p_information_category_o
      => irc_cmp_shd.g_old_rec.information_category
      ,p_information1_o
      => irc_cmp_shd.g_old_rec.information1
      ,p_information2_o
      => irc_cmp_shd.g_old_rec.information2
      ,p_information3_o
      => irc_cmp_shd.g_old_rec.information3
      ,p_information4_o
      => irc_cmp_shd.g_old_rec.information4
      ,p_information5_o
      => irc_cmp_shd.g_old_rec.information5
      ,p_information6_o
      => irc_cmp_shd.g_old_rec.information6
      ,p_information7_o
      => irc_cmp_shd.g_old_rec.information7
      ,p_information8_o
      => irc_cmp_shd.g_old_rec.information8
      ,p_information9_o
      => irc_cmp_shd.g_old_rec.information9
      ,p_information10_o
      => irc_cmp_shd.g_old_rec.information10
      ,p_object_version_number_o
      => irc_cmp_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_COMM_PROPERTIES'
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
  (p_rec              in irc_cmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  irc_cmp_shd.lck
    (p_rec.communication_property_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  irc_cmp_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  irc_cmp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  irc_cmp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  irc_cmp_del.post_delete(p_rec);
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
  (p_communication_property_id            in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   irc_cmp_shd.g_rec_type;
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
  l_rec.communication_property_id := p_communication_property_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the irc_cmp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  irc_cmp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end irc_cmp_del;

/
