--------------------------------------------------------
--  DDL for Package Body PER_PSP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSP_DEL" as
/* $Header: pepsprhi.pkb 115.5 2003/11/17 13:06:07 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_psp_del.';  -- Global package name
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
  (p_rec in per_psp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_psp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_spinal_points row.
  --
  delete from per_spinal_points
  where spinal_point_id = p_rec.spinal_point_id;
  --
  per_psp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_psp_shd.g_api_dml := false;   -- Unset the api dml status
    per_psp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_psp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in per_psp_shd.g_rec_type) is
--
  l_proc   varchar2(72) := g_package||'pre_delete';
  l_return varchar2(30);
  l_message varchar2(2000) := null;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call pqh_gsp_sync_compensation_obj.delete_option_for_point
  --
  hr_utility.trace('prec.spinal_point_id : ' || p_rec.spinal_point_id);
  --
  l_return := pqh_gsp_sync_compensation_obj.delete_option_for_point
    (p_spinal_point_id         => p_rec.spinal_point_id
    );
  --
  hr_utility.trace('pqh_gsp_sync_compensation_obj.delete_option_for_point : '
                  || l_return);
  if l_return <> 'SUCCESS' Then
         l_message := fnd_message.get;
         hr_utility.trace('error message : ' || l_message);

         fnd_message.set_name('PER','HR_289569_DEL_OPTION_FOR_POINT');
         if l_message is not null then
           fnd_message.set_token('ERR_CODE',l_message);
         else
           fnd_message.set_token('ERR_CODE','-1');
         end if;
         --
         fnd_message.raise_error;
  End if;
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
Procedure post_delete(p_rec in per_psp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_psp_rkd.after_delete
      (p_spinal_point_id
      => p_rec.spinal_point_id
      ,p_business_group_id_o
      => per_psp_shd.g_old_rec.business_group_id
      ,p_parent_spine_id_o
      => per_psp_shd.g_old_rec.parent_spine_id
      ,p_sequence_o
      => per_psp_shd.g_old_rec.sequence
      ,p_spinal_point_o
      => per_psp_shd.g_old_rec.spinal_point
      ,p_request_id_o
      => per_psp_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => per_psp_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => per_psp_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => per_psp_shd.g_old_rec.program_update_date
      ,p_object_version_number_o
      => per_psp_shd.g_old_rec.object_version_number
      --
      ,p_information_category_o
      => per_psp_shd.g_old_rec.information_category
      ,p_information1_o
      => per_psp_shd.g_old_rec.information1
      ,p_information2_o
      => per_psp_shd.g_old_rec.information2
      ,p_information3_o
      => per_psp_shd.g_old_rec.information3
      ,p_information4_o
      => per_psp_shd.g_old_rec.information4
      ,p_information5_o
      => per_psp_shd.g_old_rec.information5
      ,p_information6_o
      => per_psp_shd.g_old_rec.information6
      ,p_information7_o
      => per_psp_shd.g_old_rec.information7
      ,p_information8_o
      => per_psp_shd.g_old_rec.information8
      ,p_information9_o
      => per_psp_shd.g_old_rec.information9
      ,p_information10_o
      => per_psp_shd.g_old_rec.information10
      ,p_information11_o
      => per_psp_shd.g_old_rec.information11
      ,p_information12_o
      => per_psp_shd.g_old_rec.information12
      ,p_information13_o
      => per_psp_shd.g_old_rec.information13
      ,p_information14_o
      => per_psp_shd.g_old_rec.information14
      ,p_information15_o
      => per_psp_shd.g_old_rec.information15
      ,p_information16_o
      => per_psp_shd.g_old_rec.information16
      ,p_information17_o
      => per_psp_shd.g_old_rec.information17
      ,p_information18_o
      => per_psp_shd.g_old_rec.information18
      ,p_information19_o
      => per_psp_shd.g_old_rec.information19
      ,p_information20_o
      => per_psp_shd.g_old_rec.information20
      ,p_information21_o
      => per_psp_shd.g_old_rec.information21
      ,p_information22_o
      => per_psp_shd.g_old_rec.information22
      ,p_information23_o
      => per_psp_shd.g_old_rec.information23
      ,p_information24_o
      => per_psp_shd.g_old_rec.information24
      ,p_information25_o
      => per_psp_shd.g_old_rec.information25
      ,p_information26_o
      => per_psp_shd.g_old_rec.information26
      ,p_information27_o
      => per_psp_shd.g_old_rec.information27
      ,p_information28_o
      => per_psp_shd.g_old_rec.information28
      ,p_information29_o
      => per_psp_shd.g_old_rec.information29
      ,p_information30_o
      => per_psp_shd.g_old_rec.information30
--
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SPINAL_POINTS'
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
  (p_rec              in per_psp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- We must lock the row which we need to delete.
  --
  per_psp_shd.lck
    (p_rec.spinal_point_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_psp_bus.delete_validate(p_rec);

  hr_utility.set_location(l_proc, 20);

  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_psp_del.pre_delete(p_rec);

  hr_utility.set_location(l_proc, 30);

  --
  -- Delete the row.
  --
  per_psp_del.delete_dml(p_rec);

  hr_utility.set_location(l_proc, 40);

  --
  -- Call the supporting post-delete operation
  --
  per_psp_del.post_delete(p_rec);

  hr_utility.set_location(l_proc, 50);

  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --

  hr_utility.set_location(l_proc, 60);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_spinal_point_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_psp_shd.g_rec_type;
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
  l_rec.spinal_point_id := p_spinal_point_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_psp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_psp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End del;
--
end per_psp_del;

/
