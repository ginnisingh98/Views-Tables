--------------------------------------------------------
--  DDL for Package Body IRC_IPC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPC_DEL" as
/* $Header: iripcrhi.pkb 120.0 2005/07/26 15:08:54 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipc_del.';  -- Global package name
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
  (p_rec in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  irc_ipc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the irc_posting_contents row.
  --
  delete from irc_posting_contents
  where posting_content_id = p_rec.posting_content_id;
  --
  irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_ipc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    irc_ipc_shd.g_api_dml := false;  -- Unset the api dml status
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
Procedure pre_delete(p_rec in irc_ipc_shd.g_rec_type) is
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
Procedure post_delete(p_rec in irc_ipc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ipc_rkd.after_delete
      (p_posting_content_id
      => p_rec.posting_content_id
      ,p_display_manager_info_o
      => irc_ipc_shd.g_old_rec.display_manager_info
      ,p_display_recruiter_info_o
      => irc_ipc_shd.g_old_rec.display_recruiter_info
      ,p_attribute_category_o
      => irc_ipc_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_ipc_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_ipc_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_ipc_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_ipc_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_ipc_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_ipc_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_ipc_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_ipc_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_ipc_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_ipc_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => irc_ipc_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => irc_ipc_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => irc_ipc_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => irc_ipc_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => irc_ipc_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => irc_ipc_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => irc_ipc_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => irc_ipc_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => irc_ipc_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => irc_ipc_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => irc_ipc_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => irc_ipc_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => irc_ipc_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => irc_ipc_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => irc_ipc_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => irc_ipc_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => irc_ipc_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => irc_ipc_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => irc_ipc_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => irc_ipc_shd.g_old_rec.attribute30
      ,p_ipc_information_category_o
      => irc_ipc_shd.g_old_rec.ipc_information_category
      ,p_ipc_information1_o
      => irc_ipc_shd.g_old_rec.ipc_information1
      ,p_ipc_information2_o
      => irc_ipc_shd.g_old_rec.ipc_information2
      ,p_ipc_information3_o
      => irc_ipc_shd.g_old_rec.ipc_information3
      ,p_ipc_information4_o
      => irc_ipc_shd.g_old_rec.ipc_information4
      ,p_ipc_information5_o
      => irc_ipc_shd.g_old_rec.ipc_information5
      ,p_ipc_information6_o
      => irc_ipc_shd.g_old_rec.ipc_information6
      ,p_ipc_information7_o
      => irc_ipc_shd.g_old_rec.ipc_information7
      ,p_ipc_information8_o
      => irc_ipc_shd.g_old_rec.ipc_information8
      ,p_ipc_information9_o
      => irc_ipc_shd.g_old_rec.ipc_information9
      ,p_ipc_information10_o
      => irc_ipc_shd.g_old_rec.ipc_information10
      ,p_ipc_information11_o
      => irc_ipc_shd.g_old_rec.ipc_information11
      ,p_ipc_information12_o
      => irc_ipc_shd.g_old_rec.ipc_information12
      ,p_ipc_information13_o
      => irc_ipc_shd.g_old_rec.ipc_information13
      ,p_ipc_information14_o
      => irc_ipc_shd.g_old_rec.ipc_information14
      ,p_ipc_information15_o
      => irc_ipc_shd.g_old_rec.ipc_information15
      ,p_ipc_information16_o
      => irc_ipc_shd.g_old_rec.ipc_information16
      ,p_ipc_information17_o
      => irc_ipc_shd.g_old_rec.ipc_information17
      ,p_ipc_information18_o
      => irc_ipc_shd.g_old_rec.ipc_information18
      ,p_ipc_information19_o
      => irc_ipc_shd.g_old_rec.ipc_information19
      ,p_ipc_information20_o
      => irc_ipc_shd.g_old_rec.ipc_information20
      ,p_ipc_information21_o
      => irc_ipc_shd.g_old_rec.ipc_information21
      ,p_ipc_information22_o
      => irc_ipc_shd.g_old_rec.ipc_information22
      ,p_ipc_information23_o
      => irc_ipc_shd.g_old_rec.ipc_information23
      ,p_ipc_information24_o
      => irc_ipc_shd.g_old_rec.ipc_information24
      ,p_ipc_information25_o
      => irc_ipc_shd.g_old_rec.ipc_information25
      ,p_ipc_information26_o
      => irc_ipc_shd.g_old_rec.ipc_information26
      ,p_ipc_information27_o
      => irc_ipc_shd.g_old_rec.ipc_information27
      ,p_ipc_information28_o
      => irc_ipc_shd.g_old_rec.ipc_information28
      ,p_ipc_information29_o
      => irc_ipc_shd.g_old_rec.ipc_information29
      ,p_ipc_information30_o
      => irc_ipc_shd.g_old_rec.ipc_information30
      ,p_object_version_number_o
      => irc_ipc_shd.g_old_rec.object_version_number
      ,p_date_approved_o
      => irc_ipc_shd.g_old_rec.date_approved
      ,p_recruiter_full_name_o
      => irc_ipc_shd.g_old_rec.recruiter_full_name
      ,p_recruiter_email_o
      => irc_ipc_shd.g_old_rec.recruiter_email
      ,p_recruiter_work_telephone_o
      => irc_ipc_shd.g_old_rec.recruiter_work_telephone
      ,p_manager_full_name_o
      => irc_ipc_shd.g_old_rec.manager_full_name
      ,p_manager_email_o
      => irc_ipc_shd.g_old_rec.manager_email
      ,p_manager_work_telephone_o
      => irc_ipc_shd.g_old_rec.manager_work_telephone
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_POSTING_CONTENTS'
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
  (p_rec              in irc_ipc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  irc_ipc_shd.lck
    (p_rec.posting_content_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  irc_ipc_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  irc_ipc_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  irc_ipc_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  irc_ipc_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_posting_content_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   irc_ipc_shd.g_rec_type;
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
  l_rec.posting_content_id := p_posting_content_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the irc_ipc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  irc_ipc_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end irc_ipc_del;

/
