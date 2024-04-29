--------------------------------------------------------
--  DDL for Package Body HR_ORI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORI_DEL" as
/* $Header: hrorirhi.pkb 120.3.12010000.2 2008/08/06 08:45:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ori_del.';  -- Global package name
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
  (p_rec in hr_ori_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_ori_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the hr_organization_information row.
  --
  delete from hr_organization_information
  where org_information_id = p_rec.org_information_id;
  --
  hr_ori_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    hr_ori_shd.g_api_dml := false;   -- Unset the api dml status
    hr_ori_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    hr_ori_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in hr_ori_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   delete dml.
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
Procedure post_delete(p_rec in hr_ori_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    hr_ori_rkd.after_delete
      (p_org_information_id
      => p_rec.org_information_id
      ,p_org_information_context_o
      => hr_ori_shd.g_old_rec.org_information_context
      ,p_organization_id_o
      => hr_ori_shd.g_old_rec.organization_id
      ,p_org_information1_o
      => hr_ori_shd.g_old_rec.org_information1
      ,p_org_information10_o
      => hr_ori_shd.g_old_rec.org_information10
      ,p_org_information11_o
      => hr_ori_shd.g_old_rec.org_information11
      ,p_org_information12_o
      => hr_ori_shd.g_old_rec.org_information12
      ,p_org_information13_o
      => hr_ori_shd.g_old_rec.org_information13
      ,p_org_information14_o
      => hr_ori_shd.g_old_rec.org_information14
      ,p_org_information15_o
      => hr_ori_shd.g_old_rec.org_information15
      ,p_org_information16_o
      => hr_ori_shd.g_old_rec.org_information16
      ,p_org_information17_o
      => hr_ori_shd.g_old_rec.org_information17
      ,p_org_information18_o
      => hr_ori_shd.g_old_rec.org_information18
      ,p_org_information19_o
      => hr_ori_shd.g_old_rec.org_information19
      ,p_org_information2_o
      => hr_ori_shd.g_old_rec.org_information2
      ,p_org_information20_o
      => hr_ori_shd.g_old_rec.org_information20
      ,p_org_information3_o
      => hr_ori_shd.g_old_rec.org_information3
      ,p_org_information4_o
      => hr_ori_shd.g_old_rec.org_information4
      ,p_org_information5_o
      => hr_ori_shd.g_old_rec.org_information5
      ,p_org_information6_o
      => hr_ori_shd.g_old_rec.org_information6
      ,p_org_information7_o
      => hr_ori_shd.g_old_rec.org_information7
      ,p_org_information8_o
      => hr_ori_shd.g_old_rec.org_information8
      ,p_org_information9_o
      => hr_ori_shd.g_old_rec.org_information9
      ,p_request_id_o
      => hr_ori_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => hr_ori_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => hr_ori_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => hr_ori_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => hr_ori_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hr_ori_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hr_ori_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hr_ori_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hr_ori_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hr_ori_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hr_ori_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hr_ori_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hr_ori_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hr_ori_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hr_ori_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hr_ori_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hr_ori_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hr_ori_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hr_ori_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hr_ori_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hr_ori_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hr_ori_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hr_ori_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hr_ori_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hr_ori_shd.g_old_rec.attribute20
      ,p_object_version_number_o
      => hr_ori_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ORGANIZATION_INFORMATION'
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
  (p_rec       in hr_ori_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_ori_shd.lck
    (p_rec.org_information_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_ori_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hr_ori_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_ori_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_ori_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_org_information_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec    hr_ori_shd.g_rec_type;
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
  l_rec.org_information_id := p_org_information_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_ori_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_ori_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_ori_del;

/
