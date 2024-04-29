--------------------------------------------------------
--  DDL for Package Body GHR_PDI_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_DEL" as
/* $Header: ghpdirhi.pkb 120.1 2005/06/13 12:28:25 vravikan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdi_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ----ghr_pdi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ghr_position_descriptions row.
  --
  delete from ghr_position_descriptions
  where position_description_id = p_rec.position_description_id;
  --
--ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ----ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ghr_pdi_shd.g_rec_type) is
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     ghr_pdi_rkd.after_delete	(
      p_position_description_id => p_rec.position_description_id,
      p_classifier_date_o       => ghr_pdi_shd.g_old_rec.classifier_date,
--      p_pa_request_id_o         => ghr_pdi_shd.g_old_rec.pa_request_id,
      p_attribute_category_o    => ghr_pdi_shd.g_old_rec.attribute_category,
      p_routing_group_id_o      => ghr_pdi_shd.g_old_rec.routing_group_id,
      p_date_from_o             => ghr_pdi_shd.g_old_rec.date_from,
      p_date_to_o               => ghr_pdi_shd.g_old_rec.date_to,
      p_opm_cert_num_o          => ghr_pdi_shd.g_old_rec.opm_cert_num,
      p_flsa_o                  => ghr_pdi_shd.g_old_rec.flsa,
      p_financial_statement_o   => ghr_pdi_shd.g_old_rec.financial_statement,
      p_subject_to_ia_action_o  => ghr_pdi_shd.g_old_rec.subject_to_ia_action,
      p_position_status_o       => ghr_pdi_shd.g_old_rec.position_status,
      p_position_is_o           => ghr_pdi_shd.g_old_rec.position_is,
      p_position_sensitivity_o  => ghr_pdi_shd.g_old_rec.position_sensitivity,
      p_competitive_level_o     => ghr_pdi_shd.g_old_rec.competitive_level,
      p_pd_remarks_o            => ghr_pdi_shd.g_old_rec.pd_remarks,
      p_position_class_std_o    => ghr_pdi_shd.g_old_rec.position_class_std,
      p_category_o              => ghr_pdi_shd.g_old_rec.category,
      p_career_ladder_o         => ghr_pdi_shd.g_old_rec.career_ladder,
      p_supervisor_name_o       => ghr_pdi_shd.g_old_rec.supervisor_name,
      p_supervisor_title_o      => ghr_pdi_shd.g_old_rec.supervisor_title,
      p_supervisor_date_o       => ghr_pdi_shd.g_old_rec.supervisor_date,
      p_manager_name_o          => ghr_pdi_shd.g_old_rec.manager_name,
      p_manager_title_o         => ghr_pdi_shd.g_old_rec.manager_title,
      p_manager_date_o          => ghr_pdi_shd.g_old_rec.manager_date,
      p_classifier_name_o       => ghr_pdi_shd.g_old_rec.classifier_name,
      p_classifier_title_o      => ghr_pdi_shd.g_old_rec.classifier_title,
      p_attribute1_o            => ghr_pdi_shd.g_old_rec.attribute1,
      p_attribute2_o            => ghr_pdi_shd.g_old_rec.attribute2,
      p_attribute3_o            => ghr_pdi_shd.g_old_rec.attribute3,
      p_attribute4_o            => ghr_pdi_shd.g_old_rec.attribute4,
      p_attribute5_o            => ghr_pdi_shd.g_old_rec.attribute5,
      p_attribute6_o            => ghr_pdi_shd.g_old_rec.attribute6,
      p_attribute7_o            => ghr_pdi_shd.g_old_rec.attribute7,
      p_attribute8_o            => ghr_pdi_shd.g_old_rec.attribute8,
      p_attribute9_o            => ghr_pdi_shd.g_old_rec.attribute9,
      p_attribute10_o           => ghr_pdi_shd.g_old_rec.attribute10,
      p_attribute11_o           => ghr_pdi_shd.g_old_rec.attribute11,
      p_attribute12_o           => ghr_pdi_shd.g_old_rec.attribute12,
      p_attribute13_o           => ghr_pdi_shd.g_old_rec.attribute13,
      p_attribute14_o           => ghr_pdi_shd.g_old_rec.attribute14,
      p_attribute15_o           => ghr_pdi_shd.g_old_rec.attribute15,
      p_attribute16_o           => ghr_pdi_shd.g_old_rec.attribute16,
      p_attribute17_o           => ghr_pdi_shd.g_old_rec.attribute17,
      p_attribute18_o           => ghr_pdi_shd.g_old_rec.attribute18,
      p_attribute19_o           => ghr_pdi_shd.g_old_rec.attribute19,
      p_attribute20_o           => ghr_pdi_shd.g_old_rec.attribute20,
      p_business_group_id_o           => ghr_pdi_shd.g_old_rec.business_group_id,
      p_object_version_number_o => ghr_pdi_shd.g_old_rec.object_version_number
      );

  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_POSITION_DESCRIPTIONS'
			,p_hook_type   => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in ghr_pdi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ghr_pdi_shd.lck
	(
	p_rec.position_description_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ghr_pdi_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_position_description_id            in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ghr_pdi_shd.g_rec_type;
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
  l_rec.position_description_id:= p_position_description_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ghr_pdi_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ghr_pdi_del;

/
