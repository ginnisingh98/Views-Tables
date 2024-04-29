--------------------------------------------------------
--  DDL for Package Body PER_CTK_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTK_DEL" as
/* $Header: pectkrhi.pkb 120.7 2006/09/11 20:45:03 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ctk_del.';  -- Global package name
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
  (p_rec in per_ctk_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_tasks_in_checklist row.
  --
  delete from per_tasks_in_checklist
  where task_in_checklist_id = p_rec.task_in_checklist_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_ctk_shd.constraint_error
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
Procedure pre_delete(p_rec in per_ctk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
 -- for elgiy object

  cursor c_elig_obj (p_elig_objid number) is
      select object_version_number,effective_start_date
  from ben_elig_obj_f
  where elig_obj_id = p_elig_objid;

  -- for eligy profile and eligy object
  cursor c_elig_prfl_elig_obj (c_elig_prfl_id number, c_elig_obj_id number) is
  select
    elig_obj_elig_prfl_id,
    object_version_number,
    effective_start_date
  from
   ben_elig_obj_elig_profl_f
  where elig_obj_id = c_elig_obj_id and elig_prfl_id=c_elig_prfl_id;


  l_elig_obj_id           number;
  l_elig_obj_elig_prfl_id number;
  l_prf_ovn               number;
  l_obj_ovn               number;
  l_prf_obj_ovn           number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_effective_date        date;
Begin
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
     if ( nvl(per_ctk_shd.g_old_rec.eligibility_profile_id, hr_api.g_number) <> hr_api.g_number  AND
      nvl(per_ctk_shd.g_old_rec.eligibility_profile_id, hr_api.g_number) <> nvl(p_rec.eligibility_profile_id, hr_api.g_number))   then

      -- delete old eligy profile eligy object (child)
        open c_elig_prfl_elig_obj(per_ctk_shd.g_old_rec.eligibility_profile_id, per_ctk_shd.g_old_rec.eligibility_object_id);
          fetch c_elig_prfl_elig_obj into l_elig_obj_elig_prfl_id,l_prf_obj_ovn,l_effective_date;
          if(c_elig_prfl_elig_obj%found) then
           begin
                ben_ELIG_OBJ_ELIG_PROFL_api.delete_elig_obj_elig_profl
                (
                    p_validate=> false,
                    p_elig_obj_elig_prfl_id=>l_elig_obj_elig_prfl_id,
                    p_effective_start_date=>l_effective_start_date,
                    p_effective_end_date=>l_effective_end_date,
                    p_object_version_number=>l_prf_obj_ovn,
                    p_effective_date=>l_effective_date,
                    p_datetrack_mode =>'ZAP'
                 );
           exception

            when others then
               close c_elig_prfl_elig_obj;
               raise;
           end;
          end if;
        close c_elig_prfl_elig_obj;


        open c_elig_obj(per_ctk_shd.g_old_rec.eligibility_object_id);
          fetch c_elig_obj into l_obj_ovn,l_effective_date;
          if(c_elig_obj%found) then
            begin
                    ben_elig_obj_api.delete_elig_obj
                    (
                        p_validate=>false,
                        p_elig_obj_id=>per_ctk_shd.g_old_rec.eligibility_object_id,
                        p_effective_start_date=>l_effective_start_date,
                        p_effective_end_date=>l_effective_end_date,
                        p_object_version_number=>l_obj_ovn,
                        p_effective_date=>l_effective_date,
                        p_datetrack_mode=>'ZAP'
                    );
            exception
            when others then
                close c_elig_obj;
                raise;
            end;
          end if;
        close c_elig_obj;
   end if;
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
Procedure post_delete(p_rec in per_ctk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_ctk_rkd.after_delete
      (p_task_in_checklist_id
      => p_rec.task_in_checklist_id
      ,p_checklist_id_o
      => per_ctk_shd.g_old_rec.checklist_id
      ,p_checklist_task_name_o
      => per_ctk_shd.g_old_rec.checklist_task_name
      ,p_eligibility_object_id_o
      => per_ctk_shd.g_old_rec.eligibility_object_id
      ,p_eligibility_profile_id_o
      => per_ctk_shd.g_old_rec.eligibility_profile_id
      ,p_ame_attribute_identifier_o
      => per_ctk_shd.g_old_rec.ame_attribute_identifier
      ,p_description_o
      => per_ctk_shd.g_old_rec.description
      ,p_mandatory_flag_o
      => per_ctk_shd.g_old_rec.mandatory_flag
      ,p_target_duration_o
      => per_ctk_shd.g_old_rec.target_duration
      ,p_target_duration_uom_o
      => per_ctk_shd.g_old_rec.target_duration_uom
      ,p_task_sequence_o
      => per_ctk_shd.g_old_rec.task_sequence
      ,p_object_version_number_o
      => per_ctk_shd.g_old_rec.object_version_number
      ,p_action_url_o
      => per_ctk_shd.g_old_rec.action_url
      ,p_attribute_category_o
      => per_ctk_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => per_ctk_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => per_ctk_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => per_ctk_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => per_ctk_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => per_ctk_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => per_ctk_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => per_ctk_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => per_ctk_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => per_ctk_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => per_ctk_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => per_ctk_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => per_ctk_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => per_ctk_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => per_ctk_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => per_ctk_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => per_ctk_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => per_ctk_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => per_ctk_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => per_ctk_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => per_ctk_shd.g_old_rec.attribute20
      ,p_information_category_o
      => per_ctk_shd.g_old_rec.information_category
      ,p_information1_o
      => per_ctk_shd.g_old_rec.information1
      ,p_information2_o
      => per_ctk_shd.g_old_rec.information2
      ,p_information3_o
      => per_ctk_shd.g_old_rec.information3
      ,p_information4_o
      => per_ctk_shd.g_old_rec.information4
      ,p_information5_o
      => per_ctk_shd.g_old_rec.information5
      ,p_information6_o
      => per_ctk_shd.g_old_rec.information6
      ,p_information7_o
      => per_ctk_shd.g_old_rec.information7
      ,p_information8_o
      => per_ctk_shd.g_old_rec.information8
      ,p_information9_o
      => per_ctk_shd.g_old_rec.information9
      ,p_information10_o
      => per_ctk_shd.g_old_rec.information10
      ,p_information11_o
      => per_ctk_shd.g_old_rec.information11
      ,p_information12_o
      => per_ctk_shd.g_old_rec.information12
      ,p_information13_o
      => per_ctk_shd.g_old_rec.information13
      ,p_information14_o
      => per_ctk_shd.g_old_rec.information14
      ,p_information15_o
      => per_ctk_shd.g_old_rec.information15
      ,p_information16_o
      => per_ctk_shd.g_old_rec.information16
      ,p_information17_o
      => per_ctk_shd.g_old_rec.information17
      ,p_information18_o
      => per_ctk_shd.g_old_rec.information18
      ,p_information19_o
      => per_ctk_shd.g_old_rec.information19
      ,p_information20_o
      => per_ctk_shd.g_old_rec.information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_TASKS_IN_CHECKLIST'
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
  (p_rec              in per_ctk_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_ctk_shd.lck
    (p_rec.task_in_checklist_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_ctk_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  per_ctk_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_ctk_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_ctk_del.post_delete(p_rec);
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
  (p_task_in_checklist_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   per_ctk_shd.g_rec_type;
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
  l_rec.task_in_checklist_id := p_task_in_checklist_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_ctk_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_ctk_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_ctk_del;

/
