--------------------------------------------------------
--  DDL for Package Body PQH_CPD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CPD_DEL" as
/* $Header: pqcpdrhi.pkb 120.0 2005/05/29 01:44:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_cpd_del.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
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
  (p_rec in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
    l_proc := g_package||'delete_dml';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  pqh_cpd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqh_corps_definitions row.
  --
  delete from pqh_corps_definitions
  where corps_definition_id = p_rec.corps_definition_id;
  --
  pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
    pqh_cpd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqh_cpd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqh_cpd_shd.g_rec_type) is
--
  l_proc  varchar2(72);
--
Begin
  if g_debug then
    l_proc :=  g_package||'pre_delete';
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
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
Procedure post_delete(p_rec in pqh_cpd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  if g_debug then
     l_proc  := g_package||'post_delete';
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    pqh_cpd_rkd.after_delete
      (p_corps_definition_id
      => p_rec.corps_definition_id
      ,p_business_group_id_o
      => pqh_cpd_shd.g_old_rec.business_group_id
      ,p_name_o
      => pqh_cpd_shd.g_old_rec.name
      ,p_status_cd_o
      => pqh_cpd_shd.g_old_rec.status_cd
      ,p_retirement_age_o
      => pqh_cpd_shd.g_old_rec.retirement_age
      ,p_category_cd_o
      => pqh_cpd_shd.g_old_rec.category_cd
      ,p_recruitment_end_date_o
      => pqh_cpd_shd.g_old_rec.recruitment_end_date
      ,p_corps_type_cd_o
      => pqh_cpd_shd.g_old_rec.corps_type_cd
      ,p_starting_grade_step_id_o
      => pqh_cpd_shd.g_old_rec.starting_grade_step_id
      ,p_task_desc_o
      => pqh_cpd_shd.g_old_rec.task_desc
      ,p_secondment_threshold_o
      => pqh_cpd_shd.g_old_rec.secondment_threshold
      ,p_normal_hours_o
      => pqh_cpd_shd.g_old_rec.normal_hours
      ,p_normal_hours_frequency_o
      => pqh_cpd_shd.g_old_rec.normal_hours_frequency
      ,p_minimum_hours_o
      => pqh_cpd_shd.g_old_rec.minimum_hours
      ,p_minimum_hours_frequency_o
      => pqh_cpd_shd.g_old_rec.minimum_hours_frequency
      ,p_attribute1_o
      => pqh_cpd_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pqh_cpd_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pqh_cpd_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pqh_cpd_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pqh_cpd_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pqh_cpd_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pqh_cpd_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pqh_cpd_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pqh_cpd_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pqh_cpd_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pqh_cpd_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pqh_cpd_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pqh_cpd_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pqh_cpd_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pqh_cpd_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pqh_cpd_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pqh_cpd_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pqh_cpd_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pqh_cpd_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pqh_cpd_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pqh_cpd_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pqh_cpd_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pqh_cpd_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pqh_cpd_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pqh_cpd_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pqh_cpd_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pqh_cpd_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pqh_cpd_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pqh_cpd_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pqh_cpd_shd.g_old_rec.attribute30
      ,p_attribute_category_o
      => pqh_cpd_shd.g_old_rec.attribute_category
      ,p_object_version_number_o
      => pqh_cpd_shd.g_old_rec.object_version_number
      ,p_type_of_ps_o
      => pqh_cpd_shd.g_old_rec.type_of_ps
      ,p_date_from_o
      => pqh_cpd_shd.g_old_rec.date_from
      ,p_date_to_o
      => pqh_cpd_shd.g_old_rec.date_to
      ,p_primary_prof_field_id_o
      => pqh_cpd_shd.g_old_rec.primary_prof_field_id
      ,p_starting_grade_id_o
      => pqh_cpd_shd.g_old_rec.starting_grade_id
      ,p_ben_pgm_id_o
      => pqh_cpd_shd.g_old_rec.ben_pgm_id
      ,p_probation_period_o
      => pqh_cpd_shd.g_old_rec.probation_period
      ,p_probation_units_o
      => pqh_cpd_shd.g_old_rec.probation_units
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_CORPS_DEFINITIONS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in pqh_cpd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     l_proc := g_package||'del';
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  pqh_cpd_shd.lck
    (p_rec.corps_definition_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqh_cpd_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqh_cpd_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqh_cpd_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqh_cpd_del.post_delete(p_rec);
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
  (p_corps_definition_id                  in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqh_cpd_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     l_proc := g_package||'del';
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.corps_definition_id := p_corps_definition_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqh_cpd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqh_cpd_del.del(l_rec);
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end pqh_cpd_del;

/
