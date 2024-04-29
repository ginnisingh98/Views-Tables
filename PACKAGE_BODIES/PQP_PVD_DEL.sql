--------------------------------------------------------
--  DDL for Package Body PQP_PVD_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PVD_DEL" as
/* $Header: pqpvdrhi.pkb 115.6 2003/02/17 22:14:43 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_pvd_del.';  -- Global package name
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
  (p_rec in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pqp_pvd_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pqp_vehicle_details row.
  --
  delete from pqp_vehicle_details
  where vehicle_details_id = p_rec.vehicle_details_id;
  --
  pqp_pvd_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pqp_pvd_shd.g_api_dml := false;   -- Unset the api dml status
    pqp_pvd_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pqp_pvd_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pqp_pvd_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqp_pvd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    pqp_pvd_rkd.after_delete
      (p_vehicle_details_id
      => p_rec.vehicle_details_id
      ,p_vehicle_type_o
      => pqp_pvd_shd.g_old_rec.vehicle_type
      ,p_business_group_id_o
      => pqp_pvd_shd.g_old_rec.business_group_id
      ,p_registration_number_o
      => pqp_pvd_shd.g_old_rec.registration_number
      ,p_make_o
      => pqp_pvd_shd.g_old_rec.make
      ,p_model_o
      => pqp_pvd_shd.g_old_rec.model
      ,p_date_first_registered_o
      => pqp_pvd_shd.g_old_rec.date_first_registered
      ,p_engine_capacity_in_cc_o
      => pqp_pvd_shd.g_old_rec.engine_capacity_in_cc
      ,p_fuel_type_o
      => pqp_pvd_shd.g_old_rec.fuel_type
      ,p_fuel_card_o
      => pqp_pvd_shd.g_old_rec.fuel_card
      ,p_currency_code_o
      => pqp_pvd_shd.g_old_rec.currency_code
      ,p_list_price_o
      => pqp_pvd_shd.g_old_rec.list_price
      ,p_accessory_value_at_startda_o
      => pqp_pvd_shd.g_old_rec.accessory_value_at_startdate
      ,p_accessory_value_added_late_o
      => pqp_pvd_shd.g_old_rec.accessory_value_added_later
--      ,p_capital_contributions_o
--      => pqp_pvd_shd.g_old_rec.capital_contributions
--      ,p_private_use_contributions_o
--      => pqp_pvd_shd.g_old_rec.private_use_contributions
      ,p_market_value_classic_car_o
      => pqp_pvd_shd.g_old_rec.market_value_classic_car
      ,p_co2_emissions_o
      => pqp_pvd_shd.g_old_rec.co2_emissions
      ,p_vehicle_provider_o
      => pqp_pvd_shd.g_old_rec.vehicle_provider
      ,p_object_version_number_o
      => pqp_pvd_shd.g_old_rec.object_version_number
      ,p_vehicle_identification_num_o
      => pqp_pvd_shd.g_old_rec.vehicle_identification_number
      ,p_vehicle_ownership_o
      => pqp_pvd_shd.g_old_rec.vehicle_ownership
      ,p_vhd_attribute_category_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute_category
      ,p_vhd_attribute1_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute1
      ,p_vhd_attribute2_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute2
      ,p_vhd_attribute3_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute3
      ,p_vhd_attribute4_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute4
      ,p_vhd_attribute5_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute5
      ,p_vhd_attribute6_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute6
      ,p_vhd_attribute7_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute7
      ,p_vhd_attribute8_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute8
      ,p_vhd_attribute9_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute9
      ,p_vhd_attribute10_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute10
      ,p_vhd_attribute11_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute11
      ,p_vhd_attribute12_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute12
      ,p_vhd_attribute13_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute13
      ,p_vhd_attribute14_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute14
      ,p_vhd_attribute15_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute15
      ,p_vhd_attribute16_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute16
      ,p_vhd_attribute17_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute17
      ,p_vhd_attribute18_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute18
      ,p_vhd_attribute19_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute19
      ,p_vhd_attribute20_o
      => pqp_pvd_shd.g_old_rec.vhd_attribute20
      ,p_vhd_information_category_o
      => pqp_pvd_shd.g_old_rec.vhd_information_category
      ,p_vhd_information1_o
      => pqp_pvd_shd.g_old_rec.vhd_information1
      ,p_vhd_information2_o
      => pqp_pvd_shd.g_old_rec.vhd_information2
      ,p_vhd_information3_o
      => pqp_pvd_shd.g_old_rec.vhd_information3
      ,p_vhd_information4_o
      => pqp_pvd_shd.g_old_rec.vhd_information4
      ,p_vhd_information5_o
      => pqp_pvd_shd.g_old_rec.vhd_information5
      ,p_vhd_information6_o
      => pqp_pvd_shd.g_old_rec.vhd_information6
      ,p_vhd_information7_o
      => pqp_pvd_shd.g_old_rec.vhd_information7
      ,p_vhd_information8_o
      => pqp_pvd_shd.g_old_rec.vhd_information8
      ,p_vhd_information9_o
      => pqp_pvd_shd.g_old_rec.vhd_information9
      ,p_vhd_information10_o
      => pqp_pvd_shd.g_old_rec.vhd_information10
      ,p_vhd_information11_o
      => pqp_pvd_shd.g_old_rec.vhd_information11
      ,p_vhd_information12_o
      => pqp_pvd_shd.g_old_rec.vhd_information12
      ,p_vhd_information13_o
      => pqp_pvd_shd.g_old_rec.vhd_information13
      ,p_vhd_information14_o
      => pqp_pvd_shd.g_old_rec.vhd_information14
      ,p_vhd_information15_o
      => pqp_pvd_shd.g_old_rec.vhd_information15
      ,p_vhd_information16_o
      => pqp_pvd_shd.g_old_rec.vhd_information16
      ,p_vhd_information17_o
      => pqp_pvd_shd.g_old_rec.vhd_information17
      ,p_vhd_information18_o
      => pqp_pvd_shd.g_old_rec.vhd_information18
      ,p_vhd_information19_o
      => pqp_pvd_shd.g_old_rec.vhd_information19
      ,p_vhd_information20_o
      => pqp_pvd_shd.g_old_rec.vhd_information20
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_DETAILS'
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
  (p_rec	      in pqp_pvd_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_pvd_shd.lck
    (p_rec.vehicle_details_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_pvd_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pqp_pvd_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqp_pvd_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqp_pvd_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_vehicle_details_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  pqp_pvd_shd.g_rec_type;
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
  l_rec.vehicle_details_id := p_vehicle_details_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_pvd_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_pvd_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_pvd_del;

/
