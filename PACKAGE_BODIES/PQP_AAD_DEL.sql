--------------------------------------------------------
--  DDL for Package Body PQP_AAD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAD_DEL" as
/* $Header: pqaadrhi.pkb 115.5 2003/02/17 22:13:35 tmehra ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_aad_del.';  -- Global package name
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
Procedure delete_dml(p_rec in pqp_aad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_aad_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_analyzed_alien_data row.
  --
  delete from pqp_analyzed_alien_data
  where analyzed_data_id = p_rec.analyzed_data_id;
  --
  pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_aad_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_aad_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqp_aad_shd.g_rec_type) is
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
Procedure post_delete(
p_effective_date in date,p_rec in pqp_aad_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    pqp_aad_rkd.after_delete
      (
  p_analyzed_data_id              =>p_rec.analyzed_data_id
 ,p_assignment_id_o               =>pqp_aad_shd.g_old_rec.assignment_id
 ,p_data_source_o                 =>pqp_aad_shd.g_old_rec.data_source
 ,p_tax_year_o                    =>pqp_aad_shd.g_old_rec.tax_year
 ,p_current_residency_status_o    =>pqp_aad_shd.g_old_rec.current_residency_status
 ,p_nra_to_ra_date_o              =>pqp_aad_shd.g_old_rec.nra_to_ra_date
 ,p_target_departure_date_o       =>pqp_aad_shd.g_old_rec.target_departure_date
 ,p_tax_residence_country_code_o  =>pqp_aad_shd.g_old_rec.tax_residence_country_code
 ,p_treaty_info_update_date_o     =>pqp_aad_shd.g_old_rec.treaty_info_update_date
 ,p_number_of_days_in_usa_o       =>pqp_aad_shd.g_old_rec.number_of_days_in_usa
 ,p_withldg_allow_eligible_fla_o =>pqp_aad_shd.g_old_rec.withldg_allow_eligible_flag
 ,p_ra_effective_date_o           =>pqp_aad_shd.g_old_rec.ra_effective_date
 ,p_record_source_o               =>pqp_aad_shd.g_old_rec.record_source
 ,p_visa_type_o                   =>pqp_aad_shd.g_old_rec.visa_type
 ,p_j_sub_type_o                  =>pqp_aad_shd.g_old_rec.j_sub_type
 ,p_primary_activity_o            =>pqp_aad_shd.g_old_rec.primary_activity
 ,p_non_us_country_code_o         =>pqp_aad_shd.g_old_rec.non_us_country_code
 ,p_citizenship_country_code_o    =>pqp_aad_shd.g_old_rec.citizenship_country_code
 ,p_object_version_number_o       =>pqp_aad_shd.g_old_rec.object_version_number
,p_date_8233_signed_o             =>pqp_aad_shd.g_old_rec.date_8233_signed
,p_date_w4_signed_o               =>pqp_aad_shd.g_old_rec.date_w4_signed
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec	      in pqp_aad_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_aad_shd.lck
	(
	p_rec.analyzed_data_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  pqp_aad_bus.delete_validate(p_rec
  ,p_effective_date);
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
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_analyzed_data_id                   in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  pqp_aad_shd.g_rec_type;
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
  l_rec.analyzed_data_id:= p_analyzed_data_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the analyzed_alien_data_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_aad_del;

/
