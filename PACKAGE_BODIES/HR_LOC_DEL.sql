--------------------------------------------------------
--  DDL for Package Body HR_LOC_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOC_DEL" AS
/* $Header: hrlocrhi.pkb 120.7.12010000.2 2008/12/30 10:18:50 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  hr_loc_del.';  -- Global package name
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
PROCEDURE delete_dml(p_rec IN hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'delete_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_loc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the location row.
  --
  DELETE FROM hr_locations_all
     WHERE location_id = p_rec.location_id;
  --
  hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.child_integrity_violated THEN
    -- Child integrity has been violated
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    hr_loc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(sqlerrm));
  WHEN OTHERS THEN
    hr_loc_shd.g_api_dml := false;   -- Unset the api dml status
    RAISE;
END delete_dml;
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
PROCEDURE pre_delete(p_rec IN hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_delete;
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
PROCEDURE post_delete(p_rec IN hr_loc_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    -- Start of API User Hook for the after delete hook
    --
    hr_loc_rkd.after_delete
      (  p_location_id                     => p_rec.location_id
--
   ,p_location_code_o                 => hr_loc_shd.g_old_rec.location_code
   ,p_address_line_1_o                => hr_loc_shd.g_old_rec.address_line_1
   ,p_address_line_2_o                => hr_loc_shd.g_old_rec.address_line_2
   ,p_address_line_3_o                => hr_loc_shd.g_old_rec.address_line_3
   ,p_bill_to_site_flag_o             => hr_loc_shd.g_old_rec.bill_to_site_flag
   ,p_country_o                       => hr_loc_shd.g_old_rec.country
   ,p_description_o                   => hr_loc_shd.g_old_rec.description
   ,p_designated_receiver_id_o        => hr_loc_shd.g_old_rec.designated_receiver_id
   ,p_in_organization_flag_o          => hr_loc_shd.g_old_rec.in_organization_flag
   ,p_inactive_date_o                 => hr_loc_shd.g_old_rec.inactive_date
   ,p_inventory_organization_id_o     => hr_loc_shd.g_old_rec.inventory_organization_id
   ,p_office_site_flag_o              => hr_loc_shd.g_old_rec.office_site_flag
   ,p_postal_code_o                   => hr_loc_shd.g_old_rec.postal_code
   ,p_receiving_site_flag_o           => hr_loc_shd.g_old_rec.receiving_site_flag
   ,p_region_1_o                      => hr_loc_shd.g_old_rec.region_1
   ,p_region_2_o                      => hr_loc_shd.g_old_rec.region_2
   ,p_region_3_o                      => hr_loc_shd.g_old_rec.region_3
   ,p_ship_to_location_id_o           => hr_loc_shd.g_old_rec.ship_to_location_id
   ,p_ship_to_site_flag_o             => hr_loc_shd.g_old_rec.ship_to_site_flag
   ,p_style_o                         => hr_loc_shd.g_old_rec.style
   ,p_tax_name_o                      => hr_loc_shd.g_old_rec.tax_name
   ,p_telephone_number_1_o            => hr_loc_shd.g_old_rec.telephone_number_1
   ,p_telephone_number_2_o            => hr_loc_shd.g_old_rec.telephone_number_2
   ,p_telephone_number_3_o            => hr_loc_shd.g_old_rec.telephone_number_3
   ,p_town_or_city_o                  => hr_loc_shd.g_old_rec.town_or_city
        ,p_loc_information13_o             => hr_loc_shd.g_old_rec.loc_information13
        ,p_loc_information14_o             => hr_loc_shd.g_old_rec.loc_information14
        ,p_loc_information15_o             => hr_loc_shd.g_old_rec.loc_information15
        ,p_loc_information16_o             => hr_loc_shd.g_old_rec.loc_information16
   ,p_loc_information17_o             => hr_loc_shd.g_old_rec.loc_information17
   ,p_loc_information18_o             => hr_loc_shd.g_old_rec.loc_information18
   ,p_loc_information19_o             => hr_loc_shd.g_old_rec.loc_information19
   ,p_loc_information20_o             => hr_loc_shd.g_old_rec.loc_information20
   ,p_attribute_category_o            => hr_loc_shd.g_old_rec.attribute_category
   ,p_attribute1_o                    => hr_loc_shd.g_old_rec.attribute1
   ,p_attribute2_o                    => hr_loc_shd.g_old_rec.attribute2
   ,p_attribute3_o                    => hr_loc_shd.g_old_rec.attribute3
   ,p_attribute4_o                    => hr_loc_shd.g_old_rec.attribute4
   ,p_attribute5_o                    => hr_loc_shd.g_old_rec.attribute5
   ,p_attribute6_o                    => hr_loc_shd.g_old_rec.attribute6
   ,p_attribute7_o                    => hr_loc_shd.g_old_rec.attribute7
   ,p_attribute8_o                    => hr_loc_shd.g_old_rec.attribute8
   ,p_attribute9_o                    => hr_loc_shd.g_old_rec.attribute9
   ,p_attribute10_o                   => hr_loc_shd.g_old_rec.attribute10
   ,p_attribute11_o                   => hr_loc_shd.g_old_rec.attribute11
   ,p_attribute12_o                   => hr_loc_shd.g_old_rec.attribute12
   ,p_attribute13_o                   => hr_loc_shd.g_old_rec.attribute13
   ,p_attribute14_o                   => hr_loc_shd.g_old_rec.attribute14
   ,p_attribute15_o                   => hr_loc_shd.g_old_rec.attribute15
   ,p_attribute16_o                   => hr_loc_shd.g_old_rec.attribute16
   ,p_attribute17_o                   => hr_loc_shd.g_old_rec.attribute17
   ,p_attribute18_o                   => hr_loc_shd.g_old_rec.attribute18
   ,p_attribute19_o                   => hr_loc_shd.g_old_rec.attribute19
   ,p_attribute20_o                   => hr_loc_shd.g_old_rec.attribute20
   ,p_global_attribute_category_o     => hr_loc_shd.g_old_rec.global_attribute_category
   ,p_global_attribute1_o             => hr_loc_shd.g_old_rec.global_attribute1
   ,p_global_attribute2_o             => hr_loc_shd.g_old_rec.global_attribute2
   ,p_global_attribute3_o             => hr_loc_shd.g_old_rec.global_attribute3
   ,p_global_attribute4_o             => hr_loc_shd.g_old_rec.global_attribute4
   ,p_global_attribute5_o             => hr_loc_shd.g_old_rec.global_attribute5
   ,p_global_attribute6_o             => hr_loc_shd.g_old_rec.global_attribute6
   ,p_global_attribute7_o             => hr_loc_shd.g_old_rec.global_attribute7
   ,p_global_attribute8_o             => hr_loc_shd.g_old_rec.global_attribute8
   ,p_global_attribute9_o             => hr_loc_shd.g_old_rec.global_attribute9
   ,p_global_attribute10_o            => hr_loc_shd.g_old_rec.global_attribute10
   ,p_global_attribute11_o            => hr_loc_shd.g_old_rec.global_attribute11
   ,p_global_attribute12_o            => hr_loc_shd.g_old_rec.global_attribute12
   ,p_global_attribute13_o            => hr_loc_shd.g_old_rec.global_attribute13
   ,p_global_attribute14_o            => hr_loc_shd.g_old_rec.global_attribute14
   ,p_global_attribute15_o            => hr_loc_shd.g_old_rec.global_attribute15
   ,p_global_attribute16_o            => hr_loc_shd.g_old_rec.global_attribute16
   ,p_global_attribute17_o            => hr_loc_shd.g_old_rec.global_attribute17
   ,p_global_attribute18_o            => hr_loc_shd.g_old_rec.global_attribute18
   ,p_global_attribute19_o            => hr_loc_shd.g_old_rec.global_attribute19
   ,p_global_attribute20_o            => hr_loc_shd.g_old_rec.global_attribute20
    ,p_legal_address_flag_o              => hr_loc_shd.g_old_rec.legal_address_flag
   ,p_tp_header_id_o                  => hr_loc_shd.g_old_rec.tp_header_id
        ,p_ece_tp_location_code_o          => hr_loc_shd.g_old_rec.ece_tp_location_code
   ,p_object_version_number_o         => hr_loc_shd.g_old_rec.object_version_number
        ,p_business_group_id_o             => hr_loc_shd.g_old_rec.business_group_id
     );
   EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_LOCATIONS_ALL'
        ,p_hook_type   => 'AD'
        );
    --
    -- End of API User Hook for the after_delete hook
    --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the delete process
--   for the specified entity. The role of this process is to delete the
--   row from the HR schema. This process is the main backbone of the del
--   business process. The processing of this procedure is as follows:
--
--   1) The controlling validation process delete_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_delete process is then executed which enables any
--      logic to be processed before the delete dml process is executed.
--   3) The delete_dml process will physical perform the delete dml for the
--      specified row.
--   4) The post_delete process is then executed which enables any
--      logic to be processed after the delete dml process.
--
-- Pre Conditions:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE del
  (
   p_rec             IN  hr_loc_shd.g_rec_type
  ) IS
--
  l_proc        VARCHAR2(72) := g_package||'del';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_loc_shd.lck ( p_rec.location_id,
                   p_rec.object_version_number );
  hr_utility.set_location(l_proc, 10);
  --
  -- Call the supporting delete validate operation
  --
  hr_loc_bus.delete_validate( p_rec => p_rec );
  hr_utility.set_location(l_proc, 15);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  hr_utility.set_location(l_proc, 20);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  hr_utility.set_location(l_proc, 25);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);

END del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the delete
--   process for the specified entity and is the outermost layer. The role
--   of this process is to validate and delete the specified row from the
--   HR schema. The processing of this procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      explicitly coding the attribute parameters into the g_rec_type
--      datatype.
--   2) After the conversion has taken place, the corresponding record del
--      interface process is executed.
--
-- Pre Conditions:
--
-- In Parameters:

-- Post Success:
--   The specified row will be fully validated and deleted for the specified
--   entity without being committed
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE del
  (
  p_location_id                        IN NUMBER,
  p_object_version_number              IN NUMBER
  ) IS
--
  l_rec    hr_loc_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'del';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.location_id := p_location_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_loc_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(p_rec    => l_rec );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END del;
--
END hr_loc_del;

/
