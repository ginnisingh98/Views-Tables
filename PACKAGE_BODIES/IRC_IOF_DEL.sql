--------------------------------------------------------
--  DDL for Package Body IRC_IOF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IOF_DEL" as
/* $Header: iriofrhi.pkb 120.13.12010000.2 2009/03/06 06:12:46 kvenukop ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     private global definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iof_del.';  -- global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this procedure controls the actual dml delete logic. the functions of
--   this procedure are as follows:
--   1) to set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) to delete the specified row from the schema using the primary key in
--      the predicates.
--   3) to trap any constraint violations that may have occurred.
--   4) to raise any other errors.
--
-- prerequisites:
--   this is an internal private procedure which must be called from the del
--   procedure.
--
-- in parameters:
--   a pl/sql record structre.
--
-- post success:
--   the specified row will be delete from the schema.
--
-- post failure:
--   on the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   if a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   if any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- developer implementation notes:
--   none.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure delete_dml
  (p_rec in irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  --
  --
  -- delete the irc_offers row.
  --
  delete from irc_offers
  where offer_id = p_rec.offer_id;
  --
  --
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
--
exception
  when hr_api.child_integrity_violated then
    -- child integrity has been violated
    --
    irc_iof_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  when others then
    --
    raise;
end delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required before
--   the delete dml.
--
-- prerequisites:
--   this is an internal procedure which is called from the del procedure.
--
-- in parameters:
--   a pl/sql record structre.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- developer implementation notes:
--   any pre-processing required before the delete dml is issued should be
--   coded within this procedure. it is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- ----------------------------------------------------------------------------
procedure pre_delete(p_rec in irc_iof_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {start of comments}
--
-- description:
--   this private procedure contains any processing which is required after
--   the delete dml.
--
-- prerequistes:
--   this is an internal procedure which is called from the del procedure.
--
-- in parameters:
--   a pl/sql record structure.
--
-- post success:
--   processing continues.
--
-- post failure:
--   if an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- developer implementation notes:
--   any post-processing required after the delete dml is issued should be
--   coded within this procedure. it is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- access status:
--   internal row handler use only.
--
-- {end of comments}
-- -----------------------------------------------------------------------------
procedure post_delete(p_rec in irc_iof_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  begin
    --
    irc_iof_rkd.after_delete
      (p_offer_id
      => p_rec.offer_id
      ,p_offer_version_o
      => irc_iof_shd.g_old_rec.offer_version
      ,p_latest_offer_o
      => irc_iof_shd.g_old_rec.latest_offer
      ,p_offer_status_o
      => irc_iof_shd.g_old_rec.offer_status
      ,p_discretionary_job_title_o
      => irc_iof_shd.g_old_rec.discretionary_job_title
      ,p_offer_extended_method_o
      => irc_iof_shd.g_old_rec.offer_extended_method
      ,p_respondent_id_o
      => irc_iof_shd.g_old_rec.respondent_id
      ,p_expiry_date_o
      => irc_iof_shd.g_old_rec.expiry_date
      ,p_proposed_start_date_o
      => irc_iof_shd.g_old_rec.proposed_start_date
      ,p_offer_letter_tracking_code_o
      => irc_iof_shd.g_old_rec.offer_letter_tracking_code
      ,p_offer_postal_service_o
      => irc_iof_shd.g_old_rec.offer_postal_service
      ,p_offer_shipping_date_o
      => irc_iof_shd.g_old_rec.offer_shipping_date
      ,p_vacancy_id_o
      => irc_iof_shd.g_old_rec.vacancy_id
      ,p_applicant_assignment_id_o
      => irc_iof_shd.g_old_rec.applicant_assignment_id
      ,p_offer_assignment_id_o
      => irc_iof_shd.g_old_rec.offer_assignment_id
      ,p_address_id_o
      => irc_iof_shd.g_old_rec.address_id
      ,p_template_id_o
      => irc_iof_shd.g_old_rec.template_id
      ,p_offer_letter_file_type_o
      => irc_iof_shd.g_old_rec.offer_letter_file_type
      ,p_offer_letter_file_name_o
      => irc_iof_shd.g_old_rec.offer_letter_file_name
      ,p_attribute_category_o
      => irc_iof_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_iof_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_iof_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_iof_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_iof_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_iof_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_iof_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_iof_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_iof_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_iof_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_iof_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => irc_iof_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => irc_iof_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => irc_iof_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => irc_iof_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => irc_iof_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => irc_iof_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => irc_iof_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => irc_iof_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => irc_iof_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => irc_iof_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => irc_iof_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => irc_iof_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => irc_iof_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => irc_iof_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => irc_iof_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => irc_iof_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => irc_iof_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => irc_iof_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => irc_iof_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => irc_iof_shd.g_old_rec.attribute30
      ,p_object_version_number_o
      => irc_iof_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'irc_offers'
        ,p_hook_type   => 'ad');
      --
  end;
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
procedure del
  (p_rec              in irc_iof_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- we must lock the row which we need to delete.
  --
  irc_iof_shd.lck
    (p_rec.offer_id
    ,p_rec.object_version_number
    );
  --
  -- call the supporting delete validate operation
  --
  irc_iof_bus.delete_validate(p_rec);
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- call the supporting pre-delete operation
  --
  irc_iof_del.pre_delete(p_rec);
  --
  -- delete the row.
  --
  irc_iof_del.delete_dml(p_rec);
  --
  -- call the supporting post-delete operation
  --
  irc_iof_del.post_delete(p_rec);
  --
  -- call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
end del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
procedure del
  (p_offer_id                             in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   irc_iof_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
begin
  hr_utility.set_location('entering:'||l_proc, 5);
  --
  -- as the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- we don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.offer_id := p_offer_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- having converted the arguments into the irc_iof_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  irc_iof_del.del(l_rec);
  --
  hr_utility.set_location(' leaving:'||l_proc, 10);
end del;
--
end irc_iof_del;

/
