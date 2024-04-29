--------------------------------------------------------
--  DDL for Package Body PER_PDS_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDS_DEL" as
/* $Header: pepdsrhi.pkb 120.7.12010000.2 2009/07/15 10:28:27 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pds_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of this
--   procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_pds_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_periods_of_service row.
  --
  delete from per_periods_of_service
  where  period_of_service_id  = p_rec.period_of_service_id
  and    object_version_number = p_rec.object_version_number;
  --
  per_pds_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
    per_pds_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_pds_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_pds_shd.g_rec_type) is
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
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(p_rec in per_pds_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
-- Start of API User Hook for post_delete.
  begin
    per_pds_rkd.after_delete
    (
     p_period_of_service_id         =>p_rec.period_of_service_id
    ,p_business_group_id_o          =>per_pds_shd.g_old_rec.business_group_id
    ,p_person_id_o                  =>per_pds_shd.g_old_rec.person_id
    ,p_terminat_accepted_person_o   =>per_pds_shd.g_old_rec.termination_accepted_person_id
    ,p_date_start_o                 =>per_pds_shd.g_old_rec.date_start
    ,p_accepted_termination_date_o  =>per_pds_shd.g_old_rec.accepted_termination_date
    ,p_actual_termination_date_o    =>per_pds_shd.g_old_rec.actual_termination_date
    ,p_comments_o                   =>per_pds_shd.g_old_rec.comments
    ,p_adjusted_svc_date_o          =>per_pds_shd.g_old_rec.adjusted_svc_date
    ,p_final_process_date_o         =>per_pds_shd.g_old_rec.final_process_date
    ,p_last_standard_process_date_o =>per_pds_shd.g_old_rec.last_standard_process_date
    ,p_leaving_reason_o             =>per_pds_shd.g_old_rec.leaving_reason
    ,p_notified_termination_date_o  =>per_pds_shd.g_old_rec.notified_termination_date
    ,p_projected_termination_date_o =>per_pds_shd.g_old_rec.projected_termination_date
    ,p_request_id_o                 =>per_pds_shd.g_old_rec.request_id
    ,p_program_application_id_o     =>per_pds_shd.g_old_rec.program_application_id
    ,p_program_id_o                 =>per_pds_shd.g_old_rec.program_id
    ,p_program_update_date_o        =>per_pds_shd.g_old_rec.program_update_date
    ,p_attribute_category_o         =>per_pds_shd.g_old_rec.attribute_category
    ,p_attribute1_o                 =>per_pds_shd.g_old_rec.attribute1
    ,p_attribute2_o                 =>per_pds_shd.g_old_rec.attribute2
    ,p_attribute3_o                 =>per_pds_shd.g_old_rec.attribute3
    ,p_attribute4_o                 =>per_pds_shd.g_old_rec.attribute4
    ,p_attribute5_o                 =>per_pds_shd.g_old_rec.attribute5
    ,p_attribute6_o                 =>per_pds_shd.g_old_rec.attribute6
    ,p_attribute7_o                 =>per_pds_shd.g_old_rec.attribute7
    ,p_attribute8_o                 =>per_pds_shd.g_old_rec.attribute8
    ,p_attribute9_o                 =>per_pds_shd.g_old_rec.attribute9
    ,p_attribute10_o                =>per_pds_shd.g_old_rec.attribute10
    ,p_attribute11_o                =>per_pds_shd.g_old_rec.attribute11
    ,p_attribute12_o                =>per_pds_shd.g_old_rec.attribute12
    ,p_attribute13_o                =>per_pds_shd.g_old_rec.attribute13
    ,p_attribute14_o                =>per_pds_shd.g_old_rec.attribute14
    ,p_attribute15_o                =>per_pds_shd.g_old_rec.attribute15
    ,p_attribute16_o                =>per_pds_shd.g_old_rec.attribute16
    ,p_attribute17_o                =>per_pds_shd.g_old_rec.attribute17
    ,p_attribute18_o                =>per_pds_shd.g_old_rec.attribute18
    ,p_attribute19_o                =>per_pds_shd.g_old_rec.attribute19
    ,p_attribute20_o                =>per_pds_shd.g_old_rec.attribute20
    ,p_object_version_number_o      =>per_pds_shd.g_old_rec.object_version_number
    ,p_prior_employment_ssp_weeks_o =>per_pds_shd.g_old_rec.prior_employment_ssp_weeks
    ,p_prior_employmt_ssp_paid_to_o =>per_pds_shd.g_old_rec.prior_employment_ssp_paid_to
    ,p_pds_information_category_o    =>per_pds_shd.g_old_rec.pds_information_category
    ,p_pds_information1_o            =>per_pds_shd.g_old_rec.pds_information1
    ,p_pds_information2_o            =>per_pds_shd.g_old_rec.pds_information2
    ,p_pds_information3_o            =>per_pds_shd.g_old_rec.pds_information3
    ,p_pds_information4_o            =>per_pds_shd.g_old_rec.pds_information4
    ,p_pds_information5_o            =>per_pds_shd.g_old_rec.pds_information5
    ,p_pds_information6_o            =>per_pds_shd.g_old_rec.pds_information6
    ,p_pds_information7_o            =>per_pds_shd.g_old_rec.pds_information7
    ,p_pds_information8_o            =>per_pds_shd.g_old_rec.pds_information8
    ,p_pds_information9_o            =>per_pds_shd.g_old_rec.pds_information9
    ,p_pds_information10_o           =>per_pds_shd.g_old_rec.pds_information10
    ,p_pds_information11_o           =>per_pds_shd.g_old_rec.pds_information11
    ,p_pds_information12_o           =>per_pds_shd.g_old_rec.pds_information12
    ,p_pds_information13_o           =>per_pds_shd.g_old_rec.pds_information13
    ,p_pds_information14_o           =>per_pds_shd.g_old_rec.pds_information14
    ,p_pds_information15_o           =>per_pds_shd.g_old_rec.pds_information15
    ,p_pds_information16_o           =>per_pds_shd.g_old_rec.pds_information16
    ,p_pds_information17_o           =>per_pds_shd.g_old_rec.pds_information17
    ,p_pds_information18_o           =>per_pds_shd.g_old_rec.pds_information18
    ,p_pds_information19_o           =>per_pds_shd.g_old_rec.pds_information19
    ,p_pds_information20_o           =>per_pds_shd.g_old_rec.pds_information20
    ,p_pds_information21_o           =>per_pds_shd.g_old_rec.pds_information21
    ,p_pds_information22_o           =>per_pds_shd.g_old_rec.pds_information22
    ,p_pds_information23_o           =>per_pds_shd.g_old_rec.pds_information23
    ,p_pds_information24_o           =>per_pds_shd.g_old_rec.pds_information24
    ,p_pds_information25_o           =>per_pds_shd.g_old_rec.pds_information25
    ,p_pds_information26_o           =>per_pds_shd.g_old_rec.pds_information26
    ,p_pds_information27_o           =>per_pds_shd.g_old_rec.pds_information27
    ,p_pds_information28_o           =>per_pds_shd.g_old_rec.pds_information28
    ,p_pds_information29_o           =>per_pds_shd.g_old_rec.pds_information29
    ,p_pds_information30_o           =>per_pds_shd.g_old_rec.pds_information30
     );
    exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_PERIOD_OF_SERVICE'
        ,p_hook_type   => 'AD'
        );
  end;
  -- End of API User Hook for post_delete.
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_rec	      in per_pds_shd.g_rec_type,
  p_validate  in boolean default false
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_per_pds;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_pds_shd.lck
	(
	p_rec.period_of_service_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_pds_bus.delete_validate(p_rec);
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
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_per_pds;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_period_of_service_id               in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  per_pds_shd.g_rec_type;
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
  l_rec.period_of_service_id:= p_period_of_service_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pds_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_pds_del;

/
