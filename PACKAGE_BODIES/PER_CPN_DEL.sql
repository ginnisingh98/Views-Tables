--------------------------------------------------------
--  DDL for Package Body PER_CPN_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CPN_DEL" as
/* $Header: pecpnrhi.pkb 120.0 2005/05/31 07:14:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cpn_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.
--
-- Pre Conditions:
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
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_dml(p_rec in per_cpn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Delete the per_competences row.
  --
  delete from per_competences
  where competence_id = p_rec.competence_id;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_cpn_shd.constraint_error
   (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in per_cpn_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_cpn_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_delete is called here.
  --
  begin
     per_cpn_rkd.after_delete	(
      p_competence_id           => p_rec.competence_id                         ,
      p_business_group_id_o     => per_cpn_shd.g_old_rec.business_group_id     ,
      p_object_version_number_o => per_cpn_shd.g_old_rec.object_version_number ,
      p_name_o                  => per_cpn_shd.g_old_rec.name                  ,
      p_description_o           => per_cpn_shd.g_old_rec.description           ,
      p_date_from_o             => per_cpn_shd.g_old_rec.date_from             ,
      p_date_to_o               => per_cpn_shd.g_old_rec.date_to               ,
      p_behavioural_indicator_o => per_cpn_shd.g_old_rec.behavioural_indicator ,
      p_certification_required_o   =>
                                per_cpn_shd.g_old_rec.certification_required   ,
      p_evaluation_method_o     => per_cpn_shd.g_old_rec.evaluation_method     ,
      p_renewal_period_frequency_o =>
                                per_cpn_shd.g_old_rec.renewal_period_frequency ,
      p_renewal_period_units_o  => per_cpn_shd.g_old_rec.renewal_period_units  ,
      p_max_level_o             => per_cpn_shd.g_old_rec.max_level             ,
      p_min_level_o             => per_cpn_shd.g_old_rec.min_level             ,
      p_rating_scale_id_o       => per_cpn_shd.g_old_rec.rating_scale_id       ,
      p_attribute_category_o    => per_cpn_shd.g_old_rec.attribute_category    ,
      p_attribute1_o            => per_cpn_shd.g_old_rec.attribute1   ,
      p_attribute2_o            => per_cpn_shd.g_old_rec.attribute2   ,
      p_attribute3_o            => per_cpn_shd.g_old_rec.attribute3   ,
      p_attribute4_o            => per_cpn_shd.g_old_rec.attribute4   ,
      p_attribute5_o            => per_cpn_shd.g_old_rec.attribute5   ,
      p_attribute6_o            => per_cpn_shd.g_old_rec.attribute6   ,
      p_attribute7_o            => per_cpn_shd.g_old_rec.attribute7   ,
      p_attribute8_o            => per_cpn_shd.g_old_rec.attribute8   ,
      p_attribute9_o            => per_cpn_shd.g_old_rec.attribute9   ,
      p_attribute10_o           => per_cpn_shd.g_old_rec.attribute10  ,
      p_attribute11_o           => per_cpn_shd.g_old_rec.attribute11  ,
      p_attribute12_o           => per_cpn_shd.g_old_rec.attribute12  ,
      p_attribute13_o           => per_cpn_shd.g_old_rec.attribute13  ,
      p_attribute14_o           => per_cpn_shd.g_old_rec.attribute14  ,
      p_attribute15_o           => per_cpn_shd.g_old_rec.attribute15  ,
      p_attribute16_o           => per_cpn_shd.g_old_rec.attribute16  ,
      p_attribute17_o           => per_cpn_shd.g_old_rec.attribute17  ,
      p_attribute18_o           => per_cpn_shd.g_old_rec.attribute18  ,
      p_attribute19_o           => per_cpn_shd.g_old_rec.attribute19  ,
      p_attribute20_o           => per_cpn_shd.g_old_rec.attribute20  ,
      p_competence_alias_o      => per_cpn_shd.g_old_rec.competence_alias,
      p_competence_definition_id_o      => per_cpn_shd.g_old_rec.competence_definition_id
     ,p_competence_cluster_o    => per_cpn_shd.g_old_rec.competence_cluster
     ,p_unit_standard_id_o      => per_cpn_shd.g_old_rec.unit_standard_id
     ,p_credit_type_o           => per_cpn_shd.g_old_rec.credit_type
     ,p_credits_o               => per_cpn_shd.g_old_rec.credits
     ,p_level_type_o            => per_cpn_shd.g_old_rec.level_type
     ,p_level_number_o          => per_cpn_shd.g_old_rec.level_number
     ,p_field_o                 => per_cpn_shd.g_old_rec.field
     ,p_sub_field_o             => per_cpn_shd.g_old_rec.sub_field
     ,p_provider_o              => per_cpn_shd.g_old_rec.provider
     ,p_qa_organization_o       => per_cpn_shd.g_old_rec.qa_organization
     ,p_information_category_o  => per_cpn_shd.g_old_rec.information_category
     ,p_information1_o          => per_cpn_shd.g_old_rec.information1
     ,p_information2_o          => per_cpn_shd.g_old_rec.information2
     ,p_information3_o          => per_cpn_shd.g_old_rec.information3
     ,p_information4_o          => per_cpn_shd.g_old_rec.information4
     ,p_information5_o          => per_cpn_shd.g_old_rec.information5
     ,p_information6_o          => per_cpn_shd.g_old_rec.information6
     ,p_information7_o          => per_cpn_shd.g_old_rec.information7
     ,p_information8_o          => per_cpn_shd.g_old_rec.information8
     ,p_information9_o          => per_cpn_shd.g_old_rec.information9
     ,p_information10_o         => per_cpn_shd.g_old_rec.information10
     ,p_information11_o         => per_cpn_shd.g_old_rec.information11
     ,p_information12_o         => per_cpn_shd.g_old_rec.information12
     ,p_information13_o         => per_cpn_shd.g_old_rec.information13
     ,p_information14_o         => per_cpn_shd.g_old_rec.information14
     ,p_information15_o         => per_cpn_shd.g_old_rec.information15
     ,p_information16_o         => per_cpn_shd.g_old_rec.information16
     ,p_information17_o         => per_cpn_shd.g_old_rec.information17
     ,p_information18_o         => per_cpn_shd.g_old_rec.information18
     ,p_information19_o         => per_cpn_shd.g_old_rec.information19
     ,p_information20_o         => per_cpn_shd.g_old_rec.information20
     );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_COMPETENCES'
		 	,p_hook_type  => 'AD'
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
  p_rec	      in per_cpn_shd.g_rec_type,
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
    SAVEPOINT del_per_cpn;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_cpn_shd.lck
	(
	p_rec.competence_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_cpn_bus.delete_validate(p_rec);
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
    ROLLBACK TO del_per_cpn;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_competence_id                      in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  per_cpn_shd.g_rec_type;
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
  l_rec.competence_id:= p_competence_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_cpn_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_cpn_del;

/
