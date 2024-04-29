--------------------------------------------------------
--  DDL for Package Body PER_CAG_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAG_DEL" as
/* $Header: pecagrhi.pkb 120.1 2006/10/18 08:42:10 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cag_del.';  -- Global package name
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
--   (Note: Philippe 4/20/99 Removed the need for setting g_api_dml as this is a new
--    table and therefore there is no ovn trigger to use it).
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
Procedure delete_dml(p_rec in per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Delete the per_collective_agreements row.
  --
  delete from per_collective_agreements
  where collective_agreement_id = p_rec.collective_agreement_id;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_cag_shd.constraint_error
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
Procedure pre_delete(p_rec in per_cag_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_cag_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    per_cag_rkd.after_delete
     ( p_collective_agreement_id    =>p_rec.collective_agreement_id,
       p_business_group_id          =>per_cag_shd.g_old_rec.business_group_id,
       p_object_version_number      =>per_cag_shd.g_old_rec.object_version_number,
       p_name                       =>per_cag_shd.g_old_rec.name,
       p_status                 =>per_cag_shd.g_old_rec.status,
       p_cag_number                 =>per_cag_shd.g_old_rec.cag_number,
       p_description                =>per_cag_shd.g_old_rec.description,
       p_start_date                 =>per_cag_shd.g_old_rec.start_date,
       p_end_date                   =>per_cag_shd.g_old_rec.end_date,
       p_employer_organization_id   =>per_cag_shd.g_old_rec.employer_organization_id,
       p_employer_signatory         =>per_cag_shd.g_old_rec.employer_signatory,
       p_bargaining_organization_id =>per_cag_shd.g_old_rec.bargaining_organization_id,
       p_bargaining_unit_signatory  =>per_cag_shd.g_old_rec.bargaining_unit_signatory,
       p_jurisdiction               =>per_cag_shd.g_old_rec.jurisdiction,
       p_authorizing_body           =>per_cag_shd.g_old_rec.authorizing_body,
       p_authorized_date            =>per_cag_shd.g_old_rec.authorized_date,
       p_cag_information_category   =>per_cag_shd.g_old_rec.cag_information_category,
       p_cag_information1           =>per_cag_shd.g_old_rec.cag_information1,
       p_cag_information2           =>per_cag_shd.g_old_rec.cag_information2,
       p_cag_information3           =>per_cag_shd.g_old_rec.cag_information3,
       p_cag_information4           =>per_cag_shd.g_old_rec.cag_information4,
       p_cag_information5           =>per_cag_shd.g_old_rec.cag_information5,
       p_cag_information6           =>per_cag_shd.g_old_rec.cag_information6,
       p_cag_information7           =>per_cag_shd.g_old_rec.cag_information7,
       p_cag_information8           =>per_cag_shd.g_old_rec.cag_information8,
       p_cag_information9           =>per_cag_shd.g_old_rec.cag_information9,
       p_cag_information10          =>per_cag_shd.g_old_rec.cag_information10,
       p_cag_information11          =>per_cag_shd.g_old_rec.cag_information11,
       p_cag_information12          =>per_cag_shd.g_old_rec.cag_information12,
       p_cag_information13          =>per_cag_shd.g_old_rec.cag_information13,
       p_cag_information14          =>per_cag_shd.g_old_rec.cag_information14,
       p_cag_information15          =>per_cag_shd.g_old_rec.cag_information15,
       p_cag_information16          =>per_cag_shd.g_old_rec.cag_information16,
       p_cag_information17          =>per_cag_shd.g_old_rec.cag_information17,
       p_cag_information18          =>per_cag_shd.g_old_rec.cag_information18,
       p_cag_information19          =>per_cag_shd.g_old_rec.cag_information19,
       p_cag_information20          =>per_cag_shd.g_old_rec.cag_information20,
       p_attribute_category         =>per_cag_shd.g_old_rec.attribute_category,
       p_attribute1                 =>per_cag_shd.g_old_rec.attribute1,
       p_attribute2                 =>per_cag_shd.g_old_rec.attribute2,
       p_attribute3                 =>per_cag_shd.g_old_rec.attribute3,
       p_attribute4                 =>per_cag_shd.g_old_rec.attribute4,
       p_attribute5                 =>per_cag_shd.g_old_rec.attribute5,
       p_attribute6                 =>per_cag_shd.g_old_rec.attribute6,
       p_attribute7                 =>per_cag_shd.g_old_rec.attribute7,
       p_attribute8                 =>per_cag_shd.g_old_rec.attribute8,
       p_attribute9                 =>per_cag_shd.g_old_rec.attribute9,
       p_attribute10                =>per_cag_shd.g_old_rec.attribute10,
       p_attribute11                =>per_cag_shd.g_old_rec.attribute11,
       p_attribute12                =>per_cag_shd.g_old_rec.attribute12,
       p_attribute13                =>per_cag_shd.g_old_rec.attribute13,
       p_attribute14                =>per_cag_shd.g_old_rec.attribute14,
       p_attribute15                =>per_cag_shd.g_old_rec.attribute15,
       p_attribute16                =>per_cag_shd.g_old_rec.attribute16,
       p_attribute17                =>per_cag_shd.g_old_rec.attribute17,
       p_attribute18                =>per_cag_shd.g_old_rec.attribute18,
       p_attribute19                =>per_cag_shd.g_old_rec.attribute19,
       p_attribute20                =>per_cag_shd.g_old_rec.attribute20
     );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'per_collective_agreements'
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
  p_rec	      in per_cag_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_cag_shd.lck
	(
	p_rec.collective_agreement_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_cag_bus.delete_validate(p_rec);
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
  p_collective_agreement_id            in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  per_cag_shd.g_rec_type;
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
  l_rec.collective_agreement_id:= p_collective_agreement_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_cag_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_cag_del;

/
