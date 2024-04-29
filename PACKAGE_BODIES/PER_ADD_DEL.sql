--------------------------------------------------------
--  DDL for Package Body PER_ADD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_DEL" as
/* $Header: peaddrhi.pkb 120.1.12010000.6 2009/04/13 08:33:06 sgundoju ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_add_del.';  -- Global package name
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
Procedure delete_dml(p_rec in out nocopy per_add_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_add_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the per_addresses row.
  --
  delete from per_addresses
  where address_id = p_rec.address_id;
  --
  per_add_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
    per_add_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_add_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in  per_add_shd.g_rec_type) is
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
Procedure post_delete(p_rec in per_add_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_delete.
  begin
    per_add_rkd.after_delete
      (p_address_id                   => p_rec.address_id
      ,p_business_group_id_o
	  => per_add_shd.g_old_rec.business_group_id
      ,p_date_from_o
          => per_add_shd.g_old_rec.date_from
      ,p_address_line1_o
          => per_add_shd.g_old_rec.address_line1
      ,p_address_line2_o
          => per_add_shd.g_old_rec.address_line2
      ,p_address_line3_o
          => per_add_shd.g_old_rec.address_line3
      ,p_address_type_o
          => per_add_shd.g_old_rec.address_type
      ,p_comments_o
          => per_add_shd.g_old_rec.comments
      ,p_country_o
          => per_add_shd.g_old_rec.country
      ,p_date_to_o
          => per_add_shd.g_old_rec.date_to
      ,p_postal_code_o
          => per_add_shd.g_old_rec.postal_code
      ,p_region_1_o
          => per_add_shd.g_old_rec.region_1
      ,p_region_2_o
          => per_add_shd.g_old_rec.region_2
      ,p_region_3_o
          => per_add_shd.g_old_rec.region_3
      ,p_telephone_number_1_o
          => per_add_shd.g_old_rec.telephone_number_1
      ,p_telephone_number_2_o
          => per_add_shd.g_old_rec.telephone_number_2
      ,p_telephone_number_3_o
          => per_add_shd.g_old_rec.telephone_number_3
      ,p_town_or_city_o
          => per_add_shd.g_old_rec.town_or_city
      ,p_request_id_o
          => per_add_shd.g_old_rec.request_id
      ,p_program_application_id_o
          => per_add_shd.g_old_rec.program_application_id
      ,p_program_id_o
          => per_add_shd.g_old_rec.program_id
      ,p_program_update_date_o
          => per_add_shd.g_old_rec.program_update_date
      ,p_addr_attribute_category_o
          => per_add_shd.g_old_rec.addr_attribute_category
      ,p_addr_attribute1_o
          => per_add_shd.g_old_rec.addr_attribute1
      ,p_addr_attribute2_o
          => per_add_shd.g_old_rec.addr_attribute2
      ,p_addr_attribute3_o
          => per_add_shd.g_old_rec.addr_attribute3
      ,p_addr_attribute4_o
          => per_add_shd.g_old_rec.addr_attribute4
      ,p_addr_attribute5_o
          => per_add_shd.g_old_rec.addr_attribute5
      ,p_addr_attribute6_o
          => per_add_shd.g_old_rec.addr_attribute6
      ,p_addr_attribute7_o
          => per_add_shd.g_old_rec.addr_attribute7
      ,p_addr_attribute8_o
          => per_add_shd.g_old_rec.addr_attribute8
      ,p_addr_attribute9_o
          => per_add_shd.g_old_rec.addr_attribute9
      ,p_addr_attribute10_o
          => per_add_shd.g_old_rec.addr_attribute10
      ,p_addr_attribute11_o
          => per_add_shd.g_old_rec.addr_attribute11
      ,p_addr_attribute12_o
          => per_add_shd.g_old_rec.addr_attribute12
      ,p_addr_attribute13_o
          => per_add_shd.g_old_rec.addr_attribute13
      ,p_addr_attribute14_o
          => per_add_shd.g_old_rec.addr_attribute14
      ,p_addr_attribute15_o
          => per_add_shd.g_old_rec.addr_attribute15
      ,p_addr_attribute16_o
          => per_add_shd.g_old_rec.addr_attribute16
      ,p_addr_attribute17_o
          => per_add_shd.g_old_rec.addr_attribute17
      ,p_addr_attribute18_o
          => per_add_shd.g_old_rec.addr_attribute18
      ,p_addr_attribute19_o
          => per_add_shd.g_old_rec.addr_attribute19
      ,p_addr_attribute20_o
          => per_add_shd.g_old_rec.addr_attribute20
      ,p_add_information13_o
          => per_add_shd.g_old_rec.add_information13
      ,p_add_information14_o
          => per_add_shd.g_old_rec.add_information14
      ,p_add_information15_o
          => per_add_shd.g_old_rec.add_information15
      ,p_add_information16_o
          => per_add_shd.g_old_rec.add_information16
      ,p_add_information17_o
          => per_add_shd.g_old_rec.add_information17
      ,p_add_information18_o
          => per_add_shd.g_old_rec.add_information18
      ,p_add_information19_o
          => per_add_shd.g_old_rec.add_information19
      ,p_add_information20_o
          => per_add_shd.g_old_rec.add_information20
      ,p_object_version_number_o
          => per_add_shd.g_old_rec.object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_ADDRESSES'
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
  p_rec	      in out nocopy per_add_shd.g_rec_type,
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
    SAVEPOINT del_per_add;
  End If;
  --
  -- We must lock the row which we need to delete.
  --
  per_add_shd.lck
	(
	p_rec.address_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  per_add_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
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
    ROLLBACK TO del_per_add;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_address_id                         in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is
--
  l_rec	  per_add_shd.g_rec_type;
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
  l_rec.address_id:= p_address_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_add_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(l_rec, p_validate);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end per_add_del;

/
