--------------------------------------------------------
--  DDL for Package Body IRC_IPD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPD_DEL" as
/* $Header: iripdrhi.pkb 120.0 2005/07/26 15:09:42 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ipd_del.';  -- Global package name
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
  (p_rec in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the irc_pending_data row.
  --
  delete from irc_pending_data
  where pending_data_id = p_rec.pending_data_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    irc_ipd_shd.constraint_error
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
Procedure pre_delete(p_rec in irc_ipd_shd.g_rec_type) is
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
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in irc_ipd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_ipd_rkd.after_delete
      (p_pending_data_id
      => p_rec.pending_data_id
      ,p_email_address_o
      => irc_ipd_shd.g_old_rec.email_address
      ,p_vacancy_id_o
      => irc_ipd_shd.g_old_rec.vacancy_id
      ,p_last_name_o
      => irc_ipd_shd.g_old_rec.last_name
      ,p_first_name_o
      => irc_ipd_shd.g_old_rec.first_name
      ,p_user_password_o
      => irc_ipd_shd.g_old_rec.user_password
      ,p_resume_file_name_o
      => irc_ipd_shd.g_old_rec.resume_file_name
      ,p_resume_description_o
      => irc_ipd_shd.g_old_rec.resume_description
      ,p_resume_mime_type_o
      => irc_ipd_shd.g_old_rec.resume_mime_type
      ,p_source_type_o
      => irc_ipd_shd.g_old_rec.source_type
      ,p_job_post_source_name_o
      => irc_ipd_shd.g_old_rec.job_post_source_name
      ,p_posting_content_id_o
      => irc_ipd_shd.g_old_rec.posting_content_id
      ,p_person_id_o
      => irc_ipd_shd.g_old_rec.person_id
      ,p_processed_o
      => irc_ipd_shd.g_old_rec.processed
      ,p_sex_o
      => irc_ipd_shd.g_old_rec.sex
      ,p_date_of_birth_o
      => irc_ipd_shd.g_old_rec.date_of_birth
      ,p_per_information_category_o
      => irc_ipd_shd.g_old_rec.per_information_category
      ,p_per_information1_o
      => irc_ipd_shd.g_old_rec.per_information1
      ,p_per_information2_o
      => irc_ipd_shd.g_old_rec.per_information2
      ,p_per_information3_o
      => irc_ipd_shd.g_old_rec.per_information3
      ,p_per_information4_o
      => irc_ipd_shd.g_old_rec.per_information4
      ,p_per_information5_o
      => irc_ipd_shd.g_old_rec.per_information5
      ,p_per_information6_o
      => irc_ipd_shd.g_old_rec.per_information6
      ,p_per_information7_o
      => irc_ipd_shd.g_old_rec.per_information7
      ,p_per_information8_o
      => irc_ipd_shd.g_old_rec.per_information8
      ,p_per_information9_o
      => irc_ipd_shd.g_old_rec.per_information9
      ,p_per_information10_o
      => irc_ipd_shd.g_old_rec.per_information10
      ,p_per_information11_o
      => irc_ipd_shd.g_old_rec.per_information11
      ,p_per_information12_o
      => irc_ipd_shd.g_old_rec.per_information12
      ,p_per_information13_o
      => irc_ipd_shd.g_old_rec.per_information13
      ,p_per_information14_o
      => irc_ipd_shd.g_old_rec.per_information14
      ,p_per_information15_o
      => irc_ipd_shd.g_old_rec.per_information15
      ,p_per_information16_o
      => irc_ipd_shd.g_old_rec.per_information16
      ,p_per_information17_o
      => irc_ipd_shd.g_old_rec.per_information17
      ,p_per_information18_o
      => irc_ipd_shd.g_old_rec.per_information18
      ,p_per_information19_o
      => irc_ipd_shd.g_old_rec.per_information19
      ,p_per_information20_o
      => irc_ipd_shd.g_old_rec.per_information20
      ,p_per_information21_o
      => irc_ipd_shd.g_old_rec.per_information21
      ,p_per_information22_o
      => irc_ipd_shd.g_old_rec.per_information22
      ,p_per_information23_o
      => irc_ipd_shd.g_old_rec.per_information23
      ,p_per_information24_o
      => irc_ipd_shd.g_old_rec.per_information24
      ,p_per_information25_o
      => irc_ipd_shd.g_old_rec.per_information25
      ,p_per_information26_o
      => irc_ipd_shd.g_old_rec.per_information26
      ,p_per_information27_o
      => irc_ipd_shd.g_old_rec.per_information27
      ,p_per_information28_o
      => irc_ipd_shd.g_old_rec.per_information28
      ,p_per_information29_o
      => irc_ipd_shd.g_old_rec.per_information29
      ,p_per_information30_o
      => irc_ipd_shd.g_old_rec.per_information30
      ,p_error_message_o
      => irc_ipd_shd.g_old_rec.error_message
      ,p_creation_date_o
      => irc_ipd_shd.g_old_rec.creation_date
      ,p_last_update_date_o
      => irc_ipd_shd.g_old_rec.last_update_date
      ,p_allow_access_o
      => irc_ipd_shd.g_old_rec.allow_access
      ,p_visitor_resp_key_o
      => irc_ipd_shd.g_old_rec.visitor_resp_key
      ,p_visitor_resp_appl_id_o
      => irc_ipd_shd.g_old_rec.visitor_resp_appl_id
      ,p_security_group_key_o
      => irc_ipd_shd.g_old_rec.security_group_key
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_PENDING_DATA'
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
  (p_rec              in irc_ipd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  irc_ipd_shd.lck
    (p_rec.pending_data_id
    );
  --
  -- Call the supporting delete validate operation
  --
  irc_ipd_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  irc_ipd_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  irc_ipd_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  irc_ipd_del.post_delete(p_rec);
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
  (p_pending_data_id                      in     number
  ) is
--
  l_rec   irc_ipd_shd.g_rec_type;
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
  l_rec.pending_data_id := p_pending_data_id;
  --
  --
  -- Having converted the arguments into the irc_ipd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  irc_ipd_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end irc_ipd_del;

/
